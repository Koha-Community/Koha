#!/usr/bin/perl

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

use Test::MockObject;

use Koha::ILL::Request;
use Koha::ILL::Request::SupplierUpdate;

use Test::NoWarnings;
use Test::More tests => 5;

use_ok('Koha::ILL::Request::SupplierUpdate');

my $update = Koha::ILL::Request::SupplierUpdate->new(
    'test_type',
    'test_name',
    'Arbitrary update text'
);

isa_ok( $update, 'Koha::ILL::Request::SupplierUpdate' );

my $processor = Test::MockObject->new;
$processor->set_isa('Koha::ILL::Request::Processor');
$processor->{name} = 'Test processor';
$processor->mock(
    'run',
    sub {
        my ( $self, $update, $options, $result ) = @_;
        push @{ $result->{success} }, 'Hello';
    }
);

# attach_processor
$update->attach_processor($processor);
is(
    scalar @{ $update->{processors} },
    1,
    'attach_processors works'
);

# run_processors
is_deeply(
    $update->run_processors( {} ),
    [
        {
            name   => 'Test processor',
            result => {
                success => ['Hello'],
                error   => []
            }
        }
    ],
    'run_processors calls attached processors'
);
