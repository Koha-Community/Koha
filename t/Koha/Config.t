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

use Test::More tests => 4;
use FindBin qw($Bin $Script);

use_ok('Koha::Config');

my $config_filepath = "$Bin/../data/koha-conf.xml";

subtest 'read_from_file() tests' => sub {
    plan tests => 3;

    is( Koha::Config->read_from_file(undef), undef,
        "Undef parameter makes function return undef");

    my $got = eval { Koha::Config->read_from_file($config_filepath) };
    my $expected = {
        'listen' => {
            'biblioserver' => {
                'content' => 'unix:/home/koha/var/run/zebradb/bibliosocket',
            },
            'authorityserver' => {
                'content' => 'unix:/home/koha/var/run/zebradb/authoritysocket',
            },
        },
        'server' => {
            'biblioserver' => {
                'listenref' => 'biblioserver',
                'directory' => '/home/koha/var/lib/zebradb/biblios',
                'config' => '/home/koha/etc/zebradb/zebra-biblios-dom.cfg',
                'cql2rpn' => '/home/koha/etc/zebradb/pqf.properties',
                'xi:include' => [
                    {
                        'href' => '/home/koha/etc/zebradb/retrieval-info-bib-dom.xml',
                        'xmlns:xi' => 'http://www.w3.org/2001/XInclude'
                    },
                    {
                        'xmlns:xi' => 'http://www.w3.org/2001/XInclude',
                        'href' => '/home/koha/etc/zebradb/explain-biblios.xml'
                    }
                ],
            },
            'authorityserver' => {
                'listenref' => 'authorityserver',
                'directory' => '/home/koha/var/lib/zebradb/authorities',
                'config' => '/home/koha/etc/zebradb/zebra-authorities-dom.cfg',
                'cql2rpn' => '/home/koha/etc/zebradb/pqf.properties',
                'xi:include' => [
                    {
                        'xmlns:xi' => 'http://www.w3.org/2001/XInclude',
                        'href' => '/home/koha/etc/zebradb/retrieval-info-auth-dom.xml'
                    },
                    {
                        'href' => '/home/koha/etc/zebradb/explain-authorities.xml',
                        'xmlns:xi' => 'http://www.w3.org/2001/XInclude'
                    }
                ],
            },
        },
        'serverinfo' => {
            'biblioserver' => {
                'ccl2rpn' => '/home/koha/etc/zebradb/ccl.properties',
                'user' => 'kohauser',
                'password' => 'zebrastripes',
            },
            'authorityserver' => {
                'ccl2rpn' => '/home/koha/etc/zebradb/ccl.properties',
                'user' => 'kohauser',
                'password' => 'zebrastripes',
            }
        },
        'config' => {
            'db_scheme' => 'mysql',
            'database' => 'koha',
            'hostname' => 'localhost',
            'port' => '3306',
            'user' => 'kohaadmin',
            'pass' => 'katikoan',
            'tls' => 'no',
            'ca' => '',
            'cert' => '',
            'key' => '',
            'biblioserver' => 'biblios',
            'biblioservershadow' => '1',
            'authorityserver' => 'authorities',
            'authorityservershadow' => '1',
            'pluginsdir' => '/home/koha/var/lib/plugins',
            'enable_plugins' => '0',
            'upload_path' => '',
            'tmp_path' => '',
            'intranetdir' => '/home/koha/src',
            'opacdir' => '/home/koha/src/opac',
            'opachtdocs' => '/home/koha/src/koha-tmpl/opac-tmpl',
            'intrahtdocs' => '/home/koha/src/koha-tmpl/intranet-tmpl',
            'includes' => '/home/koha/src/koha-tmpl/intranet-tmpl/prog/en/includes/',
            'logdir' => '/home/koha/var/log',
            'docdir' => '/home/koha/doc',
            'backupdir' => '/home/koha/var/spool',
            'mana_config' => 'https://mana-kb.koha-community.org',
            'backup_db_via_tools' => '0',
            'backup_conf_via_tools' => '0',
            'install_log' => '/home/koha/misc/koha-install-log',
            'useldapserver' => '1',
            'ldapserver' => {
                ldapserver => {
                    hostname => 'ldap://another_ldap_server:389',
                    user     => 'user',
                    pass     => 'password',
                    mapping  => {
                        firstname => {
                            is => 'givenName'
                        }
                    }
                }
            },
            'useshibboleth' => '0',
            'zebra_lockdir' => '/home/koha/var/lock/zebradb',
            'lockdir' => '__LOCK_DIR__',
            'use_zebra_facets' => '1',
            'zebra_max_record_size' => '1024',
            'log4perl_conf' => '/home/koha/etc/log4perl.conf',
            'memcached_servers' => '127.0.0.1:11211',
            'memcached_namespace' => 'KOHA',
            'template_cache_dir' => '/tmp/koha',
            'api_secret_passphrase' => 'CHANGEME',
            'access_dirs' => {
                access_dir => [ '/dir_1', '/dir_2' ],
            },
            'ttf' => {
                'font' => [
                    {
                        'type' => 'TR',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf',
                    },
                    {
                        'type' => 'TB',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf',
                    },
                    {
                        'type' => 'TI',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSerif-Italic.ttf',
                    },
                    {
                        'type' => 'TBI',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSerif-BoldItalic.ttf',
                    },
                    {
                        'type' => 'C',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
                    },
                    {
                        'type' => 'CB',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf',
                    },
                    {
                        'type' => 'CO',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Oblique.ttf',
                    },
                    {
                        'type' => 'CBO',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-BoldOblique.ttf',
                    },
                    {
                        'type' => 'H',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
                    },
                    {
                        'type' => 'HO',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf',
                    },
                    {
                        'type' => 'HB',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
                    },
                    {
                        'type' => 'HBO',
                        'content' => '/usr/share/fonts/truetype/dejavu/DejaVuSans-BoldOblique.ttf',
                    },
                ],
            },
            'sms_send_config' => '/home/koha/etc/sms_send/',
            'plack_max_requests' => '50',
            'plack_workers' => '2',
            'elasticsearch' => {
                'server' => [
                    'localhost:9200',
                ],
                'index_name' => 'koha_master',
                'cxn_pool' => 'Static',
            },
            'interlibrary_loans' => {
                'backend_directory' => '/home/koha/src/Koha/Illbackends',
                'branch' => {
                    'code' => 'CPL',
                    'prefix' => 'ILL',
                },
                'staff_request_comments' => 'hide',
                'reply_date' => 'hide',
                'digital_recipient' => 'branch',
            },
            'timezone' => '',
            'bcrypt_settings' => '__BCRYPT_SETTINGS__',
            'encryption_key' => '__ENCRYPTION_KEY__',
            'dev_install' => '0',
            'strict_sql_modes' => '0',
            'plugin_repos' => '',
            'koha_xslt_security' => '',
            'smtp_server' => {
                'host' => 'localhost',
                'port' => '25',
                'timeout' => '120',
                'ssl_mode' => 'disabled',
                'user_name' => '',
                'password' => '',
                'debug' => '0',
            },
            'message_broker' => {
                'hostname' => 'localhost',
                'port' => '61613',
                'username' => 'guest',
                'password' => 'guest',
                'vhost' => '',
            },
        },
    };
    is_deeply( $got, $expected, 'File read correctly' );

    # Reading a Perl script as XML should fail hopefully
    eval { Koha::Config->read_from_file("$Bin/$Script") };
    like( $@, qr{.*Error reading file.*}, 'File failing to read raises warning');
};

subtest 'get_instance' => sub {
    plan tests => 3;

    my $config = Koha::Config->get_instance($config_filepath);
    isa_ok($config, 'Koha::Config', 'get_instance returns a Koha::Config object');
    my $same_config = Koha::Config->get_instance($config_filepath);
    is($config, $same_config, '2nd call to get_instance returns the same object');

    local $ENV{KOHA_CONF} = $config_filepath;
    my $default_config = Koha::Config->get_instance;
    is($default_config, $config, 'get_instance without parameters reads $KOHA_CONF');
};

subtest 'get' => sub {
    plan tests => 7;

    my $config = Koha::Config->get_instance($config_filepath);

    is_deeply(
        $config->get('biblioserver', 'listen'),
        { content => 'unix:/home/koha/var/run/zebradb/bibliosocket' },
    );

    is_deeply(
        $config->get('biblioserver', 'server'),
        {
            'listenref' => 'biblioserver',
            'directory' => '/home/koha/var/lib/zebradb/biblios',
            'config' => '/home/koha/etc/zebradb/zebra-biblios-dom.cfg',
            'cql2rpn' => '/home/koha/etc/zebradb/pqf.properties',
            'xi:include' => [
                {
                    'href' => '/home/koha/etc/zebradb/retrieval-info-bib-dom.xml',
                    'xmlns:xi' => 'http://www.w3.org/2001/XInclude'
                },
                {
                    'xmlns:xi' => 'http://www.w3.org/2001/XInclude',
                    'href' => '/home/koha/etc/zebradb/explain-biblios.xml'
                }
            ],
        },
    );

    is_deeply(
        $config->get('biblioserver', 'serverinfo'),
        {
            'ccl2rpn' => '/home/koha/etc/zebradb/ccl.properties',
            'user' => 'kohauser',
            'password' => 'zebrastripes',
        },
    );

    is($config->get('db_scheme'), 'mysql');
    is($config->get('ca'), '');

    is($config->get('unicorn'), undef, 'returns undef if key does not exist');
    is_deeply([$config->get('unicorn')], [undef], 'returns undef even in list context');
};
