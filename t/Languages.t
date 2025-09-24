#!/usr/bin/perl

# Copyright 2013 Equinox Software, Inc.
# Copyright 2014 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 6;
use Test::MockModule;
use CGI qw ( -utf8 );
use Koha::Cache::Memory::Lite;
use Koha::Language;

BEGIN {
    use_ok( 'C4::Languages', qw( getlanguage ) );
}

my @languages    = ();    # stores the list of active languages
                          # for the syspref mock
my $return_undef = 0;

my $module_context   = Test::MockModule->new('C4::Context');
my $module_languages = Test::MockModule->new('C4::Languages');

$module_context->mock(
    preference => sub {
        my ( $self, $pref ) = @_;
        if ($return_undef) {
            return;
        } elsif ( $pref eq 'language' || $pref eq 'OPACLanguages' ) {
            return join ',', @languages;
        } else {
            return 'XXX';
        }
    },
);

$module_languages->mock(
    _get_language_dirs => sub {
        return @languages;
    }
);

delete $ENV{HTTP_ACCEPT_LANGUAGE};

my $query = CGI->new();
@languages = ( 'de-DE', 'fr-FR' );
is( C4::Languages::getlanguage($query), 'de-DE', 'default to first language specified in syspref (bug 10560)' );

Koha::Cache::Memory::Lite->get_instance()->clear_from_cache('getlanguage');
@languages = ();
is( C4::Languages::getlanguage($query), 'en', 'default to English if no language specified in syspref (bug 10560)' );

Koha::Cache::Memory::Lite->get_instance()->clear_from_cache('getlanguage');
$return_undef = 1;
is( C4::Languages::getlanguage($query), 'en', 'default to English if no database' );

subtest 'when interface is not intranet or opac' => sub {
    plan tests => 3;

    my $cache = Koha::Cache::Memory::Lite->get_instance;
    C4::Context->interface('api');

    @languages = ( 'fr-FR', 'de-DE', 'en' );

    $ENV{HTTP_ACCEPT_LANGUAGE} = 'de-DE';
    $cache->clear_from_cache('getlanguage');
    is( C4::Languages::getlanguage(), 'de-DE', 'Accept-Language HTTP header is respected' );

    Koha::Language->set_requested_language('fr-FR');
    $cache->clear_from_cache('getlanguage');
    is( C4::Languages::getlanguage(), 'fr-FR', 'but language requested through Koha::Language is preferred' );

    @languages = ();
    $cache->clear_from_cache('getlanguage');
    is( C4::Languages::getlanguage(), 'en', 'fallback to english when no language is available' );
};
