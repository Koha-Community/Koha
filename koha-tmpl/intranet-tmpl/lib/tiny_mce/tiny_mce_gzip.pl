#!/usr/bin/perl
use strict;
use warnings FATAL => 'all', NONFATAL => 'redefine';


###################################################
#
#  @author Clinton Gormley
#  @copyright Copyright 2008, Clinton Gormley, All rights reserved.
#
#  This file compresses the TinyMCE JavaScript using GZip and
#  enables the browser to do two requests instead of one for each .js file.
#  Notice: This script defaults the button_tile_map option to true for
#  extra performance.
#
##################################################
our $VERSION  = '2.0.3';

# Default cache path is subdir to tinymce
my $cache_path = 'cache';

# Custom extra javascripts to pack
my @custom_files = qw();

# Cache for 10 days
our $cache_for = 3600 * 24 * 10;


##################################################

use File::Spec();
use Compress::Zlib();
use Digest::MD5 qw(md5_hex);
use File::Slurp qw(slurp write_file);

my %P = %{ get_params() };
our $cwd = get_cwd();

my @extra_headers
    = $P{charset}
    ? 'Content-type: text/javascript; charset=' . $P{charset}
    : 'Content-type: text/javascript';

# If this file is requested directly, send the JS compressor file
# and init with default settings
unless ( $P{js} eq 'true' ) {
    print headers(@extra_headers);
    print slurp_file('tiny_mce_gzip.js');
    print "tinyMCE_GZ.init({})\n";
    exit;
}

my %modules = (
         custom_files => \@custom_files,
         ( map { $_ => [ split( ',', $P{$_} ) ] } qw(plugins languages themes) )
);

## Check if it supports gzip
my $accept_header = $ENV{HTTP_ACCEPT_ENCODING} || '';
my ($supports_gzip) = ( $accept_header =~ m/((?:x-)?gzip)\b/i );
my $compress = ( $supports_gzip && $P{compress} ne 'false' ) ? 1 : 0;

# Get params for cache
$cache_path
    = File::Spec->file_name_is_absolute($cache_path)
    ? $cache_path
    : File::Spec->catdir( $cwd, 'cache' );
my $cache_key = get_cache_key( \%modules,         $P{suffix} );
my $js_file   = File::Spec->catfile( $cache_path, $cache_key . '.js' );
my $gz_file   = File::Spec->catfile( $cache_path, $cache_key . '.gz' );
my $cache_file = $compress ? $gz_file : $js_file;

# Use cached data or generate new?
my $data
    = ( $P{diskcache} eq 'true' && -e $cache_file )
    ? slurp_file($cache_file)
    : generate_and_cache_data( \%modules, $compress, $js_file,
                               $gz_file,  $P{core},  $P{suffix} );

# Send data
if ($compress) {
    push @extra_headers, "Content-Encoding: $supports_gzip";
}

print headers(@extra_headers);
print $data;

exit;

#===================================
sub get_params {
#===================================
    my $qs = $ENV{QUERY_STRING} || '';
    $qs =~ s/(%([0-9a-fA-F]{2,2}))/my $c = hex($2); $c < 256 ? chr($c) : $1/eg;
    my @raw_params = split( /[&;]+/, $qs );
    my %parsed = map { $_ => '' } qw(
        plugins languages themes
        diskcache js compress
        core suffix charset );
    while ( my $pair = shift @raw_params ) {
        my ( $key, $value ) = split( /=/, $pair );
        next unless exists $parsed{$key};
        $value ||= '';
        $value =~ tr/0-9a-zA-Z\-_,//cd;
        $parsed{$key} = $value;
    }
    $parsed{suffix} = $parsed{suffix} eq '_src' ? '_src' : '';
    return \%parsed;
}

#===================================
sub headers {
#===================================
    my @extra_headers = @_;
    my $date          = scalar( gmtime( time + $cache_for ) ) . " GMT";
    return <<HEADERS. join( "\n", @extra_headers ) . "\n\n";
Vary: Accept-Encoding
Expires: $date
HEADERS

}

#===================================
sub slurp_file {
#===================================
    my $file = File::Spec->catfile(@_);
    unless ( File::Spec->file_name_is_absolute($file) ) {
        $file = File::Spec->catfile( $cwd, $file );
    }
    return slurp( $file, binmode => ':raw' );
}

#===================================
sub get_cwd {
#===================================
    return File::Spec->catpath(
              File::Spec->no_upwards( ( File::Spec->splitpath($0) )[ 0, 1 ] ) );
}

#===================================
sub get_cache_key {
#===================================
    my $modules = shift;
    my $suffix  = shift;
    my $cache_key = md5_hex(
                         join( '',
                               ( map { @{ $modules->{$_} } }
                                     qw(plugins languages themes custom_files )
                               ),
                               $suffix
                         )
    );

    # Untaint cache_key
    ($cache_key) = ( $cache_key =~ /^([0-9a-f]+)$/ );
    die "Couldn't generate cache key - problem with MD5 libraries?"
        unless $cache_key;

    return $cache_key;
}

#===================================
sub generate_and_cache_data {
#===================================
    my $modules  = shift;
    my $compress = shift;
    my $js_file  = shift;
    my $gz_file  = shift;
    my $core     = shift;
    my $suffix   = shift;

    # Core file plus langs
    my @langs = @{ $modules->{languages} };

    my $js_data = join( '', map { slurp_file( 'langs', "$_.js" ) } @langs );

    # Themes plus their langs
    foreach my $theme ( @{ $modules->{themes} } ) {
        $js_data
            .= slurp_file( 'themes', $theme, "editor_template${suffix}.js" )
            . join( '',
                    map { slurp_file( 'themes', $theme, 'langs', "$_.js" ) }
                        @langs );
    }

    # Plugins plus their langs
    foreach my $plugin ( @{ $modules->{plugins} } ) {
        $js_data
            .= slurp_file( 'plugins', $plugin, "editor_plugin${suffix}.js" )
            . join(
            '',
            map {
                eval {
                    slurp_file( 'plugins', $plugin, 'langs', "$_.js" );
                    }
                    || ''
                } @langs
            );
    }

    # Any custom files
    $js_data .= slurp_file($_) for ( @{ $modules->{custom_files} } );

    # If the core is required, add that too
    unless ( $core eq 'false' ) {
        $js_data
            = slurp_file("tiny_mce${suffix}.js")
            . 'tinyMCE_GZ.start();'
            . $js_data
            . 'tinyMCE_GZ.end();';
    }

    # Compress data
    my $gz_data = Compress::Zlib::memGzip($js_data)
        or die "Couldn't gzip data";

    # write files to disk
    write_file( $js_file, { binmode => ':raw' }, $js_data );
    write_file( $gz_file, { binmode => ':raw' }, $gz_data );

    # Choose the correct data to be sent
    return $compress ? $gz_data : $js_data;
}

1;

=head1 NAME

TinyMCE Compressor Perl version 2.0.3

=head1 DESCRIPTION

TinyMCE Compressor gzips all javascript files in TinyMCE to a single
streamable file. This makes the overall download size 75% smaller and
the number of requests will also be reduced. The overall initialisation
time for TinyMCE will be reduced dramatically if you use this script.

The Perl fork of the TinyMCE compressor project page is at
L<http://github.com/clintongormley/tinymce_compressor>

=head2 Installation

Here is a step by step list on how to install the GZip compressor.

=over

=item Prerequisites

Use CPAN to install L<File::Spec>, L<File::Slurp>,
L<Digest::MD5> and L<Compress::Zlib>.

=item Installing files

Copy the tiny_mce_gzip.js and tiny_mce_gzip.pl to the tiny_mce
directory. The same directory that contains the tiny_mce.js file.

=item Create a cache directory

Create the sub directory 'C<cache>' under your tiny_mce
directory and give your web server permission to write to it, eg:

        cd /path/to/tinymce
        mkdir cache
        chown apache cache
        chmod u+rwx,og-rwx cache


B<PLEASE NOTE:> If you upgrade your Tiny MCE editor, you will need to
clear out the cache directory.

=item Update your code

Remove the current script tag:

    <script type="text/javascript" src="tinymce/jscripts/tiny_mce/tiny_mce.js"></script>

And replace it with:

    <script type="text/javascript" src="tinymce/jscripts/tiny_mce/tiny_mce_gzip.js"></script>

Add the new GZip initialization call (see below) that will
tell the compressor what to include in the output. This should be the
sum of all themes, plugins and languages contained on page.

=back

=head2 Running under mod_perl

You either need to set up your web server to execute
C<tiny_mce_gzip.pl> as a CGI script, or you can configure Apache to run
it under mod_perl, which will greatly speed up the response.

To do this, you could use a configuration like this:

    <Location /tiny_mce/tiny_mce_gzip.pl>
        SetHandler perl-script
        PerlResponseHandler ModPerl::Registry
        PerlOptions +ParseHeaders
        Options +ExecCGI
        Order allow,deny
        Allow from all
    </Location>

=head2 Example of configuration

The example below will pack both themes and all plugins into one
file/stream. Remove the things you don't need or add you custom plugins
to the settings below. Remember that the tinyMCE_GZ.init call must be
placed in B<it's own script tag.>

    <script type="text/javascript" src="tinymce/jscripts/tiny_mce/tiny_mce_gzip.js"></script>
    <script type="text/javascript">
        tinyMCE_GZ.init({
            plugins     : 'style,layer,...etc',
            themes      : 'simple,advanced',
            languages   : 'en',
            disk_cache  : true
        });
    </script>

    <!-- Needs to be seperate script tags! -->

    <script type="text/javascript">
        tinyMCE.init({
            .. your normal init ..
        });
    </script>

=head2 Troubleshooting

=over

=item *

The GZip compressor can fail to load if the server has odd settings or
is missing the required support for it to function. To see compilation
errors or other problems we suggest that you use HTTP debugging tools
like HTTP Fiddler or, in Firefox, the Firebug addon, or point you
browser directly to the GZip file.

=item *

Consult the changelog of this script and make sure that you use the
latest version of TinyMCE. These two parts are pretty much tied
together so there is no guarantee that it will work with older versions
of TinyMCE.

=back

Visit the TinyMCE forum for help with the TinyMCE Gzip Compressor.

=head2 Changelog and Bugs

See the ChangeLog here : changelog.txt

Please report any bugs that you find to clint@traveljury.com

=head2 License notice

The perl part of this library has been written by Clinton Gormley
(clint@traveljury.com).

The javascript part has been taken from the PHP compressor available at
MoxieCode.

This library is under LGPL license but it uses the zlib library, which
is free to use in commercial applications. (Read the zlib licence).

=cut
