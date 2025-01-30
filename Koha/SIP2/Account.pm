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

use Koha::SIP2::Account::PatronAttributes;
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

    my @patron_attributes = map { $_->get_for_config } @{ $self->patron_attributes->as_list };
    if (@patron_attributes) {
        $unblessed->{patron_attribute} = scalar(@patron_attributes) == 1 ? $patron_attributes[0] : \@patron_attributes;
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

=head3 type

=cut

sub _type {
    return 'SipAccount';
}

1;
