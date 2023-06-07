#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2017 Catalyst IT
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

use Modern::Perl;
use C4::Context;
use C4::InstallAuth qw( checkauth get_template_and_user );
use CGI qw ( -utf8 );
use C4::Output qw( output_html_with_http_headers );
use Koha::Patrons;
use Koha::Libraries;
use Koha::Database;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Policy::Patrons::Cardnumber;
use Koha::ItemTypes;
use Koha::CirculationRules;

#Setting variables
my $input = CGI->new;

unless ( C4::Context->preference('Version') ) {
    print $input->redirect("/cgi-bin/koha/installer/install.pl");
    exit;
}

my ( $user, $cookie, $sessionID, $flags ) =
  C4::InstallAuth::checkauth( $input, 0, undef, 'intranet' );
die "Not logged in"
  unless $user
  ; # Should not happen, we should be redirect if the user is not logged in. But do not trust authentication...

my $step = $input->param('step') || 1;
my $op   = $input->param('op')   || '';

my $template_params = {};
$template_params->{op} = $op;

my $schema = Koha::Database->new()->schema();

my @messages;

if ( $step == 1 ) {

    if ( $op eq 'add_validate_library' ) {

        my $branchcode = $input->param('branchcode');
        $branchcode = uc($branchcode);

        $branchcode =~ s|\s||g
          ; # Use a regular expression to check the value of the inputted branchcode

        my $library = Koha::Library->new(
            {
                branchcode => $branchcode,
                branchname => scalar $input->param('branchname'),
            }
        );

        eval { $library->store; };
        unless ($@) {
            push @messages, { code => 'success_on_insert_library' };
        }
        else {
            push @messages, { code => 'error_on_insert_library' };
        }
    }

    $step++ if Koha::Libraries->count;
}
if ( $step == 2 ) {
    if ( $op eq "add_validate_category" ) {

        my $searchfield = $input->param('description') // q||;
        my $categorycode = $input->param('categorycode');
        my $category;
        $template_params->{categorycode} = $categorycode;

        $categorycode = $input->param('categorycode');
        my $description           = $input->param('description');
        my $overduenoticerequired = $input->param('overduenoticerequired');
        my $category_type         = $input->param('category_type');
        my $default_privacy       = $input->param('default_privacy');
        my $enrolmentperiod       = $input->param('enrolmentperiod');
        my $enrolmentperioddate = $input->param('enrolmentperioddate') || undef;

        #Adds a new patron category to the database
        $category = Koha::Patron::Category->new(
            {
                categorycode          => $categorycode,
                description           => $description,
                overduenoticerequired => $overduenoticerequired,
                category_type         => $category_type,
                default_privacy       => $default_privacy,
                enrolmentperiod       => $enrolmentperiod,
                enrolmentperioddate   => $enrolmentperioddate
            }
        );

        eval { $category->store; };

        unless ($@) {
            push @messages, { code => 'success_on_insert_category' };
        }
        else {
            push @messages, { code => 'error_on_insert_category' };
        }
    }

    $step++ if Koha::Patron::Categories->count;
}
if ( $step == 3 ) {
    if ( $op eq 'add_validate_patron' ) {

        #Create a patron
        my $firstpassword  = $input->param('password')  || '';
        my $secondpassword = $input->param('password2') || '';
        my $cardnumber     = $input->param('cardnumber');
        my $userid         = $input->param('userid');
        my $categorycode = $input->param('categorycode_entry');
        my $patron_category =
          Koha::Patron::Categories->find( $categorycode );

        my ( $is_valid, $passworderror ) =
          Koha::AuthUtils::is_password_valid( $firstpassword,
            $patron_category );


        my $is_cardnumber_valid = Koha::Policy::Patrons::Cardnumber->is_valid($cardnumber);
        unless ( $is_cardnumber_valid ) {
            for my $m ( @{ $is_cardnumber_valid->messages } ) {
                my $message = $m->message;
                if ( $message eq 'already_exists' ) {
                    push @messages, { code => 'ERROR_cardnumber_already_exists' };
                }
                elsif ( $message eq 'invalid_length' ) {
                    push @messages, { code => 'ERROR_cardnumber_length' };
                }
            }
        }
        elsif ( $firstpassword ne $secondpassword ) {

            push @messages, { code => 'ERROR_password_mismatch' };
        }
        elsif ( $passworderror) {
                push @messages, { code => 'ERROR_password_too_short'} if $passworderror eq 'too_short';
                push @messages, { code => 'ERROR_password_too_weak'} if $passworderror eq 'too_weak';
                push @messages, { code => 'ERROR_password_has_whitespaces'} if $passworderror eq 'has_whitespaces';

        }
        else {
            my $patron_data = {
                surname      => scalar $input->param('surname'),
                firstname    => scalar $input->param('firstname'),
                cardnumber   => scalar $input->param('cardnumber'),
                branchcode   => scalar $input->param('libraries'),
                categorycode => $categorycode,
                userid       => scalar $input->param('userid'),
                privacy      => "default",
                address      => "",
                city         => "",
                flags        => 1,    # Will be superlibrarian
            };

            $patron_data->{dateexpiry} =
              $patron_category->get_expiry_date( $patron_data->{dateenrolled} );

            eval {
                my $patron = Koha::Patron->new($patron_data)->store;
                $patron->set_password({ password =>  $firstpassword });
            };

            #Error handling checking if the patron was created successfully
            unless ($@) {
                push @messages, { code => 'success_on_insert_patron' };
            }
            else {
                warn $@;
                push @messages, { code => 'error_on_insert_patron' };
            }
        }
    }

    $step++ if Koha::Patrons->search( { flags => 1 } )->count;
}
if ( $step == 4 ) {
    if ( $op eq 'add_validate_itemtype' ) {
        my $description   = $input->param('description');
        my $itemtype_code = $input->param('itemtype');
        $itemtype_code = uc($itemtype_code);

        my $itemtype = Koha::ItemType->new(
            {
                itemtype    => $itemtype_code,
                description => $description,
            }
        );
        eval { $itemtype->store; };

        unless ($@) {
            push @messages, { code => 'success_on_insert_itemtype' };
        }
        else {
            push @messages, { code => 'error_on_insert_itemtype' };
        }
    }

    $step++ if Koha::ItemTypes->count;
}
if ( $step == 5 ) {

    if ( $op eq 'add_validate_circ_rule' ) {

        #If no libraries exist then set the $branch value to *
        my $branch = $input->param('branch') || '*';

        my $type            = $input->param('type');
        my $branchcode      = $input->param('branch');
        my $categorycode    = $input->param('categorycode');
        my $itemtype        = $input->param('itemtype');
        my $maxissueqty     = $input->param('maxissueqty');
        my $issuelength     = $input->param('issuelength') || 0;
        my $lengthunit      = $input->param('lengthunit');
        my $renewalsallowed = $input->param('renewalsallowed');
        my $renewalperiod   = $input->param('renewalperiod');
        my $reservesallowed = $input->param('reservesallowed');
        my $holds_per_day   = $input->param('holds_per_day');
        my $holds_per_record = $input->param('holds_per_record');
        my $onshelfholds    = $input->param('onshelfholds') || 0;
        $maxissueqty =~ s/\s//g;
        $maxissueqty = undef if $maxissueqty !~ /^\d+/;

        my $params = {
            branchcode      => $branchcode,
            categorycode    => $categorycode,
            itemtype        => $itemtype,
            rules => {
                renewalsallowed                  => $renewalsallowed,
                renewalperiod                    => $renewalperiod,
                issuelength                      => $issuelength,
                lengthunit                       => $lengthunit,
                onshelfholds                     => $onshelfholds,
                article_requests                 => "no",
                auto_renew                       => 0,
                cap_fine_to_replacement_price    => 0,
                chargeperiod                     => 0,
                chargeperiod_charge_at           => 0,
                fine                             => 0,
                finedays                         => 0,
                firstremind                      => 0,
                hardduedate                      => "",
                hardduedatecompare               => -1,
                holds_per_day                    => $holds_per_day,
                holds_per_record                 => $holds_per_record,
                maxissueqty                      => $maxissueqty,
                maxonsiteissueqty                => "",
                maxsuspensiondays                => "",
                no_auto_renewal_after            => "",
                no_auto_renewal_after_hard_limit => "",
                norenewalbefore                  => "",
                opacitemholds                    => "N",
                overduefinescap                  => "",
                rentaldiscount                   => 0,
                reservesallowed                  => $reservesallowed,
                suspension_chargeperiod          => 1,
                decreaseloanholds                => "",
                unseen_renewals_allowed          => "",
                recalls_allowed                  => undef,
                recalls_per_record               => undef,
                on_shelf_recalls                 => undef,
                recall_due_date_interval         => undef,
                recall_overdue_fine              => undef,
                recall_shelf_time                => undef,
              }
        };

        eval {
            Koha::CirculationRules->set_rules($params);
        };

        if ($@) {
            warn $@;
            push @messages, { code => 'error_on_insert_circ_rule' };
        } else {
            push @messages, { code => 'success_on_insert_circ_rule' };
        }
    }

    $step++ if Koha::CirculationRules->count;
}

my $libraries = Koha::Libraries->search( {}, { order_by => ['branchcode'] }, );
$template_params->{libraries}   = $libraries;

if ( $step > 5 ) {
    $template_params->{all_done} = 1;    # If step 5 is complete, we are done!
    $step = 5;
}

#Getting the appropriate template to display to the user
my ( $template, $loggedinuser );
( $template, $loggedinuser, $cookie ) = C4::InstallAuth::get_template_and_user(
    {
        template_name   => "onboarding/onboardingstep${step}.tt",
        query           => $input,
        type            => "intranet",
    }
);

$template_params->{messages} = \@messages;
my $categories = Koha::Patron::Categories->search();
$template_params->{categories} = $categories;

my $itemtypes = Koha::ItemTypes->search();
$template_params->{itemtypes} = $itemtypes;

$template->param(%$template_params);

output_html_with_http_headers $input, $cookie, $template->output;
