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

use strict;
use warnings;
use ExtUtils::MakeMaker;
use POSIX;
use File::Spec;

my $DEBUG = 0;
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

Directory for Zebra's lock files.

=item ZEBRA_DATA_DIR

Directory for Zebra's data files.

=item ZEBRA_RUN_DIR

Directory for Zebra's UNIX-domain sockets.

=item EXAMPLE_DIR

Directory for example configuration files.  This directory
exists primarily to make it easier to change the
MARC format or language of the active Zebra
indexes.

=item SCRIPT_DIR

Directory for command-line scripts and daemons.

=item MAN_DIR

Directory for man pages created from POD -- will mostly
contain information of interest to Koha developers.

=item DOC_DIR

Directory for Koha documentation accessed from the 
command-line, e.g., READMEs.

=item LOG_DIR

Directory for Apache and Zebra logs produced by Koha.

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
  './authorities'               => 'INTRANET_CGI_DIR',
  './C4'                        => 'PERL_MODULE_DIR',
  './C4/SIP/t'                  => 'NONE',
  './C4/SIP/koha_test'          => 'NONE',
  './C4/tests'                  => 'NONE',
  './catalogue'                 => 'INTRANET_CGI_DIR',
  './cataloguing'               => 'INTRANET_CGI_DIR',
  './changelanguage.pl'         => 'INTRANET_CGI_DIR',
  './check_sysprefs.pl'         => 'NONE',
  './circ'                      => 'INTRANET_CGI_DIR',
  './edithelp.pl'               => 'INTRANET_CGI_DIR',
  './etc'                       => { target => 'KOHA_CONF_DIR', trimdir => -1 },
  './etc/zebradb'               => { target => 'ZEBRA_CONF_DIR', trimdir => -1 },
  './help.pl'                   => 'NONE', # FIXME
  './installer-CPAN.pl'         => 'NONE',
  './installer'                 => 'INTRANET_CGI_DIR',
  './koha-tmpl/errors'          => {target => 'INTRANET_CGI_DIR', trimdir => 2},
  './koha-tmpl/intranet-tmpl'   => {target => 'INTRANET_TMPL_DIR', trimdir => -1},
  './koha-tmpl/opac-tmpl'       => {target => 'OPAC_TMPL_DIR', trimdir => -1},
  './kohaversion.pl'            => 'INTRANET_CGI_DIR', # FIXME this may need to be in OPAC_CGI_DIR as well, with an update to C4::Context
  './labels'                    => 'INTRANET_CGI_DIR',
  './mainpage.pl'               => 'INTRANET_CGI_DIR',
  './Makefile.PL'               => 'NONE',
  './MANIFEST.SKIP'             => 'NONE',
  './members'                   => 'INTRANET_CGI_DIR',
  './misc'                      => { target => 'SCRIPT_DIR', trimdir => -1 }, 
  './misc/info'                 => { target => 'DOC_DIR', trimdir => 2 },
  './misc/release notes'        => { target => 'DOC_DIR', trimdir => 2 },
  './misc/translator'           => { target => 'EXAMPLE_DIR', trimdir => 2 }, 
  './misc/installer_devel_notes' => 'NONE',
  './opac'                      => 'OPAC_CGI_DIR',
  './README.txt'                => 'NONE',
  './reports'                   => 'INTRANET_CGI_DIR',
  './reserve'                   => 'INTRANET_CGI_DIR',
  './reviews'                   => 'INTRANET_CGI_DIR',
  './rewrite-config.PL'         => 'NONE',
  './reviews'                   => 'INTRANET_CGI_DIR',
  './rss'                       => 'NONE', # FIXME deal with a little later
  './serials'                   => 'INTRANET_CGI_DIR',
  './sms'                       => 'INTRANET_CGI_DIR',
  './suggestion'                => 'INTRANET_CGI_DIR',
  './svc'                       => 'INTRANET_CGI_DIR',
  './t'                         => 'NONE',
  './tmp'                       => 'NONE', # FIXME deal with later
  './tools'                     => 'INTRANET_CGI_DIR',
  './virtualshelves'            => 'INTRANET_CGI_DIR',
  # ignore files and directories created by the install itself
  './pm_to_blib'                => 'NONE',
  './blib'                      => 'NONE',
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

=item INSTALL_ZEBRA

Whether to install Zebra configuration files and data
directories.

=item ZEBRA_MARC_FORMAT

Specifies format of MARC records to be indexed by Zebra.

=item ZEBRA_LANGUAGE

Specifies primary language of records that will be 
indexed by Zebra.

=back

=cut

# default configuration options
my %config_defaults = (
  'INSTALL_MODE'      => 'standard',
  'INSTALL_BASE'      => '/usr/share/koha',
  'INSTALL_ZEBRA'     => 'yes',
  'ZEBRA_MARC_FORMAT' => 'marc21',
  'ZEBRA_LANGUAGE'    => 'en',
);

# valid values for certain configuration options
my %valid_config_values = (
  'INSTALL_MODE'  => { 'standard' => 1, 'single' => 1, 'dev' => 1 },
  'INSTALL_ZEBRA' => { 'yes' => 1, 'no' => 1 },
  'ZEBRA_MARC_FORMAT' => { 'marc21' => 1, 'unimarc' => 1 }, # FIXME should generate from contents of distributation
  'ZEBRA_LANGUAGE'    => { 'en' => 1, 'fr' => 1 }, # FIXME should generate from contents of distribution
);

my %config = get_configuration(\%config_defaults, \%valid_config_values);
my %target_directories = get_target_directories(\%config);
my $file_map = {};
get_file_map($target_map, $dirtree, $file_map);

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
	PM => $file_map,

    # Man pages generated from POD
    INSTALLMAN1DIR => File::Spec->catdir($target_directories{'MAN_DIR'}, 'man1'),
    INSTALLMAN3DIR => File::Spec->catdir($target_directories{'MAN_DIR'}, 'man3'),

#   CONFIGURE => sub {
#     # Ask for options with prompt($question,$default) calls here?
#     return { macro => { 'export TEST' => '755' } }
#     },

   PL_FILES => { # generator => target(s)
      'rewrite-config.PL' => [
         'blib/KOHA_CONF_DIR/koha-conf.xml',
         'blib/KOHA_CONF_DIR/koha-httpd.conf',
         'blib/ZEBRA_CONF_DIR/etc/passwd',
         'blib/ZEBRA_CONF_DIR/zebra-biblios.cfg',
         'blib/ZEBRA_CONF_DIR/zebra-authorities.cfg'
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

=head2 get_configuration_options

This prompts the user for various configuration options.

=cut

sub get_configuration {
  my $defaults = shift;
  my $valid_values = shift;
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

Please choose the installation mode);
    $msg .= _add_valid_values_disp('INSTALL_MODE', $valid_values);
    $config{'INSTALL_MODE'} = _get_value('INSTALL_MODE', $msg, $defaults->{'INSTALL_MODE'}, $valid_values);

    # set message and default value for INSTALL_BASE
    # depending on value of INSTALL_MODE
    my $install_base_default = $defaults->{'INSTALL_BASE'};
    if ($config{'INSTALL_MODE'} eq 'dev') {
        $msg = q(
Please specify the directory in which to install Koha's
active configuration files and (if applicable) the
Zebra database.  Koha's CGI scripts and templates will
be run from the current directory.);
        # FIXME - home directory portability consideration apply
        $install_base_default = (exists $ENV{'HOME'}) ? "$ENV{'HOME'}/koha-dev" : "/usr/share/koha-dev";
    } elsif ($config{'INSTALL_MODE'} eq 'single') {
        $msg = "\nPlease specify the directory in which to install Koha";
        # FIXME -- we're assuming under a 'single' mode install
        # that user will likely want to install under the home
        # directory.  This is OK in and of itself, but we should
        # use File::HomeDir to locate the home directory portably.  
        # This is deferred for now because File::HomeDir is not yet
        # core.
        $install_base_default = (exists $ENV{'HOME'}) ? "$ENV{'HOME'}/koha" : "/usr/share/koha";
    } else {
        # must be standard
        $msg = q(
Please specify the directory under which most Koha files 
will be installed.

Note that if you are planning in installing more than 
one instance of Koha, you may want to modify the last
component of the directory path, which will be used
as the package name in the FHS layout.);
    }
    $config{'INSTALL_BASE'} = _get_value('INSTALL_BASE', $msg, $install_base_default, $valid_values);
    $config{'INSTALL_BASE'} = File::Spec->rel2abs($config{'INSTALL_BASE'});

    $msg = q(
Koha can use the Zebra search engine for high-performance
searching of bibliographic and authority records.  If you
have installed the Zebra software and would like to use it,
please answer 'yes' to the following question.  Otherwise, 
Koha will default to using its internal search engine.

Please specify whether to install the Zebra configuration files);
    $msg .= _add_valid_values_disp('INSTALL_ZEBRA', $valid_values);
    $config{'INSTALL_ZEBRA'} = _get_value('INSTALL_ZEBRA', $msg, $defaults->{'INSTALL_ZEBRA'}, $valid_values);

    if ($config{'INSTALL_ZEBRA'} eq 'yes') {
        $msg = q(
Since you've chosen to use Zebra with Koha,
you must specify the primary MARC format of the
records to be indexed by Zebra.

Koha provides Zebra configuration files for MARC 21
and UNIMARC.

Please specify the MARC format);
        $msg .= _add_valid_values_disp('ZEBRA_MARC_FORMAT', $valid_values);
        $config{'ZEBRA_MARC_FORMAT'} = _get_value('ZEBRA_MARC_FORMAT', $msg, $defaults->{'ZEBRA_MARC_FORMAT'}, $valid_values);
        $msg = q(
Koha supplies Zebra configuration files tuned for
searching either English (en) or French (fr) MARC
records.

Please specify the primary language of the MARC records);
        $msg .= _add_valid_values_disp('ZEBRA_LANGUAGE', $valid_values);
        $config{'ZEBRA_LANGUAGE'} = _get_value('ZEBRA_LANGUAGE', $msg, $defaults->{'ZEBRA_LANGUAGE'}, $valid_values);
    }
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

    my $val = prompt($msg, $default);
    while (exists $valid_values->{$key} and not exists $valid_values->{$key}->{$val}) {
        my $retry_msg = "Value '$val' is not a valid option.\n";
        $retry_msg .= "Please enter a value";
        $retry_msg .= _add_valid_values_disp($key, $valid_values);
        $val = prompt($retry_msg, $default);
    }
    return $val;
}

=head2 get_target_directories 

Creates a hash mapping from symbols for installation target
directories to actual directory paths.

=cut

sub get_target_directories {
    my $config = shift;

    my $base = $config->{'INSTALL_BASE'};
    my $mode = $config->{'INSTALL_MODE'};

    # get last component of install base directory
    # to treat as package name
    my ($volume, $directories, $file) = File::Spec->splitpath($base, 1);
    my @basedir = File::Spec->splitdir($directories);
    my $package = pop @basedir;

    my %dirmap = ();
    if ($mode eq 'single') {
        $dirmap{'INTRANET_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'cgi-bin');
        $dirmap{'INTRANET_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs', 'intranet-tmpl');
        $dirmap{'INTRANET_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs');
        $dirmap{'OPAC_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'cgi-bin');
        $dirmap{'OPAC_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs', 'opac-tmpl');
        $dirmap{'OPAC_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs');
        $dirmap{'PERL_MODULE_DIR'} = File::Spec->catdir(@basedir, $package, 'lib');
        $dirmap{'KOHA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc');
        $dirmap{'ZEBRA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc', 'zebradb');
        $dirmap{'EXAMPLE_DIR'} = File::Spec->catdir(@basedir, $package, 'example');
        $dirmap{'SCRIPT_DIR'} = File::Spec->catdir(@basedir, $package, 'bin');
        $dirmap{'MAN_DIR'} = File::Spec->catdir(@basedir, $package, 'man');
        $dirmap{'DOC_DIR'} = File::Spec->catdir(@basedir, $package, 'doc');
        $dirmap{'ZEBRA_LOCK_DIR'} = File::Spec->catdir(@basedir, $package, 'var', 'lock', 'zebradb');
        $dirmap{'LOG_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'log');
        $dirmap{'ZEBRA_DATA_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lib', 'zebradb');
        $dirmap{'ZEBRA_RUN_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'run', 'zebradb');
    } elsif ($mode eq 'dev') {
        my $curdir = File::Spec->rel2abs(File::Spec->curdir());
        $dirmap{'INTRANET_CGI_DIR'} = File::Spec->catdir($curdir);
        $dirmap{'INTRANET_TMPL_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl', 'intranet-tmpl');
        $dirmap{'INTRANET_WWW_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl', 'intranet-tmpl');
        $dirmap{'OPAC_CGI_DIR'} = File::Spec->catdir($curdir, 'opac');
        $dirmap{'OPAC_TMPL_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl', 'opac-tmpl');
        $dirmap{'OPAC_WWW_DIR'} = File::Spec->catdir($curdir, 'koha-tmpl', 'opac-tmpl');
        $dirmap{'PERL_MODULE_DIR'} = File::Spec->catdir($curdir);
        $dirmap{'KOHA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc');
        $dirmap{'ZEBRA_CONF_DIR'} = File::Spec->catdir(@basedir, $package, 'etc', 'zebradb');
        $dirmap{'EXAMPLE_DIR'} = File::Spec->catdir(@basedir, $package, 'example');
        $dirmap{'SCRIPT_DIR'} = File::Spec->catdir(@basedir, $package, 'bin');
        $dirmap{'MAN_DIR'} = File::Spec->catdir(@basedir, $package, 'man');
        $dirmap{'DOC_DIR'} = File::Spec->catdir(@basedir, $package, 'doc');
        $dirmap{'ZEBRA_LOCK_DIR'} = File::Spec->catdir(@basedir, $package, 'var', 'lock', 'zebradb');
        $dirmap{'LOG_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'log');
        $dirmap{'ZEBRA_DATA_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'lib', 'zebradb');
        $dirmap{'ZEBRA_RUN_DIR'} =  File::Spec->catdir(@basedir, $package, 'var', 'run', 'zebradb');
    } else {
        # mode is standard, i.e., 'fhs'
        $dirmap{'INTRANET_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'cgi-bin');
        $dirmap{'INTRANET_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs', 'intranet-tmpl');
        $dirmap{'INTRANET_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'intranet', 'htdocs');
        $dirmap{'OPAC_CGI_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'cgi-bin');
        $dirmap{'OPAC_TMPL_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs', 'opac-tmpl');
        $dirmap{'OPAC_WWW_DIR'} = File::Spec->catdir(@basedir, $package, 'opac', 'htdocs');
        $dirmap{'PERL_MODULE_DIR'} = File::Spec->catdir(@basedir, $package, 'lib');
        $dirmap{'KOHA_CONF_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'etc', $package);
        $dirmap{'ZEBRA_CONF_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'etc', $package, 'zebradb');
        $dirmap{'EXAMPLE_DIR'} = File::Spec->catdir(@basedir, $package, 'example');
        $dirmap{'SCRIPT_DIR'} = File::Spec->catdir(@basedir, $package, 'bin');
        $dirmap{'MAN_DIR'} = File::Spec->catdir(@basedir, $package, 'man');
        $dirmap{'DOC_DIR'} = File::Spec->catdir(@basedir, $package, 'doc');
        $dirmap{'ZEBRA_LOCK_DIR'} = File::Spec->catdir(File::Spec->rootdir(), 'var', 'lock', $package, 'zebradb');
        $dirmap{'LOG_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'log', $package);
        $dirmap{'ZEBRA_DATA_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'lib', $package, 'zebradb');
        $dirmap{'ZEBRA_RUN_DIR'} =  File::Spec->catdir(File::Spec->rootdir(), 'var', 'run', $package, 'zebradb');
    }

    foreach my $key (sort keys %dirmap) {
        print sprintf("%-25.25s%s\n", $key, $dirmap{$key});
    }
    return %dirmap;
}

package MY;

sub test {
    my $self = shift;
    my $test = $self->SUPER::test(@_);
    $test =~ s!\$\(INST_LIB\)!blib/PERL_MODULE_DIR!g;
    return $test;
}

sub install {
    my $self = shift;
    my $install = ""; 
    # NOTE: we're *not* doing this: my $install = $self->SUPER::install(@_);
    # This means that we're completely overriding EU::MM's default
    # installation and uninstallation targets.
    foreach my $key (sort keys %target_directories) {
        $install .= qq(
KOHA_INST_$key = blib/$key
KOHA_DEST_$key = $target_directories{$key}
);
    }

    $install .= qq(
install :: all install_koha
\t\$(NOECHO) \$(NOOP)
);
    $install .= "install_koha ::\n";      
    $install .= "\t\$(NOECHO) umask 022; \$(MOD_INSTALL) \\\n";
    foreach my $key (sort keys %target_directories) {
        $install .= "\t\t\$(KOHA_INST_$key) \$(KOHA_DEST_$key) \\\n";
    }
    $install .= "\t\t\$(INST_MAN1DIR) \$(DESTINSTALLMAN1DIR) \\\n";
    $install .= "\t\t\$(INST_MAN3DIR) \$(DESTINSTALLMAN3DIR)\n";
    return $install;
}

sub postamble {
    # put directory mappings into Makefile
    # so that Make will export as environment
    # variables -- this is for the use of
    # rewrite-confg.PL
    my $env = join("\n", map { "export __${_}__ = $target_directories{$_}" } keys %target_directories); 
    return "$env\n";
}

__END__


=head1 SEE ALSO

ExtUtils::MakeMaker(3)

=head1 AUTHORS

MJ Ray mjr at phonecoop.coop

=cut
FIXME: Zebra lang/MARC mapping
FIXME: deal with .htaccess
