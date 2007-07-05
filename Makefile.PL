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

use ExtUtils::MakeMaker;
use POSIX;

die "perl 5.6.1 or later required" unless ($] >= 5.006001);

=head1 NAME

Makefile.PL - Koha packager and installer

=head1 SYNOPSIS

perl Makefile.PL
make

=head1 DESCRIPTION

This is a packager and installer that uses
ExtUtils::MakeMaker, which is fairly common
on perl systems.
As well as building tar or zip files
and installing,
it allows us to check pre-requisites
and generate configuration files.

=head1 VARIABLES

=head2 NAME, VERSION, ABSTRACT, AUTHOR

Basic metadata about this software.

=head2 NO_META

Suppress generation of META.yml file.

=head2 PREREQ_PM

Hash of perl modules and versions required.

=head2 PM

Hash of file mappings

=head2 CONFIGURE

Maybe use prompt() here in future to get configuration values at installation time.

=head2 PL_FILES

This is a hash of PL scripts to run after installation and
the files to ask them to generate.
Maybe use the values from CONFIGURE
to generate initial configuration files.

=cut

WriteMakefile(

    NAME => 'koha',
    VERSION => strftime('2.9.%Y%m%d%H'),
    ABSTRACT => 'Award-winning integrated library system (ILS) and Web OPAC',
    AUTHOR => 'Koha Developers <koha-devel@nongnu.org>',
    NO_META => 1,
    PREREQ_PM => {
'CGI' => 3.15,
'CGI::Carp' => 1.29,
'DBI' => 1.53,
'Data::Dumper' => 2.121_08,
'Data::Random' => 0.05,
'Date::Calc' => 5.4,
'Date::Manip' => 5.44,
'Digest::MD5' => 2.36,
'File::Temp' => 0.16,
'GD::Barcode::UPCE' => 1.1,
'Getopt::Long' => 2.35,
'Getopt::Std' => 1.05,
'HTML::Template::Pro' => 0.65,
'HTML::Tree' => 3.1901,
'HTTP::Cookies' => 1.39,
'HTTP::Request::Common' => 1.26,
'LWP::Simple' => 1.41,
'LWP::UserAgent' => 2.033,
'Lingua::Stem' => 0.82,
'List::Util' => 1.18,
'Locale::Language' => 2.07,
'MARC::Charset' => 0.95,
'MARC::File::XML' => 0.86,
'MARC::Record' => 1.38,
'MIME::Base64' => 3.07,
'MIME::QuotedPrint' => 3.07,
'Mail::Sendmail' => 0.79,
'PDF::API2' => 2.000,
'PDF::API2::Page' => 2.000,
'PDF::API2::Util' => 2.000,
'PDF::Reuse' => 0.33,
'PDF::Reuse::Barcode' => 0.05,
'POSIX' => 1.09,
'Term::ANSIColor' => 1.10,
'Test' => 1.25,
'Test::Harness' => 2.56,
'Test::More' => 0.62,
'Text::Wrap' => 2005.082401,
'Time::HiRes' => 1.86,
'Time::localtime' => 1.02,
'Unicode::Normalize' => 0.32,
'XML::LibXML' => 1.59,
'XML::SAX::ParserFactory' => 1.01,
'XML::Simple' => 2.14,
'ZOOM' => 0,
        },

	# File tree mapping
	PM => map_tree(),

#   CONFIGURE => sub {
#     # Ask for options with prompt($question,$default) calls here?
#     return { macro => { 'export TEST' => '755' } }
#     },

#   PL_FILES => { # generator => target
#     'opac/getfromintranet.PL' => ['$(INST_LIBDIR)/opac/cgi-bin/detail.pl','$(INST_LIBDIR)/opac/cgi-bin/moredetail.pl','$(INST_LIBDIR)/opac/cgi-bin/search.pl','$(INST_LIBDIR)/opac/cgi-bin/subjectsearch.pl','$(INST_LIBDIR)/opac/cgi-bin/logout.pl'],
#     'misc/koha.conf.PL' => '$(INST_LIBDIR)/../etc/koha.conf',
#     'misc/apache-koha.conf.PL' => '$(INST_LIBDIR)/../etc/apache-koha.conf',
#     'misc/koha.sql.PL' => '$(INST_LIBDIR)/intranet/scripts/koha.sql',
#     'z3950/z3950-daemon-options.PL' => '$(INST_LIBDIR)/intranet/scripts/z3950daemon/z3950-daemon-options',
#     # fake target to check permissions
#     'misc/chmod.PL' => '$(INST_LIBDIR)/fake-target'
#     }
   # need to set ownerships
   # need to load koha.sql
   # need to link koha-httpd.conf
   # need to start z3950-daemon
);

=head1 FUNCTIONS

=head2 map_tree

This function lists all files and where to install each one.
It returns a hash reference suitable for PM.

=cut

sub map_tree {
	my %result => ();

=pod

C4/*.pm is copied to perl's lib namespace.

=cut
	foreach my $src (glob("C4/*.pm")) {
		$result{$src} = '$(INST_LIBDIR)/'.$src;
	}

=pod

CGIs are copied to koha/cgi-bin
and other scripts to koha/examples.

=cut
	# Misc scripts to koha/examples
	foreach my $src (glob("*.pl"),glob("*/*.pl"),glob("installer/*.pm"),glob("*/*/*.pl"),glob("*/*/*/*.pl")) {
		if ($src =~ /(misc|updater|rss)\//) {
			$result{$src} = '$(INST_LIBDIR)/koha/scripts/'.$src;
		} else {
			$result{$src} = '$(INST_LIBDIR)/koha/cgi-bin/'.$src;
		}
	}

=pod

Templates are copied to koha/templates,

=cut
	foreach my $src (glob("koha-tmpl/*"),glob("koha-tmpl/intranet-tmpl/*/*/*"),glob("koha-tmpl/intranet-tmpl/*/*/*/*"),glob("koha-tmpl/intranet-tmpl/*/*/*/*/*"),glob("koha-tmpl/opac-tmpl/*/*/*"),glob("koha-tmpl/opac-tmpl/*/*/*/*"),glob("koha-tmpl/opac-tmpl/*/*/*/*/*")) {

=pod

excluding non-files, CVS files and whitespace in filenames.

=cut
		if ((-f $src) && ($src !~ /(\/CVS\/|\s)/)) {
			$result{$src} = '$(INST_LIBDIR)/koha/templates/'.$src;
		}
	}

	return \%result;
}

__END__


=head1 SEE ALSO

ExtUtils::MakeMaker(3)

=cut

