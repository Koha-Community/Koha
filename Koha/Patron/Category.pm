package Koha::Patron::Category;

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

use Modern::Perl;

use List::MoreUtils qw( any );

use C4::Members::Messaging;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use base qw(Koha::Object Koha::Object::Limit::Library);

=head1 NAME

Koha::Patron;;Category - Koha Patron;;Category Object class

=head1 API

=head2 Class Methods

=cut

=head3 effective_BlockExpiredPatronOpacActions_contains

my $actionBlocked = $category->effective_BlockExpiredPatronOpacActions_contains('hold');

Return if the provided action is blocked by BlockExpiredPatronOpacActions, accounting for the syspref.

=over

=item action

Action, can be one of: ['hold', 'renew', 'ill_request']

=back

=cut

sub effective_BlockExpiredPatronOpacActions_contains {
    my ( $self, $action ) = @_;

    my $blocked_actions = {
        map { ( $_, 1 ); } split /\s*\,\s*/,
        C4::Context->preference('BlockExpiredPatronOpacActions')
    };

    return $blocked_actions->{$action}
        if $self->BlockExpiredPatronOpacActions_contains('follow_syspref_BlockExpiredPatronOpacActions');
    return $self->BlockExpiredPatronOpacActions_contains($action);
}

=head3 BlockExpiredPatronOpacActions_contains

my $actionBlocked = $self->BlockExpiredPatronOpacActions_contains('hold');

Return if the provided action is blocked by this category's BlockExpiredPatronOpacActions value.

=over

=item action

Action, can be one of: ['hold', 'renew', 'ill_request']

=back

=cut

sub BlockExpiredPatronOpacActions_contains {
    my ( $self, $action ) = @_;

    my $blocked_actions = {
        map { ( $_, 1 ); } split /\s*\,\s*/,
        $self->BlockExpiredPatronOpacActions
    };

    return unless $blocked_actions->{$action};
    return 1;
}

=head3 store

=cut

sub store {
    my ($self) = @_;

    $self->dateofbirthrequired(undef)
        if not defined $self->dateofbirthrequired
        or $self->dateofbirthrequired eq '';

    $self->upperagelimit(undef)
        if not defined $self->upperagelimit
        or $self->upperagelimit eq '';

    $self->checkprevcheckout('inherit')
        unless defined $self->checkprevcheckout;

    return $self->SUPER::store;
}

=head3 default_messaging

my $messaging = $category->default_messaging();

=cut

sub default_messaging {
    my ($self) = @_;
    my $messaging_options = C4::Members::Messaging::GetMessagingOptions();
    my @messaging;
    foreach my $option (@$messaging_options) {
        my $pref = C4::Members::Messaging::GetMessagingPreferences(
            {
                categorycode => $self->categorycode,
                message_name => $option->{message_name}
            }
        );
        next unless $pref->{transports};
        my $brief_pref = {
            message_attribute_id      => $option->{message_attribute_id},
            message_name              => $option->{message_name},
            $option->{'message_name'} => 1,
        };
        foreach my $transport ( keys %{ $pref->{transports} } ) {
            push @{ $brief_pref->{transports} }, { transport => $transport };
        }
        push @messaging, $brief_pref;
    }
    return \@messaging;
}

=head2 get_expiry_date

Missing POD for get_expiry_date.

=cut

sub get_expiry_date {
    my ( $self, $date ) = @_;
    if ( $self->enrolmentperiod ) {
        $date ||= dt_from_string;
        $date = ref $date ? $date->clone() : dt_from_string($date);
        return $date->add( months => $self->enrolmentperiod, end_of_month => 'limit' );
    } else {
        return $self->enrolmentperioddate;
    }
}

=head3 get_password_expiry_date

Returns date based on password expiry days set for the category. If the value is not set
we return undef, password does not expire

my $expiry_date = $category->get_password_expiry_date();

=cut

sub get_password_expiry_date {
    my ( $self, $date ) = @_;
    if ( $self->password_expiry_days ) {
        $date ||= dt_from_string;
        $date = ref $date ? $date->clone() : dt_from_string($date);
        return $date->add( days => $self->password_expiry_days )->ymd;
    } else {
        return;
    }
}

=head3 effective_reset_password

Returns if patrons in this category can reset their password. If set in $self->reset_password
or, if undef, falls back to the OpacResetPassword system preference.

=cut

sub effective_reset_password {
    my ($self) = @_;

    return $self->reset_password // C4::Context->preference('OpacResetPassword');
}

=head3 effective_change_password

Returns if patrons in this category can change their password. If set in $self->change_password
or, if undef, falls back to the OpacPasswordChange system preference.

=cut

sub effective_change_password {
    my ($self) = @_;

    return $self->change_password // C4::Context->preference('OpacPasswordChange');
}

=head3 effective_min_password_length

    $category->effective_min_password_length()

Retrieve category's password length if set, or minPasswordLength otherwise

=cut

sub effective_min_password_length {
    my ($self) = @_;

    return $self->min_password_length // C4::Context->preference('minPasswordLength');
}

=head3 effective_require_strong_password

    $category->effective_require_strong_password()

Retrieve category's password strength if set, or RequireStrongPassword otherwise

=cut

sub effective_require_strong_password {
    my ($self) = @_;

    return $self->require_strong_password // C4::Context->preference('RequireStrongPassword');
}

=head3 effective_force_password_reset_when_set_by_staff

    $category->effective_force_password_reset_when_set_by_staff()

Returns if new staff created patrons in this category are forced to reset their password. If set in $self->force_password_reset_when_set_by_staff
or, if undef, falls back to the ForcePasswordResetWhenSetByStaff system preference.

=cut

sub effective_force_password_reset_when_set_by_staff {
    my ($self) = @_;

    return $self->force_password_reset_when_set_by_staff // C4::Context->preference('ForcePasswordResetWhenSetByStaff');
}

=head3 override_hidden_items

    if ( $patron->category->override_hidden_items ) {
        ...
    }

Returns a boolean that if patrons of this category are exempt from the OPACHiddenItems policies

TODO: Remove on bug 22547

=cut

sub override_hidden_items {
    my ($self) = @_;
    return any { $_ eq $self->categorycode }
        split( ',', C4::Context->preference('OpacHiddenItemsExceptions') );
}

=head3 can_make_suggestions


    if ( $patron->category->can_make_suggestions ) {
        ...
    }

Returns if the OPAC logged-in user is allowed to make OPAC purchase suggestions.

=cut

sub can_make_suggestions {
    my ($self) = @_;

    if ( C4::Context->preference('suggestion') ) {

        my @patron_categories = split ',', C4::Context->preference('suggestionPatronCategoryExceptions') // q{};

        return !any { $_ eq $self->categorycode } @patron_categories;
    }

    return 0;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Patron:Category
object on the API.

=cut

sub to_api_mapping {
    return {
        categorycode                           => 'patron_category_id',
        description                            => 'name',
        enrolmentperiod                        => 'enrolment_period',
        enrolmentperioddate                    => 'enrolment_period_date',
        password_expiry_days                   => 'password_expiry_days',
        upperagelimit                          => 'upper_age_limit',
        dateofbirthrequired                    => 'lower_age_limit',
        enrolmentfee                           => 'enrolment_fee',
        overduenoticerequired                  => 'overdue_notice_required',
        reservefee                             => 'reserve_fee',
        hidelostitems                          => 'hide_lost_items',
        category_type                          => 'category_type',
        BlockExpiredPatronOpacActions          => 'block_expired_patron_opac_actions',
        default_privacy                        => 'default_privacy',
        checkprevcheckout                      => 'check_prev_checkout',
        can_place_ill_in_opac                  => 'can_place_ill_in_opac',
        can_be_guarantee                       => 'can_be_guarantee',
        reset_password                         => 'reset_password',
        change_password                        => 'change_password',
        min_password_length                    => 'min_password_length',
        require_strong_password                => 'require_strong_password',
        exclude_from_local_holds_priority      => 'exclude_from_local_holds_priority',
        noissuescharge                         => 'no_issues_charge',
        noissueschargeguarantees               => 'no_issues_charge_guarantees',
        noissueschargeguarantorswithguarantees => 'no_issues_charge_guarantors_with_guarantees'
    };
}

=head2 Internal methods

=head3 _library_limits

 configure library limits

=cut

sub _library_limits {
    return {
        class   => "CategoriesBranch",
        id      => "categorycode",
        library => "branchcode",
    };
}

=head3 type

=cut

sub _type {
    return 'Category';
}

1;
