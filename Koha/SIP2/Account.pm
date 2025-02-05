package Koha::SIP2::Account;

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

use base qw(Koha::SIP2::Object Koha::Object);

use Koha::SIP2::Account::CustomItemFields;
use Koha::SIP2::Account::ItemFields;
use Koha::SIP2::Account::CustomPatronFields;
use Koha::SIP2::Account::PatronAttributes;
use Koha::SIP2::Account::SystemPreferenceOverrides;
use Koha::SIP2::Institution;

=head1 NAME

Koha::SIP2::Account- Koha SipAccount Object class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the account hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    my $unblessed = $self->unblessed;
    foreach my $key ( keys %$unblessed ) {

        # Remove all undef entries
        if ( !defined $unblessed->{$key} ) {
            delete $unblessed->{$key};
            next;
        }

        # Convert all integer values to strings
        if ( $unblessed->{$key} =~ /^[0-9]+$/ ) {
            $unblessed->{$key} = $unblessed->{$key} . '';
        }
    }

    # Delete fields unused by C4/SIP
    delete $unblessed->{sip_institution_id};
    delete $unblessed->{sip_account_id};

    # Map database columns to their expected C4/SIP counterparts
    $unblessed->{institution} = $self->institution->name;
    $unblessed->{id}          = delete $unblessed->{login_id};
    $unblessed->{password}    = delete $unblessed->{login_password};
    if ( $unblessed->{error_detect} ) {
        $unblessed->{'error-detect'} = 'enabled';
        delete $unblessed->{error_detect};
    }

    # Add relations
    # If a single element, return that, otherwise return a list

    my @custom_item_fields = map { $_->get_for_config } @{ $self->custom_item_fields->as_list };
    if (@custom_item_fields) {
        $unblessed->{custom_item_field} =
            scalar(@custom_item_fields) == 1 ? $custom_item_fields[0] : \@custom_item_fields;
    }

    my @item_fields = map { $_->get_for_config } @{ $self->item_fields->as_list };
    if (@item_fields) {
        $unblessed->{item_field} = scalar(@item_fields) == 1 ? $item_fields[0] : \@item_fields;
    }

    my @custom_patron_fields = map { $_->get_for_config } @{ $self->custom_patron_fields->as_list };
    if (@custom_patron_fields) {
        $unblessed->{custom_patron_field} =
            scalar(@custom_patron_fields) == 1 ? $custom_patron_fields[0] : \@custom_patron_fields;
    }

    my @patron_attributes = map { $_->get_for_config } @{ $self->patron_attributes->as_list };
    if (@patron_attributes) {
        $unblessed->{patron_attribute} = scalar(@patron_attributes) == 1 ? $patron_attributes[0] : \@patron_attributes;
    }

    my %system_preference_overrides =
        map { $_->variable => $_->value } @{ $self->system_preference_overrides->as_list };
    if (%system_preference_overrides) {
        $unblessed->{syspref_overrides} = \%system_preference_overrides;
    }

    return $unblessed;
}

=head3 institution

Return the institution for this account

=cut

sub institution {
    my ($self) = @_;
    my $institution_rs = $self->_result->sip_institution;
    return unless $institution_rs;
    return Koha::SIP2::Institution->_new_from_dbic($institution_rs);
}

=head3 custom_item_fields

Returns the custom item fields for this SIP account

=cut

sub custom_item_fields {
    my ( $self, $custom_item_fields ) = @_;

    if ($custom_item_fields) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->custom_item_fields->delete;

                for my $custom_item_field (@$custom_item_fields) {
                    $self->_result->add_to_sip_account_custom_item_fields($custom_item_field);
                }
            }
        );
    }

    my $custom_item_fields_rs = $self->_result->sip_account_custom_item_fields;
    return Koha::SIP2::Account::CustomItemFields->_new_from_dbic($custom_item_fields_rs);
}

=head3 item_fields

Returns the item fields for this SIP account

=cut

sub item_fields {
    my ( $self, $item_fields ) = @_;

    if ($item_fields) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->item_fields->delete;

                for my $item_field (@$item_fields) {
                    $self->_result->add_to_sip_account_item_fields($item_field);
                }
            }
        );
    }

    my $item_fields_rs = $self->_result->sip_account_item_fields;
    return Koha::SIP2::Account::ItemFields->_new_from_dbic($item_fields_rs);
}

=head3 custom_patron_fields

Returns the custom patron fields for this SIP account

=cut

sub custom_patron_fields {
    my ( $self, $custom_patron_fields ) = @_;

    if ($custom_patron_fields) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->custom_patron_fields->delete;

                for my $custom_patron_field (@$custom_patron_fields) {
                    $self->_result->add_to_sip_account_custom_patron_fields($custom_patron_field);
                }
            }
        );
    }

    my $custom_patron_fields_rs = $self->_result->sip_account_custom_patron_fields;
    return Koha::SIP2::Account::CustomPatronFields->_new_from_dbic($custom_patron_fields_rs);
}

=head3 patron_attributes

Returns the patron attributes for this SIP account

=cut

sub patron_attributes {
    my ( $self, $patron_attributes ) = @_;

    if ($patron_attributes) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->patron_attributes->delete;

                for my $patron_attribute (@$patron_attributes) {
                    $self->_result->add_to_sip_account_patron_attributes($patron_attribute);
                }
            }
        );
    }

    my $patron_attributes_rs = $self->_result->sip_account_patron_attributes;
    return Koha::SIP2::Account::PatronAttributes->_new_from_dbic($patron_attributes_rs);
}

=head3 system_preference_overrides

Returns the system preference overrides for this SIP account

=cut

sub system_preference_overrides {
    my ( $self, $system_preference_overrides ) = @_;

    if ($system_preference_overrides) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->system_preference_overrides->delete;

                for my $system_preference_override (@$system_preference_overrides) {
                    $self->_result->add_to_sip_account_system_preference_overrides($system_preference_override);
                }
            }
        );
    }

    my $system_preference_overrides_rs = $self->_result->sip_account_system_preference_overrides;
    return Koha::SIP2::Account::SystemPreferenceOverrides->_new_from_dbic($system_preference_overrides_rs);
}

=head3 type

=cut

sub _type {
    return 'SipAccount';
}

1;
