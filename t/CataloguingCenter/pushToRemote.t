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
use Scalar::Util qw(blessed);
use Try::Tiny;

use JSON;

use t::lib::TestContext;
use t::CataloguingCenter::ContextSysprefs;

use Koha::RemoteAPIs;


my $globalTestContext = {};
t::lib::TestContext::setUserenv({cardnumber => '1AbatchOverlay'}, $globalTestContext);
t::CataloguingCenter::ContextSysprefs::createRemoteAPIs($globalTestContext);

subtest "Koha::RemoteAPIs syspref loading", \&KohaRemoteAPIsSysprefLoading;
sub KohaRemoteAPIsSysprefLoading {
    my ($remoteAPIs, $expectedTestRemote, $json, $hash);
    my $testContext = {};
    eval {

    #############################################################
    #### RemoteAPIs undefined ####
    t::lib::TestObjects::SystemPreferenceFactory->createTestGroup({
                        preference => 'RemoteAPIs',
                        value => '',
                });
    try {
        $remoteAPIs = Koha::RemoteAPIs->new();
        ok(0, "RemoteAPIs syspref not defined so Koha::Exception::FeatureUnavailable");
    } catch {
        die $_ unless(blessed($_) && $_->can('rethrow'));
        is(ref($_), 'Koha::Exception::FeatureUnavailable', "RemoteAPIs syspref not defined so Koha::Exception::FeatureUnavailable");
    };

    #############################################################
    #### RemoteAPIs malformed ####
    t::lib::TestObjects::SystemPreferenceFactory->createTestGroup({
                        preference => 'RemoteAPIs',
                        value => "skadebad skedebede",
                });
    try {
        $remoteAPIs = Koha::RemoteAPIs->new();
        ok(0, "RemoteAPIs syspref malformed so Koha::Exception::BadParameter");
    } catch {
        die $_ unless(blessed($_) && $_->can('rethrow'));
        is(ref($_), 'Koha::Exception::BadParameter', "RemoteAPIs syspref malformed so Koha::Exception::BadParameter");
    };

    t::lib::TestObjects::SystemPreferenceFactory->createTestGroup({
                        preference => 'RemoteAPIs',
                        value => "---\n".
                                 "Failing config:\n".
                                 "    host: raflamangara\n",
                });
    try {
        $remoteAPIs = Koha::RemoteAPIs->new();
        ok(0, "RemoteAPIs remote host invalid so Koha::Exception::BadParameter");
    } catch {
        die $_ unless(blessed($_) && $_->can('rethrow'));
        is(ref($_), 'Koha::Exception::BadParameter', "RemoteAPIs remote host invalid so Koha::Exception::BadParameter");
    };

    #############################################################
    #### RemoteAPIs defined ok ####
    t::CataloguingCenter::ContextSysprefs::createRemoteAPIs($testContext);

    $remoteAPIs = Koha::RemoteAPIs->new();
    is(ref($remoteAPIs), 'Koha::RemoteAPIs', "Koha::RemoteAPIs created");
    is(scalar(@{$remoteAPIs->remotes}), 2, "Two Remote APIs configured");
    is($remoteAPIs->remote('test_stub')->id, "test_stub", "'Test Stub's id is cast from name");
    is(ref($remoteAPIs->remote('test_stub')), "Koha::RemoteAPIs::Remote", "'Test Stub' is a Koha::RemoteAPIs::Remote");
    is(ref($remoteAPIs->remote('test_stub')->host), "Mojo::URL", "'Test Stub's Host is a Mojo::URL");
    is($remoteAPIs->remote('test_stub')->host->to_string, "http://test.example.com:80", "'Test Stub's Host has correct value");
    is(ref($remoteAPIs->remote('test_stub')->basePath), "Mojo::URL", "'Test Stub's Base paths is a Mojo::URL");
    is($remoteAPIs->remote('test_stub')->basePath->to_string, "apina", "'Test Stub's Base path has correct value");
    is($remoteAPIs->remote('test_stub')->authentication, "none", "'Test Stub' has no authentication");
    is($remoteAPIs->remote('test_stub')->api, "Koha-Suomi", "'Test Stub' api implementation is named 'Koha-Suomi'");

    #############################################################
    #### RemoteAPIs JSONified ####
    $expectedTestRemote = {
        name     => "Test Remote",
        id       => "test_remote",
        host     => "http://testcluster.koha-suomi.fi:80",
        basePath => "api/v1",
        authentication => "cookies",
        api      => "Koha-Suomi",
    };
    $json = $remoteAPIs->toJSON;
    $hash = JSON->new->decode($json);
    is_deeply($hash->{'test_remote'}, $expectedTestRemote, "'Test Remote' survivied JSONification");

    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}



t::lib::TestObjects::ObjectFactory->tearDownTestContext($globalTestContext);
done_testing();