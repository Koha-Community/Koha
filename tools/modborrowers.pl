#!/usr/bin/perl

# Copyright 2012 BibLibre
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

# modborrowers.pl
#
# Batch Edit Patrons
# Modification for patron's fields:
# surname firstname branchcode categorycode city state zipcode country sort1
# sort2 dateenrolled dateexpiry borrowernotes
# And for patron attributes.

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Branch;
use C4::Koha;
use C4::Members;
use C4::Members::Attributes;
use C4::Members::AttributeTypes qw/GetAttributeTypes_hashref/;
use C4::Output;
use List::MoreUtils qw /any uniq/;
use Koha::List::Patron;

my $input = new CGI;
my $op = $input->param('op') || 'show_form';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/modborrowers.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => "edit_patrons" },
    }
);

my %cookies   = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
my $dbh       = C4::Context->dbh;

# Show borrower informations
if ( $op eq 'show' ) {
    my $filefh         = $input->upload('uploadfile');
    my $filecontent    = $input->param('filecontent');
    my $patron_list_id = $input->param('patron_list_id');
    my @borrowers;
    my @cardnumbers;
    my @notfoundcardnumbers;

    # Get cardnumbers from a file or the input area
    my @contentlist;
    if ($filefh) {
        while ( my $content = <$filefh> ) {
            $content =~ s/[\r\n]*$//g;
            push @cardnumbers, $content if $content;
        }
    } elsif ( $patron_list_id ) {
        my ($list) = GetPatronLists( { patron_list_id => $patron_list_id } );

        @cardnumbers =
          $list->patron_list_patrons()->search_related('borrowernumber')
          ->get_column('cardnumber')->all();

    } else {
        if ( my $list = $input->param('cardnumberlist') ) {
            push @cardnumbers, split( /\s\n/, $list );
        }
    }

    my $max_nb_attr = 0;
    for my $cardnumber ( @cardnumbers ) {
        my $borrower = GetBorrowerInfos( cardnumber => $cardnumber );
        if ( $borrower ) {
            $max_nb_attr = scalar( @{ $borrower->{patron_attributes} } )
                if scalar( @{ $borrower->{patron_attributes} } ) > $max_nb_attr;
            push @borrowers, $borrower;
        } else {
            push @notfoundcardnumbers, $cardnumber;
        }
    }

    # Just for a correct display
    for my $borrower ( @borrowers ) {
        my $length = scalar( @{ $borrower->{patron_attributes} } );
        push @{ $borrower->{patron_attributes} }, {} for ( $length .. $max_nb_attr - 1);
    }

    # Construct the patron attributes list
    my @patron_attributes_values;
    my @patron_attributes_codes;
    my $patron_attribute_types = C4::Members::AttributeTypes::GetAttributeTypes_hashref('all');
    my $patron_categories = C4::Members::GetBorrowercategoryList;
    for ( values %$patron_attribute_types ) {
        my $attr_type = C4::Members::AttributeTypes->fetch( $_->{code} );
        my $options = $attr_type->authorised_value_category
            ? GetAuthorisedValues( $attr_type->authorised_value_category )
            : undef;
        push @patron_attributes_values,
            {
                attribute_code => $_->{code},
                options        => $options,
            };

        my $category_code = $_->{category_code};
        my ( $category_lib ) = map {
            ( defined $category_code and $_->{categorycode} eq $category_code ) ? $_->{description} : ()
        } @$patron_categories;
        push @patron_attributes_codes,
            {
                attribute_code => $_->{code},
                attribute_lib  => $_->{description},
                category_lib   => $category_lib,
                type           => $attr_type->authorised_value_category ? 'select' : 'text',
            };
    }

    my @attributes_header = ();
    for ( 1 .. scalar( $max_nb_attr ) ) {
        push @attributes_header, { attribute => "Attributes $_" };
    }
    $template->param( borrowers => \@borrowers );
    $template->param( attributes_header => \@attributes_header );
    @notfoundcardnumbers = map { { cardnumber => $_ } } @notfoundcardnumbers;
    $template->param( notfoundcardnumbers => \@notfoundcardnumbers )
        if @notfoundcardnumbers;

    # Construct drop-down list values
    my $branches = GetBranchesLoop;
    my @branches_option;
    push @branches_option, { value => $_->{value}, lib => $_->{branchname} } for @$branches;
    unshift @branches_option, { value => "", lib => "" };
    my $categories = GetBorrowercategoryList;
    my @categories_option;
    push @categories_option, { value => $_->{categorycode}, lib => $_->{description} } for @$categories;
    unshift @categories_option, { value => "", lib => "" };
    my $bsort1 = GetAuthorisedValues("Bsort1");
    my @sort1_option;
    push @sort1_option, { value => $_->{authorised_value}, lib => $_->{lib} } for @$bsort1;
    unshift @sort1_option, { value => "", lib => "" }
        if @sort1_option;
    my $bsort2 = GetAuthorisedValues("Bsort2");
    my @sort2_option;
    push @sort2_option, { value => $_->{authorised_value}, lib => $_->{lib} } for @$bsort2;
    unshift @sort2_option, { value => "", lib => "" }
        if @sort2_option;

    my @mandatoryFields = split( /\|/, C4::Context->preference("BorrowerMandatoryField") );

    my @fields = (
        {
            name => "surname",
            type => "text",
            mandatory => ( grep /surname/, @mandatoryFields ) ? 1 : 0
        }
        ,
        {
            name => "firstname",
            type => "text",
            mandatory => ( grep /firstname/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "branchcode",
            type => "select",
            option => \@branches_option,
            mandatory => ( grep /branchcode/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "categorycode",
            type => "select",
            option => \@categories_option,
            mandatory => ( grep /categorycode/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "city",
            type => "text",
            mandatory => ( grep /city/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "state",
            type => "text",
            mandatory => ( grep /state/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "zipcode",
            type => "text",
            mandatory => ( grep /zipcode/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "country",
            type => "text",
            mandatory => ( grep /country/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "sort1",
            type => @sort1_option ? "select" : "text",
            option => \@sort1_option,
            mandatory => ( grep /sort1/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "sort2",
            type => @sort2_option ? "select" : "text",
            option => \@sort2_option,
            mandatory => ( grep /sort2/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "dateenrolled",
            type => "date",
            mandatory => ( grep /dateenrolled/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "dateexpiry",
            type => "date",
            mandatory => ( grep /dateexpiry/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "borrowernotes",
            type => "text",
            mandatory => ( grep /borrowernotes/, @mandatoryFields ) ? 1 : 0,
        }
    );

    $template->param('patron_attributes_codes', \@patron_attributes_codes);
    $template->param('patron_attributes_values', \@patron_attributes_values);

    $template->param( fields => \@fields );
}

# Process modifications
if ( $op eq 'do' ) {

    my @disabled = $input->param('disable_input');
    my $infos;
    for my $field ( qw/surname firstname branchcode categorycode city state zipcode country sort1 sort2 dateenrolled dateexpiry borrowernotes/ ) {
        my $value = $input->param($field);
        $infos->{$field} = $value if $value;
        $infos->{$field} = "" if grep { /^$field$/ } @disabled;
    }

    my @attributes = $input->param('patron_attributes');
    my @attr_values = $input->param('patron_attributes_value');

    my @errors;
    my @borrowernumbers = $input->param('borrowernumber');
    # For each borrower selected
    for my $borrowernumber ( @borrowernumbers ) {
        # If at least one field are filled, we want to modify the borrower
        if ( defined $infos ) {
            $infos->{borrowernumber} = $borrowernumber;
            my $success = ModMember(%$infos);
            push @errors, { error => "can_not_update", borrowernumber => $infos->{borrowernumber} } if not $success;
        }

        #
        my $borrower_categorycode = GetBorrowerCategorycode $borrowernumber;
        my $i=0;
        for ( @attributes ) {
            my $attribute;
            $attribute->{code} = $_;
            $attribute->{attribute} = $attr_values[$i];
            my $attr_type = C4::Members::AttributeTypes->fetch( $_ );
            # If this borrower is not in the category of this attribute, we don't want to modify this attribute
            ++$i and next if $attr_type->{category_code} and $attr_type->{category_code} ne $borrower_categorycode;
            my $valuename = "attr" . $i . "_value";
            if ( grep { /^$valuename$/ } @disabled ) {
                # The attribute is disabled, we remove it for this borrower !
                eval {
                    C4::Members::Attributes::DeleteBorrowerAttribute( $borrowernumber, $attribute );
                };
                push @errors, { error => $@ } if $@;
            } else {
                # Attribute's value is empty, we don't want to modify it
                ++$i and next if not $attribute->{attribute};

                eval {
                    C4::Members::Attributes::UpdateBorrowerAttribute( $borrowernumber, $attribute );
                };
                push @errors, { error => $@ } if $@;
            }
            $i++;
        }
    }
    $op = "show_results"; # We have process modifications, the user want to view its

    # Construct the results list
    my @borrowers;
    my $max_nb_attr = 0;
    for my $borrowernumber ( @borrowernumbers ) {
        my $borrower = GetBorrowerInfos( borrowernumber => $borrowernumber );
        if ( $borrower ) {
            $max_nb_attr = scalar( @{ $borrower->{patron_attributes} } )
                if scalar( @{ $borrower->{patron_attributes} } ) > $max_nb_attr;
            push @borrowers, $borrower;
        }
    }
    my @patron_attributes_option;
    for my $borrower ( @borrowers ) {
        push @patron_attributes_option, { value => "$_->{code}", lib => $_->{code} } for @{ $borrower->{patron_attributes} };
        my $length = scalar( @{ $borrower->{patron_attributes} } );
        push @{ $borrower->{patron_attributes} }, {} for ( $length .. $max_nb_attr - 1);
    }

    my @attributes_header = ();
    for ( 1 .. scalar( $max_nb_attr ) ) {
        push @attributes_header, { attribute => "Attributes $_" };
    }

    $template->param( borrowers => \@borrowers );
    $template->param( attributes_header => \@attributes_header );

    $template->param( borrowers => \@borrowers );
    $template->param( errors => \@errors );
} else {

    $template->param( patron_lists => [ GetPatronLists() ] );
}

$template->param(
    op => $op,
);
output_html_with_http_headers $input, $cookie, $template->output;
exit;

sub GetBorrowerInfos {
    my ( %info ) = @_;
    my $borrower = GetMember( %info );
    if ( $borrower ) {
        $borrower->{branchname} = GetBranchName( $borrower->{branchcode} );
        for ( qw(dateenrolled dateexpiry) ) {
            my $userdate = $borrower->{$_};
            unless ($userdate && $userdate ne "0000-00-00" and $userdate ne "9999-12-31") {
                $borrower->{$_} = '';
                next;
            }
            $borrower->{$_} = $userdate || '';
        }
        $borrower->{category_description} = GetBorrowercategory( $borrower->{categorycode} )->{description};
        my $attr_loop = C4::Members::Attributes::GetBorrowerAttributes( $borrower->{borrowernumber} );
        $borrower->{patron_attributes} = $attr_loop;
    }
    return $borrower;
}
