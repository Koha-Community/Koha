#!/usr/bin/perl

# Copyright 2007 Liblime
# Parts copyright 2010 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

# Script to take some borrowers data in a known format and load it into Koha
#
# File format
#
# cardnumber,surname,firstname,title,othernames,initials,streetnumber,streettype,
# address line , address line 2, city, zipcode, contry, email, phone, mobile, fax, work email, work phone,
# alternate streetnumber, alternate streettype, alternate address line 1, alternate city,
# alternate zipcode, alternate country, alternate email, alternate phone, date of birth, branchcode,
# categorycode, enrollment date, expiry date, noaddress, lost, debarred, contact surname,
# contact firstname, contact title, borrower notes, contact relationship
# gender, username, opac note, contact note, password, sort one, sort two
#
# any fields except cardnumber can be blank but the number of fields must match
# dates should be in the format you have set up Koha to expect
# branchcode and categorycode need to be valid

use Modern::Perl;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Members::Attributes qw(:all);
use C4::Members::AttributeTypes;
use C4::Members::Messaging;
use C4::Reports::Guided;
use C4::Templates;
use Koha::Patron::Debarments;
use Koha::Patrons;
use Koha::DateUtils;
use Koha::Token;
use Koha::Libraries;
use Koha::Patron::Categories;
use Koha::List::Patron;

use Text::CSV;
# Text::CSV::Unicode, even in binary mode, fails to parse lines with these diacriticals:
# ė
# č

use CGI qw ( -utf8 );

my (@errors, @feedback);
my $extended = C4::Context->preference('ExtendedPatronAttributes');
my $set_messaging_prefs = C4::Context->preference('EnhancedMessagingPreferences');
my @columnkeys = Koha::Patrons->columns();
@columnkeys = map { $_ ne 'borrowernumber' ? $_ : () } @columnkeys;
if ($extended) {
    push @columnkeys, 'patron_attributes';
}

my $input = CGI->new();
our $csv  = Text::CSV->new({binary => 1});  # binary needed for non-ASCII Unicode
#push @feedback, {feedback=>1, name=>'backend', value=>$csv->backend, backend=>$csv->backend}; #XXX

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "tools/import_borrowers.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'import_patrons' },
        debug           => 1,
});

# get the patron categories and pass them to the template
my @patron_categories = Koha::Patron::Categories->search_limited({}, {order_by => ['description']});
$template->param( categories => \@patron_categories );
my $columns = C4::Templates::GetColumnDefs( $input )->{borrowers};
$columns = [ grep { $_->{field} ne 'borrowernumber' ? $_ : () } @$columns ];
$template->param( borrower_fields => $columns );

if ($input->param('sample')) {
    print $input->header(
        -type       => 'application/vnd.sun.xml.calc', # 'application/vnd.ms-excel' ?
        -attachment => 'patron_import.csv',
    );
    $csv->combine(@columnkeys);
    print $csv->string, "\n";
    exit 0;
}
my $uploadborrowers = $input->param('uploadborrowers');
my $matchpoint      = $input->param('matchpoint');
if ($matchpoint) {
    $matchpoint =~ s/^patron_attribute_//;
}
my $overwrite_cardnumber = $input->param('overwrite_cardnumber');

#create a patronlist
my $createpatronlist = $input->param('createpatronlist') || 0;
my $dt = dt_from_string();
my $timestamp = $dt->ymd('-').' '.$dt->hms(':');
my $patronlistname = $uploadborrowers . ' (' . $timestamp .')';

$template->param( SCRIPT_NAME => '/cgi-bin/koha/tools/import_borrowers.pl' );

if ( $uploadborrowers && length($uploadborrowers) > 0 ) {
    die "Wrong CSRF token"
        unless Koha::Token->new->check_csrf({
            session_id => scalar $input->cookie('CGISESSID'),
            token  => scalar $input->param('csrf_token'),
        });

    push @feedback, {feedback=>1, name=>'filename', value=>$uploadborrowers, filename=>$uploadborrowers};
    my $handle = $input->upload('uploadborrowers');
    my $uploadinfo = $input->uploadInfo($uploadborrowers);
    foreach (keys %$uploadinfo) {
        push @feedback, {feedback=>1, name=>$_, value=>$uploadinfo->{$_}, $_=>$uploadinfo->{$_}};
    }

    my $imported    = 0;
    my @imported_borrowers;
    my $alreadyindb = 0;
    my $overwritten = 0;
    my $invalid     = 0;
    my $matchpoint_attr_type; 
    my %defaults = $input->Vars;

    # use header line to construct key to column map
    my $borrowerline = <$handle>;
    my $status = $csv->parse($borrowerline);
    ($status) or push @errors, {badheader=>1,line=>$., lineraw=>$borrowerline};
    my @csvcolumns = $csv->fields();
    my %csvkeycol;
    my $col = 0;
    foreach my $keycol (@csvcolumns) {
    	# columnkeys don't contain whitespace, but some stupid tools add it
    	$keycol =~ s/ +//g;
        $csvkeycol{$keycol} = $col++;
    }
    #warn($borrowerline);
    my $ext_preserve = $input->param('ext_preserve') || 0;
    if ($extended) {
        $matchpoint_attr_type = C4::Members::AttributeTypes->fetch($matchpoint);
    }

    push @feedback, {feedback=>1, name=>'headerrow', value=>join(', ', @csvcolumns)};
    my $today = output_pref;
    my @criticals = qw(surname branchcode categorycode);    # there probably should be others
    my @bad_dates;  # I've had a few.
    LINE: while ( my $borrowerline = <$handle> ) {
        my %borrower;
        my @missing_criticals;
        my $patron_attributes;
        my $status  = $csv->parse($borrowerline);
        my @columns = $csv->fields();
        if (! $status) {
            push @missing_criticals, {badparse=>1, line=>$., lineraw=>$borrowerline};
        } elsif (@columns == @columnkeys) {
            @borrower{@columnkeys} = @columns;
            # MJR: try to fill blanks gracefully by using default values
            foreach my $key (@columnkeys) {
                if ($borrower{$key} !~ /\S/) {
                    $borrower{$key} = $defaults{$key};
                }
            } 
        } else {
            # MJR: try to recover gracefully by using default values
            foreach my $key (@columnkeys) {
            	if (defined($csvkeycol{$key}) and $columns[$csvkeycol{$key}] =~ /\S/) { 
            	    $borrower{$key} = $columns[$csvkeycol{$key}];
            	} elsif ( $defaults{$key} ) {
            	    $borrower{$key} = $defaults{$key};
            	} elsif ( scalar grep {$key eq $_} @criticals ) {
            	    # a critical field is undefined
            	    push @missing_criticals, {key=>$key, line=>$., lineraw=>$borrowerline};
            	} else {
            		$borrower{$key} = '';
            	}
            }
        }
        #warn join(':',%borrower);
        if ($borrower{categorycode}) {
            push @missing_criticals, {key=>'categorycode', line=>$. , lineraw=>$borrowerline, value=>$borrower{categorycode}, category_map=>1}
                unless Koha::Patron::Categories->find($borrower{categorycode});
        } else {
            push @missing_criticals, {key=>'categorycode', line=>$. , lineraw=>$borrowerline};
        }
        if ($borrower{branchcode}) {
            push @missing_criticals, {key=>'branchcode', line=>$. , lineraw=>$borrowerline, value=>$borrower{branchcode}, branch_map=>1}
                unless Koha::Libraries->find($borrower{branchcode});
        } else {
            push @missing_criticals, {key=>'branchcode', line=>$. , lineraw=>$borrowerline};
        }
        if (@missing_criticals) {
            foreach (@missing_criticals) {
                $_->{borrowernumber} = $borrower{borrowernumber} || 'UNDEF';
                $_->{surname}        = $borrower{surname} || 'UNDEF';
            }
            $invalid++;
            (25 > scalar @errors) and push @errors, {missing_criticals=>\@missing_criticals};
            # The first 25 errors are enough.  Keeping track of 30,000+ would destroy performance.
            next LINE;
        }
        if ($extended) {
            my $attr_str = $borrower{patron_attributes};
            $attr_str =~ s/\xe2\x80\x9c/"/g; # fixup double quotes in case we are passed smart quotes
            $attr_str =~ s/\xe2\x80\x9d/"/g;
            push @feedback, {feedback=>1, name=>'attribute string', value=>$attr_str, filename=>$uploadborrowers};
            delete $borrower{patron_attributes};    # not really a field in borrowers, so we don't want to pass it to ModMember.
            $patron_attributes = extended_attributes_code_value_arrayref($attr_str); 
        }
	# Popular spreadsheet applications make it difficult to force date outputs to be zero-padded, but we require it.
        foreach (qw(dateofbirth dateenrolled dateexpiry)) {
            my $tempdate = $borrower{$_} or next;
            $tempdate = eval { output_pref( { dt => dt_from_string( $tempdate ), dateonly => 1, dateformat => 'iso' } ); };
            if ($tempdate) {
                $borrower{$_} = $tempdate;
            } else {
                $borrower{$_} = '';
                push @missing_criticals, {key=>$_, line=>$. , lineraw=>$borrowerline, bad_date=>1};
            }
        }
        $borrower{dateenrolled} ||= $today;
        $borrower{dateexpiry}   ||= Koha::Patron::Categories->find( $borrower{categorycode} )->get_expiry_date( $borrower{dateenrolled} );
        my $borrowernumber;
        my $member;
        if ( ($matchpoint eq 'cardnumber') && ($borrower{'cardnumber'}) ) {
            $member = Koha::Patrons->find( { cardnumber => $borrower{'cardnumber'} } );
        } elsif ( ($matchpoint eq 'userid') && ($borrower{'userid'}) ) {
            $member = Koha::Patrons->find( { userid => $borrower{'userid'} } );
        } elsif ($extended) {
            if (defined($matchpoint_attr_type)) {
                foreach my $attr (@$patron_attributes) {
                    if ($attr->{code} eq $matchpoint and $attr->{value} ne '') {
                        my @borrowernumbers = $matchpoint_attr_type->get_patrons($attr->{value});
                        $borrowernumber = $borrowernumbers[0] if scalar(@borrowernumbers) == 1;
                        last;
                    }
                }
            }
        }

        if ($member) {
            $member = $member->unblessed;
            $borrowernumber = $member->{'borrowernumber'};
        } else {
            $member = {};
        }

        if ( C4::Members::checkcardnumber( $borrower{cardnumber}, $borrowernumber ) ) {
            push @errors, {
                invalid_cardnumber => 1,
                borrowernumber => $borrowernumber,
                cardnumber => $borrower{cardnumber}
            };
            $invalid++;
            next;
        }

        if ($borrowernumber) {
            # borrower exists
            unless ($overwrite_cardnumber) {
                $alreadyindb++;
                $template->param('lastalreadyindb'=>$borrower{'surname'}.' / '.$borrowernumber);
                next LINE;
            }
            $borrower{'borrowernumber'} = $borrowernumber;
            for my $col (keys %borrower) {
                # use values from extant patron unless our csv file includes this column or we provided a default.
                # FIXME : You cannot update a field with a  perl-evaluated false value using the defaults.

                # The password is always encrypted, skip it!
                next if $col eq 'password';

                unless(exists($csvkeycol{$col}) || $defaults{$col}) {
                    $borrower{$col} = $member->{$col} if($member->{$col}) ;
                }
            }

            # Check if the userid provided does not exist yet
            if (  exists $borrower{userid}
                     and $borrower{userid}
                 and not Check_Userid( $borrower{userid}, $borrower{borrowernumber} ) ) {
                push @errors, { duplicate_userid => 1, userid => $borrower{userid} };
                $invalid++;
                next LINE;
            }

            unless (ModMember(%borrower)) {
                $invalid++;
                # until we have better error trapping, we have no way of knowing why ModMember errored out...
                push @errors, {unknown_error => 1};
                $template->param('lastinvalid'=>$borrower{'surname'}.' / '.$borrowernumber);
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
                    $patron_attributes = extended_attributes_merge($old_attributes, $patron_attributes);  #TODO: expose repeatable options in template
                }
                push @errors, {unknown_error => 1} unless SetBorrowerAttributes($borrower{'borrowernumber'}, $patron_attributes, 'no_branch_limit' );
            }
            $overwritten++;
            $template->param('lastoverwritten'=>$borrower{'surname'}.' / '.$borrowernumber);
        } else {
            # FIXME: fixup_cardnumber says to lock table, but the web interface doesn't so this doesn't either.
            # At least this is closer to AddMember than in members/memberentry.pl
            if (!$borrower{'cardnumber'}) {
                $borrower{'cardnumber'} = fixup_cardnumber(undef);
            }
            if ($borrowernumber = AddMember(%borrower)) {

                if ( $borrower{debarred} ) {
                    AddDebarment(
                        {
                            borrowernumber => $borrowernumber,
                            expiration     => $borrower{debarred},
                            comment        => $borrower{debarredcomment}
                        }
                    );
                }

                if ($extended) {
                    SetBorrowerAttributes($borrowernumber, $patron_attributes);
                }

                if ($set_messaging_prefs) {
                    C4::Members::Messaging::SetMessagingPreferencesFromDefaults({ borrowernumber => $borrowernumber,
                                                                                  categorycode => $borrower{categorycode} });
                }

                $imported++;
                $template->param('lastimported'=>$borrower{'surname'}.' / '.$borrowernumber);
                push @imported_borrowers, $borrowernumber; #for patronlist
            } else {
                $invalid++;
                push @errors, {unknown_error => 1};
                $template->param('lastinvalid'=>$borrower{'surname'}.' / AddMember');
            }
        }
    }

    if ( $imported && $createpatronlist ) {
        my $patronlist = AddPatronList({ name => $patronlistname });
        AddPatronsToList({ list => $patronlist, borrowernumbers => \@imported_borrowers });
        $template->param('patronlistname' => $patronlistname);
    }

    (@errors  ) and $template->param(  ERRORS=>\@errors  );
    (@feedback) and $template->param(FEEDBACK=>\@feedback);
    $template->param(
        'uploadborrowers' => 1,
        'imported'        => $imported,
        'overwritten'     => $overwritten,
        'alreadyindb'     => $alreadyindb,
        'invalid'         => $invalid,
        'total'           => $imported + $alreadyindb + $invalid + $overwritten,
    );

} else {
    if ($extended) {
        my @matchpoints = ();
        my @attr_types = C4::Members::AttributeTypes::GetAttributeTypes(undef, 1);
        foreach my $type (@attr_types) {
            my $attr_type = C4::Members::AttributeTypes->fetch($type->{code});
            if ($attr_type->unique_id()) {
            push @matchpoints, { code =>  "patron_attribute_" . $attr_type->code(), description => $attr_type->description() };
            }
        }
        $template->param(matchpoints => \@matchpoints);
    }

    $template->param(
        csrf_token => Koha::Token->new->generate_csrf(
            { session_id => scalar $input->cookie('CGISESSID'), }
        ),
    );

}

output_html_with_http_headers $input, $cookie, $template->output;

