#!/usr/bin/perl

# Tests for C4::Auth::haspermission

# This file is part of Koha.
#
# Copyright 2016 Rijksmuseum
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
use Test::More tests => 13;

use Koha::Database;
use t::lib::TestBuilder;
use C4::Auth qw(haspermission);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Adding two borrowers and granular permissions for the second borrower
my $builder = t::lib::TestBuilder->new();
my $borr1 = $builder->build({
    source => 'Borrower',
    value  => {
        surname => 'Superlib',
        flags   => 1,
    },
});
my $borr2 = $builder->build({
    source => 'Borrower',
    value  => {
        surname => 'Bor2',
        flags   => 2 + 4 + 2**11, # circulate, catalogue, acquisition
    },
});
$builder->build({
    source => 'UserPermission',
    value  => {
        borrowernumber => $borr2->{borrowernumber},
        module_bit => 13, # tools
        code => 'upload_local_cover_images',
    },
});
$builder->build({
    source => 'UserPermission',
    value  => {
        borrowernumber => $borr2->{borrowernumber},
        module_bit => 13, # tools
        code => 'batch_upload_patron_images',
    },
});

# Check top level permission for superlibrarian
my $r = haspermission( $borr1->{userid},
    { circulate => 1, editcatalogue => 1 } );
is( ref($r), 'HASH', 'Superlibrarian/circulate' );

# Check specific top level permission(s) for borr2
$r = haspermission( $borr2->{userid},
    { circulate => 1, catalogue => 1 } );
is( ref($r), 'HASH', 'Borrower2/circulate' );
$r = haspermission( $borr2->{userid}, { updatecharges => 1 } );
is( $r, 0, 'Borrower2/updatecharges should fail' );

# Check granular permission with 1: means all subpermissions
$r = haspermission( $borr1->{userid}, { tools => 1 } );
is( ref($r), 'HASH', 'Superlibrarian/tools granular all' );
$r = haspermission( $borr2->{userid}, { tools => 1 } );
is( $r, 0, 'Borrower2/tools granular all should fail' );

# Check granular permission with *: means at least one subpermission
$r = haspermission( $borr1->{userid}, { tools => '*' } );
is( ref($r), 'HASH', 'Superlibrarian/tools granular *' );
$r = haspermission( $borr2->{userid}, { acquisition => '*' } );
is( ref($r), 'HASH', 'Borrower2/acq granular *' );
$r = haspermission( $borr2->{userid}, { tools => '*' } );
is( ref($r), 'HASH', 'Borrower2/tools granular *' );
$r = haspermission( $borr2->{userid}, { serials => '*' } );
is( $r, 0, 'Borrower2/serials granular * should fail' );

# Check granular permission with one or more specific subperms
$r = haspermission( $borr1->{userid}, { tools => 'edit_news' } );
is( ref($r), 'HASH', 'Superlibrarian/tools edit_news' );
$r = haspermission( $borr2->{userid}, { acquisition => 'budget_manage' } );
is( ref($r), 'HASH', 'Borrower2/acq budget_manage' );
$r = haspermission( $borr2->{userid},
    { acquisition => 'budget_manage', tools => 'edit_news' } );
is( $r, 0, 'Borrower2/two granular should fail' );
$r = haspermission( $borr2->{userid}, {
    tools => 'upload_local_cover_images',
    tools => 'batch_upload_patron_images',
});
is( ref($r), 'HASH', 'Borrower2/tools granular two upload subperms' );

# End
$schema->storage->txn_rollback;
