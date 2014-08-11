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

use Test::More tests => 16;
use Test::MockModule;

use t::lib::TestBuilder;

use C4::Members;
use Koha::Patrons;

my $schema = Koha::Database->schema;
my $dbh = C4::Context->dbh;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;


# Password policy simplenumeric
my $category1 = $builder->build({
    source => 'Category',
    value  => {
        categorycode => 'XYZ1',
        passwordpolicy => 'simplenumeric'
    },
});

# Password policy alphanumeric
my $category2 = $builder->build({
    source => 'Category',
    value  => {
        categorycode => 'XYZ2',
        passwordpolicy => 'alphanumeric'
    },
});

# Password policy complex
my $category3 = $builder->build({
    source => 'Category',
    value  => {
        categorycode => 'XYZ3',
        passwordpolicy => 'complex'
    },
});

# Password policy blank
my $category4 = $builder->build({
    source => 'Category',
    value  => {
        categorycode => 'XYZ4',
        passwordpolicy => ''
    },
});

my $newpassword = '1234';
my $newpassword2 = '1234';

C4::Context->set_preference("minPasswordLength", "4");
C4::Context->set_preference("minAlnumPasswordLength", "5");
C4::Context->set_preference("minComplexPasswordLength", "6");

my ($success, $errorcode, $errormessage) = ValidateMemberPassword($category1->{categorycode}, $newpassword, $newpassword2);
ok($success, "Simplenumeric password policy ok");

$newpassword = '123';
$newpassword2 = '123';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category1->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOSIMPLEPOLICYMATCH", "Simplenumeric password policy length too short");

$newpassword = 'DA123';
$newpassword2 = 'DA123';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category1->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOSIMPLEPOLICYMATCH", "Simplenumeric password policy not in valid format");

$newpassword = 'DA123';
$newpassword2 = 'DA123';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category2->{categorycode}, $newpassword, $newpassword2);
ok($success, "Alphanumeric password policy ok");

$newpassword = '123A';
$newpassword2 = '123A';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category2->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOALPHAPOLICYMATCH", "Alphanumeric password policy length too short");

$newpassword = '12345';
$newpassword2 = '12345';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category2->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOALPHAPOLICYMATCH", "Alphanumeric password policy not in valid format");

$newpassword = 'Da!@123';
$newpassword2 = 'Da!@123';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category3->{categorycode}, $newpassword, $newpassword2);
ok($success, "Complex password policy ok");

$newpassword = '12tA!';
$newpassword2 = '12tA!';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category3->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOCOMPLEXPOLICYMATCH", "Complex password policy length too short");

$newpassword = '12345';
$newpassword2 = '12345';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category3->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOCOMPLEXPOLICYMATCH", "Complex password policy not in valid format");

$newpassword = '12!4';
$newpassword2 = '12!4';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category4->{categorycode}, $newpassword, $newpassword2);
ok($success, "Blank password policy ok");

$newpassword = '123';
$newpassword2 = '123';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category4->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOLENGTHMATCH", "Blank password policy length too short");

C4::Context->set_preference("minPasswordLength", "");

$newpassword = '123';
$newpassword2 = '123';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category4->{categorycode}, $newpassword, $newpassword2);
ok($success, "Blank password policy length ok");

$newpassword = '12DA';
$newpassword2 = '12DA';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category4->{categorycode}, $newpassword, $newpassword2);
ok($success, "Blank password policy format ok");

$newpassword = '12345';
$newpassword2 = '12344';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category1->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "NOPASSWORDMATCH", "The passwords do not match");

($success, $errorcode, $errormessage) = ValidateMemberPassword(undef, $newpassword, $newpassword2);
is($errorcode, "NOCATEGORY", "No category given");

$newpassword = '123 ';
$newpassword2 = '123 ';

($success, $errorcode, $errormessage) = ValidateMemberPassword($category4->{categorycode}, $newpassword, $newpassword2);
is($errorcode, "WHITESPACEMATCH", "Has leading or trailing whitespace");


$schema->storage->txn_rollback;