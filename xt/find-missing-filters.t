#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 1;
use File::Find;
use File::Slurp;
use Data::Dumper;

my @themes;

# OPAC themes
my $opac_dir  = 'koha-tmpl/opac-tmpl';
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
for my $theme ( grep { not /^\.|lib|js|xslt/ } readdir($dh) ) {
    push @themes, "$opac_dir/$theme/en";
}
close $dh;

# STAFF themes
my $staff_dir = 'koha-tmpl/intranet-tmpl';
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
for my $theme ( grep { not /^\.|lib|js/ } readdir($dh) ) {
    push @themes, "$staff_dir/$theme/en";
}
close $dh;

my @files;
sub wanted {
    my $name = $File::Find::name;
    push @files, $name
        if $name =~ m[\.(tt|inc)$] and -f $name;
}

my @tt_directives = (
    qr{^\s*INCLUDE},
    qr{^\s*USE},
    qr{^\s*IF},
    qr{^\s*UNLESS},
    qr{^\s*ELSE},
    qr{^\s*ELSIF},
    qr{^\s*END},
    qr{^\s*SET},
    qr{^\s*FOR},
    qr{^\s*FOREACH},
    qr{^\s*MACRO},
    qr{^\s*SWITCH},
    qr{^\s*CASE},
    qr{^\s*PROCESS},
    qr{^\s*DEFAULT},
    qr{^\s*TRY},
    qr{^\s*CATCH},
    qr{^\s*BLOCK},
    qr{^\s*FILTER},
    qr{^\s*STOP},
    qr{^\s*NEXT},
);

sub process_tt_content {
    my ($content) = @_;
    my ( $use_raw, $has_use_raw );
    my @errors;
    for my $line ( split "\n", $content ) {
        if ( $line =~ m{\[%[^%]+%\]} ) {

            # handle exceptions first
            $use_raw = 1
              if $line =~ m{|\s*\$raw};    # Is the file use the raw filter?

            # Do we have Asset without the raw filter?
            if ( $line =~ m{^\s*\[% Asset} ) {
                push @errors, { error => 'asset_must_be_raw', line => $line }
                  and next
                  unless $line =~ m{\|\s*\$raw};
            }

            $has_use_raw++
              if $line =~ m{\[% USE raw %\]};    # Does [% Use raw %] exist?

            # Loop on TT blocks
            while (
                $line =~ m{
                    \[%
                    (?<pre_chomp>(\s|\-|~)*)
                    (?<tt_block>[^%\-~]+)
                    (?<post_chomp>(\s|\-|~)*)
                    %\]}gmxs
              )
            {
                my $tt_block = $+{tt_block};

                # It's a TT directive, no filters needed
                next if grep { $tt_block =~ $_ } @tt_directives;

                next
                  if $tt_block =~ m{\s?\|\s?\$KohaDates\s?$}
                  ;    # We could escape it but should be safe
                next if $tt_block =~ m{^\#};    # Is a comment, skip it

                push @errors, { error => 'missing_filter', line => $line }
                  if $tt_block !~ m{\|\s?\$raw}   # already escaped correctly with raw
                  && $tt_block !~ m{=}            # assignment, maybe we should require to use SET (?)
                  && $tt_block !~ m{\|\s?ur(l|i)} # already has url or uri filter
                  && $tt_block !~ m{\|\s?html}    # already has html filter
                  && $tt_block !~ m{^(?<before>\S+)\s+UNLESS\s+(?<after>\S+)} # Specific for [% foo UNLESS bar %]
                ;
            }
        }
    }

    return @errors;
}

find({ wanted => \&wanted, no_chdir => 1 }, @themes );

my @errors;
for my $file ( @files ) {
    say $file;
    my $content = read_file($file);
    my @e = process_tt_content($content);
    push @errors, { file => $file, errors => \@e } if @e;
}

is( @errors, 0, "Template variables should be correctly escaped" )
    or diag(Dumper @errors);
