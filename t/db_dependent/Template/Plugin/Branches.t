#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 14;

use C4::Context;
use Koha::Database;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Template::Plugin::Branches');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $library = $builder->build({
    source => 'Branch',
    value => {
        branchcode => 'MYLIBRARY',
    }
});
my $another_library = $builder->build({
    source => 'Branch',
    value => {
        branchcode => 'ANOTHERLIB',
    }
});

my $plugin = Koha::Template::Plugin::Branches->new();
ok($plugin, "initialized Branches plugin");

my $name = $plugin->GetName($library->{branchcode});
is($name, $library->{branchname}, 'retrieved expected name for library');

$name = $plugin->GetName('__ANY__');
is($name, '', 'received empty string as name of the "__ANY__" placeholder library code');

$name = $plugin->GetName(undef);
is($name, '', 'received empty string as name of NULL/undefined library code');

$library = $plugin->GetLoggedInBranchcode();
is($library, '', 'no active library if there is no active user session');

C4::Context->_new_userenv('DUMMY_SESSION_ID');
C4::Context->set_userenv(123, 'userid', 'usercnum', 'First name', 'Surname', 'MYLIBRARY', 'My Library', 0);
$library = $plugin->GetLoggedInBranchcode();
is($library, 'MYLIBRARY', 'GetLoggedInBranchcode() returns active library');

C4::Context->set_preference( 'IndependentBranches', 0 );
my $libraries = $plugin->all();
ok( scalar(@$libraries) > 1, 'If IndependentBranches is not set, all libraries should be returned' );
is( grep ( { $_->{branchcode} eq 'MYLIBRARY'  and $_->{selected} == 1 } @$libraries ),       1, 'Without selected parameter, my library should be preselected' );
is( grep ( { $_->{branchcode} eq 'ANOTHERLIB' and not exists $_->{selected} } @$libraries ), 1, 'Without selected parameter, other library should not be preselected' );
$libraries = $plugin->all( { selected => 'ANOTHERLIB' } );
is( grep ( { $_->{branchcode} eq 'MYLIBRARY'  and not exists $_->{selected} } @$libraries ), 1, 'With selected parameter, my library should not be preselected' );
is( grep ( { $_->{branchcode} eq 'ANOTHERLIB' and $_->{selected} == 1 } @$libraries ),       1, 'With selected parameter, other library should be preselected' );

C4::Context->set_preference( 'IndependentBranches', 1 );
$libraries = $plugin->all();
is( scalar(@$libraries), 1, 'If IndependentBranches is set, only 1 library should be returned' );
$libraries = $plugin->all( { unfiltered => 1 } );
ok( scalar(@$libraries) > 1, 'If IndependentBranches is set, all libraries should be returned if the unfiltered flag is set' );
