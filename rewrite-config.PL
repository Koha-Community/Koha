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

use Sys::Hostname;
use Socket;

=head1 NAME

rewrite-config.PL - helper for the Koha packager and installer

=head1 SYNOPSIS

	perl rewrite-config.PL configurationfile

=head1 DESCRIPTION

This helper script replaces placeholders in the
configuration files with value either supplied through
the environment (with export, or by putting them on
the start of the make command linke) or with reasonable
guesses worked out by the script.

=head2 KEYS

The following configuration keys are available:

BASE_DIR, MYSQL_DB, MYSQL_HOST, MYSQL_PASS, MYSQL_USER, WEBMASTER_EMAIL, WEBSERVER_DOMAIN,
WEBSERVER_HOST, WEBSERVER_IP, WEBSERVER_PORT, WEBSERVER_PORT_LIBRARIAN, ZEBRA_PASS, ZEBRA_USER

=cut

$myhost = hostname();
$mydomain = $myhost;
$mydomain =~ s/^.*?\.//;

# These are our configuration guesses
# Keys were extracted by
# <grep -o '__.*__' etc/* | cut -f2 -d: | sort -u | sed -e 's/^/  "/;s/$/" => "",/'
%configuration = (
  "__BASE_DIR__" => sprintf("/usr/lib/perl5/site-perl/%vd/koha",$^V),
  "__MYSQL_DB__" => "koha",
  "__MYSQL_HOST__" => $myhost,
  "__MYSQL_PASS__" => "katikoan",
  "__MYSQL_USER__" => "kohaadmin",
  "__WEBMASTER_EMAIL__" => 'webmaster@'.$mydomain,
  "__WEBSERVER_DOMAIN__" => $mydomain,
  "__WEBSERVER_HOST__" => $myhost,
  # This is set like this to rescue systems with broken DNS
  "__WEBSERVER_IP__" => $ENV{'WEBSERVER_IP'} || inet_ntoa(scalar gethostbyname($myhost||'localhost')) || die "Cannot get our own IP address: DNS fault?",
  "__WEBSERVER_PORT__" => 80,
  "__WEBSERVER_PORT_LIBRARIAN__" => 8080,
  "__ZEBRA_PASS__" => "zebrastripes",
  "__ZEBRA_USER__" => "kohauser",
);

# Override configuration from the environment
foreach $key (keys %configuration) {
  if (defined($ENV{$key})) {
    $configuration{$key} = $ENV{$key};
  }
}

$fname = $ARGV[0];
$file = read_file($fname);
$file =~ s/__.*?__/$configuration{$&}/seg;
chmod 0644, $fname;
open(OUTPUT,">$fname") || die "Can't open $fname for write: $!";
print OUTPUT $file;
close(OUTPUT);

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

