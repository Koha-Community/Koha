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

use CGI;

use Test::More tests => 6;
use Test::Deep;
use Test::MockModule;

use t::lib::Mocks;

BEGIN {
    use_ok( 'C4::Templates' );
    can_ok( 'C4::Templates',
         qw/ GetColumnDefs
             getlanguagecookie
             setlanguagecookie
             themelanguage
             gettemplate
             _get_template_file
             param
             output /);
}

my $query   = CGI->new();
my $columns = C4::Templates::GetColumnDefs( $query );

is( ref( $columns ) eq 'HASH', 1, 'GetColumnDefs returns a hashref' );
# get the tables names, sorted
my @keys = sort keys %{$columns};
is( scalar @keys, 6, 'GetColumnDefs correctly returns the 5 tables defined in columns.def' );
my @tables = qw( biblio biblioitems borrowers items statistics subscription );
cmp_deeply( \@keys, \@tables, 'GetColumnDefs returns the expected tables');

subtest 'Testing themelanguage for unique themes (BZ 17982)' => sub {
    plan tests => 12;
    my $testing_language;
    my $module_language = Test::MockModule->new('C4::Languages');

    $module_language->mock(
        'getlanguage',
        sub {
            return $testing_language;
        }
    );

    my $cgi = CGI->new();
    my $htdocs = C4::Context->config('intrahtdocs');
    my $section = 'intranet';

    # trigger first case.
    $testing_language = 'en';
    my ($theme, $lang, $availablethemes) = C4::Templates::themelanguage( $htdocs, 'about.tt', $section, $cgi);
    is($theme,'prog',"Expected theme: set en - $theme");
    is($lang,'en','Expected language: set en');
    cmp_deeply( $availablethemes, [ 'prog' ], 'We only expect one prog: set en' );

    # trigger second case.
    $testing_language = q{};
    ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, 'about.tt', $section, $cgi);
    is($theme,'prog',"Expected theme: default en - $theme");
    is($lang,'en','Expected language: default en');
    cmp_deeply( $availablethemes, [ 'prog' ], 'We only expect one prog: default en' );

    # trigger third case.
    my $template = $htdocs . '/prog/en/modules/about.tt';
    ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, $template, $section, $cgi);
    is($theme,'prog',"Expected defined theme: unset - $theme");
    is($lang,q{},'Expected language: unset');
    cmp_deeply( $availablethemes, [ 'prog' ], 'We only expect one prog: unset' );

    # trigger bad case.
    $template = $htdocs . '/prog/en/kaboom/about.tt';
    ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, $template, $section, $cgi);
    is($lang,undef,'Expected language: not coded for');
    is( $availablethemes, undef, 'We only expect no prog: not coded for' );
    is($theme,undef,"Expected no theme: not coded for");

    return;
};

1;
