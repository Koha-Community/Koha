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

use Test::NoWarnings;
use Test::More tests => 3;
use Scalar::Util qw( weaken );
use Template;

use Koha::Template::Plugin::SafeURL;

subtest 'safe_url filter' => sub {
    plan tests => 2;

    my $tt = Template->new( { PLUGIN_BASE => 'Koha::Template::Plugin' } );
    my $output;

    $tt->process( \'[% USE SafeURL %][% url | safe_url %]', { url => 'https://example.org/a b' }, \$output )
        or die $tt->error;
    is( $output, 'https://example.org/a%20b', 'The URL is parsed and stringified by URI' );

    $output = '';
    $tt->process( \'[% USE SafeURL %][% url | safe_url %]', { url => 'https://example.org/path?x=1' }, \$output )
        or die $tt->error;
    is( $output, 'https://example.org/path?x=1', 'A well formed URL is returned unchanged' );
};

subtest 'template context is released after processing' => sub {
    plan tests => 1;

    my $tt      = Template->new( { PLUGIN_BASE => 'Koha::Template::Plugin' } );
    my $context = $tt->context;
    weaken $context;

    my $output;
    $tt->process( \'[% USE SafeURL %][% url | safe_url %]', { url => 'https://example.org' }, \$output )
        or die $tt->error;
    undef $tt;

    is( $context, undef, 'The template context is freed once the Template object is gone' );
};
