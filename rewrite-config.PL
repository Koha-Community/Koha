# Copyright 2007 MJ Ray
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
# 2007/11/12    Added DB_PORT and changed other keywords to reflect multi-dbms support.    -fbcit

use Modern::Perl;
use Sys::Hostname;
use Socket;

=head1 NAME

rewrite-config.PL - helper for the Koha packager and installer

=head1 SYNOPSIS

    perl rewrite-config.PL configurationfile

=head1 DESCRIPTION

This helper script replaces keywords in the
configuration files with value either supplied through
the environment (with export, or by putting them on
the start of the make command line) or with reasonable
guesses worked out by the script.

=head2 KEYWORDS

The following configuration keywords are available:

PREFIX,
BASE_DIR, CGI_DIR, LOG_DIR, PLUGINS_DIR, INSTALL_BASE,
DB_TYPE, DB_HOST, DB_PORT, DB_NAME, DB_PASS, DB_USER, DB_USE_TLS, DB_TLS_CA_CERT, DB_TLS_CLIENT_KEY, DB_TLS_CLIENT_CERT, WEBMASTER_EMAIL, WEBSERVER_DOMAIN,
WEBSERVER_HOST, WEBSERVER_IP, WEBSERVER_PORT, WEBSERVER_PORT_LIBRARIAN, ZEBRA_PASS, ZEBRA_USER

=head1 EXAMPLES

To override the guessed hostname and email address, run:

    WEBSERVER_HOST=mysecrethostname.com.invalid \
    WEBMASTER_EMAIL=webmaster@publichost.com make install

Note that if WEBSERVER_HOST does not resolve to an IP address, you will
also need to override WEBSERVER_IP.

=cut

my $myhost;
my $mydomain;
if ( $myhost = $ENV{WEBSERVER_HOST} || hostname ) {
    ( $mydomain = $myhost ) =~ s/.*?\.//;
} else {
    $myhost   = 'localhost';
    $mydomain = 'localdomain';
}

my $myip;
unless ( $myip = $ENV{WEBSERVER_IP} ) {
    my $byname = gethostbyname($myhost)
        or die "Could not get the IP address of $myhost, DNS fault? ($!)";
    $myip = inet_ntoa $byname
        or die "can't inet_ntoa ($!)";
}

my $prefix = $ENV{'INSTALL_BASE'} || "/usr";

# These are our configuration guesses
# Keys were extracted by
# <grep -o '__.*__' etc/* | cut -f2 -d: | sort -u | sed -e 's/^/  "/;s/$/" => "",/'
my %configuration = (
    "__KOHA_INSTALLED_VERSION__"     => "no_version_found",
    "__LOG_DIR__"                    => "/var/log",
    "__PLUGINS_DIR__"                => "/var/lib/koha/plugins",
    "__DB_TYPE__"                    => "mysql",
    "__DB_NAME__"                    => "koha",
    "__DB_HOST__"                    => $myhost,
    "__DB_PORT__"                    => "3306",
    "__DB_USER__"                    => "kohaadmin",
    "__DB_PASS__"                    => "katikoan",
    "__DB_USE_TLS__"                 => "no",
    "__DB_TLS_CA_CERTIFICATE__"      => "",
    "__DB_TLS_CLIENT_CERTIFICATE__"  => "",
    "__DB_TLS_CLIENT_KEY__"          => "",
    "__WEBMASTER_EMAIL__"            => 'webmaster@' . $mydomain,
    "__WEBSERVER_DOMAIN__"           => $mydomain,
    "__WEBSERVER_HOST__"             => $myhost,
    "__WEBSERVER_IP__"               => $myip,
    "__WEBSERVER_PORT__"             => "80",
    "__WEBSERVER_PORT_LIBRARIAN__"   => "8080",
    "__ZEBRA_SRU_HOST__"             => $myhost,
    "__ZEBRA_SRU_BIBLIOS_PORT__"     => "9998",
    "__ZEBRA_SRU_AUTHORITIES_PORT__" => "9999",
    "__KOHA_USER__"                  => "koha",
    "__KOHA_GROUP__"                 => "koha",
    "__ZEBRA_PASS__"                 => "zebrastripes",
    "__ZEBRA_USER__"                 => "kohauser",
    '__BACKUP_DIR__'                 => "$prefix/var/spool",
    '__API_CGI_DIR__'                => "$prefix/api",
    '__INTRANET_CGI_DIR__'           => "$prefix/intranet/cgi-bin",
    '__INTRANET_TMPL_DIR__'          => "$prefix/intranet/templates",
    '__INTRANET_WWW_DIR__'           => "$prefix/intranet/www",
    '__OPAC_CGI_DIR__'               => "$prefix/opac/cgi-bin",
    '__OPAC_TMPL_DIR__'              => "$prefix/opac/templates",
    '__OPAC_WWW_DIR__'               => "$prefix/opac/www",
    '__PERL_MODULE_DIR__' => ( $ENV{'INSTALLSITELIB'} || sprintf( $prefix . "/lib/perl5/site_perl/%vd", $^V ) )
        . "/koha",
    '__KOHA_CONF_DIR__'         => "$prefix/etc/koha",
    '__ZEBRA_CONF_DIR__'        => "$prefix/etc/koha/zebradb",
    '__MISC_DIR__'              => "$prefix/misc",
    '__SCRIPT_DIR__'            => "$prefix/bin",
    '__SCRIPT_NONDEV_DIR__'     => "$prefix/bin",
    '__MAN_DIR__'               => "$prefix/man",
    '__DOC_DIR__'               => "$prefix/doc",
    '__ZEBRA_LOCK_DIR__'        => "$prefix/var/lock/zebradb",
    '__ZEBRA_DATA_DIR__'        => "$prefix/var/lib/zebradb",
    '__ZEBRA_RUN_DIR__'         => "$prefix/var/run/zebradb",
    '__ZEBRA_MARC_FORMAT__'     => 'marc21',
    '__ZEBRA_LANGUAGE__'        => 'en',
    '__ZEBRA_TOKENIZER__'       => 'chr',
    '__ZEBRA_TOKENIZER_STMT__'  => 'charmap word-phrase-utf.chr',
    '__ZEBRA_PTOKENIZER_STMT__' => 'charmap word-phrase-utf.chr',
    '__AUTH_RETRIEVAL_CFG__'    => 'retrieval-info-auth-dom.xml',
    '__BIB_RETRIEVAL_CFG__'     => 'retrieval-info-bib-dom.xml',
    '__ZEBRA_AUTH_CFG__'        => 'zebra-authorities-dom.cfg',
    '__ZEBRA_BIB_CFG__'         => 'zebra-biblios-dom.cfg',
    "__MERGE_SERVER_HOST__"     => $myhost,
    "__INSTALL_MODE__"          => 'standard',
    "__INSTALL_BASE__"          => '/usr/share/koha',
    "__INSTALL_SRU__"           => 'yes',
    "__RUN_DATABASE_TESTS__"    => 'no',
    "__PATH_TO_ZEBRA__"         => "",
    "__USE_MEMCACHED__"         => 'yes',
    "__MEMCACHED_SERVERS__"     => "",
    "__MEMCACHED_NAMESPACE__"   => "",
    "__USE_ELASTICSEARCH__"     => 'no',
    "__ELASTICSEARCH_SERVERS__" => "localhost:9200",
    "__ELASTICSEARCH_INDEX__"   => "koha",
    "__FONT_DIR__"              => "/usr/share/fonts/truetype/dejavu",
    "__TEMPLATE_CACHE_DIR__"    => "/tmp/koha",
    '__SMTP_HOST__'             => 'localhost',
    '__SMTP_PORT__'             => '25',
    '__SMTP_TIMEOUT__'          => '120',
    '__SMTP_SSL_MODE__'         => 'disabled',
    '__SMTP_USER_NAME__'        => '',
    '__SMTP_PASSWORD__'         => '',
    '__SMTP_DEBUG__'            => '0',
    '__PERL_MODULE_LIB_DIR__'   => "$prefix/lib",
    '__PERL5LIB_DIRS__'         => "$prefix/lib",
);

# Override configuration from the environment
foreach my $key ( keys %configuration ) {
    if ( defined( $ENV{$key} ) ) {
        $configuration{$key} = $ENV{$key};
    }
}

my $fname = $ARGV[0];
my $file  = &read_file($fname);
$file =~ s/__.*?__/exists $configuration{$&} ? $configuration{$&} : $&/seg;

# At this point, file is in 'blib' and by default
# has mode a-w.  Therefore, must change permission
# to make it writable.  Note that stat and chmod
# (the Perl functions) should work on Win32
my $old_perm;
$old_perm = ( stat $fname )[2] & oct(7777);
my $new_perm = $old_perm | oct(200);
chmod $new_perm, $fname;

open( my $output, ">", $fname ) || die "Can't open $fname for write: $!";
print $output $file;
close($output);

chmod $old_perm, $fname;

# Idea taken from perlfaq5
sub read_file {
    local $/;
    open( my $fh, '<', $_[0] ) || die "Can't open $_[0] for read";
    my $file = <$fh>;
    close $fh;
    return $file;
}

__END__


=head1 SEE ALSO

Makefile.PL, ExtUtils::MakeMaker(3)

=head1 AUTHOR

MJ Ray mjr at phonecoop.coop

=cut
