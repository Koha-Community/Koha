#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Data::Dumper;

use Getopt::Long;
use File::Basename;
use File::Copy;

my $help_msg = <<EOH;
This script does a first-cut conversion of koha HTML::Template template files (.tmpl).
It creates a mirror of koha-tmpl called koha-tt where converted files will be placed.
By default all files will be converted: use the --file (-f) argument to specify
  individual files to process.

Options:
    --koharoot (-r): Root directory of koha installation.
    --type (-t): template file extenstions to match
        (defaults to tmpl|inc|xsl).
    --copyall (-c): Also copy across all files in template directory
    --file (-f): specify individual files to process
    --debug (-d): output more information.
EOH

my $tmpl_in_dir      = 'koha-tmpl';
my $tmpl_out_dir     = 'koha-tt';

# template toolkit variables NOT to scope, in other words, variables that need to remain global (case sensitive)
my @globals = ("themelang","JacketImages","OPACAmazonCoverImages","GoogleJackets","BakerTaylorEnabled",
"SyndeticsEnabled", "OpacRenewalAllowed", "item_level_itypes","noItemTypeImages",
"virtualshelves", "RequestOnOpac", "COinSinOPACResults", "OPACXSLTResultsDisplay",
"OPACItemsResultsDisplay", "LibraryThingForLibrariesID", "opacuserlogin", "TagsEnabled",
"TagsShowOnList", "TagsInputOnList","loggedinusername","opacbookbag",
"OPACAmazonEnabled", "SyndeticsCoverImages","using_https");

# Arguments:
my $KOHA_ROOT;
my $tmpl_extn_match  = "tmpl|inc|xsl"; # Type match defaults to *.tmpl plus *.inc if not specified
my $copy_other_files = 0;
my @template_files;
my @files_w_tmpl_loops;
my $verbose          = 0;
GetOptions (
    "koharoot=s"        => \$KOHA_ROOT,
    "type|t=s"          => \$tmpl_extn_match,
    "copyall|c"         => \$copy_other_files,
    "file|f=s"          => \@template_files,         # array of filenames
    "verbose+"          => \$verbose,                # incremental flag
) or die $help_msg;

if ( ! $KOHA_ROOT || ! -d $KOHA_ROOT ) {
    croak "Koha root not passed or is not correct.";
}
if ( ! -d "$KOHA_ROOT/$tmpl_in_dir" ) {
    croak "Cannot find template dir ($tmpl_in_dir)";
}

# Attempt to create koha-tt dir..
if ( ! -d "$KOHA_ROOT/$tmpl_out_dir" ) {
    mkdir("$KOHA_ROOT/$tmpl_out_dir") #, '0755'
       or croak "Cannot create $tmpl_out_dir directory in $KOHA_ROOT: $!";
}

# Obtain list of files to process - go recursively through tmpl_in_dir and subdirectories..
unless ( scalar(@template_files) ) {
    @template_files = mirror_template_dir_structure_return_files("$KOHA_ROOT/$tmpl_in_dir", "$tmpl_extn_match");
}
foreach my $file (@template_files) {
    (my $new_path = $file) =~ s/$tmpl_in_dir/$tmpl_out_dir/;
    $new_path =~ s/\.tmpl/.tt/;
    $new_path = "$KOHA_ROOT/$new_path" unless ( $new_path =~ m/^$KOHA_ROOT/ );

    open my $ITMPL, '<', $file or croak "Can't open $file for input: $!";
    open my $OTT, '>', $new_path or croak "Can't open $new_path for output: $!";

    # allows 'proper' handling of for loop scope
    # cur_scope is a stack of scopes, the last being the current
    #   when opening a for loop push scope onto end, when closing for loop pop
    my @cur_scope = ("");
    # flag representing if we've found a for loop this iteration
    my $for_loop_found = 0;

    for my $input_tmpl(<$ITMPL>){
        my @parts = split "<", $input_tmpl;
        for( my $i=0; $i<=$#parts; ++$i ){
            my $input_tmpl = $i ? "<" . $parts[$i] : $parts[$i]; # add < sign back in to every part except the first
	$for_loop_found = 0;

	# handle poorly names variable such as f1!, f1+, f1-, f1| and mod
	$input_tmpl =~ s/"(\w+)\|"/"$1pipe"/ig;
	$input_tmpl =~ s/"(\w+)\+"/"$1plus"/ig;
	$input_tmpl =~ s/"(\w+)\-"/"$1minus"/ig;
	$input_tmpl =~ s/"(\w+)!"/"$1exclamation"/ig;
	$input_tmpl =~ s/"(\w+),(\w+)"/"$1comma$2"/ig; #caused a problem in patron search
	$input_tmpl =~ s/NAME="mod"/NAME="modname"/ig;
	# handle 'naked' TMPL_VAR "parameter" by turning them into what they should be, TMPL_VAR NAME="parameter"
	$input_tmpl =~ s/TMPL_VAR\s+"(\w+)"/TMPL_VAR NAME="$1"/ig;
	# make an end (ESCAPE NAME DEFAULT) into a ned (NAME ESCAPE DEFAULT)
	$input_tmpl =~ s/ESCAPE="(\w+?)"\s+NAME=['"](\w+?)['"]\s+DEFAULT=['"](.+?)['"]/NAME="$2" ESCAPE="$1" DEFAULT="$3"/ig;

	# Process..
	# NB: if you think you're seeing double, you probably are, *some* (read:most) patterns appear twice: once with quotations marks, once without.
	#     trying to combine them into a single pattern proved troublesome as a regex like ['"]?(.*?)['"]? was causing problems and fixing the problem caused (alot) more complex regex

	# variables
	$input_tmpl =~ s/<[!-]*\s*TMPL_VAR\s+NAME\s?=\s?['"]?\s*(\w*?)\s*['"]?\s+ESCAPE=['"](\w*?)['"]\s+DEFAULT=['"]?(.*?)['"]?\s*-*>/[% DEFAULT $cur_scope[-1]$1="$3" |$2 %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_VAR\s+NAME\s?=\s?['"]\s*(\w*?)\s*['"]\s+ESCAPE=['"]?(\w*?)['"]?\s*-*>/[% $cur_scope[-1]$1 |$2 %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_VAR\s+NAME\s?=\s?(\w*?)\s+ESCAPE=['"]?(\w*?)['"]?\s*-*>/[% $cur_scope[-1]$1 |$2 %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_VAR\s+ESCAPE=['"]?(\w*?)['"]?\s+NAME\s?=\s?['"]?([\w-]*?)['"]?\s*-*>/[% $cur_scope[-1]$2 |$1 %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_VAR\s+NAME\s?=\s?['"]?(\w*?)['"]?\s+DEFAULT=['"](.*?)['"]\s*-*>/[% DEFAULT $cur_scope[-1]$1="$2" %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_VAR\s+NAME\s?=\s?['"]?\s*(\w*?)\s*['"]?\s+DEFAULT=(.*?)\s*-*>/[% DEFAULT $cur_scope[-1]$1=$2 %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL[_\s]VAR\s+NAME\s?=\s?['"]?\s*(\w*?)\s*['"]?\s*-*>/[% $cur_scope[-1]$1 %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL[_\s]VAR\s+EXPR\s?=\s?['"](.*?)['"]\s*-*>/[% $1 %]/ig;     # TMPL_VAR NAME and TMPL_VAR EXPR are logically equiv
	$input_tmpl =~ s/<[!-]*\s*TMPL[_\s]VAR\s+EXPR\s?=\s?(.*?)\s*-*>/[% $1 %]/ig;

	# if, elseif and unless blocks
	$input_tmpl =~ s/<[!-]*\s*TMPL_IF\s+EXPR\s?=\s?['"](.*?)['"]\s*-*>/[% IF ( $1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_IF\s+EXPR\s?=\s?(.*?)\s*-*>/[% IF ( $1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_IF\s+NAME\s?=\s?['"]\s*(\w*?)\s*['"]\s*-*>/[% IF ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_IF\s+NAME\s?=\s?(\w*?)\s*-*>/[% IF ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_IF\s+['"](.*?)['"]\s*-*>/[% IF ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_IF\s+([\w\s]*?)\s*-*>/[% IF ( $cur_scope[-1]$1 ) %]/ig;

	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSIF\s+EXPR\s?=\s?['"](.*?)['"]\s*-*>/[% ELSIF ( $1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSIF\s+EXPR\s?=\s?(.*?)\s*-*>/[% ELSIF ( $1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSIF\s+NAME\s?=\s?['"](\w*?)['"]\s*-*>/[% ELSIF ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSIF\s+NAME\s?=\s?(\w*?)\s*-*>/[% ELSIF ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSIF\s+['"](\w*?)['"]\s*-*>/[% ELSIF ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSIF\s+(\w*?)\s*-*>/[% ELSIF ( $cur_scope[-1]$1 ) %]/ig;

	$input_tmpl =~ s/<[!-]*\s*TMPL_ELSE\s*-*>/[% ELSE %]/ig;
	$input_tmpl =~ s/<[!-]*\s*\/TMPL_IF\s*-*>/[% END %]/ig;

	$input_tmpl =~ s/<[!-]*\s*TMPL_UNLESS\s+NAME\s?=\s?['"]?(\w*?)['"]?\s*-*>/[% UNLESS ( $cur_scope[-1]$1 ) %]/ig;
	$input_tmpl =~ s/<[!-]*\s*\/TMPL_UNLESS\s*-*>/[% END %]/ig;
	# includes
	$input_tmpl =~ s/<[!-]*\s*TMPL_INCLUDE\s+NAME\s?=\s?"(.*?\.inc)"\s*-*>/[% INCLUDE '$1' %]/ig;
	$input_tmpl =~ s/<[!-]*\s*TMPL_INCLUDE\s+NAME\s?=\s?"(.*?)"\s*-*>/[% INCLUDE $1 %]/ig;

        #reverse scoping bug fix
        for my $tag (@globals){
            next unless $cur_scope[-1];
            $input_tmpl =~ s/$cur_scope[-1]$tag/$tag/g;
        }

 	if ($input_tmpl =~ m/<[!-]*\s*TMPL_LOOP/i ){
	    $for_loop_found = 1;
	}

	$input_tmpl =~ s/<[!-]*\s*TMPL_LOOP\s+NAME\s?=\s?['"](?<SCOPE>.*?)['"]\s*-*>/"[% FOREACH " . substr($+{SCOPE}, 0, -1) . " IN $cur_scope[-1]$1 %]"/ieg;
	$input_tmpl =~ s/<[!-]*\s*TMPL_LOOP\s+NAME\s?=\s?(?<SCOPE>.*?)\s*-*>/"[% FOREACH " . substr($+{SCOPE}, 0, -1) . " IN $cur_scope[-1]$1 %]"/ieg;

	# handle new scope
	if($for_loop_found){
	    my $scope = substr($+{SCOPE}, 0, -1) . ".";
	    push(@cur_scope, $scope);
	    $for_loop_found = 0;
	}

	# handle loops and old scope
	if ( $input_tmpl =~ m/<!--[\s\/]*TMPL_LOOP\s*-->/i ) {
	    push(@files_w_tmpl_loops, $new_path);
	    pop(@cur_scope);
	}

	$input_tmpl =~ s/<[!-]*\s*\/TMPL_LOOP\s*-*>/[% END %]/ig;

	# misc 'patches'
	$input_tmpl =~ s/\seq\s/ == /ig;
	$input_tmpl =~ s/HTML/html/g;
	$input_tmpl =~ s/URL/url/g;
        $input_tmpl =~ s/dhtmlcalendar_dateformat/DHTMLcalendar_dateformat/ig;
	$input_tmpl =~ s/\w*\.__first__/loop.first/ig;
	$input_tmpl =~ s/\w*\.__last__/loop.last/ig;
	$input_tmpl =~ s/\w*\.__odd__/loop.odd/ig;
	$input_tmpl =~ s/\w*\.__even__/loop.even/ig;
	$input_tmpl =~ s/\w*\.__counter__/loop.count/ig; #loop.count gives the range (0..max) whereas loop.index gives the range (1..max+1), __counter__ is unknown

	# hack to get around lack of javascript filter
	$input_tmpl =~ s/\|\s*JS/|replace("'", "\\'") |replace('"', '\\"') |replace('\\n', '\\\\n') |replace('\\r', '\\\\r')/ig;
    
	# Write out..
        print $OTT $input_tmpl;
        }
    }
    close $ITMPL;
    close $OTT;
}

if ( scalar(@files_w_tmpl_loops) && $verbose ) {
    print "\nThese files contain TMPL_LOOPs that need double checking:\n";
    foreach my $file (@files_w_tmpl_loops) {
        print "$file\n";
    }
}

## SUB-ROUTINES ##

# Create new directory structure and return list of template files
sub mirror_template_dir_structure_return_files {
    my($dir, $type) = @_;

    my @files = ();
    if ( opendir(DIR, $dir) ) {
        my @dirent = readdir DIR;   # because DIR is shared when recursing
        closedir DIR;
        for my $dirent (@dirent) {
            my $path = "$dir/$dirent";
            if ( $dirent =~ /^\./ ) {
              ;
            }
            elsif ( -f $path ) {
                (my $new_path = $path) =~ s/$tmpl_in_dir/$tmpl_out_dir/;
                $new_path = "$KOHA_ROOT/$new_path" unless ( $new_path =~ m/^$KOHA_ROOT/ );
                if ( !defined $type || $dirent =~ /\.(?:$type)$/) {
                    push(@files, $path);
                }
                elsif ( $copy_other_files ) {
                    copy($path, $new_path)
                      or croak "Failed to copy $path to $new_path: $!";
                }
            }
            elsif ( -d $path ) {
                (my $new_path = $path) =~ s/$tmpl_in_dir/$tmpl_out_dir/;
                $new_path = "$KOHA_ROOT/$new_path" unless ( $new_path =~ m/^$KOHA_ROOT/ );
                if ( ! -d $new_path ) {
                    mkdir($new_path) #, '0755'
                      or croak "Failed to create " . $new_path ." directory: $!";
                }
                my @sub_files = mirror_template_dir_structure_return_files($path, $type);
                push(@files, @sub_files) if ( scalar(@sub_files) );
            }
        }
    } else {
        warn("Cannot open $dir: $! ... skipping");
    }

    return @files;
}
