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

use ExtUtils::MakeMaker;
use POSIX;

die "perl 5.6.1 or later required" unless ($] >= 5.006001);

# Hash up directory structure & files beginning with the directory we were called from (should be the base of koha)...

my $dirtree = hashdir('.');
my %result = ();

=head1 NAME

Makefile.PL - Koha packager and installer

=head1 SYNOPSIS

=head2 BASIC INSTALLATION

	perl Makefile.PL
	make
	sudo make install

=head2 PACKAGING RELEASE TARBALLS

	make manifest tardist
	make manifest zipdist

=head2 CLEANING UP

	make clean

=head1 DESCRIPTION

This is a Packager and installer that uses
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

=head2 CONFIGURE

Maybe use prompt() here in future to get configuration values 
interactively at installation time.

=head2 PL_FILES

This is a hash of PL scripts to run after installation and
the files to ask them to generate.
Maybe use the values from CONFIGURE
to generate initial configuration files in future.

=cut

my $marc_value;
my $lang_value;


while ($marc_value ne 'marc21' && $marc_value ne 'unimarc'){
   my $message= "Chose your flavour of MARC, unimarc or marc21 [marc21]";
   $marc_value=prompt($message) || 'marc21';
}
while ($lang_value ne 'en' && $lang_value ne 'fr'){
   my $message= "Choose your language, en or fr [en]";
   $lang_value=prompt($message) || 'en';
}

WriteMakefile(

    NAME => 'koha',
    #VERSION => strftime('2.9.%Y%m%d%H',gmtime),
    VERSION_FROM => 'C4/Context.pm',
    ABSTRACT => 'Award-winning integrated library system (ILS) and Web OPAC',
    AUTHOR => 'Koha Developers <koha-devel@nongnu.org>',
    NO_META => 1,
    PREREQ_PM => {
'CGI' => 3.15,
'CGI::Carp' => 1.29,
'CGI::Session' => '4.10',
'Class::Factory::Util' => 1.7,
'Class::Accessor' => 0.30,
'DBD::mysql' => 3.0008,
'DBI' => 1.53,
'Data::Dumper' => 2.121_08,
'Date::Calc' => 5.4,
'Date::Manip' => 5.44,
'Digest::MD5' => 2.36,
'File::Temp' => 0.16,
'GD::Barcode::UPCE' => 1.1,
'Getopt::Long' => 2.35,
'Getopt::Std' => 1.05,
'HTML::Template::Pro' => 0.65,
'HTTP::Cookies' => 1.39,
'HTTP::Request::Common' => 1.26,
'LWP::Simple' => 1.41,
'LWP::UserAgent' => 2.033,
'Lingua::Stem' => 0.82,
'List::Util' => 1.18,
'Locale::Language' => 2.07,
'MARC::Charset' => 0.98,
'MARC::Crosswalk::DublinCore' => 0.03,
'MARC::File::XML' => 0.88,
'MARC::Record' => 2.00,
'MIME::Base64' => 3.07,
'MIME::QuotedPrint' => 3.07,
'Mail::Sendmail' => 0.79,
'PDF::API2' => 2.000,
'PDF::API2::Page' => 2.000,
'PDF::API2::Util' => 2.000,
'PDF::Reuse' => 0.33,
'PDF::Reuse::Barcode' => 0.05,
'POSIX' => 1.09,
'Schedule::At' => 1.06,
'Term::ANSIColor' => 1.10,
'Test' => 1.25,
'Test::Harness' => 2.56,
'Test::More' => 0.62,
'Text::CSV' => 0.01,
'Text::CSV_XS' => 0.32,
'Text::Wrap' => 2005.082401,
'Time::HiRes' => 1.86,
'Time::localtime' => 1.02,
'Unicode::Normalize' => 0.32,
'XML::Dumper' => 0.81,
'XML::LibXML' => 1.59,
'XML::SAX::ParserFactory' => 1.01,
'XML::Simple' => 2.14,
'XML::RSS' => 1.31,
'ZOOM' => 1.16,
        },

	# File tree mapping
#	PM => map_tree(),
	PM => unhashdir($dirtree),

	# disable tests
	'test' => {TESTS => 't/dummy.t'},

#   CONFIGURE => sub {
#     # Ask for options with prompt($question,$default) calls here?
#     return { macro => { 'export TEST' => '755' } }
#     },

   PL_FILES => { # generator => target(s)
      'rewrite-config.PL' => [
         '$(PREFIX)/share/koha/etc/koha-conf.xml',
         '$(PREFIX)/share/koha/etc/koha-httpd.conf',
         '$(PREFIX)/share/koha/etc/zebradb/etc/passwd',
         '$(PREFIX)/share/koha/etc/zebradb/zebra-biblios.cfg',
         '$(PREFIX)/share/koha/etc/zebradb/zebra-authorities.cfg'
         ]
   }
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
        next if $file =~ m/^\.{1,2}/;
        my $path = $dir .'/' . $file;
        $tree->{$file} = hashdir($path), next if -d $path;
        push @{$tree->{'.'}}, $file;
    }
    return $tree;
}

=head2 unhashdir

This function unhashes the hash of hashes generated by hashdir().
This directory unhashing routine is the personal work of Chris Nighswonger (fbcit).
Modified here to build koha makefile. It lists all files and where to install each one.
It then returns a hash reference suitable for the PM variable above.

=cut

sub unhashdir{
	my $dirhash = shift;
	my $dirlevel = shift;
	my $toplevel = $dirlevel;
	for my $k1 ( sort keys %$dirhash ) {
		if ($k1 ne '.' && $k1 ne '') {
			$dirlevel = ( $dirlevel ? $dirlevel . '/' . $k1 : $k1 );
			&unhashdir($dirhash->{ $k1 }, $dirlevel);
			$dirlevel = $toplevel;
		}
		elsif ( $k1 eq '.' ) {
			foreach $file ( @{$dirhash->{ $k1 }} ) {
#				TODO: There are some hacks here that may be able to be improved... -fbcit
				if ( $file =~ /^./ ) { next; } # skip hidden files and directories.

				elsif ( $file =~ /\.pm/ && $dirlevel =~ /C4/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(INST_LIBDIR)/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # C4/*.pm is copied to perl's lib namespace.

				elsif ( $dirlevel !~ /koha-tmpl/ && $dirlevel =~ /(installer|errors)/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(PREFIX)/lib/cgi-bin/koha/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # error templates are copied to $(PREFIX)/lib/cgi-bin/koha/

				elsif ( $dirlevel =~ /koha-tmpl/ && $dirlevel !~ /errors/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(INST_LIBDIR)/koha/templates/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # error templates are copied to $(INST_LIBDIR)/koha/templates/

				elsif ( $dirlevel =~ /(misc|rss)/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(INST_LIBDIR)/koha/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # misc & rss are copied to koha,

#				elsif ( $dirlevel =~ /(intranet-tmpl|opac-tmpl)/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(INST_LIBDIR)/koha/templates/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # Templates are copied to koha/templates,

				elsif ( $file !~ /\.pl/ && $dirlevel =~ /etc/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(PREFIX)/share/koha/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # Misc etc to koha/etc

				elsif ( $file =~ /\.pl/ ) { $result{ ($dirlevel ? $dirlevel . '/' . $file : $file) } = '$(PREFIX)/lib/cgi-bin/koha/' . ($dirlevel ? $dirlevel . '/' . $file : $file); } # CGIs are copied to $(PREFIX)/lib/cgi-bin/koha/ print $result{ ($dirlevel ? $dirlevel . '/' . $file : $file)},"\n\n"; 

			}
			next;
		}
	}
	return \%result;
}

__END__


=head1 SEE ALSO

ExtUtils::MakeMaker(3)

=head1 AUTHORS

MJ Ray mjr at phonecoop.coop

=cut

