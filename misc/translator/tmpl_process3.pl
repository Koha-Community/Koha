#!/usr/bin/perl
# This file is part of Koha
# Parts copyright 2003-2004 Paul Poulain
# Parts copyright 2003-2004 Jerome Vizcaino
# Parts copyright 2004 Ambrose Li

use FindBin;
use lib $FindBin::Bin;

=head1 NAME

tmpl_process3.pl - Alternative version of tmpl_process.pl
using gettext-compatible translation files

=cut

use strict;
#use warnings; FIXME - Bug 2505
use File::Basename qw( fileparse );
use Getopt::Long qw( GetOptions );
use Locale::PO;
use TmplTokenizer;
use VerboseWarnings qw( pedantic_p warn_additional warn_normal warn_pedantic error_additional error_normal );

###############################################################################

use vars qw( @in_dirs @filenames @match @nomatch $str_file $out_dir $quiet );
use vars qw( @excludes $exclude_regex );
use vars qw( $recursive_p );
use vars qw( $pedantic_p );
use vars qw( $href );
use vars qw( $type );   # file extension (DOS form without the dot) to match
use vars qw( $charset_in $charset_out );

###############################################################################

sub find_translation {
    my($s) = @_;
    my $key = $s;
    if ($s =~ /\S/s) {
      $key = TmplTokenizer::string_canon($key);
      $key = TmplTokenizer::charset_convert($key, $charset_in, $charset_out);
      $key = TmplTokenizer::quote_po($key);
    }
    if (defined $href->{$key} && !$href->{$key}->fuzzy && length Locale::PO->dequote($href->{$key}->msgstr)){
	if ($s =~ /^(\s+)/){
	    return $1 . Locale::PO->dequote($href->{$key}->msgstr);
	}
	else {
	    return Locale::PO->dequote($href->{$key}->msgstr);
	}
    }
    else {
	return $s;
    }
}

sub text_replace_tag {
    my($t, $attr) = @_;
    my $it;
    my @ttvar;

    # value [tag=input], meta
    my $tag = ($t =~ /^<(\S+)/s) ? lc($1) : undef;
    my $translated_p = 0;
    for my $a ('alt', 'content', 'title', 'value', 'label', 'placeholder', 'aria-label') {
    if ($attr->{$a}) {
        next if $a eq 'label' && $tag ne 'optgroup';
        next if $a eq 'content' && $tag ne 'meta';
        next if $a eq 'value' && ($tag ne 'input' || (ref $attr->{'type'} && $attr->{'type'}->[1] =~ /^(?:checkbox|hidden|radio)$/)); # FIXME

        my($key, $val, $val_orig, $order) = @{$attr->{$a}}; #FIXME
        if ($val =~ /\S/s) {
            # for selected attributes replace '[%..%]' with '%s' and remember matches
            if ( $a =~ /title|value|alt|content|placeholder|aria-label/ ) {
                while ( $val =~ s/(\[\%.*?\%\])/\%s/ ) {
                    my $var = $1;
                    push @ttvar, $1;
                }
            }
            # find translation for transformed attributes
            my $s = find_translation($val);
            # replace '%s' with original content (in order) on translated string, this is fragile!
            if ( $a =~ /title|value|alt|content|placeholder|aria-label/ and @ttvar ) {
                while ( @ttvar ) {
                    my $var = shift @ttvar;
                    $s =~ s/\%s/$var/;
                }
            }
            if ($attr->{$a}->[1] ne $s) { #FIXME
                $attr->{$a}->[1] = $s; # FIXME
                $attr->{$a}->[2] = ($s =~ /"/s)? "'$s'": "\"$s\""; #FIXME
                $translated_p = 1;
            }
        }
    }
    }
    if ($translated_p) {
     $it = "<$tag"
          . join('', map { if ($_ ne '/'){
                             sprintf(' %s="%s"', $_, $attr->{$_}->[1]);
          }
              else {
                  sprintf(' %s',$_);
                  }
                         
              } sort {
                  $attr->{$a}->[3] <=> $attr->{$b}->[3] #FIXME
                      || $a cmp $b # Sort attributes BZ 22236
              } keys %$attr);
        $it .= '>';
    }
    else {
        $it = $t;
    }
    return $it;
}

sub text_replace {
    my($h, $output) = @_;
    for (;;) {
    my $s = TmplTokenizer::next_token($h);
    last unless defined $s;
    my($kind, $t, $attr) = ($s->type, $s->string, $s->attributes);
    if ($kind eq C4::TmplTokenType::TEXT) {
        print $output find_translation($t);
    } elsif ($kind eq C4::TmplTokenType::TEXT_PARAMETRIZED) {
        my $fmt = find_translation($s->form);
        print $output TmplTokenizer::parametrize($fmt, 1, $s, sub {
        $_ = $_[0];
        my($kind, $t, $attr) = ($_->type, $_->string, $_->attributes);
        $kind == C4::TmplTokenType::TAG && %$attr?
            text_replace_tag($t, $attr): $t });
    } elsif ($kind eq C4::TmplTokenType::TAG && %$attr) {
        print $output text_replace_tag($t, $attr);
    } elsif ($s->has_js_data) {
        for my $t (@{$s->js_data}) {
        # FIXME for this whole block
        if ($t->[0]) {
            printf $output "%s%s%s", $t->[2], find_translation($t->[3]),
                $t->[2];
        } else {
            print $output $t->[1];
        }
        }
    } elsif (defined $t) {
        # Quick fix to bug 4472
        $t = "<!DOCTYPE stylesheet ["  if $t =~ /DOCTYPE stylesheet/ ;
        print $output $t;
    }
    }
}

sub listfiles {
    my($dir, $type, $action) = @_;
    my $filenames = join ('|', @filenames); # used to update strings from this file
    my $match     = join ('|', @match);     # use only this files
    my $nomatch   = join ('|', @nomatch);   # do no use this files
    my @it = ();
    my $dir_h;
    if (opendir($dir_h, $dir)) {
        my @dirent = readdir $dir_h;   # because $dir_h is shared when recursing
        closedir $dir_h;
        for my $dirent (@dirent) {
            my $path = "$dir/$dirent";
            if ($dirent =~ /^\./ || $dirent eq 'CVS' || $dirent eq 'RCS'
            || (defined $exclude_regex && $dirent =~ /^(?:$exclude_regex)$/)) {
            ;
            } elsif (-f $path) {
                my $basename = fileparse( $path );
                push @it, $path
                    if  ( not @filenames or $basename =~ /($filenames)/i )
                    and ( not @match     or $basename =~ /($match)/i     ) # files to include
                    and ( not @nomatch   or $basename !~ /($nomatch)/i   ) # files not to include
                    and (!defined $type || $dirent =~ /\.(?:$type)$/) || $action eq 'install';
            } elsif (-d $path && $recursive_p) {
                push @it, listfiles($path, $type, $action);
            }
        }
    } else {
        warn_normal("$dir: $!", undef);
    }
    return @it;
}

###############################################################################

sub mkdir_recursive {
    my($dir) = @_;
    local($`, $&, $', $1);
    $dir = $` if $dir ne /^\/+$/ && $dir =~ /\/+$/;
    my ($prefix, $basename) = ($dir =~ /\/([^\/]+)$/s)? ($`, $1): ('.', $dir);
    mkdir_recursive($prefix) if $prefix ne '.' && !-d $prefix;
    if (!-d $dir) {
    print STDERR "Making directory $dir...\n" unless $quiet;
    # creates with rwxrwxr-x permissions
    mkdir($dir, 0775) || warn_normal("$dir: $!", undef);
    }
}

###############################################################################

sub usage {
    my($exitcode) = @_;
    my $h = $exitcode? *STDERR: *STDOUT;
    print $h <<EOF;
Usage: $0 install [OPTION]
  or:  $0 --help
Install translated templates.

  -i, --input=SOURCE          Get or update strings from SOURCE directory(s).
                              On create or update can have multiple values.
                              On install only one value.
  -o, --outputdir=DIRECTORY   Install translation(s) to specified DIRECTORY
      --pedantic-warnings     Issue warnings even for detected problems
                              which are likely to be harmless
  -r, --recursive             SOURCE in the -i option is a directory
  -f, --filename=FILE         FILE is a specific filename or part of it.
                              If given, only these files will be processed.
                              On update only relevant strings will be updated.
  -m, --match=FILE            FILE is a specific filename or part of it.
                              If given, only these files will be processed.
  -n, --nomatch=FILE          FILE is a specific filename or part of it.
                              If given, these files will not be processed.
  -s, --str-file=FILE         Specify FILE as the translation (po) file
                              for input (install) or output (create, update)
  -x, --exclude=REGEXP        Exclude dirs matching the given REGEXP
      --help                  Display this help and exit
  -q, --quiet                 no output to screen (except for errors)

Try `perldoc $0` for perhaps more information.
EOF
    exit($exitcode);
}

###############################################################################

sub usage_error {
    for my $msg (split(/\n/, $_[0])) {
    print STDERR "$msg\n";
    }
    print STDERR "Try `$0 --help for more information.\n";
    exit(-1);
}

###############################################################################

GetOptions(
    'input|i=s'             => \@in_dirs,
    'filename|f=s'          => \@filenames,
    'match|m=s'             => \@match,
    'nomatch|n=s'           => \@nomatch,
    'outputdir|o=s'         => \$out_dir,
    'recursive|r'           => \$recursive_p,
    'str-file|s=s'          => \$str_file,
    'exclude|x=s'           => \@excludes,
    'quiet|q'               => \$quiet,
    'pedantic-warnings|pedantic'    => sub { $pedantic_p = 1 },
    'help'              => \&usage,
) || usage_error();

VerboseWarnings::set_application_name($0);
VerboseWarnings::set_pedantic_mode($pedantic_p);

my $action = shift or usage_error('You must specify an ACTION.');
usage_error('You must at least specify input and string list filenames.')
    if !@in_dirs || !defined $str_file;

# Type match defaults to *.tt plus *.inc if not specified
$type = "tt|inc|xsl|xml|def" if !defined($type);

# Check the inputs for being directories
for my $in_dir ( @in_dirs ) {
    usage_error("$in_dir: Input must be a directory.\n"
        . "(Symbolic links are not supported at the moment)")
        unless -d $in_dir;
}

# Generates the global exclude regular expression
$exclude_regex =  '(?:'.join('|', @excludes).')' if @excludes;

my @in_files;
# Generate the list of input files if a directory is specified
# input is a directory, generates list of files to process

for my $fn ( @filenames ) {
    die "You cannot specify input files and directories at the same time.\n"
        if -d $fn;
}
for my $in_dir ( @in_dirs ) {
    $in_dir =~ s/\/$//; # strips the trailing / if any
    @in_files = ( @in_files, listfiles($in_dir, $type, $action));
}

# restores the string list from file
$href = Locale::PO->load_file_ashash($str_file, 'utf-8');

# guess the charsets. HTML::Templates defaults to iso-8859-1
if (defined $href) {
    die "$str_file: PO file is corrupted, or not a PO file\n" unless defined $href->{'""'};
    $charset_out = TmplTokenizer::charset_canon($2) if $href->{'""'}->msgstr =~ /\bcharset=(["']?)([^;\s"'\\]+)\1/;
    $charset_in = $charset_out;
#     for my $msgid (keys %$href) {
#   if ($msgid =~ /\bcharset=(["']?)([^;\s"'\\]+)\1/) {
#       my $candidate = TmplTokenizer::charset_canon $2;
#       die "Conflicting charsets in msgid: $charset_in vs $candidate => $msgid\n"
#           if defined $charset_in && $charset_in ne $candidate;
#       $charset_in = $candidate;
#   }
#     }

    # BUG6464: check consistency of PO messages
    #  - count number of '%s' in msgid and msgstr
    for my $msg ( values %$href ) {
        my $id_count  = split(/%s/, $msg->{msgid}) - 1;
        my $str_count = split(/%s/, $msg->{msgstr}) - 1;
        next if $id_count == $str_count ||
                $msg->{msgstr} eq '""' ||
                grep { /fuzzy/ } @{$msg->{_flags}};
        warn_normal(
            "unconsistent %s count: ($id_count/$str_count):\n" .
            "  line:   " . $msg->{loaded_line_number} . "\n" .
            "  msgid:  " . $msg->{msgid} . "\n" .
            "  msgstr: " . $msg->{msgstr} . "\n", undef);
    }
}

# set our charset in to UTF-8
if (!defined $charset_in) {
    $charset_in = TmplTokenizer::charset_canon('UTF-8');
    warn "Warning: Can't determine original templates' charset, defaulting to $charset_in\n" unless ( $quiet );
}
# set our charset out to UTF-8
if (!defined $charset_out) {
    $charset_out = TmplTokenizer::charset_canon('UTF-8');
    warn "Warning: Charset Out defaulting to $charset_out\n" unless ( $quiet );
}
my $st;

if ($action eq 'install') {
    if(!defined($out_dir)) {
    usage_error("You must specify an output directory when using the install method.");
    }
    
    if ( scalar @in_dirs > 1 ) {
    usage_error("You must specify only one input directory when using the install method.");
    }

    my $in_dir = shift @in_dirs;

    if ($in_dir eq $out_dir) {
    warn "You must specify a different input and output directory.\n";
    exit -1;
    }

    # Make sure the output directory exists
    # (It will auto-create it, but for compatibility we should not)
    -d $out_dir || die "$out_dir: The directory does not exist\n";

    # Try to open the file, because Locale::PO doesn't check :-/
    open(my $fh, '<', $str_file) || die "$str_file: $!\n";
    close $fh;

    # creates the new tmpl file using the new translation
    for my $input (@in_files) {
        die "Assertion failed"
            unless substr($input, 0, length($in_dir) + 1) eq "$in_dir/";

        my $target = $out_dir . substr($input, length($in_dir));
        my $targetdir = ($target =~ /[^\/]+$/s) ? $` : undef;

        if (!defined $type || $input =~ /\.(?:$type)$/) {
            my $h = TmplTokenizer->new( $input );
            $h->set_allow_cformat( 1 );
            VerboseWarnings::set_input_file_name($input);
            mkdir_recursive($targetdir) unless -d $targetdir;
            print STDERR "Creating $target...\n" unless $quiet;
            open( my $fh, ">:encoding(UTF-8)", "$target" ) || die "$target: $!\n";
            text_replace( $h, $fh );
            close $fh;
        } else {
        # just copying the file
            mkdir_recursive($targetdir) unless -d $targetdir;
            system("cp -f $input $target");
            print STDERR "Copying $input...\n" unless $quiet;
        }
    }

} else {
    usage_error('Unknown action specified.');
}

if ($st == 0) {
    printf "The %s seems to be successful.\n", $action unless $quiet;
} else {
    printf "%s FAILED.\n", "\u$action" unless $quiet;
}
exit 0;

###############################################################################

=head1 SYNOPSIS

./tmpl_process3.pl [ I<tmpl_process.pl options> ]

=head1 DESCRIPTION

This is an alternative version of the tmpl_process.pl script,
using standard gettext-style PO files.  While there still might
be changes made to the way it extracts strings, at this moment
it should be stable enough for general use; it is already being
used for the Chinese and Polish translations.

Currently, the create, update, and install actions have all been
reimplemented and seem to work.

=head2 Features

=over

=item -

Translation files in standard Uniforum PO format.
All standard tools including all gettext tools,
plus PO file editors like kbabel(1) etc.
can be used.

=item -

Minor changes in whitespace in source templates
do not generally require strings to be re-translated.

=item -

Able to handle <TMPL_VAR> variables in the templates;
<TMPL_VAR> variables are usually extracted in proper context,
represented by a short %s placeholder.

=item -

Able to handle text input and radio button INPUT elements
in the templates; these INPUT elements are also usually
extracted in proper context,
represented by a short %S or %p placeholder.

=item -

Automatic comments in the generated PO files to provide
even more context (line numbers, and the names and types
of the variables).

=item -

The %I<n>$s (or %I<n>$p, etc.) notation can be used
for change the ordering of the variables,
if such a reordering is required for correct translation.

=item -

If a particular <TMPL_VAR> should not appear in the
translation, it can be suppressed with the %0.0s notation.

=item -

Using the PO format also means translators can add their
own comments in the translation files, if necessary.

=back

=head1 NOTES

Anchors are represented by an <AI<n>> notation.
The meaning of this non-standard notation might not be obvious.

=head1 BUGS

This script may not work in Windows.

There are probably some other bugs too, since this has not been
tested very much.

=head1 SEE ALSO

TmplTokenizer.pm,
Locale::PO(3),

=cut
