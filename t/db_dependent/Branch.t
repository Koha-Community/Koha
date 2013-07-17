#!/usr/bin/perl

# Copyright 2013 Equinox Software, Inc.
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
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Data::Dumper;

use Test::More tests => 6;

use C4::Branch;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Branch');
}

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# clear the slate
$dbh->do('DELETE FROM branchcategories');

my @category_types = GetCategoryTypes();
is_deeply(\@category_types, [ 'searchdomain', 'properties' ], 'received expected library category types');

my %new_category = (
    categorycode     => 'LIBCATCODE',
    categoryname     => 'library category name',
    codedescription  => 'library category code description',
    categorytype     => 'searchdomain',
    show_in_pulldown => 1,
);
ModBranchCategoryInfo({
    add => 1,
    %new_category,
});

my $category = GetBranchCategory('LIBCATCODE');
is_deeply($category, \%new_category, 'fetched newly added library category');

$category = GetBranchCategory();
is($category, undef, 'retrieve library category only if code is supplied (bug 10515)');

my $categories = GetBranchCategories();
is_deeply($categories, [ \%new_category ], 'retrieve all expected library categories (bug 10515)');

$categories = GetBranchCategories(undef, undef, 'LIBCATCODE');
is_deeply($categories, [ { %new_category, selected => 1 } ], 'retrieve expected, eselected library category (bug 10515)');

$dbh->rollback();
