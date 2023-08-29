package Koha::REST::V1::ERM::EUsage::UsagePlatforms;

# Copyright 2023 PTFS Europe

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

use Mojo::Base 'Mojolicious::Controller';
use Module::Load qw( load );

use Koha::ERM::EUsage::UsagePlatforms;

use Clone        qw( clone );
use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );
use JSON;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $usage_platforms_set = Koha::ERM::EUsage::UsagePlatforms->new;
        my $usage_platforms     = $c->objects->search($usage_platforms_set);
        return $c->render( status => 200, openapi => $usage_platforms );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
