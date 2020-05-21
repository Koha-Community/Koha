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
use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Koha qw( GetAuthorisedValues );
use C4::Members;
use C4::Output qw( output_html_with_http_headers );
use Koha::DateUtils qw( dt_from_string );
use Koha::List::Patron qw( GetPatronLists );
use Koha::Libraries;
use Koha::Patron::Categories;
use Koha::Patron::Debarments qw( AddDebarment DelDebarment );
use Koha::Patrons;
use List::MoreUtils qw(uniq);

my $input = CGI->new;
my $op = $input->param('op') || 'show_form';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/modborrowers.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { tools => "edit_patrons" },
    }
);

my $logged_in_user = Koha::Patrons->find( $loggedinuser );

$template->param( CanUpdatePasswordExpiration => 1 ) if $logged_in_user->is_superlibrarian;

my $dbh       = C4::Context->dbh;

# Show borrower informations
if ( $op eq 'show' ) {
    my @borrowers;
    my @patronidnumbers;
    my @notfoundcardnumbers;
    my $useborrowernumbers = 0;

    # Get cardnumbers from a file or the input area
    if( my $cardnumberlist = $input->param('cardnumberlist') ){
        # User submitted a list of card numbers
        push @patronidnumbers, split( /\s\n/, $cardnumberlist );
    } elsif ( my $cardnumberuploadfile = $input->param('cardnumberuploadfile') ){
        # User uploaded a file of card numbers
        binmode $cardnumberuploadfile, ':encoding(UTF-8)';
        while ( my $content = <$cardnumberuploadfile> ) {
            next unless $content;
            $content =~ s/[\r\n]*$//;
            push @patronidnumbers, $content if $content;
        }
    } elsif ( my $borrowernumberlist = $input->param('borrowernumberlist') ){
        # User submitted a list of borrowernumbers
        $useborrowernumbers = 1;
        push @patronidnumbers, split( /\s\n/, $borrowernumberlist );
    } elsif ( my $borrowernumberuploadfile = $input->param('borrowernumberuploadfile') ){
        # User uploaded a file of borrowernumbers
        $useborrowernumbers = 1;
        binmode $borrowernumberuploadfile, ':encoding(UTF-8)';
        while ( my $content = <$borrowernumberuploadfile> ) {
            next unless $content;
            $content =~ s/[\r\n]*$//;
            push @patronidnumbers, $content if $content;
        }
    } elsif ( my $patron_list_id = $input->param('patron_list_id') ){
        # User selected a patron list
        my ($list) = GetPatronLists( { patron_list_id => $patron_list_id } );
        @patronidnumbers =
          $list->patron_list_patrons()->search_related('borrowernumber')
          ->get_column('cardnumber')->all();
    }

    my $max_nb_attr = 0;

    # Make sure there is only one of each patron id number
    @patronidnumbers = uniq( @patronidnumbers );

    for my $patronidnumber ( @patronidnumbers ) {
        my $patron;
        if( $useborrowernumbers == 1 ){
            $patron = Koha::Patrons->find( { borrowernumber => $patronidnumber } );
        } else {
            $patron = Koha::Patrons->find( { cardnumber => $patronidnumber } );
        }
        if ( $patron ) {
            if ( $logged_in_user->can_see_patron_infos( $patron ) ) {
                my $borrower = $patron->unblessed;
                my $attributes = $patron->extended_attributes;
                $borrower->{patron_attributes} = $attributes->as_list;
                $borrower->{patron_attributes_count} = $attributes->count;
                $max_nb_attr = $borrower->{patron_attributes_count} if $borrower->{patron_attributes_count} > $max_nb_attr;
                push @borrowers, $borrower;
            } else {
                push @notfoundcardnumbers, $patronidnumber;
            }
        } else {
            push @notfoundcardnumbers, $patronidnumber;
        }
    }

    # Just for a correct display
    for my $borrower ( @borrowers ) {
        my $length = $borrower->{patron_attributes_count};
        push @{ $borrower->{patron_attributes} }, {} for ( $length .. $max_nb_attr - 1);
    }

    # Construct the patron attributes list
    my @patron_attributes_values;
    my @patron_attributes_codes;
    my $library_id = C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
    my $patron_attribute_types = Koha::Patron::Attribute::Types->search_with_library_limits({}, {}, $library_id);
    my @patron_categories = Koha::Patron::Categories->search_with_library_limits({}, {order_by => ['description']})->as_list;
    while ( my $attr_type = $patron_attribute_types->next ) {
        next if $attr_type->unique_id; # Don't display patron attributes that must be unqiue
        my $options = $attr_type->authorised_value_category
            ? GetAuthorisedValues( $attr_type->authorised_value_category )
            : undef;
        push @patron_attributes_values,
            {
                attribute_code => $attr_type->code,
                options        => $options,
            };

        my $category_code = $attr_type->category_code;
        my ( $category_lib ) = map {
            ( defined $category_code and $attr_type->category_code eq $category_code ) ? $attr_type->description : ()
        } @patron_categories;
        push @patron_attributes_codes,
            {
                attribute_code => $attr_type->code,
                attribute_lib  => $attr_type->description,
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
    $template->param( useborrowernumbers => $useborrowernumbers );

    # Construct drop-down list values
    my $branches = Koha::Libraries->search({}, { order_by => ['branchname'] })->unblessed;
    my @branches_option;
    push @branches_option, { value => $_->{branchcode}, lib => $_->{branchname} } for @$branches;
    unshift @branches_option, { value => "", lib => "" };
    my @categories_option;
    push @categories_option, { value => $_->categorycode, lib => $_->description } for @patron_categories;
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
            name => "streetnumber",
            type => "text",
            mandatory => ( grep /streetnumber/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "address",
            type => "text",
            mandatory => ( grep /address/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "address2",
            type => "text",
            mandatory => ( grep /address2/, @mandatoryFields ) ? 1 : 0,
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
            name => "email",
            type => "text",
            mandatory => ( grep /email/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "phone",
            type => "text",
            mandatory => ( grep /phone/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "mobile",
            type => "text",
            mandatory => ( grep /mobile/, @mandatoryFields ) ? 1 : 0,
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
        ,
        {
            name => "opacnote",
            type => "text",
            mandatory => ( grep /opacnote/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "debarred",
            type => "date",
            mandatory => ( grep /debarred/, @mandatoryFields ) ? 1 : 0,
        }
        ,
        {
            name => "debarredcomment",
            type => "text",
            mandatory => ( grep /debarredcomment/, @mandatoryFields ) ? 1 : 0,
        },
    );

    push @fields, { name => "password_expiration_date", type => "date" } if $logged_in_user->is_superlibrarian;

    $template->param('patron_attributes_codes', \@patron_attributes_codes);
    $template->param('patron_attributes_values', \@patron_attributes_values);

    $template->param( fields => \@fields );
}

# Process modifications
if ( $op eq 'do' ) {

    my @disabled = $input->multi_param('disable_input');
    my $infos;
    for my $field ( qw/surname firstname branchcode categorycode streetnumber address address2 city state zipcode country email phone mobile sort1 sort2 dateenrolled dateexpiry password_expiration_date borrowernotes opacnote debarred debarredcomment/ ) {
        my $value = $input->param($field);
        $infos->{$field} = $value if $value;
        $infos->{$field} = "" if grep { $_ eq $field } @disabled;
    }

    for my $field ( qw( dateenrolled dateexpiry debarred password_expiration_date ) ) {
        $infos->{$field} = dt_from_string($infos->{$field}) if $infos->{$field};
    }

    delete $infos->{password_expiration_date} unless $logged_in_user->is_superlibrarian;

    my @errors;
    my @borrowernumbers = $input->multi_param('borrowernumber');
    # For each borrower selected
    for my $borrowernumber ( @borrowernumbers ) {

        # If at least one field are filled, we want to modify the borrower
        if ( defined $infos ) {
            # If a debarred date or debarred comment has been submitted make a new debarment
            if ( $infos->{debarred} || $infos->{debarredcomment} ) {
                AddDebarment(
                    {
                        borrowernumber => $borrowernumber,
                        type           => 'MANUAL',
                        comment        => $infos->{debarredcomment},
                        expiration     => $infos->{debarred},
                    });
            }

            # If debarment date or debarment comment are disabled then remove all debarrments
            my $patron = Koha::Patrons->find( $borrowernumber );
            if ( grep { /debarred/ } @disabled ) {
                eval {
                   my $debarrments = $patron->restrictions;
                   while( my $debarment = $debarrments->next ) {
                      DelDebarment( $debarment->borrower_debarment_id );
                   }
                };
            }

            $infos->{borrowernumber} = $borrowernumber;
            eval { $patron->set($infos)->store; };
            if ( $@ ) { # FIXME We could provide better error handling here
                $infos->{cardnumber} = $patron ? $patron->cardnumber || '' : '';
                push @errors, { error => "can_not_update", borrowernumber => $infos->{borrowernumber}, cardnumber => $infos->{cardnumber} };
            }
        }

        my $patron = Koha::Patrons->find( $borrowernumber );
        my @attributes = $input->multi_param('patron_attributes');
        my @attr_values = $input->multi_param('patron_attributes_value');
        my $attributes;
        my $i = 0;
        for my $code ( @attributes ) {
            push @{ $attributes->{$code}->{values} }, shift @attr_values; # Handling repeatables
            $attributes->{$code}->{disabled} = grep { $_ eq sprintf("attr%s_value", ++$i) } @disabled;
        }

        for my $code ( keys %$attributes ) {
            my $attr_type = Koha::Patron::Attribute::Types->find($code);
            # If this borrower is not in the category of this attribute, we don't want to modify this attribute
            next if $attr_type->category_code and $attr_type->category_code ne $patron->categorycode;

            if ( $attributes->{$code}->{disabled} ) {
                # The attribute is disabled, we remove it for this borrower !
                eval {
                    $patron->get_extended_attribute($code)->delete;
                };
                push @errors, { error => $@ } if $@;
            } else {
                eval {
                    $patron->extended_attributes->search({'me.code' => $code})->filter_by_branch_limitations->delete;
                    $patron->add_extended_attribute({ code => $code, attribute => $_ }) for @{$attributes->{$code}->{values}};
                };
                push @errors, { error => $@ } if $@;
            }
        }
    }
    $op = "show_results"; # We have process modifications, the user want to view its

    # Construct the results list
    my @borrowers;
    my $max_nb_attr = 0;
    for my $borrowernumber ( @borrowernumbers ) {
        my $patron = Koha::Patrons->find( $borrowernumber );
        if ( $patron ) {
            my $category_description = $patron->category->description;
            my $borrower = $patron->unblessed;
            $borrower->{category_description} = $category_description;
            my $attributes = $patron->extended_attributes;
            $borrower->{patron_attributes} = $attributes->as_list;
            $max_nb_attr = $attributes->count if $attributes->count > $max_nb_attr;
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

    $template->param( errors => \@errors );
} else {

    $template->param( patron_lists => [ GetPatronLists() ] );
}

$template->param(
    op => $op,
);
output_html_with_http_headers $input, $cookie, $template->output;
exit;
