#!/usr/bin/perl
#
# Copyright 2016 KohaSuomi
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
use Test::More;
use Try::Tiny;
use Scalar::Util qw(blessed);

use Koha::Database;
use C4::KohaSuomi::VendorConfig;
use C4::KohaSuomi::AcquisitionIntegration;
use t::db_dependent::KohaSuomi::RemoteBiblioPackageImporter::Context;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

C4::Context->setCommandlineEnvironment();
Koha::Logger->setConsoleVerbosity(undef); #Put this to 4 to log all levels

my $testContext = {};
my $matchers = t::db_dependent::KohaSuomi::RemoteBiblioPackageImporter::Context->prepareContext($testContext);



subtest "Get VendorConfig from syspref", \&newVendorConfigFromSyspref;
sub newVendorConfigFromSyspref {
    my ($c);
    eval {

    my $c = C4::KohaSuomi::AcquisitionIntegration::getVendorConfig('BTJBiblios');
    is($c->localStorageDir, '/tmp/testImportedMARC', 'localStorageDir');
    is($c->encoding, 'UTF-8', 'encoding');
    is($c->configKey, 'BTJBiblios', 'configKey');

    };
    if ($@) {
        ok(0, $@);
    };
}



subtest "new() VendorConfig exceptions", \&newVendorConfigExceptions;
sub newVendorConfigExceptions {
    my ($c);
    eval {

    try {
        my $c = C4::KohaSuomi::VendorConfig->new({});
    } catch {
        is(ref($_), 'Koha::Exception::BadSystemPreference', 'Got proper exception type');
        like($_->error, qr/Missing mandatory parameter/,    'Got proper exception message');
    };

    };
    if ($@) {
        ok(0, $@);
    };
}



tearDown($testContext);
sub tearDown {
    my ($testContext) = @_;
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}

$schema->storage->txn_rollback;

done_testing;
