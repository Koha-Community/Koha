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

use C4::Context;
use XML::LibXML;

use Test::NoWarnings;
use Test::More tests => 5;

use t::lib::Selenium;
use t::lib::TestBuilder;
use utf8;

my $original_ILSDI_value      = C4::Context->preference('ILS-DI');
my $original_OpacPublic_value = C4::Context->preference('OpacPublic');
my $builder                   = t::lib::TestBuilder->new;

my $login = $ENV{KOHA_USER} || 'koha';

my @cleanup;

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 2 if $@;

    my $s      = t::lib::Selenium->new;
    my $driver = $s->driver;
    $driver->set_window_size( 3840, 1080 );

    subtest 'Disabled ILS-DI and enabled OPAC' => sub {
        plan tests => 2;
        C4::Context->set_preference( 'ILS-DI',     0 );
        C4::Context->set_preference( 'OpacPublic', 1 );
        my $ilsdi_page = $s->opac_base_url . q|ilsdi.pl?service=LookupPatron&id=abceasyas123|;
        $driver->get($ilsdi_page);
        my $xml_content = $driver->get_page_source;
        my $parser      = XML::LibXML->new();
        my $doc         = $parser->parse_string($xml_content);
        my $result      = $doc->find('/LookupPatron/message');
        my $literal     = $result->to_literal->value();
        is( "$literal", 'ILS-DI is disabled.', "ILS-DI is disabled" );

        $driver->get( $s->opac_base_url . q|ilsdi.pl| );
        isnt( $driver->get_title(), 'Log in to your account › Koha online catalog', "HTML explanation shows" );
    };

    subtest 'Disabled ILS-DI and disabled OPAC' => sub {
        plan tests => 2;
        C4::Context->set_preference( 'ILS-DI',     0 );
        C4::Context->set_preference( 'OpacPublic', 0 );
        my $ilsdi_page = $s->opac_base_url . q|ilsdi.pl?service=LookupPatron&id=abceasyas123|;
        $driver->get($ilsdi_page);
        my $xml_content = $driver->get_page_source;
        my $parser      = XML::LibXML->new();
        my $doc         = $parser->parse_string($xml_content);
        my $result      = $doc->find('/LookupPatron/message');
        my $literal     = $result->to_literal->value();
        is( "$literal", 'ILS-DI is disabled.', "ILS-DI is disabled" );

        $driver->get( $s->opac_base_url . q|ilsdi.pl| );
        isnt( $driver->get_title(), 'Log in to your account › Koha online catalog', "HTML explanation shows" );
    };

    subtest 'Enabled ILS-DI and enabled OPAC' => sub {
        plan tests => 2;
        C4::Context->set_preference( 'ILS-DI',     1 );
        C4::Context->set_preference( 'OpacPublic', 1 );
        my $ilsdi_page = $s->opac_base_url . q|ilsdi.pl?service=LookupPatron&id=abceasyas123|;
        $driver->get($ilsdi_page);
        my $xml_content = $driver->get_page_source;
        my $parser      = XML::LibXML->new();
        my $doc         = $parser->parse_string($xml_content);
        my $result      = $doc->find('/LookupPatron/message');
        my $literal     = $result->to_literal->value();
        isnt( "$literal", 'ILS-DI is disabled.', "ILS-DI is NOT disabled" );

        $driver->get( $s->opac_base_url . q|ilsdi.pl| );
        isnt( $driver->get_title(), 'Log in to your account › Koha online catalog', "HTML explanation shows" );
    };

    subtest 'Enabled ILS-DI and disabled OPAC' => sub {
        plan tests => 2;
        C4::Context->set_preference( 'ILS-DI',     1 );
        C4::Context->set_preference( 'OpacPublic', 0 );
        my $ilsdi_page = $s->opac_base_url . q|ilsdi.pl?service=LookupPatron&id=abceasyas123|;
        $driver->get($ilsdi_page);
        my $xml_content = $driver->get_page_source;
        my $parser      = XML::LibXML->new();
        my $doc         = $parser->parse_string($xml_content);
        my $result      = $doc->find('/LookupPatron/message');
        my $literal     = $result->to_literal->value();
        isnt( "$literal", 'ILS-DI is disabled.', "ILS-DI is NOT disabled" );

        $driver->get( $s->opac_base_url . q|ilsdi.pl| );
        isnt( $driver->get_title(), 'Log in to your account › Koha online catalog', "HTML explanation shows" );
    };

    $driver->quit();
}

END {
    C4::Context->set_preference( 'ILS-DI',     $original_ILSDI_value );
    C4::Context->set_preference( 'OpacPublic', $original_OpacPublic_value );
    $_->delete for @cleanup;
}
