#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2002 Paul Poulain
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Form::MessagingPreferences;
use Koha::Patrons;
use Koha::Database;
use Koha::Patron::Categories;
use Koha::Libraries;

my $input        = CGI->new;
my $searchfield  = $input->param('description') // q||;
my $categorycode = $input->param('categorycode');
my $op           = $input->param('op') // 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/categories.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_patron_categories' },
    }
);

if ( $op eq 'add_form' ) {

    $template->param(
        category => scalar Koha::Patron::Categories->find($categorycode),
    );

    if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
        C4::Form::MessagingPreferences::set_form_values( { categorycode => $categorycode }, $template );
    }
} elsif ( $op eq 'cud-add_validate' ) {
    my $categorycode                           = $input->param('categorycode');
    my $description                            = $input->param('description');
    my $enrolmentperiod                        = $input->param('enrolmentperiod');
    my $enrolmentperioddate                    = $input->param('enrolmentperioddate')  || undef;
    my $password_expiry_days                   = $input->param('password_expiry_days') || undef;
    my $upperagelimit                          = $input->param('upperagelimit');
    my $dateofbirthrequired                    = $input->param('dateofbirthrequired');
    my $enrolmentfee                           = $input->param('enrolmentfee');
    my $reservefee                             = $input->param('reservefee');
    my $hidelostitems                          = $input->param('hidelostitems');
    my $overduenoticerequired                  = $input->param('overduenoticerequired');
    my $category_type                          = $input->param('category_type');
    my $BlockExpiredPatronOpacActions          = join( ',', $input->multi_param('BlockExpiredPatronOpacActions') );
    my $checkPrevCheckout                      = $input->param('checkprevcheckout');
    my $can_place_ill_in_opac                  = $input->param('can_place_ill_in_opac') // 1;
    my $default_privacy                        = $input->param('default_privacy');
    my $reset_password                         = $input->param('reset_password');
    my $change_password                        = $input->param('change_password');
    my $exclude_from_local_holds_priority      = $input->param('exclude_from_local_holds_priority');
    my $min_password_length                    = $input->param('min_password_length');
    my $require_strong_password                = $input->param('require_strong_password');
    my $noissuescharge                         = $input->param('noissuescharge')                         || undef;
    my $noissueschargeguarantees               = $input->param('noissueschargeguarantees')               || undef;
    my $noissueschargeguarantorswithguarantees = $input->param('noissueschargeguarantorswithguarantees') || undef;
    my $enforce_expiry_notice                  = $input->param('enforce_expiry_notice');

    my @branches                               = grep { $_ ne q{} } $input->multi_param('branches');
    my $can_be_guarantee                       = $input->param('can_be_guarantee');
    my $force_password_reset_when_set_by_staff = $input->param('force_password_reset_when_set_by_staff');

    $reset_password                         = undef if $reset_password eq -1;
    $change_password                        = undef if $change_password eq -1;
    $min_password_length                    = undef unless length($min_password_length);
    $require_strong_password                = undef if $require_strong_password eq -1;
    $force_password_reset_when_set_by_staff = undef if $force_password_reset_when_set_by_staff eq -1;

    my $is_a_modif = $input->param("is_a_modif");

    if ($is_a_modif) {
        my $category = Koha::Patron::Categories->find($categorycode);
        $category->categorycode($categorycode);
        $category->description($description);
        $category->enrolmentperiod($enrolmentperiod);
        $category->enrolmentperioddate($enrolmentperioddate);
        $category->password_expiry_days($password_expiry_days);
        $category->upperagelimit($upperagelimit);
        $category->dateofbirthrequired($dateofbirthrequired);
        $category->enrolmentfee($enrolmentfee);
        $category->reservefee($reservefee);
        $category->hidelostitems($hidelostitems);
        $category->overduenoticerequired($overduenoticerequired);
        $category->category_type($category_type);
        $category->can_be_guarantee($can_be_guarantee);
        $category->BlockExpiredPatronOpacActions($BlockExpiredPatronOpacActions);
        $category->checkprevcheckout($checkPrevCheckout);
        $category->can_place_ill_in_opac($can_place_ill_in_opac);
        $category->default_privacy($default_privacy);
        $category->reset_password($reset_password);
        $category->change_password($change_password);
        $category->exclude_from_local_holds_priority($exclude_from_local_holds_priority);
        $category->min_password_length($min_password_length);
        $category->require_strong_password($require_strong_password);
        $category->noissuescharge($noissuescharge);
        $category->noissueschargeguarantees($noissueschargeguarantees);
        $category->noissueschargeguarantorswithguarantees($noissueschargeguarantorswithguarantees);
        $category->force_password_reset_when_set_by_staff($force_password_reset_when_set_by_staff);
        $category->enforce_expiry_notice($enforce_expiry_notice);
        eval {
            $category->store;
            $category->replace_library_limits( \@branches );
        };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $category = Koha::Patron::Category->new(
            {
                categorycode                           => $categorycode,
                description                            => $description,
                enrolmentperiod                        => $enrolmentperiod,
                enrolmentperioddate                    => $enrolmentperioddate,
                password_expiry_days                   => $password_expiry_days,
                upperagelimit                          => $upperagelimit,
                dateofbirthrequired                    => $dateofbirthrequired,
                enrolmentfee                           => $enrolmentfee,
                reservefee                             => $reservefee,
                hidelostitems                          => $hidelostitems,
                overduenoticerequired                  => $overduenoticerequired,
                category_type                          => $category_type,
                can_be_guarantee                       => $can_be_guarantee,
                BlockExpiredPatronOpacActions          => $BlockExpiredPatronOpacActions,
                checkprevcheckout                      => $checkPrevCheckout,
                can_place_ill_in_opac                  => $can_place_ill_in_opac,
                default_privacy                        => $default_privacy,
                reset_password                         => $reset_password,
                change_password                        => $change_password,
                exclude_from_local_holds_priority      => $exclude_from_local_holds_priority,
                min_password_length                    => $min_password_length,
                require_strong_password                => $require_strong_password,
                noissuescharge                         => $noissuescharge,
                noissueschargeguarantees               => $noissueschargeguarantees,
                noissueschargeguarantorswithguarantees => $noissueschargeguarantorswithguarantees,
                enforce_expiry_notice                  => $enforce_expiry_notice,
                force_password_reset_when_set_by_staff => $force_password_reset_when_set_by_staff,
            }
        );
        eval {
            $category->store;
            $category->replace_library_limits( \@branches );
        };

        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }

    if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
        C4::Form::MessagingPreferences::handle_form_action(
            $input,
            { categorycode => scalar $input->param('categorycode') }, $template
        );
    }

    $searchfield = q||;
    $op          = 'list';
} elsif ( $op eq 'delete_confirm' ) {

    my $count = Koha::Patrons->search( { categorycode => $categorycode } )->count;

    my $category = Koha::Patron::Categories->find($categorycode);

    $template->param(
        category            => $category,
        patrons_in_category => $count,
    );

} elsif ( $op eq 'cud-delete_confirmed' ) {
    my $categorycode = uc( $input->param('categorycode') );

    my $category = Koha::Patron::Categories->find($categorycode);
    my $deleted  = eval { $category->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }

    $op = 'list';
}

if ( $op eq 'list' ) {
    my $categories = Koha::Patron::Categories->search(
        { description => { -like => "$searchfield%" } },
        { order_by    => [ 'category_type', 'description', 'categorycode' ] }
    );

    $template->param(
        categories => $categories,
    );
}

$template->param(
    categorycode => $categorycode,
    searchfield  => $searchfield,
    messages     => \@messages,
    op           => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;
