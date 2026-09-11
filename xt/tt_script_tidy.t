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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use File::Slurp qw( read_file );
use Test::More;

use Test::NoWarnings;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new( { context => 'tidy' } );
my @tt_files  = $dev_files->ls_tt_files;

@tt_files = grep { !m{/value_builder/} } @tt_files;

my @multiple_tt_allowed = qw(
    koha-tmpl/opac-tmpl/bootstrap/en/includes/opac-bottom.inc
    koha-tmpl/opac-tmpl/bootstrap/en/modules/sci/sci-main.tt
    koha-tmpl/opac-tmpl/bootstrap/en/modules/sco/sco-main.tt
);

plan tests => scalar(@tt_files) * 4 + 1;

for my $file (@tt_files) {

    my @lines                         = read_file($file);
    my $fails_has_tt_tags             = 0;
    my $fails_has_tt_allowed          = 0;
    my $fails_exception_not_module    = 0;
    my $script_tags_with_tags_allowed = 0;
    my ( $in_script, $has_tt_tags, $tt_tags_allowed );
    for my $line (@lines) {

        if ( $line =~ m{<script} ) {
            if ( $line =~ m{data-tt-allowed-exception="true"} ) {
                $tt_tags_allowed = 1;
                $fails_exception_not_module++
                    unless $line =~ m{type="module"} || $line =~ m{type="importmap"};
            } elsif ( $line =~ m{data-tt-allowed="true"} ) {
                $tt_tags_allowed = 1;
                $script_tags_with_tags_allowed++;
            }
            $in_script = 1;
            next;
        }

        if ( $line =~ m{<\/script>} ) {
            if ( $has_tt_tags && !$tt_tags_allowed ) {
                $fails_has_tt_tags++;
            }
            if ( !$has_tt_tags && $tt_tags_allowed ) {
                $fails_has_tt_allowed++;
            }
            $tt_tags_allowed = 0;
            $has_tt_tags     = 0;
            $in_script       = 0;
        }
        next unless $in_script;

        $has_tt_tags ||= $line =~ m{\[\%.*?\%\]}s;
    }

    is( $fails_has_tt_tags, 0, qq{$file has a <script> tag with Template::Toolkit tags.} );
    is(
        $fails_has_tt_allowed, 0,
        qq{$file has a <script> tag with data-tt-allowed="true" or data-tt-allowed-exception="true" but without Template::Toolkit tags.}
    );
    is(
        $fails_exception_not_module, 0,
        qq{$file has a <script> tag with data-tt-allowed-exception="true" that is not type="module" or type="importmap".}
    );
    if ( grep { $file eq $_ } @multiple_tt_allowed ) {
        pass(qq{$file is allowed to have more than one <script> tag with data-tt-allowed="true"});
    } else {
        ok(
            $script_tags_with_tags_allowed <= 1,
            qq{$file has more than one <script> tag with data-tt-allowed="true".}
        );
    }
}
