package Koha::Patrons::Import;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Moo;
use namespace::clean;

use Carp;
use Text::CSV;

use C4::Members;
use C4::Members::Attributes qw(:all);
use C4::Members::AttributeTypes;

use Koha::Libraries;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::Debarments;
use Koha::DateUtils;

=head1 NAME

Koha::Patrons::Import - Perl Module containing import_patrons method exported from import_borrowers script.

=head1 SYNOPSIS

use Koha::Patrons::Import;

=head1 DESCRIPTION

This module contains one method for importing patrons in bulk.

=head1 FUNCTIONS

=head2 import_patrons

 my $return = Koha::Patrons::Import::import_patrons($params);

Applies various checks and imports patrons in bulk from a csv file.

Further pod documentation needed here.

=cut

has 'today_iso' => ( is => 'ro', lazy => 1,
    default => sub { output_pref( { dt => dt_from_string(), dateonly => 1, dateformat => 'iso' } ); }, );

has 'text_csv' => ( is => 'rw', lazy => 1,
    default => sub { Text::CSV->new( { binary => 1, } ); },  );

sub import_patrons {
    my ($self, $params) = @_;

    my $handle = $params->{file};
    unless( $handle ) { carp('No file handle passed in!'); return; }

    my $matchpoint           = $params->{matchpoint};
    my $defaults             = $params->{defaults};
    my $ext_preserve         = $params->{preserve_extended_attributes};
    my $overwrite_cardnumber = $params->{overwrite_cardnumber};
    my $extended             = C4::Context->preference('ExtendedPatronAttributes');
    my $set_messaging_prefs  = C4::Context->preference('EnhancedMessagingPreferences');

    my @columnkeys = $self->set_column_keys($extended);
    my @feedback;
    my @errors;

    my $imported    = 0;
    my $alreadyindb = 0;
    my $overwritten = 0;
    my $invalid     = 0;
    my @imported_borrowers;
    my $matchpoint_attr_type = $self->set_attribute_types({ extended => $extended, matchpoint => $matchpoint, });

    # Use header line to construct key to column map
    my %csvkeycol;
    my $borrowerline = <$handle>;
    my @csvcolumns   = $self->prepare_columns({headerrow => $borrowerline, keycol => \%csvkeycol, errors => \@errors, });
    push(@feedback, { feedback => 1, name => 'headerrow', value => join( ', ', @csvcolumns ) });

    my @criticals = qw( surname );    # there probably should be others - rm branchcode && categorycode
  LINE: while ( my $borrowerline = <$handle> ) {
        my $line_number = $.;
        my %borrower;
        my @missing_criticals;

        my $status  = $self->text_csv->parse($borrowerline);
        my @columns = $self->text_csv->fields();
        if ( !$status ) {
            push @missing_criticals, { badparse => 1, line => $line_number, lineraw => $borrowerline };
        }
        elsif ( @columns == @columnkeys ) {
            @borrower{@columnkeys} = @columns;

            # MJR: try to fill blanks gracefully by using default values
            foreach my $key (@columnkeys) {
                if ( $borrower{$key} !~ /\S/ ) {
                    $borrower{$key} = $defaults->{$key};
                }
            }
        }
        else {
            # MJR: try to recover gracefully by using default values
            foreach my $key (@columnkeys) {
                if ( defined( $csvkeycol{$key} ) and $columns[ $csvkeycol{$key} ] =~ /\S/ ) {
                    $borrower{$key} = $columns[ $csvkeycol{$key} ];
                }
                elsif ( $defaults->{$key} ) {
                    $borrower{$key} = $defaults->{$key};
                }
                elsif ( scalar grep { $key eq $_ } @criticals ) {

                    # a critical field is undefined
                    push @missing_criticals, { key => $key, line => $., lineraw => $borrowerline };
                }
                else {
                    $borrower{$key} = '';
                }
            }
        }

        # Check if borrower category code exists and if it matches to a known category. Pushing error to missing_criticals otherwise.
        $self->check_borrower_category($borrower{categorycode}, $borrowerline, $line_number, \@missing_criticals);

        # Check if branch code exists and if it matches to a branch name. Pushing error to missing_criticals otherwise.
        $self->check_branch_code($borrower{branchcode}, $borrowerline, $line_number, \@missing_criticals);

        # Popular spreadsheet applications make it difficult to force date outputs to be zero-padded, but we require it.
        $self->format_dates({borrower => \%borrower, lineraw => $borrowerline, line => $line_number, missing_criticals => \@missing_criticals, });

        if (@missing_criticals) {
            foreach (@missing_criticals) {
                $_->{borrowernumber} = $borrower{borrowernumber} || 'UNDEF';
                $_->{surname}        = $borrower{surname}        || 'UNDEF';
            }
            $invalid++;
            ( 25 > scalar @errors ) and push @errors, { missing_criticals => \@missing_criticals };

            # The first 25 errors are enough.  Keeping track of 30,000+ would destroy performance.
            next LINE;
        }

        # Set patron attributes if extended.
        my $patron_attributes = $self->set_patron_attributes($extended, $borrower{patron_attributes}, \@feedback);
        if( $extended ) { delete $borrower{patron_attributes}; } # Not really a field in borrowers.

        # Default date enrolled and date expiry if not already set.
        $borrower{dateenrolled} = $self->today_iso() unless $borrower{dateenrolled};
        $borrower{dateexpiry} = Koha::Patron::Categories->find( $borrower{categorycode} )->get_expiry_date( $borrower{dateenrolled} ) unless $borrower{dateexpiry};

        my $borrowernumber;
        my ( $member, $patron );
        if ( defined($matchpoint) && ( $matchpoint eq 'cardnumber' ) && ( $borrower{'cardnumber'} ) ) {
            $patron = Koha::Patrons->find( { cardnumber => $borrower{'cardnumber'} } );
        }
        elsif ( defined($matchpoint) && ($matchpoint eq 'userid') && ($borrower{'userid'}) ) {
            $patron = Koha::Patrons->find( { userid => $borrower{userid} } );
        }
        elsif ($extended) {
            if ( defined($matchpoint_attr_type) ) {
                foreach my $attr (@$patron_attributes) {
                    if ( $attr->{code} eq $matchpoint and $attr->{value} ne '' ) {
                        my @borrowernumbers = $matchpoint_attr_type->get_patrons( $attr->{value} );
                        $borrowernumber = $borrowernumbers[0] if scalar(@borrowernumbers) == 1;
                        last;
                    }
                }
            }
        }

        if ($patron) {
            $member = $patron->unblessed;
            $borrowernumber = $member->{'borrowernumber'};
        } else {
            $member = {};
        }

        if ( C4::Members::checkcardnumber( $borrower{cardnumber}, $borrowernumber ) ) {
            push @errors,
              {
                invalid_cardnumber => 1,
                borrowernumber     => $borrowernumber,
                cardnumber         => $borrower{cardnumber}
              };
            $invalid++;
            next;
        }


        # Check if the userid provided does not exist yet
        if (    defined($matchpoint)
            and $matchpoint ne 'userid'
            and exists $borrower{userid}
            and $borrower{userid}
            and not Koha::Patron->new( { userid => $borrower{userid} } )->has_valid_userid
        ) {
            push @errors, { duplicate_userid => 1, userid => $borrower{userid} };
            $invalid++;
            next LINE;
        }

        if ($borrowernumber) {

            # borrower exists
            unless ($overwrite_cardnumber) {
                $alreadyindb++;
                push(
                    @feedback,
                    {
                        already_in_db => 1,
                        value         => $borrower{'surname'} . ' / ' . $borrowernumber
                    }
                );
                next LINE;
            }
            $borrower{'borrowernumber'} = $borrowernumber;
            for my $col ( keys %borrower ) {

                # use values from extant patron unless our csv file includes this column or we provided a default.
                # FIXME : You cannot update a field with a  perl-evaluated false value using the defaults.

                # The password is always encrypted, skip it!
                next if $col eq 'password';

                unless ( exists( $csvkeycol{$col} ) || $defaults->{$col} ) {
                    $borrower{$col} = $member->{$col} if ( $member->{$col} );
                }
            }

            unless ( ModMember(%borrower) ) {
                $invalid++;

                push(
                    @errors,
                    {
                        name  => 'lastinvalid',
                        value => $borrower{'surname'} . ' / ' . $borrowernumber
                    }
                );
                next LINE;
            }
            # Don't add a new restriction if the existing 'combined' restriction matches this one
            if ( $borrower{debarred} && ( ( $borrower{debarred} ne $member->{debarred} ) || ( $borrower{debarredcomment} ne $member->{debarredcomment} ) ) ) {

                # Check to see if this debarment already exists
                my $debarrments = GetDebarments(
                    {
                        borrowernumber => $borrowernumber,
                        expiration     => $borrower{debarred},
                        comment        => $borrower{debarredcomment}
                    }
                );

                # If it doesn't, then add it!
                unless (@$debarrments) {
                    AddDebarment(
                        {
                            borrowernumber => $borrowernumber,
                            expiration     => $borrower{debarred},
                            comment        => $borrower{debarredcomment}
                        }
                    );
                }
            }
            if ($extended) {
                if ($ext_preserve) {
                    my $old_attributes = GetBorrowerAttributes($borrowernumber);
                    $patron_attributes = extended_attributes_merge( $old_attributes, $patron_attributes );
                }
                push @errors, { unknown_error => 1 }
                  unless SetBorrowerAttributes( $borrower{'borrowernumber'}, $patron_attributes, 'no_branch_limit' );
            }
            $overwritten++;
            push(
                @feedback,
                {
                    feedback => 1,
                    name     => 'lastoverwritten',
                    value    => $borrower{'surname'} . ' / ' . $borrowernumber
                }
            );
        }
        else {
            my $patron = eval {
                Koha::Patron->new(\%borrower)->store;
            };
            unless ( $@ ) {

                if ( $patron->is_debarred ) {
                    AddDebarment(
                        {
                            borrowernumber => $patron->borrowernumber,
                            expiration     => $patron->debarred,
                            comment        => $patron->debarredcomment,
                        }
                    );
                }

                if ($extended) {
                    SetBorrowerAttributes( $patron->borrowernumber, $patron_attributes );
                }

                if ($set_messaging_prefs) {
                    C4::Members::Messaging::SetMessagingPreferencesFromDefaults(
                        {
                            borrowernumber => $patron->borrowernumber,
                            categorycode   => $patron->categorycode,
                        }
                    );
                }

                $imported++;
                push @imported_borrowers, $patron->borrowernumber; #for patronlist
                push(
                    @feedback,
                    {
                        feedback => 1,
                        name     => 'lastimported',
                        value    => $patron->surname . ' / ' . $patron->borrowernumber,
                    }
                );
            }
            else {
                $invalid++;
                push @errors, { unknown_error => 1 };
                push(
                    @errors,
                    {
                        name  => 'lastinvalid',
                        value => $borrower{'surname'} . ' / Create patron',
                    }
                );
            }
        }
    }

    return {
        feedback      => \@feedback,
        errors        => \@errors,
        imported      => $imported,
        overwritten   => $overwritten,
        already_in_db => $alreadyindb,
        invalid       => $invalid,
        imported_borrowers => \@imported_borrowers,
    };
}

=head2 prepare_columns

 my @csvcolumns = $self->prepare_columns({headerrow => $borrowerline, keycol => \%csvkeycol, errors => \@errors, });

Returns an array of all column key and populates a hash of colunm key positions.

=cut

sub prepare_columns {
    my ($self, $params) = @_;

    my $status = $self->text_csv->parse($params->{headerrow});
    unless( $status ) {
        push( @{$params->{errors}}, { badheader => 1, line => 1, lineraw => $params->{headerrow} });
        return;
    }

    my @csvcolumns = $self->text_csv->fields();
    my $col = 0;
    foreach my $keycol (@csvcolumns) {
        # columnkeys don't contain whitespace, but some stupid tools add it
        $keycol =~ s/ +//g;
        $params->{keycol}->{$keycol} = $col++;
    }

    return @csvcolumns;
}

=head2 set_attribute_types

 my $matchpoint_attr_type = $self->set_attribute_types({ extended => $extended, matchpoint => $matchpoint, });

Returns an attribute type based on matchpoint parameter.

=cut

sub set_attribute_types {
    my ($self, $params) = @_;

    my $attribute_types;
    if( $params->{extended} ) {
        $attribute_types = C4::Members::AttributeTypes->fetch($params->{matchpoint});
    }

    return $attribute_types;
}

=head2 set_column_keys

 my @columnkeys = set_column_keys($extended);

Returns an array of borrowers' table columns.

=cut

sub set_column_keys {
    my ($self, $extended) = @_;

    my @columnkeys = map { $_ ne 'borrowernumber' ? $_ : () } Koha::Patrons->columns();
    push( @columnkeys, 'patron_attributes' ) if $extended;

    return @columnkeys;
}

=head2 set_patron_attributes

 my $patron_attributes = set_patron_attributes($extended, $borrower{patron_attributes}, $feedback);

Returns a reference to array of hashrefs data structure as expected by SetBorrowerAttributes.

=cut

sub set_patron_attributes {
    my ($self, $extended, $patron_attributes, $feedback) = @_;

    unless( $extended ) { return; }
    unless( defined($patron_attributes) ) { return; }

    # Fixup double quotes in case we are passed smart quotes
    $patron_attributes =~ s/\xe2\x80\x9c/"/g;
    $patron_attributes =~ s/\xe2\x80\x9d/"/g;

    push (@$feedback, { feedback => 1, name => 'attribute string', value => $patron_attributes });

    my $result = extended_attributes_code_value_arrayref($patron_attributes);

    return $result;
}

=head2 check_branch_code

 check_branch_code($borrower{branchcode}, $borrowerline, $line_number, \@missing_criticals);

Pushes a 'missing_criticals' error entry if no branch code or branch code does not map to a branch name.

=cut

sub check_branch_code {
    my ($self, $branchcode, $borrowerline, $line_number, $missing_criticals) = @_;

    # No branch code
    unless( $branchcode ) {
        push (@$missing_criticals, { key => 'branchcode', line => $line_number, lineraw => $borrowerline, });
        return;
    }

    # look for branch code
    my $library = Koha::Libraries->find( $branchcode );
    unless( $library ) {
        push (@$missing_criticals, { key => 'branchcode', line => $line_number, lineraw => $borrowerline,
                                     value => $branchcode, branch_map => 1, });
    }
}

=head2 check_borrower_category

 check_borrower_category($borrower{categorycode}, $borrowerline, $line_number, \@missing_criticals);

Pushes a 'missing_criticals' error entry if no category code or category code does not map to a known category.

=cut

sub check_borrower_category {
    my ($self, $categorycode, $borrowerline, $line_number, $missing_criticals) = @_;

    # No branch code
    unless( $categorycode ) {
        push (@$missing_criticals, { key => 'categorycode', line => $line_number, lineraw => $borrowerline, });
        return;
    }

    # Looking for borrower category
    my $category = Koha::Patron::Categories->find($categorycode);
    unless( $category ) {
        push (@$missing_criticals, { key => 'categorycode', line => $line_number, lineraw => $borrowerline,
                                     value => $categorycode, category_map => 1, });
    }
}

=head2 format_dates

 format_dates({borrower => \%borrower, lineraw => $lineraw, line => $line_number, missing_criticals => \@missing_criticals, });

Pushes a 'missing_criticals' error entry for each of the 3 date types dateofbirth, dateenrolled and dateexpiry if it can not
be formatted to the chosen date format. Populates the correctly formatted date otherwise.

=cut

sub format_dates {
    my ($self, $params) = @_;

    foreach my $date_type (qw(dateofbirth dateenrolled dateexpiry)) {
        my $tempdate = $params->{borrower}->{$date_type} or next();
        my $formatted_date = eval { output_pref( { dt => dt_from_string( $tempdate ), dateonly => 1, dateformat => 'iso' } ); };

        if ($formatted_date) {
            $params->{borrower}->{$date_type} = $formatted_date;
        } else {
            $params->{borrower}->{$date_type} = '';
            push (@{$params->{missing_criticals}}, { key => $date_type, line => $params->{line}, lineraw => $params->{lineraw}, bad_date => 1 });
        }
    }
}

1;

=head1 AUTHOR

Koha Team

=cut
