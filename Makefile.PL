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

die "perl 5.6.1 or later required" unless ($] >= 5.006001);

WriteMakefile(
    NAME => 'Koha',
    DISTNAME => 'koha',
    VERSION => '2.2.8',
    NO_META => 1,
    PREREQ_PM => {
        'DBI' => 0,
        'Date::Manip' => 0,
        'DBD::mysql' => 0,
        'Digest::MD5' => 0,
        'HTML::Template' => 0,
        'MARC::Record' => 2.0,     # custom
        'MARC::Charset' => 0.95,   # custom
        'MARC::File::XML' => 0.61, # custom
        'Mail::Sendmail' => 0,
        'PDF::API2' => 0.57,
        'PDF::Reuse::Barcode' => 0.05,
        #'Net::LDAP' => 0, # optional?
        'Net::Z3950::ZOOM' => 1.14,
        #'XML::Simple'=> 0,
	    'XML::LibXML' => 1.58
        },
   CONFIGURE => sub {
     # Figure out options here?
     return { macro => { 'export TEST' => '755' } }
     },
   PMLIBDIRS => [ '.' ],
#   PL_FILES => { # generator => target
#     'opac/getfromintranet.PL' => ['$(INST_LIBDIR)/opac/cgi-bin/detail.pl','$(INST_LIBDIR)/opac/cgi-bin/moredetail.pl','$(INST_LIBDIR)/opac/cgi-bin/search.pl','$(INST_LIBDIR)/opac/cgi-bin/subjectsearch.pl','$(INST_LIBDIR)/opac/cgi-bin/logout.pl'],
#     'misc/koha.conf.PL' => '$(INST_LIBDIR)/../etc/koha.conf',
#     'misc/apache-koha.conf.PL' => '$(INST_LIBDIR)/../etc/apache-koha.conf',
#     'misc/koha.sql.PL' => '$(INST_LIBDIR)/intranet/scripts/koha.sql',
#     'z3950/z3950-daemon-options.PL' => '$(INST_LIBDIR)/intranet/scripts/z3950daemon/z3950-daemon-options',
#     # fake target to check permissions
#     'misc/chmod.PL' => '$(INST_LIBDIR)/fake-target'
#     }
   # post-inst script:
   # need to set ownerships
   # need to load koha.sql
   # need to set up conf files
);

sub MY::libscan {
  my ($self,$path) = @_;
  
  # set up the recursion
  if (-d $path) { 1; }
  elsif ($path !~ /\//) { $path = ''; }
  # from here
  # reimplementation of buildrelease and Install::installfiles
  # ban some shell specials too
  elsif ($path =~ /(\/CVS\/|\.(bak|orig|PL)$|\/,|\/t\/|[^\$]\(| )/) { $path = ''; }
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
