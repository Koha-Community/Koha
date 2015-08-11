package Koha::ApiKeys;

# Copyright BibLibre 2015
#
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
use Scalar::Util qw(blessed);

use Koha::Patrons;
use Koha::ApiKey;

use base qw(Koha::Objects);

use Koha::Exception::BadParameter;
use Koha::Exception::UnknownObject;

=head1 NAME

Koha::ApiKeys - Koha API Keys Object class

=head1 API

=head2 Class Methods

=cut

=head3 _type

=cut

sub _type {
    return 'ApiKey';
}

sub object_class {
    return 'Koha::ApiKey';
}

sub _get_castable_unique_columns {
    return ['api_key_id', 'api_key'];
}

=head grant

    my $apiKey = Koha::ApiKey->grant({borrower => $borrower,
                                    apiKey => $apiKey
                                });

Granting an ApiKey should be easy. This creates a new ApiKey for the given Borrower,
or sets the owner of an existing key.
$PARAM1 HASHRef of params, {
            borrower => MANDATORY, a Koha::Patron or something castable to one.
            apiKey   => OPTIONAL, an existing Koha::ApiKEy to give to somebody else.
                                not sure why anybody would want to do that, but
                                provided as a convenience for testing.
}
@THROWS Koha::Exception::BadParameter
=cut

sub grant {
    my ($self, $borrower, $apiKey) = @_;
    $borrower = Koha::Patrons->cast($borrower);
    if ($apiKey) {
        $apiKey = Koha::ApiKeys->cast($apiKey);
        $apiKey->borrowernumber($borrower->borrowernumber);
    }
    else {
        $apiKey = new Koha::ApiKey;
        $apiKey->borrowernumber($borrower->borrowernumber);
        $apiKey->api_key(String::Random->new->randregex('[a-zA-Z0-9]{32}'));
    }
    $apiKey->store;
    return $apiKey;
}

sub delete {
    my ($self, $apiKey) = @_;
    $apiKey = Koha::ApiKeys->cast($apiKey);

    if ($apiKey) {
        $apiKey->delete;
    }
}

sub revoke {
    my ($self, $apiKey) = @_;
    $apiKey = Koha::ApiKeys->cast($apiKey);

    if ($apiKey) {
        $apiKey->active(0);
        $apiKey->store;
    }
    return $apiKey;
}

sub activate {
    my ($self, $apiKey) = @_;
    $apiKey = Koha::ApiKeys->cast($apiKey);

    if ($apiKey) {
        $apiKey->active(1);
        $apiKey->store;
    }
    return $apiKey;
}

1;
