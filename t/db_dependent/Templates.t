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

use Test::More tests => 8;
use Test::Deep;
use Test::MockModule;
use Test::Warn;
use File::Temp qw/tempfile/;

use t::lib::Mocks;

use C4::Auth qw//;

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

subtest 'Testing themelanguage' => sub {
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
    t::lib::Mocks::mock_preference( 'template', 'prog' );

    # trigger first case.
    $testing_language = 'en';
    my ($theme, $lang, $availablethemes) = C4::Templates::themelanguage( $htdocs, 'about.tt', $section, $cgi);
    is($theme,'prog',"Expected theme: set en - $theme");
    is($lang,'en','Expected language: set en');
    cmp_deeply( $availablethemes, [ 'prog' ], 'We only expect one available theme for set en' );

    # trigger second case.
    $testing_language = q{};
    ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, 'about.tt', $section, $cgi);
    is($theme,'prog',"Expected theme: default en - $theme");
    is($lang,'en','Expected language: default en');
    cmp_deeply( $availablethemes, [ 'prog' ], 'We only expect one available theme for default en' );

    # trigger third case.
    my $template = $htdocs . '/prog/en/modules/about.tt';
    ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, $template, $section, $cgi);
    is($theme,'prog',"Expected defined theme: unset - $theme");
    is($lang,q{},'Expected language: unset');
    cmp_deeply( $availablethemes, [ 'prog' ], 'We only expect one available theme for unset' );

    # trigger bad case.
    $template = $htdocs . '/prog/en/kaboom/about.tt';
    ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, $template, $section, $cgi);
    is($lang,undef,'Expected language: not coded for');
    is( $availablethemes, undef, 'We do not expect any available themes -- not coded for' );
    is($theme,undef,"Expected no theme: not coded for");

    return;
};

subtest 'Testing gettemplate/badtemplatecheck' => sub {
    plan tests => 7;

    my $cgi = CGI->new;
    my $template;
    warning_like { eval { $template = C4::Templates::gettemplate( '/etc/passwd', 'opac', $cgi ) }; warn $@ if $@; } qr/bad template/, 'Bad template check';
    is( $template ? $template->output: '', '', 'Check output' );

    # Test a few more bad paths to gettemplate triggering badtemplatecheck
    warning_like { eval { C4::Templates::gettemplate( '../topsecret.tt', 'opac', $cgi ) }; warn $@ if $@; } qr/bad template/, 'No safe chars';
    warning_like { eval { C4::Templates::gettemplate( '/noaccess/topsecret.tt', 'opac', $cgi ) }; warn $@ if $@; } qr/bad template/, 'Directory not allowed';
    warning_like { eval { C4::Templates::gettemplate( C4::Context->config('intrahtdocs') . '2/prog/en/modules/about.tt', 'intranet', $cgi ) }; warn $@ if $@; } qr/bad template/, 'Directory not allowed too';

    # Allow templates from /tmp
    t::lib::Mocks::mock_config( 'pluginsdir', [ '/tmp' ] );
    warning_like { eval { C4::Templates::badtemplatecheck( '/tmp/about.tt' ) }; warn $@ if $@; } undef, 'No warn on template from plugin dir';
    # Refuse wrong extension
    warning_like { eval { C4::Templates::badtemplatecheck( '/tmp/about.tmpl' ) }; warn $@ if $@; } qr/bad template/, 'Warn on bad extension';
};

subtest "Absolute path change in _get_template_file" => sub {
    plan tests => 1;

    # We create a simple template in /tmp.
    # We simulate an anonymous OPAC session; the OPACBaseURL template variable
    # should be filled by get_template_and_user.
    t::lib::Mocks::mock_config( 'pluginsdir', [ C4::Context::temporary_directory ] );
    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'without any doubt' );
    my ( $fh, $fn ) = tempfile( SUFFIX => '.tt', UNLINK => 1, DIR => C4::Context::temporary_directory );
    print $fh q|I am a [% quality %] template [% OPACBaseURL %]|;
    close $fh;
    my ( $template, $login, $cookie ) = C4::Auth::get_template_and_user({
        template_name => $fn,
        query => CGI::new,
        type => "opac",
        authnotrequired => 1,
    });
    $template->param( quality => 'good-for-nothing' );
    like( $template->output, qr/a good.+template.+doubt/, 'Testing a template with an absolute path' );
};
