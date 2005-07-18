# Copyright 2005 MJ Ray and koha development team
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
# Current maintainer MJR slef at users.sourceforge.net
# See http://www.koha.org/wiki/?page=KohaInstaller

use ExtUtils::MakeMaker;

die "perl >= 5.6.1 required" unless ($] >= 5.006001);

WriteMakefile(
    NAME => 'Koha',
    DISTNAME => 'koha',
    VERSION => '2.3.0',
    NO_META => 1,
    PREREQ_PM => {
        'DBI' => 1,
        'Date::Manip' => 1,
        'DBD::MySQL' => 1,
        'HTML::Template' => 1,
        'Digest::MD5' => 1,
        'MARC::Record' => 1,
        'Mail::Sendmail' => 1,
        'PDF::API2' => 1,
        'Net::LDAP' => 1,
        'Event' => 1,
        'Net::Z3950' => 1
        },
   CONFIGURE => sub {
     # Figure out options here?
     return {}
     },
   PMLIBDIRS => [ '.' ],
   PL_FILES => { # generator => target
     # need to copy detail, moredetail, search, subjectsearch and logout from intranet to opac
     # need to write koha.conf
     # need to write koha-httpd.conf
     # need to write koha.sql
     }
   # need to check permissions somehow
);

sub MY::libscan {
  my ($self,$path) = @_;
  
  # set up the recursion
  if (-d $path) { 1; }
  elsif ($path !~ /\//) { $path = ''; }
  # from here
  # reimplementation of buildrelease and Install::installfiles
  # ban some shell specials too
  elsif ($path =~ /(\/CVS\/|\.bak$|\.orig$|\/,|\/t\/|[^\$]\(| )/) { $path = ''; }
  elsif (
    $path =~ s:\)/misc:\)/intranet/scripts: ||
    $path =~ s:\)/updater:\)/intranet/scripts/updater: ||
    $path =~ s:\)/z3950/(processz3950queue|.*sh):\)/intranet/scripts/z3950daemon/\1: ||
    $path =~ s:\)/z3950:\)/intranet/cgi-bin/z3950: ||
    $path =~ s:\)/koha-tmpl/intranet-tmpl:\)/intranet/htdocs/intranet-tmpl: ||
    $path =~ s:\)/koha-tmpl/intranet.html:\)/intranet/htdocs/index.html: ||
    $path =~ s:\)/koha-tmpl/opac-tmpl:\)/opac/htdocs/opac-tmpl: ||
    $path =~ s:\)/koha-tmpl/opac.html:\)/opac/htdocs/index.html: ||
    $path =~ s:\)/opac:\)/opac/cgi-bin:
    ) { 1; }
  elsif ($path !~ /\.p[lm]$/) { $path = ''; }
  elsif ($path !~ /\)\/C4/) { $path =~ s!/!/intranet/cgi-bin/!; }

  #print STDERR $path."\n";
  
  return($path);
  
  }
