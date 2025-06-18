package Koha::REST::V1::ERM::EUsage::UsageTitles;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';
use Module::Load qw( load );

use Koha::ERM::EUsage::UsageTitles;
use Koha::ERM::EUsage::UsagePlatforms;
use Koha::ERM::EUsage::UsageItems;
use Koha::ERM::EUsage::UsageDatabases;
use Koha::ERM::EUsage::UsageDataProvider;
use Koha::ERM::EUsage::UsageDataProviders;

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
        my $usage_titles_set = Koha::ERM::EUsage::UsageTitles->new;
        my $usage_titles     = $c->objects->search($usage_titles_set);
        return $c->render( status => 200, openapi => $usage_titles );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
