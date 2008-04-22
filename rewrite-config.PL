# Copyright 2007 MJ Ray
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
# Current maintainer MJR http://mjr.towers.org.uk/
# See http://www.koha.org/wiki/?page=KohaInstaller
# 
# 2007/11/12	Added DB_PORT and changed other keywords to reflect multi-dbms support.	-fbcit

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
BASE_DIR, CGI_DIR, LOG_DIR, INSTALL_BASE,
DB_TYPE, DB_HOST, DB_PORT, DB_NAME, DB_PASS, DB_USER, WEBMASTER_EMAIL, WEBSERVER_DOMAIN,
WEBSERVER_HOST, WEBSERVER_IP, WEBSERVER_PORT, WEBSERVER_PORT_LIBRARIAN, ZEBRA_PASS, ZEBRA_USER

=head1 EXAMPLES

To override the guessed hostname and email address, run:

	WEBSERVER_HOST=mysecrethostname.com.invalid \
	WEBMASTER_EMAIL=webmaster@publichost.com make install

Note that if WEBSERVER_HOST does not resolve to an IP address, you will
also need to override WEBSERVER_IP.

=cut

$myhost = hostname();
$mydomain = $myhost;
$mydomain =~ s/^.*?\.//;
# This is set here to rescue systems with broken DNS
$myip = $ENV{'WEBSERVER_IP'} || inet_ntoa(scalar gethostbyname($myhost||'localhost')) || die "Cannot get our own IP address: DNS fault?";
$prefix = $ENV{'INSTALL_BASE'} || "/usr";

# These are our configuration guesses
# Keys were extracted by
# <grep -o '__.*__' etc/* | cut -f2 -d: | sort -u | sed -e 's/^/  "/;s/$/" => "",/'
%configuration = (
  "__KOHA_INSTALLED_VERSION__" => "no_version_found",
  "__LOG_DIR__" => "/var/log",
  "__DB_TYPE__" => "mysql",
  "__DB_NAME__" => "koha",
  "__DB_HOST__" => $myhost,
  "__DB_PORT__" => "3306",
  "__DB_USER__" => "kohaadmin",
  "__DB_PASS__" => "katikoan",
  "__WEBMASTER_EMAIL__" => 'webmaster@'.$mydomain,
  "__WEBSERVER_DOMAIN__" => $mydomain,
  "__WEBSERVER_HOST__" => $myhost,
  "__WEBSERVER_IP__" => $myip,
  "__WEBSERVER_PORT__" => "80",
  "__WEBSERVER_PORT_LIBRARIAN__" => "8080",
  "__ZEBRA_SRU_HOST__" => $myhost,
  "__ZEBRA_SRU_BIBLIOS_PORT__" => "9998",
  "__ZEBRA_SRU_AUTHORITIES_PORT__" => "9999",
  "__KOHA_USER__" => "koha",
  "__KOHA_GROUP__" => "koha",
  "__ZEBRA_PASS__" => "zebrastripes",
  "__ZEBRA_USER__" => "kohauser",
  '__INTRANET_CGI_DIR__' => "$prefix/intranet/cgi-bin",
  '__INTRANET_TMPL_DIR__' => "$prefix/intranet/templates",
  '__INTRANET_WWW_DIR__' => "$prefix/intranet/www",
  '__OPAC_CGI_DIR__' => "$prefix/opac/cgi-bin",
  '__OPAC_TMPL_DIR__' => "$prefix/opac/templates",
  '__OPAC_WWW_DIR__' => "$prefix/opac/www",
  '__PERL_MODULE_DIR__' =>  ($ENV{'INSTALLSITELIB'} || sprintf($prefix."/lib/perl5/site_perl/%vd",$^V))."/koha",
  '__KOHA_CONF_DIR__' => "$prefix/etc/koha",
  '__ZEBRA_CONF_DIR__' => "$prefix/etc/koha/zebradb",
  '__PAZPAR2_CONF_DIR__' => "$prefix/etc/koha/pazpar2",
  '__MISC_DIR__' => "$prefix/misc",
  '__SCRIPT_DIR__' => "$prefix/bin",
  '__MAN_DIR__' => "$prefix/man",
  '__DOC_DIR__' => "$prefix/doc",
  '__ZEBRA_LOCK_DIR__' => "$prefix/var/lock/zebradb",
  '__ZEBRA_DATA_DIR__' => "$prefix/var/lib/zebradb",
  '__ZEBRA_RUN_DIR__' => "$prefix/var/run/zebradb",
  '__ZEBRA_MARC_FORMAT__' => 'marc21',
  '__ZEBRA_LANGUAGE__' => 'en',
  '__ZEBRA_AUTH_CFG__' => 'zebra-authorities.cfg',
  '__AUTH_RETRIEVAL_CFG__' => 'retrieval-info-auth-grs1.xml',
  "__MERGE_SERVER_HOST__" => $myhost,
  "__MERGE_SERVER_PORT__" => '11001',
  "__PAZPAR2_HOST__" => $myhost,
  "__PAZPAR2_PORT__" => '11002',
  "__INSTALL_MODE__" => 'standard',
  "__INSTALL_BASE__" => '/usr/share/koha',
  "__INSTALL_ZEBRA__" => 'yes',
  "__INSTALL_SRU__" => 'yes',
  "__INSTALL_PAZPAR2__" => 'no',
  "__PAZPAR2_TOGGLE_XML_PRE__" => '<!--',
  "__PAZPAR2_TOGGLE_XML_POST__" => '-->',
  "__AUTH_INDEX_MODE__" => 'grs1',
  "__RUN_DATABASE_TESTS__" => 'no',
);

# Override configuration from the environment
foreach $key (keys %configuration) {
  if (defined($ENV{$key})) {
    $configuration{$key} = $ENV{$key};
  }
}

# munge commenting out the PazPar2 mergeserver
# entry in koha-conf.xml if necessary
if ($configuration{'__INSTALL_PAZPAR2__'} eq 'yes') {
    $configuration{'__PAZPAR2_TOGGLE_XML_PRE__'} = '';
    $configuration{'__PAZPAR2_TOGGLE_XML_POST__'} = '';
}

$fname = $ARGV[0];
$file = &read_file($fname);
$file =~ s/__.*?__/exists $configuration{$&} ? $configuration{$&} : $&/seg;

# At this point, file is in 'blib' and by default
# has mode a-w.  Therefore, must change permission
# to make it writable.  Note that stat and chmod
# (the Perl functions) should work on Win32
my $old_perm;
$old_perm = (stat $fname)[2] & 07777;
my $new_perm = $old_perm | 0200;
chmod $new_perm, $fname;

open(OUTPUT,">$fname") || die "Can't open $fname for write: $!";
print OUTPUT $file;
close(OUTPUT);

chmod $old_perm, $fname;

# Idea taken from perlfaq5
sub read_file($) {
  local(*INPUT,$/);
  open(INPUT,$_[0]) || die "Can't open $_[0] for read";
  my $file = <INPUT>;
  return $file;
}

__END__


=head1 SEE ALSO

Makefile.PL, ExtUtils::MakeMaker(3)

=head1 AUTHOR

MJ Ray mjr at phonecoop.coop

=cut

