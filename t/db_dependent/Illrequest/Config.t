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

use Koha::Database;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::Exception;

use Test::More tests => 5;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::Illrequest::Config');

my $base_limits = {
    branch => { CPL => { count => 1, method => 'annual' } },
    brw_cat => { A => { count => -1, method => 'active' } },
    default => { count => 10, method => 'annual' },
};

my $base_censorship = { censor_notes_staff => 1, censor_reply_date => 1 };

subtest 'Basics' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config("interlibrary_loans", {});

    my $config = Koha::Illrequest::Config->new;
    isa_ok($config, "Koha::Illrequest::Config",
           "Correctly create and load a config object.");

    # backend:
    is($config->backend, undef, "backend: Undefined backend is undefined.");
    is($config->backend("Mock"), "Mock", "backend: setter works.");
    is($config->backend, "Mock", "backend: setter is persistent.");

    # backend_dir:
    is($config->backend_dir, undef, "backend_dir: Undefined backend_dir is undefined.");
    is($config->backend_dir("/tmp/"), "/tmp/", "backend_dir: setter works.");
    is($config->backend_dir, "/tmp/", "backend_dir: setter is persistent.");

    # partner_code:
    is($config->partner_code, "IL", "partner_code: Undefined partner_code is undefined.");
    is($config->partner_code("ILTST"), "ILTST", "partner_code: setter works.");
    is($config->partner_code, "ILTST", "partner_code: setter is persistent.");

    # limits:
    is_deeply($config->limits, {}, "limits: Undefined limits is empty hash.");
    is_deeply($config->limits($base_limits), $base_limits, "limits: setter works.");
    is_deeply($config->limits, $base_limits, "limits: setter is persistent.");

    # censorship:
    is_deeply($config->censorship, { censor_notes_staff => 0, censor_reply_date => 0 },
              "censorship: Undefined censorship is default values.");
    is_deeply($config->censorship($base_censorship), $base_censorship, "censorship: setter works.");
    is_deeply($config->censorship, $base_censorship, "censorship: setter is persistent.");

    # getLimitRules
    dies_ok( sub { $config->getLimitRules("FOO") }, "getLimitRules: die if not correct type.");
    is_deeply($config->getLimitRules("brw_cat"), {
        A => { count => -1, method => 'active' },
        default => { count => 10, method => 'annual' },
    }, "getLimitRules: fetch brw_cat limits.");
    is_deeply($config->getLimitRules("branch"), {
        CPL => { count => 1, method => 'annual' },
        default => { count => 10, method => 'annual' },
    }, "getLimitRules: fetch brw_cat limits.");

    $schema->storage->txn_rollback;
};

# _load_unit_config:

subtest '_load_unit_config' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $config = Koha::Illrequest::Config->new;

    dies_ok(
        sub { Koha::Illrequest::Config::_load_unit_config({
            id => 'durineadu', type => 'baz'
        }) },
        "_load_unit_config: die if ID is not default, and type is not branch or brw_cat."
    );
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => {}, id => 'default', config => {}, test => 1
        }), {}, "_load_unit_config: invocation without id returns unmodified config."
    );

    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { api_key => 'foo', api_auth => 'bar' },
            id => "CPL", type => 'branch', config => {}
        }),
        { credentials => { api_keys => { CPL => { api_key => 'foo', api_auth => 'bar' } } } },
        "_load_unit_config: add auth values."
    );

    # Populate request_limits
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { request_limit => [ 'heelo', 1234 ] },
            id => "CPL", type => 'branch', config => {}
        }), {}, "_load_unit_config: invalid request_limit structure."
    );
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { request_limit => { method => 'eudiren', count => '-5465' } },
            id => "CPL", type => 'branch', config => {}
        }), {}, "_load_unit_config: invalid method & count."
    );
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { request_limit => { method => 'annual', count => 6 } },
            id => "default", config => {}
        }),
        { limits => { default => { method => 'annual', count => 6 } } },
        "_load_unit_config: correct default request_limits."
    );

    # Populate prefix
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { prefix => 'Foo-ill' },
            id => "default", config => {}
        }),
        { prefixes => { default => 'Foo-ill' } },
        "_load_unit_config: correct default prefix."
    );
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { prefix => 'Foo-ill' },
            id => "A", config => {}, type => 'brw_cat'
        }),
        { prefixes => { brw_cat => { A => 'Foo-ill' } } },
        "_load_unit_config: correct brw_cat prefix."
    );

    # Populate digital_recipient
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { digital_recipient => 'borrower' },
            id => "default", config => {}
        }),
        { digital_recipients => { default => 'borrower' } },
        "_load_unit_config: correct default digital_recipient."
    );
    is_deeply(
        Koha::Illrequest::Config::_load_unit_config({
            unit => { digital_recipient => 'branch' },
            id => "A", config => {}, type => 'brw_cat'
        }),
        { digital_recipients => { brw_cat => { A => 'branch' } } },
        "_load_unit_config: correct brw_cat digital_recipient."
    );

    $schema->storage->txn_rollback;
};

# _load_configuration:

# We have already tested _load_unit_config, so we are reasonably confident
# that the per-branch, per-borrower_category & default sections parsing is
# good.
#
# Now we need to ensure that Arrays & Hashes are handled correctly, that
# censorship & ill partners are loaded correctly and that the backend
# directory is set correctly.

subtest '_load_configuration' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $config = Koha::Illrequest::Config->new;

    # Return basic configuration
    is_deeply(
        Koha::Illrequest::Config::_load_configuration({}, 0),
        {
            backend_directory  => undef,
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => {},
            digital_recipients => {},
            prefixes           => {},
            partner_code       => 'IL',
            raw_config         => {},
        },
        "load_configuration: return the base configuration."
    );

    # Return correct backend_dir
    is_deeply(
        Koha::Illrequest::Config::_load_configuration({ backend_directory => '/tmp/' }, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => {},
            digital_recipients => {},
            prefixes           => {},
            partner_code       => 'IL',
            raw_config         => { backend_directory => '/tmp/' },
        },
        "load_configuration: return the correct backend_dir."
    );

    # Map over branch configs
    my $xml_config = {
        backend_directory => '/tmp/',
        branch => [
            { code => '1', request_limit => { method => 'annual', count => 1 } },
            { code => '2', prefix => '2-prefix' },
            { code => '3', digital_recipient => 'branch' }
        ]
    };
    is_deeply(
        Koha::Illrequest::Config::_load_configuration($xml_config, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => { branch => { 1 => { method => 'annual', count => 1 } } },
            digital_recipients => { branch => { 3 => 'branch' } },
            prefixes           => { branch => { 2 => '2-prefix' } },
            partner_code       => 'IL',
            raw_config         => $xml_config,
        },
        "load_configuration: multi branch config parsed correctly."
    );
    # Single branch config
    $xml_config = {
        backend_directory => '/tmp/',
        branch => {
            code => '1',
            request_limit => { method => 'annual', count => 1 },
            prefix => '2-prefix',
            digital_recipient => 'branch',
        }
    };
    is_deeply(
        Koha::Illrequest::Config::_load_configuration($xml_config, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => { branch => { 1 => { method => 'annual', count => 1 } } },
            digital_recipients => { branch => { 1 => 'branch' } },
            prefixes           => { branch => { 1 => '2-prefix' } },
            partner_code       => 'IL',
            raw_config         => $xml_config,
        },
        "load_configuration: single branch config parsed correctly."
    );

    # Map over borrower_category settings
    $xml_config = {
        backend_directory => '/tmp/',
        borrower_category => [
            { code => 'A', request_limit => { method => 'annual', count => 1 } },
            { code => 'B', prefix => '2-prefix' },
            { code => 'C', digital_recipient => 'branch' }
        ]
    };
    is_deeply(
        Koha::Illrequest::Config::_load_configuration($xml_config, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => { brw_cat => { A => { method => 'annual', count => 1 } } },
            digital_recipients => { brw_cat => { C => 'branch' } },
            prefixes           => { brw_cat => { B => '2-prefix' } },
            partner_code       => 'IL',
            raw_config         => $xml_config,
        },
        "load_configuration: multi borrower_category config parsed correctly."
    );
    # Single borrower_category config
    $xml_config = {
        backend_directory => '/tmp/',
        borrower_category => {
            code => '1',
            request_limit => { method => 'annual', count => 1 },
            prefix => '2-prefix',
            digital_recipient => 'branch',
        }
    };
    is_deeply(
        Koha::Illrequest::Config::_load_configuration($xml_config, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => { brw_cat => { 1 => { method => 'annual', count => 1 } } },
            digital_recipients => { brw_cat => { 1 => 'branch' } },
            prefixes           => { brw_cat => { 1 => '2-prefix' } },
            partner_code       => 'IL',
            raw_config         => $xml_config,
        },
        "load_configuration: single borrower_category config parsed correctly."
    );

    # Default Configuration
    $xml_config = {
        backend_directory => '/tmp/',
        request_limit => { method => 'annual', count => 1 },
        prefix => '2-prefix',
        digital_recipient => 'branch',
    };
    is_deeply(
        Koha::Illrequest::Config::_load_configuration($xml_config, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => { default => { method => 'annual', count => 1 } },
            digital_recipients => { default => 'branch' },
            prefixes           => { default => '2-prefix' },
            partner_code       => 'IL',
            raw_config         => $xml_config,
        },
        "load_configuration: parse the default configuration."
    );

    # Censorship
    $xml_config = {
        backend_directory => '/tmp/',
        staff_request_comments => 'hide',
        reply_date => 'hide'
    };
    is_deeply(
        Koha::Illrequest::Config::_load_configuration($xml_config, 0),
        {
            backend_directory  => '/tmp/',
            censorship         => {
                censor_notes_staff => 1,
                censor_reply_date => 1,
            },
            limits             => {},
            digital_recipients => {},
            prefixes           => {},
            partner_code       => 'IL',
            raw_config         => $xml_config,
        },
        "load_configuration: parse censorship settings configuration."
    );

    # Partner library category
    is_deeply(
        Koha::Illrequest::Config::_load_configuration({ partner_code => 'FOOBAR' }),
        {
            backend_directory  => undef,
            censorship         => {
                censor_notes_staff => 0,
                censor_reply_date => 0,
            },
            limits             => {},
            digital_recipients => {},
            prefixes           => {},
            partner_code       => 'FOOBAR',
            raw_config         => { partner_code => 'FOOBAR' },
        },
        "load_configuration: Set partner code."
    );

    $schema->storage->txn_rollback;
};


subtest 'Final tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config("interlibrary_loans", {});

    my $config = Koha::Illrequest::Config->new;

    # getPrefixes (error & undef):
    is($config->getPrefixes(), undef,
              "getPrefixes: Undefined branch prefix is undefined.");

    is($config->has_branch(), undef, "Config does not have branch when no config loaded");

    # getDigitalRecipients (error & undef):
    dies_ok( sub { $config->getDigitalRecipients("FOO") },
             "getDigitalRecipients: die if not correct type.");
    is_deeply($config->getDigitalRecipients("brw_cat"), { default => undef},
              "getDigitalRecipients: Undefined brw_cat dig rec is undefined.");
    is_deeply($config->getDigitalRecipients("branch"), { default => undef},
              "getDigitalRecipients: Undefined branch dig rec is undefined.");

    $config->{configuration} = Koha::Illrequest::Config::_load_configuration({
            backend_directory => '/tmp/',
            prefix => 'DEFAULT-prefix',
            digital_recipient => 'branch',
            borrower_category => [
                { code => 'B', prefix => '2-prefix' },
                { code => 'C', digital_recipient => 'branch' }
            ],
            branch => [
                { code => '1', prefix => 'T-prefix' },
                { code => '2', digital_recipient => 'borrower' }
            ]
        }, 0
    );

    # getPrefixes (values):
    is_deeply($config->getPrefixes(),
              { '1' => 'T-prefix' },
              "getPrefixes: return configuration branch prefixes.");

    # getDigitalRecipients (values):
    is_deeply($config->getDigitalRecipients("brw_cat"),
              { C => 'branch', default => 'branch' },
              "getDigitalRecipients: return brw_cat digital_recipients.");
    is_deeply($config->getDigitalRecipients("branch"),
              { 2 => 'borrower', default => 'branch' },
              "getDigitalRecipients: return branch digital_recipients.");

    # has_branch test
    ok($config->has_branch(), "has_branch returns true if branch defined in configuration");

    $schema->storage->txn_rollback;
};


1;
