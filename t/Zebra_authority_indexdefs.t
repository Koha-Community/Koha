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

use File::Basename qw( dirname );
use File::Slurp    qw( read_file );
use XML::LibXML;
use XML::LibXSLT;

my $zebradb_dir = dirname(__FILE__) . '/../etc/zebradb';
my @flavours    = qw( marc21 unimarc );

sub indexdefs_file {
    my ($flavour) = @_;
    return "$zebradb_dir/marc_defs/$flavour/authorities/authority-koha-indexdefs.xml";
}

subtest 'Every field indexed as authtype also feeds the authtype phrase register' => sub {

    plan tests => scalar @flavours;

    # C4::AuthoritiesMarc::SearchAuthorities matches authtype with the
    # completeness attribute (@attr 6=3, bug 41795), which only looks at the
    # phrase register: a record whose authority type is only indexed as
    # authtype:w would never be found by a type-filtered search (bug 43498).
    for my $flavour (@flavours) {
        my $doc = XML::LibXML->load_xml( location => indexdefs_file($flavour) );
        my $xpc = XML::LibXML::XPathContext->new($doc);
        $xpc->registerNs( kohaidx => $doc->documentElement->namespaceURI );

        my @missing;
        for my $target ( $xpc->findnodes('//kohaidx:target_index[starts-with(., "authtype:")]') ) {
            my $block = $target->parentNode;
            next if $xpc->exists( 'kohaidx:target_index[. = "authtype:p"]', $block );
            push @missing, join( ' ', grep { defined } $block->localname, $block->getAttribute('tag') );
        }
        my %seen;
        @missing = grep { !$seen{$_}++ } @missing;

        is_deeply( \@missing, [], "$flavour: no authtype index without authtype:p" )
            or diag( "Missing authtype:p in: " . join( ', ', @missing ) );
    }
};

subtest 'authority-zebra-indexdefs.xsl is up to date with authority-koha-indexdefs.xml' => sub {

    plan tests => scalar @flavours;

    my $stylesheet = XML::LibXSLT->new->parse_stylesheet(
        XML::LibXML->load_xml( location => "$zebradb_dir/xsl/koha-indexdefs-to-zebra.xsl" ) );

    for my $flavour (@flavours) {
        my $generated = $stylesheet->output_as_bytes(
            $stylesheet->transform( XML::LibXML->load_xml( location => indexdefs_file($flavour) ) ) );
        my $shipped = read_file(
            "$zebradb_dir/marc_defs/$flavour/authorities/authority-zebra-indexdefs.xsl",
            binmode => ':raw'
        );
        ok( $generated eq $shipped, "$flavour: authority-zebra-indexdefs.xsl matches its regenerated version" )
            or diag("Regenerate it with xsltproc, see the header of authority-koha-indexdefs.xml");
    }
};
