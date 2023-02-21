# Copyright 2007 MJ Ray
# Copyright 2016 PTFS Europe
#
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
#
# Current maintainer MJR http://mjr.towers.org.uk/
#

use strict;
use warnings;
use ExtUtils::MakeMaker;
use POSIX;
use File::Spec;
use Getopt::Long qw/HelpMessage/;
use FindBin; # we need to enforce which C4::Installer::PerlModule is used in case more than one is installed

use lib $FindBin::Bin;

use C4::Installer::PerlModules;

my $koha_pm = C4::Installer::PerlModules->new;

my $DEBUG = 0;
die "perl 5.10 or later required" unless ($] >= 5.010000);

# Hash up directory structure & files beginning with the directory we were called from (should be the base of koha)...

my $dirtree = hashdir('.');
my %result = ();

=head1 NAME

Makefile.PL - Koha packager and installer

=head1 SYNOPSIS

=head2 BASIC INSTALLATION

    perl Makefile.PL
    make
    make test
    sudo make install

=head2 UPGRADE INSTALLATION

    NOTE: This option is only available if koha-install-log exists.

    perl Makefile.PL --prev-install-log /path/to/koha-install-log

    make
    make test
    sudo make upgrade

=head2 PACKAGING RELEASE TARBALLS

    make manifest tardist
    make manifest zipdist

=head2 CLEANING UP

	make clean

=head2 CLI PARAMETERS

    --prev-install-log           Read configuration from previous installation
    --install_mode               Installation mode (dev, standard, single)
    --db_type                    Database (mysql, Pg)
    --db_host                    Database host (e.g. localhost)
    --db_port                    Database port (e.g. 3306)
    --db_name                    Database name (e.g. koha)
    --db_user                    Database user (e.g. kohaadmin)
    --db_pass                    Database password (e.g. katikoan)
    --zebra_marc_format          Zebra MARC format (marc21, unimarc)
    --zebra_language             Zebra language (e.g. en)
    --zebra_tokenizer            Zebra tokenizer (chr, icu)
    --zebra_user                 Zebra user (e.g. kohauser)
    --zebra_pass                 Zebra password (e.g. zebrastripes)
    --zebra_sru_host             Zebra SRU servername (e.g. localhost)
    --zebra_sru_biblios_port     Zebra SRU biblios port (e.g. 9998)
    --zebra_sru_authorities_port Zebra SRU biblios port (e.g. 9999)
    --koha_user                  Koha Unix user (e.g. koha)
    --koha_group                 Koha Unix group (e.g. koha)
    --install_sru                Install the SRU server (yes, no)
    --use_memcached              Use Memcached (yes, no)
    --font_dir                   Location of fonts (e.g. /usr/share/fonts/truetype/dejavu)
    --run_database_tests         Run database dependent tests (yes, no)
    --install_base               Base directory of installation (e.g. /usr/share/koha)
    --template-cache-dir         Specify a template cache directory (e.g. /var/cache/koha)
    --help                       Display this help message

=head1 DESCRIPTION

This is a packager and installer that uses
ExtUtils::MakeMaker, which is fairly common
on perl systems.
As well as building tar or zip files
and installing with the above commands,
it allows us to check pre-requisites
and generate configuration files.

=head1 VARIABLES

=head2 NAME, VERSION_FROM, ABSTRACT, AUTHOR

Basic metadata about this software.

=head2 NO_META

Suppress generation of META.yml file.

=head2 PREREQ_PM

Hash of perl modules and versions required.

=head2 PM

Hash of file mappings

=head2 PL_FILES

This is a hash of PL scripts to run after installation and
the files to ask them to generate.
Maybe use the values from CONFIGURE
to generate initial configuration files in future.

=cut

=head2 target_map

This is a hash mapping directories and files in the
source tree to installation target directories.  The rules
for this mapping are:

=over 4

=item If a directory or file is specified, it and its
contents will be copied to the installation target directory.

=item If a subdirectory of a mapped directory is specified,
its target overrides the parent's target for that subdirectory.

=item The value of each map entry may either be a scalar containing
one target or a reference to a hash containing 'target' and 'trimdir'
keys.

=item Any files at the top level of the source tree that are
not included in the map will not be installed.

=item Any directories at the top level of the source tree
that are not included in the map will be installed in
INTRANET_CGI_DIR.  This is a sensible default given the
current organization of the source tree, but (FIXME) it
would be better to reorganize the source tree to better
match the installation system, to allow adding new directories
without having to adjust Makefile.PL each time.  The idea
is to make the C<$target_map> hash as minimal as possible.

=back

The permitted installation targets are:

=over 4

=item INTRANET_CGI_DIR

CGI scripts for intranet (staff) interface.

=item INTRANET_TMPL_DIR

HTML templates for the intranet interface.

=item INTRANET_WWW_DIR

HTML files, images, etc. for DocumentRoot for the intranet interface.

=item OPAC_CGI_DIR

CGI scripts for OPAC (public) interface.

=item OPAC_TMPL_DIR

HTML templates for the OPAC interface.

=item OPAC_WWW_DIR

HTML files, images, etc. for DocumentRoot for the OPAC interface.

=item PERL_MODULE_DIR

Perl modules (at present just the C4 modules) that are intimately
tied to Koha.  Depending on the installation options, these
may or may not be installed one of the standard directories
in Perl's default @LIB.

=item KOHA_CONF_DIR

Directory for Koha configuration files.

=item ZEBRA_CONF_DIR

Directory for Zebra configuration files.

=item ZEBRA_LOCK_DIR

Directory for Zebra's lock files.  This includes subdirs for authorities,
biblios, and the zebra rebuild function.  Any activity to reindex
zebra from koha should interlock here with rebuild_zebra.pl.

=item ZEBRA_DATA_DIR

Directory for Zebra's data files.

=item ZEBRA_RUN_DIR

Directory for Zebra's UNIX-domain sockets.

=item ELASTICSEARCH_SERVERS

Server:port of the Elasticsearch server to use, as a comma separated list:
eg. 192.168.0.100:9200, localhost:9200

=item ELASTICSEARCH_INDEX

Unique index in Elasticsearch, for this Koha-instance
eg. koha-mykoha  or just  koha

=item MISC_DIR

Directory for for miscellaenous scripts, among other
things the translation toolkit and RSS feed tools.

=item SCRIPT_DIR

Directory for command-line scripts and daemons to
be set up all for installation modes.

=item SCRIPT_NONDEV_DIR

Directory for command-line scripts that should
be installed in the same directory as the
SCRIPT_DIR target except 'dev' installs.

=item MAN_DIR

Directory for man pages created from POD -- will mostly
contain information of interest to Koha developers.

=item DOC_DIR

Directory for Koha documentation accessed from the
command-line, e.g., READMEs.

=item LOCK_DIR

Directory for Koha scripts to put their locks.

=item LOG_DIR

Directory for Apache and Zebra logs produced by Koha.

=item BACKUP_DIR

Directory for backup files produced by Koha.

=item PLUGINS_DIR

Directory for external Koha plugins.

=item FONT_DIR

Directory where DejaVu fonts are installed.

=item NONE

This is a dummy target used to explicitly state
that a given file or directory is not to be installed.
This is used either for parts of the installer itself
or for development tools that are not applicable to a
production installation.

=back

=cut

my $target_map = {
  './about.pl'                  => 'INTRANET_CGI_DIR',
  './acqui'                     => 'INTRANET_CGI_DIR',
  './admin'                     => 'INTRANET_CGI_DIR',
  './api'                       => { target => 'API_CGI_DIR', trimdir => -1 },
  './app.psgi'                  => 'SCRIPT_DIR',
  './authorities'               => 'INTRANET_CGI_DIR',
  './basket'                    => 'INTRANET_CGI_DIR',
  './bin'                       => { target => 'SCRIPT_DIR', trimdir => -1 },
  './C4'                        => 'PERL_MODULE_DIR',
  './C4/SIP/t'                  => 'NONE',
  './C4/SIP/koha_test'          => 'NONE',
  './C4/tests'                  => 'NONE',
  './catalogue'                 => 'INTRANET_CGI_DIR',
  './cataloguing'               => 'INTRANET_CGI_DIR',
  './changelanguage.pl'         => 'INTRANET_CGI_DIR',
  './check_sysprefs.pl'         => 'NONE',
  './circ'                      => 'INTRANET_CGI_DIR',
  './clubs'                     => 'INTRANET_CGI_DIR',
  './course_reserves'           => 'INTRANET_CGI_DIR',
  './cpanfile'                  => 'PERL_MODULE_DIR',
  './docs/history.txt'          => { target => 'DOC_DIR', trimdir => -1 },
  './docs/contributors.yaml'    => { target => 'DOC_DIR', trimdir => -1 },
  './docs/teams.yaml'           => { target => 'DOC_DIR', trimdir => -1 },
  './offline_circ'              => 'INTRANET_CGI_DIR',
  './erm'                       => 'INTRANET_CGI_DIR',
  './etc'                       => { target => 'KOHA_CONF_DIR', trimdir => -1 },
  './etc/zebradb'               => { target => 'ZEBRA_CONF_DIR', trimdir => -1 },
  './etc/z3950'                 => { target => 'Z3950_CONF_DIR', trimdir => -1 },
  './help.pl'                   => 'INTRANET_CGI_DIR',
  './ill'                       => 'INTRANET_CGI_DIR',
  './installer-CPAN.pl'         => 'NONE',
  './installer'                 => 'INTRANET_CGI_DIR',
  './errors'                    => {target => 'INTRANET_CGI_DIR'},
  './Koha'                      => 'PERL_MODULE_DIR',
  './Koha.pm'                   => 'PERL_MODULE_DIR',
  './koha-tmpl/intranet-tmpl'   => {target => 'INTRANET_TMPL_DIR', trimdir => -1},
  './koha-tmpl/opac-tmpl'       => {target => 'OPAC_TMPL_DIR', trimdir => -1},
  './kohaversion.pl'            => 'INTRANET_CGI_DIR',
  './labels'                    => 'INTRANET_CGI_DIR',
  './lib'                       => {target => 'PERL_MODULE_LIB_DIR', trimdir => -1},
  './mainpage.pl'               => 'INTRANET_CGI_DIR',
  './Makefile.PL'               => 'NONE',
  './MANIFEST.SKIP'             => 'NONE',
  './members'                   => 'INTRANET_CGI_DIR',
  './misc'                      => { target => 'SCRIPT_NONDEV_DIR', trimdir => -1 },
  './misc/bin'                  => { target => 'SCRIPT_DIR', trimdir => -1 },
  './misc/release_notes'        => { target => 'DOC_DIR', trimdir => 2 },
  './misc/translator'           => { target => 'MISC_DIR', trimdir => 2 },
  './misc/koha-install-log'     => { target => 'MISC_DIR', trimdir => -1 },
  './misc/installer_devel_notes' => 'NONE',
  './opac'                      => 'OPAC_CGI_DIR',
  './OpenILS'                   => 'PERL_MODULE_DIR',
  './README.txt'                => 'NONE',
  './patroncards'               => 'INTRANET_CGI_DIR',
  './patron_lists'              => 'INTRANET_CGI_DIR',
  './plugins'                   => 'INTRANET_CGI_DIR',
  './pos'                       => 'INTRANET_CGI_DIR',
  './recalls'                   => 'INTRANET_CGI_DIR',
  './reports'                   => 'INTRANET_CGI_DIR',
  './reserve'                   => 'INTRANET_CGI_DIR',
  './reviews'                   => 'INTRANET_CGI_DIR',
  './rewrite-config.PL'         => 'NONE',
  './reviews'                   => 'INTRANET_CGI_DIR',
  './rotating_collections'      => 'INTRANET_CGI_DIR',
  './serials'                   => 'INTRANET_CGI_DIR',
  './services'                  => 'INTRANET_CGI_DIR',
  './skel'                      => 'NONE',
  './skel/var/lock/koha'        => { target => 'LOCK_DIR', trimdir => -1 },
  './skel/var/log/koha'         => { target => 'LOG_DIR', trimdir => -1 },
  './skel/var/spool/koha'       => { target => 'BACKUP_DIR', trimdir => -1 },
  './skel/var/run/koha/zebradb' => { target => 'ZEBRA_RUN_DIR', trimdir => -1 },
  './skel/var/lock/koha/zebradb/authorities' => { target => 'ZEBRA_LOCK_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/authorities/key'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/authorities/register'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/authorities/shadow'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/authorities/tmp'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lock/koha/zebradb/biblios' => { target => 'ZEBRA_LOCK_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/biblios/key'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/biblios/register'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/biblios/shadow'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lib/koha/zebradb/biblios/tmp'  => { target => 'ZEBRA_DATA_DIR', trimdir => 6 },
  './skel/var/lock/koha/zebradb/rebuild' => { target => 'ZEBRA_LOCK_DIR', trimdir => 6 },
  './skel/var/lib/koha/plugins' => { target => 'PLUGINS_DIR', trimdir => 6 },
  './sms'                       => 'INTRANET_CGI_DIR',
  './suggestion'                => 'INTRANET_CGI_DIR',
  './svc'                       => 'INTRANET_CGI_DIR',
  './t'                         => 'NONE',
  './xt'                        => 'NONE',
  './tags'                      => 'INTRANET_CGI_DIR',
  './tmp'                       => 'NONE', # FIXME need to determine whether
                                           # Koha generates any persistent temp files
                                           # that should go in /var/tmp/koha
  './tools'                     => 'INTRANET_CGI_DIR',
  './virtualshelves'            => 'INTRANET_CGI_DIR',
  # ignore files and directories created by the install itself
  './pm_to_blib'                => 'NONE',
  './blib'                      => 'NONE',
  '.sass-lint.yml'              => 'NONE',
  '.scss-lint.yml'              => 'NONE',
  '.eslintrc.json'              => 'NONE',
  'gulpfile.js'                 => 'NONE',
  'package.json'                => 'NONE',
  'yarn.lock'                   => 'NONE',
  'cypress.json'                => 'NONE',
  'tsconfig.json'               => 'NONE',
  'webpack.config.js'           => 'NONE',
};

=head1 CONFIGURATION OPTIONS

The following configuration options are used by the installer.

=over 4

=item INSTALL_MODE

Specifies whether installation will be FHS-compliant (default,
assumes user has root), put everything under
a single directory (for users installing on a web host
that allows CGI scripts and a MySQL database but not root
access), or development (for a developer who wants to run
Koha from a git clone with no fuss).

=item INSTALL_BASE

Directory under which most components will go.  Default
value will vary depending on INSTALL_MODE.

=item DB_TYPE

Type of DBMS (e.g., mysql or Pg).

=item DB_HOST

Name of DBMS server.

=item DB_PORT

Port that DBMS server is listening on.

=item DB_NAME

Name of the DBMS database for Koha.

=item DB_USER

Name of DBMS user account for Koha's database.

=item DB_PASS

Pasword of DMBS user account for Koha's database.

=item ZEBRA_MARC_FORMAT

Specifies format of MARC records to be indexed by Zebra.

=item ZEBRA_LANGUAGE

Specifies primary language of records that will be
indexed by Zebra.

=item ZEBRA_USER

Internal Zebra user account for the index.

=item ZEBRA_PASS

Internal Zebra user account's password.

=item KOHA_USER

System user account that will own Koha's files.

=item KOHA_GROUP

System group that will own Koha's files.

=item SMTP_HOST

SMTP server host name (default: localhost)

=item SMTP_PORT

SMTP server port (default: 25)

=item SMTP_TIMEOUT

Connection timeour in seconds (default: 120)

=item SMTP_SSL_MODE

SSL mode. Options are 'disabled' (default), 'ssl' and 'starttls'

=item SMTP_USER_NAME

SMTP authentication user name

=item SMTP_PASSWORD

SMTP authentication password

=item SMTP_DEBUG

Enable debug mode for SMTP (default: no)

=back

=cut

# default configuration options
my %config_defaults = (
  'DB_TYPE'           => 'mysql',
  'DB_HOST'           => 'localhost',
  'DB_NAME'           => 'koha',
  'DB_USER'           => 'kohaadmin',
  'DB_PASS'           => 'katikoan',
  'DB_USE_TLS'	      => 'no',
  'DB_TLS_CA_CERTIFICATE'  => '/etc/mysql-ssl/server-ca.pem',
  'DB_TLS_CLIENT_CERTIFICATE'  => '/etc/mysql-ssl/client-cert.pem',
  'DB_TLS_CLIENT_KEY' => '/etc/mysql-ssl/client-key.pem',
  'INSTALL_SRU'       => 'yes',
  'ZEBRA_MARC_FORMAT' => 'marc21',
  'ZEBRA_LANGUAGE'    => 'en',
  'ZEBRA_TOKENIZER'   => 'chr',
  'ZEBRA_USER'        => 'kohauser',
  'ZEBRA_PASS'        => 'zebrastripes',
  'ZEBRA_SRU_HOST'    => 'localhost',
  'ZEBRA_SRU_BIBLIOS_PORT'    => '9998',
  'ZEBRA_SRU_AUTHORITIES_PORT'    => '9999',
  'KOHA_USER'         => 'koha',
  'KOHA_GROUP'        => 'koha',
  'MERGE_SERVER_HOST' => 'localhost',
  'MERGE_SERVER_PORT' => '11001',
  'RUN_DATABASE_TESTS' => 'no',
  'PATH_TO_ZEBRA' => '',
  'USE_MEMCACHED'     => 'yes',
  'MEMCACHED_SERVERS' => '127.0.0.1:11211',
  'MEMCACHED_NAMESPACE' => 'KOHA',
  'TEMPLATE_CACHE_DIR' => '/tmp/koha',
  'USE_ELASTICSEARCH'     => 'no',
  'ELASTICSEARCH_SERVERS' => 'localhost:9200',
  'ELASTICSEARCH_INDEX'  => 'koha',
  'FONT_DIR'          => '/usr/share/fonts/truetype/dejavu',
  'SMTP_HOST'      => 'localhost',
  'SMTP_PORT'      => '25',
  'SMTP_TIMEOUT'   => '120',
  'SMTP_SSL_MODE'  => 'disabled',
  'SMTP_USER_NAME' => '',
  'SMTP_PASSWORD'  => '',
  'SMTP_DEBUG'     => 'no',
);

# set some default configuration options based on OS
# more conditions need to be added for other OS's

warn "Your platform appears to be $^O.\n" if $DEBUG;

if ( $^O eq 'cygwin' ) {
	# Most Unix2Win32 ports seem to poke everything into the Program Files directory
	# this could be changed to put some files (ie. libraries) into system32, etc.
	$config_defaults{'INSTALL_MODE'} = 'single';
	$config_defaults{'INSTALL_BASE'} = 'c:/progra~1/koha';	# Use 8.3 names to be safe...
}
else {
	$config_defaults{'INSTALL_MODE'} = 'standard';
	$config_defaults{'INSTALL_BASE'} = '/usr/share/koha';
}

# valid values for certain configuration options
my %valid_config_values = (
  'INSTALL_MODE'  => { 'standard' => 1, 'single' => 1, 'dev' => 1 },
  'DB_TYPE' => { 'mysql' => 1, 'Pg' => 1 },
  'DB_USE_TLS' => {'yes', 'no'},
  'INSTALL_SRU' => { 'yes' => 1, 'no' => 1 },
  'ZEBRA_MARC_FORMAT' => { 'marc21' => 1, 'unimarc' => 1 }, # FIXME should generate from contents of distributation
  'ZEBRA_LANGUAGE'    => { 'cs' => 1, 'el' => 1, 'en' => 1, 'es' => 1, 'fr' => 1, 'nb' => 1, 'ru' => 1, 'uk' => 1 }, # FIXME should generate from contents of distribution
  'ZEBRA_TOKENIZER' => { chr => 1, icu => 1 },
  'RUN_DATABASE_TESTS' => { 'yes' => 1, 'no' => 1 },
  'USE_MEMCACHED'      => { 'yes' => 1, 'no' => 1 },
  'USE_ELASTICSEARCH'  => { 'yes' => 1, 'no' => 1 },
  'SMTP_SSL_MODE'      => { 'disabled' => 1, 'ssl' => 1, 'starttls' => 1 },
  'SMTP_DEBUG'         => { 'yes' => 1, 'no' => 1 },
);

# get settings from command-line
my $koha_install_log = "";
my $cli_koha_install_mode = "";
my $cli_koha_db_type = "";
my $cli_koha_db_host = "";
my $cli_koha_db_port = "";
my $cli_koha_db_name = "";
my $cli_koha_db_user = "";
my $cli_koha_db_pass = "";
my $cli_zebra_marc_format = "";
my $cli_zebra_language = "",
my $cli_zebra_tokenizer = "";
my $cli_zebra_user = "";
my $cli_zebra_pass = "";
my $cli_zebra_sru_host = "";
my $cli_zebra_sru_bib_port = "";
my $cli_zebra_sru_auth_port = "";
my $cli_koha_user = "";
my $cli_koha_group = "";
my $cli_koha_install_sru = "";
my $cli_koha_use_memcached = "";
my $cli_koha_font_dir = "";
my $cli_koha_run_database_tests = "";
my $cli_koha_install_base = "";
my $cli_koha_template_cache_dir = "";
my $cli_smtp_host      = "";
my $cli_smtp_port      = "";
my $cli_smtp_timeout   = "";
my $cli_smtp_ssl_mode  = "";
my $cli_smtp_user_name = "";
my $cli_smtp_password  = "";
my $cli_smtp_debug     = "";

Getopt::Long::Configure('pass_through');
my $results = GetOptions(
    "prev-install-log=s"           => \$koha_install_log,
    "install_mode=s"               => \$cli_koha_install_mode,
    "db_type=s"                    => \$cli_koha_db_type,
    "db_host=s"                    => \$cli_koha_db_host,
    "db_port=s"                    => \$cli_koha_db_port,
    "db_name=s"                    => \$cli_koha_db_name,
    "db_user=s"                    => \$cli_koha_db_user,
    "db_pass=s"                    => \$cli_koha_db_pass,
    "zebra_marc_format=s"          => \$cli_zebra_marc_format,
    "zebra_language=s"             => \$cli_zebra_language,
    "zebra_tokenizer=s"            => \$cli_zebra_tokenizer,
    "zebra_user=s"                 => \$cli_zebra_user,
    "zebra_pass=s"                 => \$cli_zebra_pass,
    "zebra_sru_host=s"             => \$cli_zebra_sru_host,
    "zebra_sru_biblios_port=s"     => \$cli_zebra_sru_bib_port,
    "zebra_sru_authorities_port=s" => \$cli_zebra_sru_auth_port,
    "koha_user=s"                  => \$cli_koha_user,
    "koha_group=s"                 => \$cli_koha_group,
    "install_sru=s"                => \$cli_koha_install_sru,
    "use_memcached=s"              => \$cli_koha_use_memcached,
    "font_dir=s"                   => \$cli_koha_font_dir,
    "run_database_tests=s"         => \$cli_koha_run_database_tests,
    "install_base=s"               => \$cli_koha_install_base,
    "template-cache-dir=s"         => \$cli_koha_template_cache_dir,
    "smtp-host=s"                  => \$cli_smtp_host,
    "smtp-port=s"                  => \$cli_smtp_port,
    "smtp-timeout=s"               => \$cli_smtp_timeout,
    "smtp-ssl-mode=s"              => \$cli_smtp_ssl_mode,
    "smtp-user-name=s"             => \$cli_smtp_user_name,
    "smtp-password=s"              => \$cli_smtp_password,
    "smtp-debug"                   => \$cli_smtp_debug,
    "help"                         => sub { HelpMessage(0) },
) or HelpMessage(1);

my %install_log_values = ();
if ($koha_install_log ne "") {
    get_install_log_values($koha_install_log, \%install_log_values);
} else {
    # Try to set install_log_values for provided values;
    get_cli_values(\%install_log_values);
}

my %config = get_configuration(\%config_defaults, \%valid_config_values, \%install_log_values);
my ($target_directories, $skip_directories) = get_target_directories(\%config);
display_configuration(\%config, $target_directories);
my $file_map = {};
get_file_map($target_map, $dirtree, $file_map);

#NOTE: List files generated by build-resources.PL, so that they're copied into blib for installation
#INTRANET_TMPL_DIR
$file_map->{'koha-tmpl/intranet-tmpl/prog/css/calendar.css'} = 'blib/INTRANET_TMPL_DIR/prog/css/calendar.css';
$file_map->{'koha-tmpl/intranet-tmpl/prog/css/holds.css'} = 'blib/INTRANET_TMPL_DIR/prog/css/holds.css';
$file_map->{'koha-tmpl/intranet-tmpl/prog/css/installer.css'} = 'blib/INTRANET_TMPL_DIR/prog/css/installer.css';
$file_map->{'koha-tmpl/intranet-tmpl/prog/css/mainpage.css'} = 'blib/INTRANET_TMPL_DIR/prog/css/mainpage.css';
$file_map->{'koha-tmpl/intranet-tmpl/prog/css/staff-global.css'} = 'blib/INTRANET_TMPL_DIR/prog/css/staff-global.css';
$file_map->{'koha-tmpl/intranet-tmpl/prog/js/vue/dist/main.js'} = 'blib/INTRANET_TMPL_DIR/prog/js/vue/dist/main.js';
$file_map->{'koha-tmpl/intranet-tmpl/prog/js/vue/dist/main.js.LICENSE.txt'} = 'blib/INTRANET_TMPL_DIR/prog/js/vue/dist/main.js.LICENSE.txt';
#OPAC_TMPL_DIR
$file_map->{'koha-tmpl/opac-tmpl/bootstrap/css/opac.css'} = 'blib/OPAC_TMPL_DIR/bootstrap/css/opac.css';
$file_map->{'koha-tmpl/opac-tmpl/bootstrap/css/opac-rtl.css'} = 'blib/OPAC_TMPL_DIR/bootstrap/css/opac-rtl.css';
$file_map->{'koha-tmpl/opac-tmpl/bootstrap/css/print.css'} = 'blib/OPAC_TMPL_DIR/bootstrap/css/print.css';
$file_map->{'koha-tmpl/opac-tmpl/bootstrap/css/print-rtl.css'} = 'blib/OPAC_TMPL_DIR/bootstrap/css/print-rtl.css';
$file_map->{'koha-tmpl/opac-tmpl/bootstrap/css/sco.css'} = 'blib/OPAC_TMPL_DIR/bootstrap/css/sco.css';
$file_map->{'koha-tmpl/opac-tmpl/bootstrap/css/sco-rtl.css'} = 'blib/OPAC_TMPL_DIR/bootstrap/css/sco-rtl.css';

my $pl_files = {
      'rewrite-config.PL' => [
         'blib/KOHA_CONF_DIR/koha-conf.xml',
         'blib/KOHA_CONF_DIR/koha-httpd.conf',
         'blib/KOHA_CONF_DIR/log4perl.conf',
         'blib/KOHA_CONF_DIR/koha-worker.service',
         'blib/ZEBRA_CONF_DIR/etc/default.idx',
         'blib/MISC_DIR/koha-install-log'
         ],
	  'fix-perl-path.PL' => [	# this script ensures the correct shebang line for the platform installed on...
		 'blib'
		 ],
};

push @{ $pl_files->{'rewrite-config.PL'} }, (
    'blib/ZEBRA_CONF_DIR/etc/passwd',
    'blib/ZEBRA_CONF_DIR/zebra-biblios-dom.cfg',
    'blib/ZEBRA_CONF_DIR/zebra-authorities-dom.cfg',
    'blib/ZEBRA_CONF_DIR/explain-authorities.xml',
    'blib/ZEBRA_CONF_DIR/explain-biblios.xml',
    'blib/ZEBRA_CONF_DIR/retrieval-info-auth-dom.xml',
    'blib/ZEBRA_CONF_DIR/retrieval-info-bib-dom.xml',
);
push @{ $pl_files->{'rewrite-config.PL'} }, (
    'blib/SCRIPT_DIR/koha-zebra-ctl.sh',
    'blib/SCRIPT_DIR/koha-index-daemon-ctl.sh',
);
$config{'ZEBRA_AUTH_CFG'} = 'zebra-authorities-dom.cfg';
$config{'ZEBRA_BIB_CFG'}  = 'zebra-biblios-dom.cfg';
$config{'AUTH_RETRIEVAL_CFG'} = 'retrieval-info-auth-dom.xml';
$config{'BIB_RETRIEVAL_CFG'}  = 'retrieval-info-bib-dom.xml';

if ($config{'INSTALL_MODE'} ne "dev") {
    push @{ $pl_files->{'rewrite-config.PL'} }, (
        'blib/PERL_MODULE_DIR/C4/Context.pm',
    );
}

$config{ZEBRA_TOKENIZER_STMT} = $config{ZEBRA_TOKENIZER} eq 'icu'
    ? 'icuchain words-icu.xml'
    : 'charmap word-phrase-utf.chr';

$config{ZEBRA_PTOKENIZER_STMT} = $config{ZEBRA_TOKENIZER} eq 'icu'
    ? 'icuchain phrases-icu.xml'
    : 'charmap word-phrase-utf.chr';

my %test_suite_override_dirs = (
    KOHA_CONF_DIR  => ['etc'],
    ZEBRA_CONF_DIR => ['etc', 'zebradb'],
    Z3950_CONF_DIR => ['etc', 'z3950'],
    LOCK_DIR       => ['var', 'lock'],
    LOG_DIR        => ['var', 'log'],
    BACKUP_DIR     => ['var', 'spool'],
    SCRIPT_DIR     => ['bin'],
    ZEBRA_LOCK_DIR => ['var', 'lock', 'zebradb'],
    ZEBRA_DATA_DIR => ['var', 'lib', 'zebradb'],
    ZEBRA_RUN_DIR  => ['var', 'run', 'zebradb'],
);

WriteMakefile(
              NAME         => 'koha',
              #VERSION     => strftime('2.9.%Y%m%d%H',gmtime),
              VERSION_FROM => 'kohaversion.pl',
              ABSTRACT     => 'Award-winning integrated library system (ILS) and Web OPAC',
              AUTHOR       => 'Koha Contributors <https://koha-community.org/>',
              NO_META      => 1,
              PREREQ_PM    => $koha_pm->prereq_pm,

              # File tree mapping
              PM => $file_map,

              # Man pages generated from POD
	      # ExtUtils::MakeMaker already manage $(DESTDIR)
              INSTALLMAN1DIR => File::Spec->catdir(_strip_destdir($target_directories->{'MAN_DIR'}), 'man1'),
              INSTALLMAN3DIR => File::Spec->catdir(_strip_destdir($target_directories->{'MAN_DIR'}), 'man3'),

              PL_FILES => $pl_files,
);

=head1 FUNCTIONS

=head2 hashdir

This function recurses through the directory structure and builds
a hash of hashes containing the structure with arrays holding filenames.
This directory hashing routine was taken from BrowserUK @ http://www.perlmonks.org/?node_id=219919

=cut

sub hashdir{
    my $dir = shift;
    opendir my $dh, $dir or die $!;
    my $tree = {}->{$dir} = {};
    while( my $file = readdir($dh) ) {
        next if $file =~ m/^\.{1,2}/ and $file !~ /^\.htaccess/; # .htaccess is a special case
        my $path = $dir .'/' . $file;
        $tree->{$file} = hashdir($path), next if -d $path;
        push @{$tree->{'.'}}, $file;
    }
    return $tree;
}

=head2 get_file_map

This function combines the target_map and file hash to
map each source file to its destination relative to
the set of installation targets.

Output will be a hash mapping from each source file
to its destination value, like this:

'mainpage.pl' => '$(INTRANET_CGI_DIR)/mainpage.pl'

=cut

sub get_file_map {
    my $target_map = shift;
    my $dirtree = shift;
    my $file_map = shift;
    my $curr_path = @_ ? shift : ['.'];

    # Traverse the directory tree.
    # For each file or directory, identify the
    # most specific match in the target_map
    foreach my $dir (sort keys %{ $dirtree }) {
        if ($dir eq '.') {
            # deal with files in directory
            foreach my $file (sort @{ $dirtree->{$dir} }) {
                my $targetdir = undef;
                my $matchlevel = undef;
                # first, see if there is a match on this specific
                # file in the target map
                my $filepath = join("/", @$curr_path, $file);
                if (exists $target_map->{$filepath}) {
                    $targetdir = $target_map->{$filepath};
                    $matchlevel = scalar(@$curr_path) + 1;
                } else {
                    # no match on the specific file; look for
                    # a directory match
                    for (my $i = scalar(@$curr_path) - 1; $i >= 0; $i--)  {
                        my $dirpath = join("/", @$curr_path[0..$i]);
                        if (exists $target_map->{$dirpath}) {
                            $targetdir = $target_map->{$dirpath};
                            $matchlevel = $i + 1;
                            last;
                        }
                    }
                }
                if (defined $targetdir) {
                     _add_to_file_map($file_map, $targetdir, $curr_path, $file, $matchlevel);
                } else {
                    my $path = join("/", @$curr_path);
                    print "failed to map: $path/$file\n" if $DEBUG;
                }
            }
        } else {
            # dealing with subdirectory
            push @$curr_path, $dir;
            get_file_map($target_map, $dirtree->{$dir}, $file_map, $curr_path);
            pop @$curr_path;
        }
    }
}

sub _add_to_file_map {
    my $file_map = shift;
    my $targetdir = shift;
    my $curr_path = shift;
    my $file = shift;
    my $matchlevel = shift;
    my $dest_path = @_ ? shift : $curr_path;

    # The target can be one of the following:
    # 1. scalar representing target symbol
    # 2. hash ref containing target and trimdir keys
    #
    # Consequently, this routine traverses this structure,
    # calling itself recursively, until it deals with
    # all of the scalar target symbols.
    if (ref $targetdir eq 'HASH') {
        my $subtarget = $targetdir->{target};
        if (exists $targetdir->{trimdir}) {
            # if we get here, we've specified that
            # rather than installing the file to
            # $(TARGET)/matching/dirs/subdirs/file,
            # we want to install it to
            # $(TARGET)/subdirs/file
            #
            # Note that this the only place where
            # $matchlevel is used.
            my @new_dest_path = @$dest_path;
            if ($targetdir->{trimdir} == -1)  {
                splice @new_dest_path, 0, $matchlevel;
            } else {
                splice @new_dest_path, 0, $targetdir->{trimdir};
            }
            _add_to_file_map($file_map, $subtarget, $curr_path, $file, $matchlevel, \@new_dest_path);
        } else {
            # actually getting here means that the
            # target was unnecessarily listed
            # as a hash, but we'll forgive that
            _add_to_file_map($file_map, $subtarget, $curr_path, $file, $matchlevel);
        }
    } elsif ($targetdir ne 'NONE' and $targetdir ne '') {
        my $source = File::Spec->catfile(@$curr_path, $file);
        my $destination = File::Spec->catfile('blib', $targetdir, @$dest_path, $file);
        #print "$source => $destination\n"; # DEBUG
        # quote spaces in file names
        # FIXME: this is of questionable portability and
        # probably depends on user's make recognizing this
        # quoting syntax -- probably better to remove
        # spaces and shell metacharacters from all file names
        $source =~ s/ /\\ /g;
        $destination =~ s/ /\\ /g;

        $file_map->{$source} = $destination;
    }
}

=head2 get_cli_values

Reads values provided on cli for configuration values

=cut

sub get_cli_values {
    my $values = shift;
    my $map = {
        INSTALL_MODE               => $cli_koha_install_mode,
        DB_TYPE                    => $cli_koha_db_type,
        DB_HOST                    => $cli_koha_db_host,
        DB_PORT                    => $cli_koha_db_port,
        DB_NAME                    => $cli_koha_db_name,
        DB_USER                    => $cli_koha_db_user,
        DB_PASS                    => $cli_koha_db_pass,
        ZEBRA_MARC_FORMAT          => $cli_zebra_marc_format,
        ZEBRA_LANGUAGE             => $cli_zebra_language,
        ZEBRA_TOKENIZER            => $cli_zebra_tokenizer,
        ZEBRA_USER                 => $cli_zebra_user,
        ZEBRA_PASS                 => $cli_zebra_pass,
        ZEBRA_SRU_HOST             => $cli_zebra_sru_host,
        ZEBRA_SRU_BIBLIOS_PORT     => $cli_zebra_sru_bib_port,
        ZEBRA_SRU_AUTHORITIES_PORT => $cli_zebra_sru_auth_port,
        KOHA_USER                  => $cli_koha_user,
        KOHA_GROUP                 => $cli_koha_group,
        INSTALL_SRU                => $cli_koha_install_sru,
        USE_MEMCACHED              => $cli_koha_use_memcached,
        FONT_DIR                   => $cli_koha_font_dir,
        RUN_DATABASE_TESTS         => $cli_koha_run_database_tests,
        INSTALL_BASE               => $cli_koha_install_base,
        TEMPLATE_CACHE_DIR         => $cli_koha_template_cache_dir,
        SMTP_HOST                  => $cli_smtp_host,
        SMTP_PORT                  => $cli_smtp_port,
        SMTP_TIMEOUT               => $cli_smtp_timeout,
        SMTP_SSL_MODE              => $cli_smtp_ssl_mode,
        SMTP_USER_NAME             => $cli_smtp_user_name,
        SMTP_PASSWORD              => $cli_smtp_password,
        SMTP_DEBUG                 => (defined $cli_smtp_debug) ? ( $cli_smtp_debug ? 'yes' : 'no' ) : $values->{SMTP_DEBUG},
    };
    foreach my $key (keys %{$map}) {
        $values->{$key} = $map->{$key} if ($map->{$key});
    }
}

=head2 get_install_log_values

Reads value from the Koha install log specified by
--prev-install-log

=cut

sub get_install_log_values {
    my $install_log = shift;
    my $values = shift;

    open my $log, '<', $install_log or die "Cannot open install log $install_log: $!\n";
    while (<$log>) {
        chomp;
        next if /^#/ or /^\s*$/;
        next if /^=/;
        next unless m/=/;
        s/\s+$//g;
        my ($key, $value) = split /=/, $_, 2;
        $values->{$key} = $value;
    }
    close $log;

    print <<_EXPLAIN_INSTALL_LOG_;
Reading values from install log $install_log.  You
will be prompted only for settings that have been
added since the last time you installed Koha.  To
be prompted for all settings, run 'perl Makefile.PL'
without the --prev-install-log option.
_EXPLAIN_INSTALL_LOG_
}

=head2 get_configuration

This prompts the user for various configuration options.

=cut

sub get_configuration {
  my $defaults = shift;
  my $valid_values = shift;
  my $install_log_values = shift;
  my %config = ();

  my $msg = q(
By default, Koha can be installed in one of three ways:

standard: Install files in conformance with the Filesystem
          Hierarchy Standard (FHS).  This is the default mode
          and should be used when installing a production
          Koha system.  On Unix systems, root access is
          needed to complete a standard installation.

single:   Install files under a single directory.  This option
          is useful for installing Koha without root access, e.g.,
          on a web host that allows CGI scripts and MySQL databases
          but requires the user to keep all files under the user's
          HOME directory.

dev:      Create a set of symbolic links and configuration files to
          allow Koha to run directly from the source distribution.
          This mode is useful for developers who want to run
          Koha from a git clone.

Installation mode);
    $msg .= _add_valid_values_disp('INSTALL_MODE', $valid_values);
    $config{'INSTALL_MODE'} = _get_value('INSTALL_MODE', $msg, $defaults->{'INSTALL_MODE'}, $valid_values, $install_log_values);

    # set message and default value for INSTALL_BASE
    # depending on value of INSTALL_MODE
    my $install_base_default = $defaults->{'INSTALL_BASE'};
    if ($config{'INSTALL_MODE'} eq 'dev') {
        $msg = q(
Please specify the directory in which to install Koha's
active configuration files and (if applicable) the
Zebra database.  Koha's CGI scripts and templates will
be run from the current directory.

Configuration directory:);
        # FIXME - home directory portability consideration apply
        $install_base_default =
	    $ENV{DESTDIR}
	    || ( exists $ENV{HOME} ? "$ENV{HOME}/koha-dev" : "$defaults->{'INSTALL_BASE'}-dev" )
	;
    } elsif ($config{'INSTALL_MODE'} eq 'single') {
        $msg = "\nPlease specify the directory in which to install Koha";
        # FIXME -- we're assuming under a 'single' mode install
        # that user will likely want to install under the home
        # directory.  This is OK in and of itself, but we should
        # use File::HomeDir to locate the home directory portably.
        # This is deferred for now because File::HomeDir is not yet
        # core.
		# --we must also keep this portable to the major OS's -fbcit
        $install_base_default = (exists $ENV{'HOME'}) ? "$ENV{'HOME'}/koha" : $defaults->{'INSTALL_BASE'};
    } else {
        # must be standard
        $msg = q(
Please specify the directory under which most Koha files
will be installed.

Note that if you are planning in installing more than
one instance of Koha, you may want to modify the last
component of the directory path, which will be used
as the package name in the FHS layout.

Base installation directory);
    }
    $config{'INSTALL_BASE'} = _get_value('INSTALL_BASE', $msg, $install_base_default, $valid_values, $install_log_values);

    $config{'INSTALL_BASE'} = File::Spec->rel2abs($config{'INSTALL_BASE'});
	print "INSTALL_BASE=$config{'INSTALL_BASE'}\r\n" if $DEBUG;
    if ($config{'INSTALL_MODE'} eq "standard") {
        $msg = q(
Since you are using the 'standard' install
mode, you should run 'make install' as root.
However, it is recommended that a non-root
user (on Unix and Linux platforms) have
ownership of Koha's files, including the
Zebra indexes if applicable.

Please specify a user account.  This
user account does not need to exist
right now, but it needs to exist
before you run 'make install'.  Please
note that for security reasons, this
user should not be the same as the user
account Apache runs under.

User account);
        $config{'KOHA_USER'} = _get_value('KOHA_USER', $msg, $defaults->{'KOHA_USER'}, $valid_values, $install_log_values);

        $msg = q(
Please specify the group that should own
Koha's files.  As above, this group need
not exist right now, but should be created
before you run 'make install'.

Group);
        $config{'KOHA_GROUP'} = _get_value('KOHA_GROUP', $msg, $defaults->{'KOHA_GROUP'}, $valid_values, $install_log_values);
    }

    $msg = q(
Please specify which database engine you will use
to store data in Koha.  The choices are MySQL and
PostgreSQL; please note that at the moment
PostgreSQL support is highly experimental.

DBMS to use);
    $msg .= _add_valid_values_disp('DB_TYPE', $valid_values);
    $config{'DB_TYPE'} = _get_value('DB_TYPE', $msg, $defaults->{'DB_TYPE'}, $valid_values, $install_log_values);

    $msg = q(
Please specify the name or address of your
database server.  Note that the database
does not have to exist at this point, it
can be created after running 'make install'
and before you try using Koha for the first time.

Database server);
    $config{'DB_HOST'} = _get_value('DB_HOST', $msg, $defaults->{'DB_HOST'}, $valid_values, $install_log_values);

    $msg = q(
Please specify the port used to connect to the
DMBS);
    my $db_port_default = $config{'DB_TYPE'} eq 'mysql' ? '3306' : '5432';
    $config{'DB_PORT'} = _get_value('DB_PORT', $msg, $db_port_default, $valid_values, $install_log_values);

    $msg = q(
Please specify the name of the database to be
used by Koha);
    $config{'DB_NAME'} = _get_value('DB_NAME', $msg, $defaults->{'DB_NAME'}, $valid_values, $install_log_values);
    if ($config{'DB_TYPE'} eq 'mysql'){
        $msg = q(
Please specify whether the connection to MySQL will use TLS
        );
        $config{'DB_USE_TLS'} = _get_value('DB_USE_TLS', $msg, $defaults->{'DB_USE_TLS'}, $valid_values, $install_log_values);
    }
    if ($config{'DB_USE_TLS'} eq 'yes'){
        $msg = q(
Please enter the path to the CA certificate for TLS
        );
        $config{'DB_TLS_CA_CERTIFICATE'} = _get_value('DB_TLS_CA_CERTIFICATE', $msg, $defaults->{'DB_TLS_CA_CERTIFICATE'}, $valid_values, $install_log_values);

        $msg = q(
Please enter the path to the client certificate for TLS
        );
        $config{'DB_TLS_CLIENT_CERTIFICATE'} = _get_value('DB_TLS_CLIENT_CERTIFICATE', $msg, $defaults->{'DB_TLS_CLIENT_CERTIFICATE'}, $valid_values, $install_log_values);
        $msg = q(
Please enter the path to the client key for TLS
        );
        $config{'DB_TLS_CLIENT_KEY'} = _get_value('DB_TLS_CLIENT_KEY', $msg, $defaults->{'DB_TLS_CLIENT_KEY'}, $valid_values, $install_log_values);
    }

    $msg = q(
Please specify the user that owns the database to be
used by Koha);
    $config{'DB_USER'} = _get_value('DB_USER', $msg, $defaults->{'DB_USER'}, $valid_values, $install_log_values);

    $msg = q(
Please specify the password of the user that owns the
database to be used by Koha);
    $config{'DB_PASS'} = _get_value('DB_PASS', $msg, $defaults->{'DB_PASS'}, $valid_values, $install_log_values);

    print q(
Koha uses the Zebra search engine for high-performance
searching of bibliographic and authority records.  Checking
to see if you have installed the Zebra software...
);

    if (defined(my $zebra_path = find_zebra())) {
        $config{'PATH_TO_ZEBRA'} = $zebra_path;
        print qq(
Found 'zebrasrv' and 'zebraidx' in $zebra_path.
);
    } else {
        print q(
Unable to find the Zebra programs 'zebrasrv' and 'zebraidx'
in your PATH or in some of the usual places.  If you haven't
installed Zebra yet, please do so and run Makefile.PL again.

);
    }

    $msg = q(
You must specify the primary MARC format of the
records to be indexed by Zebra.

Koha provides Zebra configuration files for MARC21,
and UNIMARC.

MARC format for Zebra indexing);
    $msg .= _add_valid_values_disp('ZEBRA_MARC_FORMAT', $valid_values);
    $config{'ZEBRA_MARC_FORMAT'} = _get_value('ZEBRA_MARC_FORMAT', $msg, $defaults->{'ZEBRA_MARC_FORMAT'}, $valid_values, $install_log_values);
    $msg = q(
Koha supplies Zebra configuration files tuned for
searching either English (en) or French (fr) MARC
records.

Primary language for Zebra indexing);
    $msg .= _add_valid_values_disp('ZEBRA_LANGUAGE', $valid_values);
    $config{'ZEBRA_LANGUAGE'} = _get_value('ZEBRA_LANGUAGE', $msg, $defaults->{'ZEBRA_LANGUAGE'}, $valid_values, $install_log_values);

    $msg = q(
Zebra has two methods to perform records tokenization
and characters normalization: CHR and ICU. ICU is
recommended for catalogs containing non-Latin
characters.);

    $msg .= _add_valid_values_disp('ZEBRA_TOKENIZER', $valid_values);
    $config{'ZEBRA_TOKENIZER'} = _get_value('ZEBRA_TOKENIZER', $msg, $defaults->{'ZEBRA_TOKENIZER'}, $valid_values, $install_log_values);

    $msg = q(
Please specify Zebra database user);
    $config{'ZEBRA_USER'} = _get_value('ZEBRA_USER', $msg, $defaults->{'ZEBRA_USER'}, $valid_values, $install_log_values);

    $msg = q(
Please specify the Zebra database password);
    $config{'ZEBRA_PASS'} = _get_value('ZEBRA_PASS', $msg, $defaults->{'ZEBRA_PASS'}, $valid_values, $install_log_values);

    $msg = q(
Since you've chosen to use Zebra, you can enable the SRU/
Z39.50 Server if you so choose, but you must specify a
few configuration options for it.

Please note that if you choose *NOT* to configure SRU,
koha-conf.xml will still contain some references to SRU
settings.  Those references will be ignored by Koha.

Install the SRU configuration files?);
    $msg .= _add_valid_values_disp('INSTALL_SRU', $valid_values);
    $config{'INSTALL_SRU'} = _get_value('INSTALL_SRU', $msg, $defaults->{'INSTALL_SRU'}, $valid_values, $install_log_values);

    if ($config{'INSTALL_SRU'} eq 'yes') {
        $msg = q(
Since you've chosen to configure SRU, you must
specify the host and port(s) that the SRU
Servers (bibliographic and authority) should run on.
);
        $msg = q(
SRU Database host?);
        $config{'ZEBRA_SRU_HOST'} = _get_value('ZEBRA_SRU_HOST', $msg, $defaults->{'ZEBRA_SRU_HOST'}, $valid_values, $install_log_values);

        $msg = q(
SRU port for bibliographic data?);
        $config{'ZEBRA_SRU_BIBLIOS_PORT'} = _get_value('ZEBRA_SRU_BIBLIOS_PORT', $msg, $defaults->{'ZEBRA_SRU_BIBLIOS_PORT'}, $valid_values, $install_log_values);

        $msg = q(
SRU port for authority data?);
        $config{'ZEBRA_SRU_AUTHORITIES_PORT'} = _get_value('ZEBRA_SRU_AUTHORITIES_PORT', $msg, $defaults->{'ZEBRA_SRU_AUTHORITIES_PORT'}, $valid_values, $install_log_values);

    }

  $msg = q(
Use memcached to cache the results of some function calls?
This provides a significant performance improvement.
You will need a Memcached server running.);
  $msg .= _add_valid_values_disp('USE_MEMCACHED', $valid_values);
  $config{'USE_MEMCACHED'} = _get_value('USE_MEMCACHED', $msg, $defaults->{'USE_MEMCACHED'}, $valid_values, $install_log_values);
  if ($config{'USE_MEMCACHED'} eq 'yes'){
      $msg = q(
Since you've chosen to use caching, you must specify the memcached servers and the namespace to use:
);
      $msg = q(
Memcached server address?);
      $config{'MEMCACHED_SERVERS'} = _get_value('MEMCACHED_SERVERS', $msg, $defaults->{'MEMCACHED_SERVERS'}, $valid_values, $install_log_values);

      $msg = q(
Memcached namespace?);
      $config{'MEMCACHED_NAMESPACE'} = _get_value('MEMCACHED_NAMESPACE', $msg, $defaults->{'MEMCACHED_NAMESPACE'}, $valid_values, $install_log_values);
  }


  $msg = q(
Use Elasticsearch to serve search results?
You will need a Elasticsearch server running.);
  $msg .= _add_valid_values_disp('USE_ELASTICSEARCH', $valid_values);
  $config{'USE_ELASTICSEARCH'} = _get_value('USE_ELASTICSEARCH', $msg, $defaults->{'USE_ELASTICSEARCH'}, $valid_values, $install_log_values);
  if ($config{'USE_ELASTICSEARCH'} eq 'yes'){
      $msg = q(
Define the ELASTICSEARCH_SERVERS with a comma-separated list. Eg
localhost:9200, 192.168.0.100:9200
);
      $msg = q(
Elasticsearch server addresses?);
      $config{'ELASTICSEARCH_SERVERS'} = _get_value('ELASTICSEARCH_SERVERS', $msg, $defaults->{'ELASTICSEARCH_SERVERS'}, $valid_values, $install_log_values);

      $msg = q(
What index name to use for this Koha-instance? It must be unique for each Koha
sharing the same Elasticsearch-cluster

Elasticsearch index?);
      $config{'ELASTICSEARCH_INDEX'} = _get_value('ELASTICSEARCH_INDEX', $msg, $defaults->{'ELASTICSEARCH_INDEX'}, $valid_values, $install_log_values);
  }

  $msg = q(
Template cache directory?);
  $config{'TEMPLATE_CACHE_DIR'} = _get_value('TEMPLATE_CACHE_DIR', $msg, $defaults->{'TEMPLATE_CACHE_DIR'}, $valid_values, $install_log_values);

  $msg = q(
Path to DejaVu fonts?);
  $config{'FONT_DIR'} = _get_value('FONT_DIR', $msg, $defaults->{'FONT_DIR'}, $valid_values, $install_log_values);

  $msg = q(
SMTP settings
You will be able to set your default SMTP configuration.);
  $msg .= q{
SMTP host name?};
  $config{'SMTP_HOST'} = _get_value('SMTP_HOST', $msg, $defaults->{'SMTP_HOST'}, $valid_values, $install_log_values);

  $msg = q{
SMTP port?};
  $config{'SMTP_PORT'} = _get_value('SMTP_PORT', $msg, $defaults->{'SMTP_PORT'}, $valid_values, $install_log_values);

  $msg = q{
SMTP timeout (in seconds)?};
  $config{'SMTP_TIMEOUT'} = _get_value('SMTP_TIMEOUT', $msg, $defaults->{'SMTP_TIMEOUT'}, $valid_values, $install_log_values);

  $msg = q{
SMTP SSL mode?};
  $msg .= _add_valid_values_disp('SMTP_SSL_MODE', $valid_values);
  $config{'SMTP_SSL_MODE'} = _get_value('SMTP_SSL_MODE', $msg, $defaults->{'SMTP_SSL_MODE'}, $valid_values, $install_log_values);

  $msg = q{
SMTP user name?};
  $config{'SMTP_USER_NAME'} = _get_value('SMTP_USER_NAME', $msg, $defaults->{'SMTP_USER_NAME'}, $valid_values, $install_log_values);

  $msg = q{
SMTP password?};
  $config{'SMTP_PASSWORD'} = _get_value('SMTP_PASSWORD', $msg, $defaults->{'SMTP_PASSWORD'}, $valid_values, $install_log_values);

  $msg = q{
SMTP debug mode?};
  $msg .= _add_valid_values_disp('SMTP_DEBUG', $valid_values);
  $config{'SMTP_DEBUG'} = _get_value('SMTP_DEBUG', $msg, $defaults->{'SMTP_DEBUG'}, $valid_values, $install_log_values);

  $config{'SMTP_DEBUG'} = ( $config{'SMTP_DEBUG'} eq 'yes' ) ? 1 : 0;

  $msg = q(
Would you like to run the database-dependent test suite?);
  $msg .= _add_valid_values_disp( 'RUN_DATABASE_TESTS', $valid_values );
    $config{'RUN_DATABASE_TESTS'} = _get_value( 'RUN_DATABASE_TESTS', $msg, $defaults->{'RUN_DATABASE_TESTS'}, $valid_values, $install_log_values );

  if ( $config{'RUN_DATABASE_TESTS'} eq 'yes' ) {
      $config{'TEST_DB_TYPE'} = $config{'DB_TYPE'};
      $config{'TEST_DB_HOST'} = $config{'DB_HOST'};
      $msg = q(TEST DATABASE

THE DATA IN THIS DATABASE WILL BE DESTROYED during the process of
testing. Please don't do this on your production database. It is not
reversible.

YOU WILL SUFFER DATA LOSS if you run this test suite on your test
database. You are better off not running this optional test suite than
doing it in a database that you don't want to lose.

Please specify the name of the test database to be
used by Koha);

      $config{'TEST_DB_NAME'} = _get_value('TEST_DB_NAME', $msg, $defaults->{'TEST_DB_NAME'}, $valid_values, $install_log_values);
      while ( $config{'TEST_DB_NAME'} eq $config{'DB_NAME'} ) {
          $msg = q(Please do not use the same database for testing as you do for production. You run the severe risk of data loss.);
          $config{'TEST_DB_NAME'} = _get_value('TEST_DB_NAME', $msg, $defaults->{'TEST_DB_NAME'}, $valid_values, $install_log_values);
      }

      $msg = q(
Please specify the user that owns the database to be
used by Koha);
    $config{'TEST_DB_USER'} = _get_value('TEST_DB_USER', $msg, $defaults->{'TEST_DB_USER'}, $valid_values, $install_log_values);

      $msg = q(
Please specify the password of the user that owns the
database to be used by Koha);
      $config{'TEST_DB_PASS'} = _get_value('TEST_DB_PASS', $msg, $defaults->{'TEST_DB_PASS'}, $valid_values, $install_log_values);
  }

    print "\n\n";

    # add version number
    my $version = "no_version_found";
    eval {
        require 'kohaversion.pl';
        $version = kohaversion();
    };
    $config{'KOHA_INSTALLED_VERSION'} = $version;

    return %config;
}

sub _add_valid_values_disp {
    my $key = shift;
    my $valid_values = shift;

    my $disp = "";
    if (exists $valid_values->{$key}) {
        $disp = " (" . join(", ", sort keys %{ $valid_values->{$key} }) . ")";
    }
    return $disp;
}

sub _get_value {
    my $key = shift;
    my $msg = shift;
    my $default = shift;
    my $valid_values = shift;
    my $install_log_values = shift;

    # take value from install log if present
    if (exists $install_log_values{$key}) {
        $install_log_values{$key} =~ s/\$/\$\$/g;
        return $install_log_values{$key};
    }

    # override default value from environment
    if (exists $ENV{$key}) {
        $default = $ENV{$key};
        $msg .= " (default from environment)";
    }

    my $val = prompt($msg, $default);

    while (exists $valid_values->{$key} and
           $val ne $default and
           not exists $valid_values->{$key}->{$val}) {
        my $retry_msg = "Value '$val' is not a valid option.\n";
        $retry_msg .= "Please enter a value";
        $retry_msg .= _add_valid_values_disp($key, $valid_values);
        $val = prompt($retry_msg, $default);
    }
    $val =~ s/\$/\$\$/g;
    return $val;
}

=head2 get_target_directories

Creates a hash mapping from symbols for installation target
directories to actual directory paths.

Also returns a hash indicating targets for which
files need not be copied -- this is used for the 'dev'
mode installation, where some files are installed in place.

=cut

sub get_target_directories {
    my $config = shift;

    my $base = $config->{'INSTALL_BASE'};
    my $mode = $config->{'INSTALL_MODE'};

    # get last component of install base directory
    # to treat as package name
    my ($volume, $directories, $file) = File::Spec->splitpath($base, 1);

    my @basedir = File::Spec->splitdir($directories);

    if ( $^O eq 'cygwin' ) { shift @basedir; unshift @basedir, 'c:'; }   # in a cygwin environment, $volume is returned empty

    my $package = pop @basedir;


    my %dirmap = ();
    my %skipdirs = ();
    if ($mode eq 'single') {
        $dirmap{'API_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'api');
        $dirmap{'INTRANET_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'cgi-bin');
        $dirmap{'INTRANET_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs', 'intranet-tmpl');
        $dirmap{'INTRANET_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs');
        $dirmap{'OPAC_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'cgi-bin');
        $dirmap{'OPAC_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs', 'opac-tmpl');
        $dirmap{'OPAC_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs');
        $dirmap{'PERL_MODULE_DIR'} = File::Spec->catdir(@basedir, $package, 'lib');
        $dirmap{'PERL_MODULE_LIB_DIR'} = File::Spec->catdir(@basedir, $package, 'lib');
        $dirmap{'KOHA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc');
        $dirmap{'ZEBRA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc', 'zebradb');
        $dirmap{'Z3950_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc', 'z3950');
        $dirmap{'MISC_DIR'} = File::Spec->catdir(@basedir, $package, 'misc');
        $dirmap{'SCRIPT_DIR'} = File::Spec->catdir(@basedir, $package, 'bin');
        $dirmap{'SCRIPT_NONDEV_DIR'} = $dirmap{'SCRIPT_DIR'};
        $dirmap{'MAN_DIR'} = File::Spec->catdir(@basedir, $package, 'man');
        $dirmap{'DOC_DIR'} = File::Spec->catdir(@basedir, $package, 'doc');
        $dirmap{'ZEBRA_LOCK_DIR'} = File::Spec->catdir(@basedir, $package, 'var', 'lock', 'zebradb');
        $dirmap{'LOCK_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lock');
        $dirmap{'LOG_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'log');
        $dirmap{'BACKUP_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'spool');
        $dirmap{'PLUGINS_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lib', 'koha', 'plugins');
        $dirmap{'ZEBRA_DATA_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lib', 'zebradb');
        $dirmap{'ZEBRA_RUN_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'run', 'zebradb');
    } elsif ($mode eq 'dev') {
        my $curdir = File::Spec->rel2abs(File::Spec->curdir());
        $dirmap{'API_CGI_DIR'} = File::Spec->catdir($curdir, 'api');
        $skipdirs{'API_CGI_DIR'} = 1;
        $dirmap{'INTRANET_CGI_DIR'} = File::Spec->catdir($curdir);
        $skipdirs{'INTRANET_CGI_DIR'} = 1;
        $dirmap{'INTRANET_TMPL_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl', 'intranet-tmpl');
        $skipdirs{'INTRANET_TMPL_DIR'} = 1;
        $dirmap{'INTRANET_WWW_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl');
        $skipdirs{'INTRANET_WWW_DIR'} = 1;
        $dirmap{'OPAC_CGI_DIR'} = File::Spec->catdir($curdir);
        $skipdirs{'OPAC_CGI_DIR'} = 1;
        $dirmap{'OPAC_TMPL_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl', 'opac-tmpl');
        $skipdirs{'OPAC_TMPL_DIR'} = 1;
        $dirmap{'OPAC_WWW_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl');
        $skipdirs{'OPAC_WWW_DIR'} = 1;
        #NOTE: We're hacking the dirmap here, so that PERL_MODULE_DIR tokens get rewritten correctly for git installs
        $dirmap{'PERL_MODULE_DIR'} = File::Spec->catdir($curdir);
        $skipdirs{'PERL_MODULE_DIR'} = 1;
        $dirmap{'PERL_MODULE_LIB_DIR'} = File::Spec->catdir($curdir,'lib');
        $skipdirs{'PERL_MODULE_LIB_DIR'} = 1;
        $dirmap{'KOHA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc');
        $dirmap{'ZEBRA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc', 'zebradb');
        $dirmap{'Z3950_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc', 'z3950');
        $dirmap{'MISC_DIR'} = File::Spec->catdir(@basedir, $package, 'misc');
        $dirmap{'SCRIPT_DIR'} = File::Spec->catdir(@basedir, $package, 'bin');
        #For dev install, point NONDEV_DIR to misc in current dir (not base)
        #Used by supportdir in koha-conf.xml (BZ 12031)
        $dirmap{'SCRIPT_NONDEV_DIR'} = File::Spec->catdir($curdir, 'misc');
        $skipdirs{'SCRIPT_NONDEV_DIR'} = 1;
        $dirmap{'MAN_DIR'} = File::Spec->catdir(@basedir, $package, 'man');
        $dirmap{'DOC_DIR'} = File::Spec->catdir(@basedir, $package, 'doc');
        $dirmap{'ZEBRA_LOCK_DIR'} = File::Spec->catdir(@basedir, $package, 'var', 'lock', 'zebradb');
        $dirmap{'LOCK_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lock');
        $dirmap{'LOG_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'log');
        $dirmap{'BACKUP_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'spool');
        $dirmap{'PLUGINS_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lib', 'plugins');
        $dirmap{'ZEBRA_DATA_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lib', 'zebradb');
        $dirmap{'ZEBRA_RUN_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'run', 'zebradb');
    } else {
        # mode is standard, i.e., 'fhs'
        $dirmap{'API_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'api');
        $dirmap{'INTRANET_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'cgi-bin');
        $dirmap{'INTRANET_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs', 'intranet-tmpl');
        $dirmap{'INTRANET_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs');
        $dirmap{'OPAC_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'cgi-bin');
        $dirmap{'OPAC_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs', 'opac-tmpl');
        $dirmap{'OPAC_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs');
        $dirmap{'PERL_MODULE_DIR'} = File::Spec->catdir(@basedir, $package, 'lib');
        $dirmap{'PERL_MODULE_LIB_DIR'} = File::Spec->catdir(@basedir, $package, 'lib');
        $dirmap{'KOHA_CONF_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'etc', $package);
        $dirmap{'ZEBRA_CONF_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'etc', $package, 'zebradb');
        $dirmap{'Z3950_CONF_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'etc', $package, 'z3950');
        $dirmap{'MISC_DIR'} = File::Spec->catdir(@basedir, $package, 'misc');
        $dirmap{'SCRIPT_DIR'} = File::Spec->catdir(@basedir, $package, 'bin');
        $dirmap{'SCRIPT_NONDEV_DIR'} = $dirmap{'SCRIPT_DIR'};
        $dirmap{'MAN_DIR'} = File::Spec->catdir(@basedir, $package, 'man');
        $dirmap{'DOC_DIR'} = File::Spec->catdir(@basedir, $package, 'doc');
        $dirmap{'ZEBRA_LOCK_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'var', 'lock', $package, 'zebradb');
        $dirmap{'LOCK_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'lock', $package);
        $dirmap{'LOG_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'log', $package);
        $dirmap{'BACKUP_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'spool', $package);
        $dirmap{'PLUGINS_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'lib', $package, 'plugins');
        $dirmap{'ZEBRA_DATA_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'lib', $package, 'zebradb');
        $dirmap{'ZEBRA_RUN_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'run', $package, 'zebradb');
    }

    _get_env_overrides(\%dirmap);
    _get_argv_overrides(\%dirmap);
    _add_destdir(\%dirmap);

    return \%dirmap, \%skipdirs;
}

=head2 get_test_dir

Map a directory target to the corresponding path for
the test suite.

=cut

sub get_test_dir {
    my ($dirname) = @_;

    my @basedir = (File::Spec->rel2abs(File::Spec->curdir()), 't', 'run');
    if (exists $test_suite_override_dirs{$dirname}) {
        return File::Spec->catdir(@basedir, @{ $test_suite_override_dirs{$dirname} });
    } else {
        return;
    }

}

sub _get_env_overrides {
    my $dirmap = shift;

    foreach my $key (keys %$dirmap) {
        if (exists $ENV{$key}) {
            $dirmap->{$key} = $ENV{$key};
            print "Setting $key from environment\n";
        }
    }
}

sub _get_argv_overrides {
    my $dirmap = shift;

    my @new_argv = ();
    for (my $i = 0; $i <= $#ARGV; $i++) {
        if ($ARGV[$i] =~ /^([^=]+)=([^=]+)$/ and exists $dirmap->{$1}) {
            $dirmap->{$1} = $2;
        } else {
            push @new_argv, $ARGV[$i];
        }
    }
    @ARGV = @new_argv;
}

sub _strip_destdir {
    my $dir = shift;
    $dir =~ s/^\$\(DESTDIR\)//;
    return $dir;
}

sub _add_destdir {
    my $dirmap = shift;

    foreach my $key (keys %$dirmap) {
        $dirmap->{$key} = '$(DESTDIR)'.$dirmap->{$key};
    }
}

sub display_configuration {
    my $config = shift;
    my $dirmap = shift;
    my @version = grep /\/usr\/share\/perl\//, @INC;
    push @version, ('/usr/share/perl/5.10') if !$version[0];
    print "\n\nKoha will be installed with the following configuration parameters:\n\n";
    foreach my $key (sort keys %$config) {
        print sprintf("%-25.25s%s\n", $key, $config->{$key});
    }

    print "\nand in the following directories:\n\n";
    foreach my $key (sort keys %$dirmap) {
        print sprintf("%-25.25s%s\n", $key, $dirmap->{$key});
    }
    print "\n\nTo change any configuration setting, please run\n";
    print "perl Makefile.PL again.  To override one of the target\n";
    print "directories, you can do so on the command line like this:\n";
    print "\nperl Makefile.PL PERL_MODULE_DIR=$version[0]\n\n";
    print "You can also set different default values for parameters\n";
    print "or override directory locations by using environment variables.\n";
    print "\nFor example:\n\n";
    print "export DB_USER=my_koha\n";
    print "perl Makefile.PL\n";
    print "\nor\n\n";
    print "DB_USER=my_koha DOC_DIR=/usr/local/info perl Makefile.PL\n\n";
}

=head2 find_zebra

Attempt to find Zebra - check user's PATH and
a few other directories for zebrasrv and zebraidx.

=cut

sub find_zebra {
    my @search_dirs = map {
                            my $abs = File::Spec->rel2abs($_);
                            my ($toss, $directories);
                            ($toss, $directories, $toss) = File::Spec->splitpath($abs, 1);
                            $directories;
                        }  split /:/, $ENV{PATH};
    push @search_dirs, qw(/usr/local/bin /opt/local/bin /usr/bin);
    my @zebrasrv_dirs = grep { -x File::Spec->catpath('', $_, 'zebrasrv') } @search_dirs;
    return unless @zebrasrv_dirs;
    # verify that directory that contains zebrasrv also contains zebraidx
    foreach my $dir (@zebrasrv_dirs) {
        return $dir if -x File::Spec->catpath('', $dir, 'zebraidx');
    }
    return;
}

package MY;

sub test {
    my $self = shift;
    my $test = $self->SUPER::test(@_);
    $test =~ s!\$\(INST_LIB\)!blib/PERL_MODULE_DIR!g;

    # set KOHA_CONF
    $test =~ s!\$\(FULLPERLRUN\)!KOHA_CONF=blib/KOHA_CONF_DIR/koha-conf.xml \$(FULLPERLRUN)!g;
    return $test;
}

sub install {
    my $self = shift;
    my $install = "";
    # NOTE: we're *not* doing this: my $install = $self->SUPER::install(@_);
    # This means that we're completely overriding EU::MM's default
    # installation and uninstallation targets.

    my $perl5lib_dirs = _build_perl5lib_string({ target_dirs => $target_directories });

# If installation is on Win32, we need to do permissions different from *nix
    if ( $^O =~ /darwin|linux|cygwin|freebsd|solaris/ ) { # this value needs to be verified for each platform and modified accordingly
	    foreach my $key (sort keys %$target_directories) {
		    $install .= qq(
KOHA_INST_$key = blib/$key
KOHA_DEST_$key = $target_directories->{$key}
) unless exists $skip_directories->{$key};
		}
		$install .= qq(
install :: all install_koha set_koha_ownership set_koha_permissions warn_koha_env_vars
\t\$(NOECHO) \$(NOOP)
);
			$install .= "install_koha ::\n";
			$install .= "\t\$(NOECHO) umask 022; \$(MOD_INSTALL) \\\n";
			foreach my $key (sort keys %$target_directories) {
				$install .= "\t\t\$(KOHA_INST_$key) \$(KOHA_DEST_$key) \\\n"
          unless exists $skip_directories->{$key};
			}
			$install .= "\t\t\$(INST_MAN1DIR) \$(DESTINSTALLMAN1DIR) \\\n";
			$install .= "\t\t\$(INST_MAN3DIR) \$(DESTINSTALLMAN3DIR)\n";

			$install .= "\n";
			$install .= "set_koha_ownership ::\n";
# Do not try to change ownership if DESTDIR is set
			if ($config{'INSTALL_MODE'} eq 'standard' and $config{'KOHA_USER'} ne "root") {
				foreach my $key (sort keys %$target_directories) {
            $install .= "\t\$(NOECHO) if test -z \"\$(DESTDIR)\"; then chown -R $config{'KOHA_USER'}:$config{'KOHA_GROUP'} \$(KOHA_DEST_$key); fi\n"
            unless exists $skip_directories->{$key};
				}
			} else {
				$install .= "\t\t\$(NOECHO) \$(NOOP)\n\n";
			}

			$install .= "\n";
			$install .= "set_koha_permissions ::\n";
			# This is necessary because EU::MM installs files
			# as either 0444 or 0555, and we want the owner
			# of Koha's files to have write permission by default.
			foreach my $key (sort keys %$target_directories) {
				$install .= "\t\$(NOECHO) chmod -R u+w \$(KOHA_DEST_$key)\n"
          unless exists $skip_directories->{$key};
			}
	}

	$install .= "\n";

    $install .= "warn_koha_env_vars ::\n";
    $install .= "\t\$(NOECHO) \$(ECHO)\n";
    $install .= "\t\$(NOECHO) \$(ECHO) Koha\\'s files have now been installed. \n";
    $install .= "\t\$(NOECHO) \$(ECHO)\n";
    $install .= "\t\$(NOECHO) \$(ECHO) In order to use Koha\\'s command-line batch jobs,\n";
    $install .= "\t\$(NOECHO) \$(ECHO) you should set the following environment variables:\n";
    $install .= "\t\$(NOECHO) \$(ECHO)\n";
    $install .= "\t\$(NOECHO) \$(ECHO) export KOHA_CONF=\$(KOHA_DEST_KOHA_CONF_DIR)/koha-conf.xml\n";
    $install .= "\t\$(NOECHO) \$(ECHO) export PERL5LIB=$perl5lib_dirs\n";
    $install .= "\t\$(NOECHO) \$(ECHO)\n";
    $install .= "\t\$(NOECHO) \$(ECHO) For other post-installation tasks, please consult the README.\n";
    $install .= "\t\$(NOECHO) \$(ECHO)\n";

    $install .= _update_zebra_conf_target();

    $install .= upgrade();

    return $install;
}

=head2 _update_zebra_conf_target

Add an installation target for updating
Zebra's configuration files.

=cut

sub _update_zebra_conf_target {

    my $target = "\nupdate_zebra_conf ::\n";
    $target .= "\tumask 022; \$(MOD_INSTALL) \\\n";
    $target .= "\t\t\$(KOHA_INST_ZEBRA_CONF_DIR) \$(KOHA_DEST_ZEBRA_CONF_DIR) \n";
    $target .= "\t\$(NOECHO) chmod -R u+w \$(KOHA_DEST_ZEBRA_CONF_DIR)\n";
    $target .= "\tumask 022; \$(MOD_INSTALL) \\\n";

    return $target;
}

sub upgrade {
    my $upgrade = "";

    my $backup_suffix;
    if (exists $install_log_values{'KOHA_INSTALLED_VERSION'}) {
        my $version = $install_log_values{'KOHA_INSTALLED_VERSION'};
        $version =~ s/\./_/g;
        $backup_suffix = "_koha_$version";
    } else {
        $backup_suffix = "_upgrade_backup";
    }

    $upgrade .= qq/
MOD_BACKUP = \$(ABSPERLRUN) -MC4::Installer::UpgradeBackup -e 'backup_changed_files({\@ARGV}, '$backup_suffix', '\''\$(VERBINST)'\'', '\''\$(UNINST)'\'');' --

upgrade :: make_upgrade_backup install
\t\$(NOECHO) \$(NOOP)
make_upgrade_backup ::
\t\$(NOECHO) umask 022; \$(MOD_BACKUP) \\
/;
    foreach my $key (qw/KOHA_CONF_DIR INTRANET_TMPL_DIR INTRANET_WWW_DIR OPAC_TMPL_DIR OPAC_WWW_DIR
                     ZEBRA_CONF_DIR PLUGINS_DIR/) {
    	$upgrade .= "\t\t\$(KOHA_INST_$key) \$(KOHA_DEST_$key) \\\n"
            unless exists $skip_directories->{$key} or
                   not exists $target_directories->{$key};
    }
    $upgrade =~ s/\\\n$/\n/;

    return $upgrade;
}
sub postamble {
    # put directory mappings into Makefile
    # so that Make will export as environment
    # variables -- this is for the use of
    # rewrite-confg.PL

    my $env;

    #NOTE: Build __PERL5LIB_DIRS__ for rewrite-config.PL
    my $perl5lib_dirs = _build_perl5lib_string({ target_dirs => $target_directories });
    if ($perl5lib_dirs){
        $env .= "export __PERL5LIB_DIRS__ := $perl5lib_dirs\n"
    }

	# Hereagain, we must alter syntax per platform...
        {
		$env .= join("\n", map { "export __${_}__ := $target_directories->{$_}" } keys %$target_directories);
		$env .= "\n\n";
		$env .= join("\n", map { "export __${_}__ := $config{$_}" } keys %config);
	}

    return "$env\n";
}

sub top_targets {
    my $inherited = shift->SUPER::top_targets(@_);
    my $compile_step;
    $compile_step .= "all :: compile_css_js\n";
    $compile_step .= "\t" . '$(NOECHO) $(NOOP)' . "\n";
    $compile_step .= "\n";
    $compile_step .= "compile_css_js:\n";
    $compile_step .= "\t" . '$(PERLRUN) build-resources.PL' . "\n";
    my $top_targets = $compile_step . "\n" . $inherited;
    return $top_targets;
}

sub _build_perl5lib_string {
    my ($args) = @_;
    my %unique_map = ();
    my $perl5lib_str;
    my $target_dirs = $args->{target_dirs};
    my @dir_codes = ("PERL_MODULE_DIR","PERL_MODULE_LIB_DIR");
    if ($target_dirs){
        foreach my $code (@dir_codes){
            my $path = $target_dirs->{ $code };
            if ($path){
                $unique_map{$path} = 1 unless $unique_map{$path};
            }
        }
        my @paths = sort keys %unique_map;
        if (@paths){
            $perl5lib_str = join(':',@paths);
        }
    }
    return $perl5lib_str;
}

__END__


=head1 SEE ALSO

ExtUtils::MakeMaker(3)

=head1 AUTHORS

MJ Ray mjr at phonecoop.coop
Galen Charlton galen.charlton at liblime.com

=cut

FIXME: deal with .htaccess
