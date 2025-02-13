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

use Test::More tests => 1;

use C4::Installer;
use C4::SIP::Sip::Configuration;
use XML::Simple;

use Koha::SIP2::Institutions;
use Koha::SIP2::Accounts;
use Koha::SIP2::Listeners;
use Koha::SIP2::ServerParams;
use Koha::SIP2::SystemPreferenceOverrides;

subtest 'Config from XML matches config from database' => sub {

    plan tests => 4;

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    Koha::SIP2::Institutions->delete;
    Koha::SIP2::Accounts->delete;
    Koha::SIP2::Listeners->delete;
    Koha::SIP2::ServerParams->delete;
    Koha::SIP2::SystemPreferenceOverrides->delete;

    my $koha_instance    = $ENV{KOHA_CONF} =~ m!^.+/sites/([^/]+)/koha-conf\.xml$! ? $1 : undef;
    my $SIPconfigXMLFile = "/etc/koha/sites/$koha_instance/SIPconfig.xml";
    my $fileSIPconfig    = C4::SIP::Sip::Configuration->new($SIPconfigXMLFile);

    is( scalar( keys %{ $fileSIPconfig->{accounts} } ), 5, 'fileSIPconfig->{accounts} has 5 members' );
    is( Koha::SIP2::Accounts->search()->count,          0, 'Database does not yet contain any accounts' );

    run_atomic_updates( ['bug_37893.pl'] );    #TODO: Update this to the DBREV when pushed

    is( Koha::SIP2::Accounts->search()->count, 5, 'Database now contains 5 accounts' );

    my $databaseSIPconfig = C4::SIP::Sip::Configuration->new($SIPconfigXMLFile);

    # Remove 'parms' out of each institution. This is not used and was not migrated
    foreach my $key ( keys %{ $fileSIPconfig->{institutions} } ) {
        delete $fileSIPconfig->{institutions}->{$key}{'parms'};
    }

    # Remove 'register_id' out of each account if it's empty. This can no longer be returned as an empty string as is now an FK constraint
    foreach my $key ( keys %{ $fileSIPconfig->{accounts} } ) {
        if ( defined $fileSIPconfig->{accounts}->{$key}{'register_id'}
            && $fileSIPconfig->{accounts}->{$key}{'register_id'} eq "" )
        {
            delete $fileSIPconfig->{accounts}->{$key}{'register_id'};
        }
    }

    #Test accounts
    is_deeply(
        $fileSIPconfig,
        $databaseSIPconfig,
        'config from XML file matches config from database'
    );

    $schema->storage->txn_rollback;
};
