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

use Test::More tests => 2;

use t::lib::TestBuilder;

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

subtest 'config_timestamp is updated when database configuration changes' => sub {

    plan tests => 3;

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    Koha::SIP2::Institutions->delete;
    Koha::SIP2::Accounts->delete;
    Koha::SIP2::Listeners->delete;
    Koha::SIP2::ServerParams->delete;
    Koha::SIP2::SystemPreferenceOverrides->delete;

    my $builder    = t::lib::TestBuilder->new();
    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
    my ( $response, $findpatron );
    my $seen_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $branchcode,
                password   => '123456',
            },
        }
    )->store();

    Koha::SIP2::Institutions->search()->delete;
    my $sip_institution = $builder->build_object(
        {
            class => 'Koha::SIP2::Institutions',
            value => {
                name           => 'CPL',
                implementation => 'ILS',
                retries        => 5,
                status_update  => 0,
                timeout        => 25,
            },
        }
    )->store();

    my $sip_account = $builder->build_object(
        {
            class => 'Koha::SIP2::Accounts',
            value => {
                login_id           => $seen_patron->userid,
                login_password     => '123456',
                sip_institution_id => $sip_institution->sip_institution_id,
                allow_fields       => '',
                hide_fields        => '',
            },
        }
    )->store();

    my $cfg = C4::SIP::Sip::Configuration->get_configuration();

    is(
        $cfg->{accounts}->{ $sip_account->login_id }->{allow_fields}, '',
        '$cfg->{accounts}->{$sip_account->login_id}->{allow_fields} is empty'
    );

    my $original_timestamp = Koha::SIP2::ServerParams->find( { key => 'config_timestamp' } );

    sleep 1;
    $sip_account->allow_fields('AB')->store();
    my $new_cfg = C4::SIP::Sip::Configuration->get_configuration();

    my $last_timestamp = Koha::SIP2::ServerParams->find( { key => 'config_timestamp' } );

    isnt(
        $original_timestamp->value, $last_timestamp->value,
        'config_timestamp should be updated when database configuration changes'
    );

    is(
        $cfg->{accounts}->{ $sip_account->login_id }->{allow_fields}, $sip_account->allow_fields,
        '$cfg->{accounts}->{$sip_account->login_id}->{allow_fields} should now return the new value'
    );

    $schema->storage->txn_rollback;
};
