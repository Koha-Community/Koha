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

use Koha::Illrequest;
use Koha::Illrequest::SupplierUpdate;

use Test::More tests => 4;

use_ok('Koha::Illrequest::SupplierUpdate');

my $update = Koha::Illrequest::SupplierUpdate->new(
    'test_type',
    'test_name',
    'Arbitrary update text'
);

isa_ok( $update, 'Koha::Illrequest::SupplierUpdate' );

my $processor = Test::MockObject->new;
$processor->set_isa('Koha::Illrequest::Processor');
$processor->{name} = 'Test processor';
$processor->mock('run', sub {
    my ( $self, $update, $options, $result ) = @_;
    push @{$result->{success}}, 'Hello';
});

# attach_processor
$update->attach_processor($processor);
is(
    scalar @{$update->{processors}},
    1,
    'attach_processors works'
);

# run_processors
is_deeply(
    $update->run_processors({}),
    [{
        name => 'Test processor',
        result => {
            success => ['Hello'],
            error => []
        }
    }],
    'run_processors calls attached processors'
);
