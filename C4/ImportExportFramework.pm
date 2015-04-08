package C4::ImportExportFramework;

# Copyright 2010-2011 MASmedios.com y Ministerio de Cultura
#
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

use strict;
use warnings;
use XML::LibXML;
use XML::LibXML::XPathContext;
use Digest::MD5 qw();
use POSIX qw(strftime);

use C4::Context;
use C4::Debug;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    $VERSION = 3.07.00.049;    # set version for version checking
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        &ExportFramework
        &ImportFramework
        &createODS
    );
}


use constant XMLSTR => '<?xml version="1.0" encoding="UTF-8"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">

<Styles>
 <Style ss:ID="Default" ss:Name="Normal">
  <Alignment ss:Vertical="Bottom"/>
  <Borders/>
  <Font/>
  <Interior/>
  <NumberFormat/>
  <Protection/>
 </Style>
 <Style ss:ID="s27">
  <Font x:Family="Swiss" ss:Color="#0000FF" ss:Bold="1"/>
 </Style>
 <Style ss:ID="s21">
  <NumberFormat ss:Format="yyyy\-mm\-dd"/>
 </Style>
 <Style ss:ID="s22">
  <NumberFormat ss:Format="yyyy\-mm\-dd\ hh:mm:ss"/>
 </Style>
 <Style ss:ID="s23">
  <NumberFormat ss:Format="hh:mm:ss"/>
 </Style>
</Styles>

</Workbook>
';


use constant ODSSTR => '<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" office:version="1.0">
<office:scripts/>
<office:font-face-decls/>
<office:automatic-styles/>
</office:document-content>';


use constant ODS_STYLES_STR => '<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" office:version="1.0">
<office:font-face-decls></office:font-face-decls>
<office:styles></office:styles>
<office:automatic-styles></office:automatic-styles>
<office:master-styles></office:master-styles>
</office:document-styles>';


use constant ODS_SETTINGS_STR => '<?xml version="1.0" encoding="UTF-8"?>
<office:document-settings xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0" xmlns:ooo="http://openoffice.org/2004/office" office:version="1.0"><office:settings>
<config:config-item-set config:name="ooo:view-settings">
<config:config-item config:name="VisibleAreaTop" config:type="int">0</config:config-item>
<config:config-item config:name="VisibleAreaLeft" config:type="int">0</config:config-item>
<config:config-item config:name="VisibleAreaWidth" config:type="int">2000</config:config-item>
<config:config-item config:name="VisibleAreaHeight" config:type="int">900</config:config-item>
<config:config-item-map-indexed config:name="Views"><config:config-item-map-entry>
<config:config-item config:name="ViewId" config:type="string">View1</config:config-item>
<config:config-item-map-named config:name="Tables">
<config:config-item-map-entry config:name="Sheet1"><config:config-item config:name="CursorPositionX" config:type="int">0</config:config-item><config:config-item config:name="CursorPositionY" config:type="int">1</config:config-item><config:config-item config:name="HorizontalSplitMode" config:type="short">0</config:config-item><config:config-item config:name="VerticalSplitMode" config:type="short">0</config:config-item><config:config-item config:name="HorizontalSplitPosition" config:type="int">0</config:config-item><config:config-item config:name="VerticalSplitPosition" config:type="int">0</config:config-item><config:config-item config:name="ActiveSplitRange" config:type="short">2</config:config-item><config:config-item config:name="PositionLeft" config:type="int">0</config:config-item><config:config-item config:name="PositionRight" config:type="int">0</config:config-item><config:config-item config:name="PositionTop" config:type="int">0</config:config-item><config:config-item config:name="PositionBottom" config:type="int">0</config:config-item>
</config:config-item-map-entry>
</config:config-item-map-named>
<config:config-item config:name="ActiveTable" config:type="string">Sheet1</config:config-item>
<config:config-item config:name="HorizontalScrollbarWidth" config:type="int">270</config:config-item>
<config:config-item config:name="ZoomType" config:type="short">0</config:config-item>
<config:config-item config:name="ZoomValue" config:type="int">100</config:config-item>
<config:config-item config:name="PageViewZoomValue" config:type="int">50</config:config-item>
<config:config-item config:name="ShowPageBreakPreview" config:type="boolean">false</config:config-item>
<config:config-item config:name="ShowZeroValues" config:type="boolean">true</config:config-item>
<config:config-item config:name="ShowNotes" config:type="boolean">true</config:config-item>
<config:config-item config:name="ShowGrid" config:type="boolean">true</config:config-item>
<config:config-item config:name="GridColor" config:type="long">12632256</config:config-item>
<config:config-item config:name="ShowPageBreaks" config:type="boolean">true</config:config-item>
<config:config-item config:name="HasColumnRowHeaders" config:type="boolean">true</config:config-item>
<config:config-item config:name="HasSheetTabs" config:type="boolean">true</config:config-item>
<config:config-item config:name="IsOutlineSymbolsSet" config:type="boolean">true</config:config-item>
<config:config-item config:name="IsSnapToRaster" config:type="boolean">false</config:config-item>
<config:config-item config:name="RasterIsVisible" config:type="boolean">false</config:config-item>
<config:config-item config:name="IsRasterAxisSynchronized" config:type="boolean">true</config:config-item></config:config-item-map-entry></config:config-item-map-indexed>
</config:config-item-set>
<config:config-item-set config:name="ooo:configuration-settings">
<config:config-item config:name="ShowZeroValues" config:type="boolean">true</config:config-item>
<config:config-item config:name="ShowNotes" config:type="boolean">true</config:config-item>
<config:config-item config:name="ShowGrid" config:type="boolean">true</config:config-item>
<config:config-item config:name="GridColor" config:type="long">12632256</config:config-item>
<config:config-item config:name="ShowPageBreaks" config:type="boolean">true</config:config-item>
<config:config-item config:name="LinkUpdateMode" config:type="short">3</config:config-item>
<config:config-item config:name="HasColumnRowHeaders" config:type="boolean">true</config:config-item>
<config:config-item config:name="HasSheetTabs" config:type="boolean">true</config:config-item>
<config:config-item config:name="IsOutlineSymbolsSet" config:type="boolean">true</config:config-item>
<config:config-item config:name="IsSnapToRaster" config:type="boolean">false</config:config-item>
<config:config-item config:name="RasterIsVisible" config:type="boolean">false</config:config-item>
<config:config-item config:name="IsRasterAxisSynchronized" config:type="boolean">true</config:config-item>
<config:config-item config:name="AutoCalculate" config:type="boolean">true</config:config-item>
<config:config-item config:name="PrinterName" config:type="string">Generic Printer</config:config-item>
<config:config-item config:name="ApplyUserData" config:type="boolean">true</config:config-item>
<config:config-item config:name="CharacterCompressionType" config:type="short">0</config:config-item>
<config:config-item config:name="SaveVersionOnClose" config:type="boolean">false</config:config-item>
<config:config-item config:name="UpdateFromTemplate" config:type="boolean">false</config:config-item>
<config:config-item config:name="AllowPrintJobCancel" config:type="boolean">true</config:config-item>
<config:config-item config:name="LoadReadonly" config:type="boolean">false</config:config-item>
</config:config-item-set>
</office:settings></office:document-settings>';


use constant ODS_MANIFEST_STR => '<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
 <manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.spreadsheet" manifest:full-path="/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/statusbar/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/accelerator/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/floater/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/popupmenu/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/progressbar/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/menubar/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/toolbar/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/images/Bitmaps/"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/images/"/>
 <manifest:file-entry manifest:media-type="application/vnd.sun.xml.ui.configuration" manifest:full-path="Configurations2/"/>
 <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="content.xml"/>
 <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="styles.xml"/>
 <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="meta.xml"/>
 <manifest:file-entry manifest:media-type="" manifest:full-path="Thumbnails/"/>
 <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="settings.xml"/>
</manifest:manifest>';


=head1 NAME

C4::ImportExportFramework - Import/Export Framework to Excel-xml/ODS Module Functions

=head1 SYNOPSIS

  use C4::ImportExportFramework;

=head1 DESCRIPTION

Module to Import/Export Framework to Excel-xml/ODS on intranet administration - MARC Frameworks section

Module to Import/Export Framework to Excel-xml/ODS on intranet administration - MARC Frameworks section
exporting the tables marc_tag_structure, marc_subfield_structure to excel-xml/ods or viceversa

Functions for handling import/export.


=head1 SUBROUTINES



=head2 ExportFramework

Export all the information of a Framework to an excel "xml" file or OpenDocument SpreadSheet "ods" file.

return :
succes

=cut

sub ExportFramework
{
    my ($frameworkcode, $xmlStrRef, $mode) = @_;

    my $dbh = C4::Context->dbh;
    if ($dbh) {
        my $dom;
        my $root;
        my $elementSS;
        if ($mode eq 'ods' || $mode eq 'excel') {
            eval {
                my $parser = XML::LibXML->new();
                $dom = $parser->parse_string(($mode && $mode eq 'ods')?ODSSTR:XMLSTR);
                if ($dom) {
                    $root = $dom->documentElement();
                    if ($mode && $mode eq 'ods') {
                        my $elementBody = $dom->createElement('office:body');
                        $root->appendChild($elementBody);
                        $elementSS = $dom->createElement('office:spreadsheet');
                        $elementBody->appendChild($elementSS);
                    }
                }
            };
            if ($@) {
                $debug and warn "Error ExportFramework $@\n";
                return 0;
            }
        }

        if (_export_table('marc_tag_structure', $dbh, ($mode eq 'csv')?$xmlStrRef:$dom, ($mode eq 'ods')?$elementSS:$root, $frameworkcode, $mode)) {
            if (_export_table('marc_subfield_structure', $dbh, ($mode eq 'csv')?$xmlStrRef:$dom, ($mode eq 'ods')?$elementSS:$root, $frameworkcode, $mode)) {
                $$xmlStrRef = $dom->toString(1) if ($mode eq 'ods' || $mode eq 'excel');
                return 1;
            }
        }
    }
    return 0;
}#ExportFramework




# Export all the data from a mysql table to an spreadsheet.
sub _export_table
{
    my ($table, $dbh, $dom, $root, $frameworkcode, $mode) = @_;
    if ($mode eq 'csv') {
        _export_table_csv($table, $dbh, $dom, $root, $frameworkcode);
    } elsif ($mode eq 'ods') {
        _export_table_ods($table, $dbh, $dom, $root, $frameworkcode);
    } else {
        _export_table_excel($table, $dbh, $dom, $root, $frameworkcode);
    }
}

# Export the mysql table to an csv file
sub _export_table_csv
{
    my ($table, $dbh, $strCSV, $root, $frameworkcode) = @_;

    eval {
        # First row with the name of the columns
        my $query = 'SHOW COLUMNS FROM ' . $table;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my @fields = ();
        while (my $hashRef = $sth->fetchrow_hashref) {
            $$strCSV .= '"' . $hashRef->{Field} . '",';
            push @fields, $hashRef->{Field};
        }
        chop $$strCSV;
        $$strCSV .= chr(10);
        # Populate rows with the data from mysql
        $query = 'SELECT * FROM ' . $table . ' WHERE frameworkcode=?';
        $sth = $dbh->prepare($query);
        $sth->execute($frameworkcode);
        my $data;
        while (my $hashRef = $sth->fetchrow_hashref) {
            for (@fields) {
                $hashRef->{$_} =~ s/[\r\n]//g;
                $$strCSV .= '"' . $hashRef->{$_} . '",';
            }
            chop $$strCSV;
            $$strCSV .= chr(10);
        }
        $$strCSV .= chr(10);
        for (@fields) {
            # Separator for change of table
            $$strCSV .= '"#-#",';
        }
        chop $$strCSV;
        $$strCSV .= chr(10);
        $$strCSV .= chr(10);
    };
    if ($@) {
        $debug and warn "Error _export_table_csv $@\n";
        return 0;
    }
    return 1;
}#_export_table_csv


# Export the mysql table to an ods file
sub _export_table_ods
{
    my ($table, $dbh, $dom, $root, $frameworkcode) = @_;

    eval {
        my $elementTable = $dom->createElement('table:table');
        $elementTable->setAttribute('table:name', $table);
        $elementTable->setAttribute('table:print', 'false');
        $root->appendChild($elementTable);
        my $elementRow = $dom->createElement('table:table-row');
        $elementTable->appendChild($elementRow);

        my $elementCell;
        my $elementData;
        # First row with the name of the columns
        my $query = 'SHOW COLUMNS FROM ' . $table;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my @fields = ();
        while (my $hashRef = $sth->fetchrow_hashref) {
            $elementCell = $dom->createElement('table:table-cell');
            $elementCell->setAttribute('office:value-type', 'string');
            $elementCell->setAttribute('office:value', $hashRef->{Field});
            $elementRow->appendChild($elementCell);
            $elementData = $dom->createElement('text:p');
            $elementCell->appendChild($elementData);
            $elementData->appendTextNode($hashRef->{Field});
            push @fields, {name => $hashRef->{Field}, type => ($hashRef->{Type} =~ /int/i)?'float':'string'};
        }
        # Populate rows with the data from mysql
        $query = 'SELECT * FROM ' . $table . ' WHERE frameworkcode=?';
        $sth = $dbh->prepare($query);
        $sth->execute($frameworkcode);
        my $data;
        while (my $hashRef = $sth->fetchrow_hashref) {
            $elementRow = $dom->createElement('table:table-row');
            $elementTable->appendChild($elementRow);
            for (@fields) {
                $data = $hashRef->{$_->{name}};
                if ($_->{type} eq 'float' && !defined($data)) {
                    $data = '0';
                } elsif ($_->{type} eq 'string' && (!$data && $data ne '0')) {
                    $data = '#';
                }
                $data = _parseContent2Xml($data) if ($_->{type} eq 'string');
                $elementCell = $dom->createElement('table:table-cell');
                $elementCell->setAttribute('office:value-type', $_->{type});
                $elementCell->setAttribute('office:value', $data);
                $elementRow->appendChild($elementCell);
                $elementData = $dom->createElement('text:p');
                $elementCell->appendChild($elementData);
                $elementData->appendTextNode($data);
            }
        }
    };
    if ($@) {
        $debug and warn "Error _export_table_ods $@\n";
        return 0;
    }
    return 1;
}#_export_table_ods


# Export the mysql table to an excel-xml (openoffice/libreoffice compatible) file
sub _export_table_excel
{
    my ($table, $dbh, $dom, $root, $frameworkcode) = @_;

    eval {
        my $elementWS = $dom->createElement('Worksheet');
        $elementWS->setAttribute('ss:Name', $table);
        $root->appendChild($elementWS);
        my $elementTable = $dom->createElement('ss:Table');
        $elementWS->appendChild($elementTable);
        my $elementRow = $dom->createElement('ss:Row');
        $elementTable->appendChild($elementRow);

        # First row with the name of the columns
        my $elementCell;
        my $elementData;
        my $query = 'SHOW COLUMNS FROM ' . $table;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        my @fields = ();
        while (my $hashRef = $sth->fetchrow_hashref) {
            $elementCell = $dom->createElement('ss:Cell');
            $elementCell->setAttribute('ss:StyleID', 's27');
            $elementRow->appendChild($elementCell);
            $elementData = $dom->createElement('ss:Data');
            $elementData->setAttribute('ss:Type', 'String');
            $elementCell->appendChild($elementData);
            $elementData->appendTextNode($hashRef->{Field});
            push @fields, {name => $hashRef->{Field}, type => ($hashRef->{Type} =~ /int/i)?'Number':'String'};
        }
        # Populate rows with the data from mysql
        $query = 'SELECT * FROM ' . $table . ' WHERE frameworkcode=?';
        $sth = $dbh->prepare($query);
        $sth->execute($frameworkcode);
        my $data;
        while (my $hashRef = $sth->fetchrow_hashref) {
            $elementRow = $dom->createElement('ss:Row');
            $elementTable->appendChild($elementRow);
            for (@fields) {
                $elementCell = $dom->createElement('ss:Cell');
                $elementRow->appendChild($elementCell);
                $elementData = $dom->createElement('ss:Data');
                $elementData->setAttribute('ss:Type', $_->{type});
                $elementCell->appendChild($elementData);
                $data = $hashRef->{$_->{name}};
                if ($_->{type} eq 'Number' && !defined($data)) {
                    $data = '0';
                } elsif ($_->{type} eq 'String' && (!$data && $data ne '0')) {
                    $data = '#';
                }
                $elementData->appendTextNode(($_->{type} eq 'String')?_parseContent2Xml($data):$data);
            }
        }
    };
    if ($@) {
        $debug and warn "Error _export_table_excel $@\n";
        return 0;
    }
    return 1;
}#_export_table_excel







# Format chars problematics to a correct format for xml.
sub _parseContent2Xml
{
    my $content = shift;

    $content =~ s/\&(?![a-zA-Z#0-9]{1,4};)/&amp;/g;
    $content =~ s/</&lt;/g;
    $content =~ s/>/&gt;/g;
    return $content;
}#_parseContent2Xml


# Get the tmp directory on the system
sub _getTmp
{
    my $tmp = '/tmp';
    if ($ENV{'TMP'} && -d $ENV{'TMP'}) {
        $tmp = $ENV{'TMP'};
    } elsif ($ENV{'TMPDIR'} && -d $ENV{'TMPDIR'}) {
        $tmp = $ENV{'TMPDIR'};
    } elsif ($ENV{'TEMP'} && -d $ENV{'TEMP'}) {
        $tmp = $ENV{'TEMP'};
    }
    return $tmp;
}#_getTmp


# Create our tempdir directory for the ods process
sub _createTmpDir
{
    my $tmp = shift;

    my $tempdir = (-d $tmp)?$tmp . '/':'./';
    $tempdir .= 'tmp_ods_' . Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().{}.$$));
    eval {
        mkdir $tempdir;
    };
    if ($@) {
        return;
    } else {
        return $tempdir;
    }
}#_createTmpDir

=head2 createODS

Creates a temporary directory to create the ods file and read it to store its content in a string.

return :
success

=cut

sub createODS
{
    my ($strContent, $lang, $strODSRef) = @_;

    my $tmp = _getTmp();
    my $tempModule = 1;
    my $tempdir;
    eval {
        require File::Temp;
        import File::Temp qw/ tempfile tempdir /;
        $tempdir = tempdir ( 'tmp_ods_' . $$ . '_XXXXXXXX', DIR => (-d $tmp)?$tmp:'.', CLEANUP => 1);
    };
    if ($@) {
        $tempModule = 0;
        $tempdir = _createTmpDir($tmp);
    }
    if ($tempdir) {
        my $fh;
        # populate tempdir directory with the ods elements
        eval {
            if (open($fh, '>',  "$tempdir/content.xml")) {
                print {$fh} $strContent;
                close($fh);
            }
            if (open($fh, '>', "$tempdir/mimetype")) {
                print {$fh} 'application/vnd.oasis.opendocument.spreadsheet';
                close($fh);
            }
            if (open($fh, '>', "$tempdir/meta.xml")) {
                print {$fh} _getMeta($lang);
                close($fh);
            }
            if (open($fh, '>', "$tempdir/styles.xml")) {
                print {$fh} ODS_STYLES_STR;
                close($fh);
            }
            if (open($fh, '>', "$tempdir/settings.xml")) {
                print {$fh} ODS_SETTINGS_STR;
                close($fh);
            }
            mkdir($tempdir.'/META-INF/');
            mkdir($tempdir.'/Configurations2/');
            mkdir($tempdir.'/Configurations2/acceleator/');
            mkdir($tempdir.'/Configurations2/images/');
            mkdir($tempdir.'/Configurations2/popupmenu/');
            mkdir($tempdir.'/Configurations2/statusbar/');
            mkdir($tempdir.'/Configurations2/floater/');
            mkdir($tempdir.'/Configurations2/menubar/');
            mkdir($tempdir.'/Configurations2/progressbar/');
            mkdir($tempdir.'/Configurations2/toolbar/');

            if (open($fh, '>', "$tempdir/META-INF/manifest.xml")) {
                print {$fh} ODS_MANIFEST_STR;
                close($fh);
            }
        };
        if ($@) {
            $debug and warn "Error createODS $@\n";
        } else {
            # create ods file from tempdir directory
            eval {
                require Archive::Zip;
                import Archive::Zip qw( :ERROR_CODES :CONSTANTS );
                my $zip = Archive::Zip->new();
                $zip->addTree( $tempdir, '' );
                $zip->writeToFileNamed($tempdir . '/new.ods');
            };
            if ($@) {
                my $cmd = qx(which zip 2>/dev/null || whereis zip);
                chomp $cmd;
                $cmd = 'zip' if (!$cmd || !-x $cmd);
                system("cd $tempdir && $cmd -r new.ods ./");
            }
            my $ok = 0;
            # read ods file and return as a string
            if (-f "$tempdir/new.ods") {
                if (open ($fh, '<', "$tempdir/new.ods")) {
                    binmode $fh;
                    my $buffer;
                    while (read ($fh, $buffer, 65536)) {
                        $$strODSRef .= $buffer;
                    }
                    close($fh);
                    $ok = 1;
                }
            }
            # delete tempdir directory
            if (!$tempModule && $tempdir) {
                eval {
                    require File::Path;
                    import File::Temp qw/ rmtree /;
                    rmtree($tempdir);
                };
                if ($@) {
                    system("rm -rf $tempdir");
                }
            }
            return 1 if ($ok);
        }
    }
    return 0;
}#createODS


# return Meta content for ods file
sub _getMeta
{
    my $lang = shift;

    my $myDate = strftime ("%Y-%m-%dT%H:%M:%S", localtime(time()));
    my $meta = '<?xml version="1.0" encoding="UTF-8"?>
    <office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:ooo="http://openoffice.org/2004/office" office:version="1.0">
        <office:meta>
            <meta:generator>ods-php</meta:generator>
            <meta:creation-date>' . $myDate . '</meta:creation-date>
            <dc:date>' . $myDate . '</dc:date>
            <dc:language>' . $lang . '</dc:language>
            <meta:editing-cycles>2</meta:editing-cycles>
            <meta:editing-duration>PT15S</meta:editing-duration>
            <meta:user-defined meta:name="Info 1"/>
            <meta:user-defined meta:name="Info 2"/>
            <meta:user-defined meta:name="Info 3"/>
            <meta:user-defined meta:name="Info 4"/>
        </office:meta>
    </office:document-meta>';
    return $meta;
}#_getMeta


=head2 ImportFramework

Import all the information of a Framework from a excel-xml/ods file.

return :
success

=cut

sub ImportFramework
{
    my ($filename, $frameworkcode, $deleteFilename) = @_;

    my $tempdir;
    my $ok = -1;
    my $dbh = C4::Context->dbh;
    if (-r $filename && $dbh) {
        my $extension = '';
        if ($filename =~ /\.(csv|ods|xml)$/i) {
            $extension = lc($1);
        } else {
            unlink ($filename) if ($deleteFilename); # remove temporary file
            return -1;
        }
        if ($extension eq 'ods') {
            ($tempdir, $filename) = _openODS($filename, $deleteFilename);
        }
        if ($filename) {
            my $dom;
            eval {
                if ($extension eq 'ods' || $extension eq 'xml') {
                    # They have xml structure, so read it on a dom object
                    my $parser = XML::LibXML->new();
                    $dom = $parser->parse_file($filename);
                    if ($dom) {
                        my $root = $dom->documentElement();
                    }
                } else {
                    # They are text files, so open it to read
                    open($dom, '<', $filename);
                }
                if ($dom) {
                    # Process both tables
                    my $numDeleted = 0;
                    my $numDeletedAux = 0;
                    if (($numDeletedAux = _import_table($dbh, 'marc_tag_structure', $frameworkcode, $dom, ['frameworkcode', 'tagfield'], $extension)) >= 0) {
                        $numDeleted += $numDeletedAux if ($numDeletedAux > 0);
                        if (($numDeletedAux = _import_table($dbh, 'marc_subfield_structure', $frameworkcode, $dom, ['frameworkcode', 'tagfield', 'tagsubfield'], $extension)) >= 0) {
                            $numDeleted += $numDeletedAux if ($numDeletedAux > 0);
                            $ok = ($numDeleted > 0)?$numDeleted:0;
                        }
                    }
                } else {
                    $debug and warn "Error ImportFramework couldn't create dom\n";
                }
            };
            if ($@) {
                $debug and warn "Error ImportFramework $@\n";
            } else {
                if ($extension eq 'csv') {
                    close($dom) if ($dom);
                }
            }
        }
        unlink ($filename) if ($deleteFilename); # remove temporary file
    } else {
        $debug and warn "Error ImportFramework no conex to database or not readeable $filename\n";
    }
    if ($deleteFilename && $tempdir && -d $tempdir && -w $tempdir) {
        eval {
            require File::Path;
            import File::Temp qw/ rmtree /;
            rmtree($tempdir);
        };
        if ($@) {
            system("rm -rf $tempdir");
        }
    }
    return $ok;
}#ImportFramework

# Open (uncompress) ods file and return the content.xml file
sub _openODS
{
    my ($filename, $deleteFilename) = @_;

    my $tmp = _getTmp();
    my $tempModule = 1;
    my $tempdir;
    eval {
        require File::Temp;
        import File::Temp qw/ tempfile tempdir /;
        $tempdir = tempdir ( 'tmp_ods_' . $$ . '_XXXXXXXX', DIR => (-d $tmp)?$tmp:'.', CLEANUP => 1);
    };
    if ($@) {
        $tempModule = 0;
        $tempdir = _createTmpDir($tmp);
    }
    if ($tempdir) {
        eval {
            require Archive::Zip;
            import Archive::Zip qw( :ERROR_CODES :CONSTANTS );
            my $zip = Archive::Zip->new($filename);
            foreach my $file ($zip->members) {
                next if ($file->isDirectory);
                (my $extractName = $file->fileName) =~ s{.*/}{};
                next unless ($extractName eq 'content.xml');
                $file->extractToFileNamed("$tempdir/$extractName");
            }
        };
        if ($@) {
            my $cmd = qx(which unzip 2>/dev/null || whereis unzip);
            chomp $cmd;
            $cmd = 'unzip' if (!$cmd || !-x $cmd);
            system("$cmd $filename -d $tempdir");
        }
        if (-f "$tempdir/content.xml") {
            unlink ($filename) if ($deleteFilename);
            return ($tempdir, "$tempdir/content.xml");
        }
    }
    unlink ($filename) if ($deleteFilename);
    return ($tempdir, undef);
}#_openODS



# Check the table and columns corresponds with worksheet
sub _check_validity_worksheet
{
    my ($dbh, $table, $nodeFields, $fieldsA, $format) = @_;

    my $ret = 0;
    eval {
        my $query = 'DESCRIBE ' . $table;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        $sth->finish;
        $query = 'SHOW COLUMNS FROM ' . $table;
        $sth = $dbh->prepare($query);
        $sth->execute();
        my $fields = {};
        while (my $hashRef = $sth->fetchrow_hashref) {
            $fields->{$hashRef->{Field}} = $hashRef->{Field};
        }
        my @fields;
        my $fieldsR;
        if ($fieldsA) {
            $fieldsR = $fieldsA;
        } else {
            $fieldsR = \@fields;
            _getFields($nodeFields, $fieldsR, $format);
        }
        $ret = 1;
        for (@$fieldsR) {
            unless (exists($fields->{$_})) {
                $ret = 0;
                last;
            }
        }
    };
    return $ret;
}#_check_validity_worksheet


# Import the data from an excel-xml/ods to mysql tables.
sub _import_table
{
    my ($dbh, $table, $frameworkcode, $dom, $PKArray, $format) = @_;
    my %fields2Delete;
    my $query;
    my @fields;
    # Create hash with all elements defined by primary key to know which ones to delete after parsing the spreadsheet
    eval {
        @fields = @$PKArray;
        shift @fields;
        $query = 'SELECT ' . join(',', @fields) . ' FROM ' . $table . ' WHERE frameworkcode=?';
        my $sth = $dbh->prepare($query);
        $sth->execute($frameworkcode);
        my $field;
        while (my $hashRef = $sth->fetchrow_hashref) {
            $field = '';
            map { $field .= $hashRef->{$_} . '_'; } @fields;
            chop $field;
            $fields2Delete{$field} = 1;
        }
        $sth->finish;
    };
    my $ok = 0;
    if ($format eq 'csv') {
        my @fieldsName = ();
        eval {
            my $query = 'SHOW COLUMNS FROM ' . $table;
            my $sth = $dbh->prepare($query);
            $sth->execute();
            while (my $hashRef = $sth->fetchrow_hashref) {
                push @fieldsName, $hashRef->{Field};
            }
        };
        $ok = _import_table_csv($dbh, $table, $frameworkcode, $dom, $PKArray, \%fields2Delete, \@fieldsName);
    } elsif ($format eq 'ods') {
        $ok = _import_table_ods($dbh, $table, $frameworkcode, $dom, $PKArray, \%fields2Delete);
    } else {
        $ok = _import_table_excel($dbh, $table, $frameworkcode, $dom, $PKArray, \%fields2Delete);
    }
    if ($ok) {
        if (($ok = scalar(keys %fields2Delete)) > 0) {
            $query = 'DELETE FROM ' . $table . ' WHERE ';
            map {$query .= $_ . '=? AND ';} @$PKArray;
            $query = substr($query, 0, -4);
            my $sth = $dbh->prepare($query);
            for (keys %fields2Delete) {
                eval {
                    $sth->execute(($frameworkcode, split('_', $_)));
                };
            }
        }
    } else {
        $ok = -1;
    }
    return $ok;
}#_import_table


# Insert/Update the row from the spreadsheet in the database
sub _processRow_DB
{
    my ($dbh, $db_scheme, $table, $fields, $dataStr, $updateStr, $dataFields, $dataFieldsHash, $PKArray, $fieldsPK, $fields2Delete) = @_;

    my $ok = 0;
    my $query;
    if ($db_scheme eq 'mysql') {
        $query = 'INSERT INTO ' . $table . ' (' . $fields . ') VALUES (' . $dataStr . ') ON DUPLICATE KEY UPDATE ' . $updateStr;
    } else {
        $query = 'INSERT INTO ' . $table . ' (' . $fields . ') VALUES (' . $dataStr . ')';
    }
    eval {
        my $sth = $dbh->prepare($query);
        if ($db_scheme eq 'mysql') {
            $sth->execute((@$dataFields, @$dataFields));
        } else {
            $sth->execute(@$dataFields);
        }
    };
    if ($@) {
        unless ($db_scheme eq 'mysql') {
            $query = 'UPDATE ' . $table . ' SET ' . $updateStr . ' WHERE ';
            map {$query .= $_ . '=? AND ';} @$PKArray;
            $query = substr($query, 0, -4);
            eval {
                my $sth2 = $dbh->prepare($query);
                my @dataPK = ();
                map {push @dataPK, $dataFieldsHash->{$_};} @$PKArray;
                $sth2->execute((@$dataFields, @dataPK));
            };
            $ok = 1 unless ($@);
        }
        $debug and warn "Error _processRows_Table $@\n";
    } else {
        $ok = 1;
    }
    if ($ok) {
        my $field = '';
        map { $field .= $dataFieldsHash->{$_} . '_'; } @$fieldsPK;
        chop $field;
        delete $fields2Delete->{$field} if (exists($fields2Delete->{$field}));
    }
    return $ok;
}#_processRow_DB


# Process the rows of a worksheet and insert/update them in a mysql table.
sub _processRows_Table
{
    my ($dbh, $frameworkcode, $nodeR, $table, $PKArray, $format, $fields2Delete) = @_;

    my $query;
    my @fields = ();
    my $fields = '';
    my $dataStr = '';
    my $updateStr = '';
    my $j = 0;
    my $db_scheme = C4::Context->config("db_scheme");
    my $ok = 0;
    my @fieldsPK = @$PKArray;
    shift @fieldsPK;
    while ($nodeR) {
        if ($nodeR->nodeType == 1 && (($format && $format eq 'ods' && $nodeR->nodeName =~ /(?:table:)?table-row/) || ($nodeR->nodeName =~ /(?:ss:)?Row/)) && $nodeR->hasChildNodes()) {
            if ($j == 0) {
                # Get name columns
                _getFields($nodeR, \@fields, $format);
                return 0 unless _check_validity_worksheet($dbh, $table, $nodeR, \@fields, $format);
                $fields = join(',', @fields);
                $dataStr = '';
                map { $dataStr .= '?,';} @fields;
                chop($dataStr) if ($dataStr);
                $updateStr = '';
                map { $updateStr .= $_ . '=?,';} @fields;
                chop($updateStr) if ($updateStr);
            } else {
                # Get data from row
                my ($dataFields, $dataFieldsR) = _getDataFields($frameworkcode, $nodeR, \@fields, $format);
                if (scalar(@fields) == scalar(@$dataFieldsR)) {
                    $ok = _processRow_DB($dbh, $db_scheme, $table, $fields, $dataStr, $updateStr, $dataFieldsR, $dataFields, $PKArray, \@fieldsPK, $fields2Delete);
                }
            }
            $j++;
        }
        $nodeR = $nodeR->nextSibling;
    }
    return 1;
}#_processRows_Table




# Import worksheet from the csv file to the mysql table
sub _import_table_csv
{
    my ($dbh, $table, $frameworkcode, $dom, $PKArray, $fields2Delete, $fields) = @_;

    my $row = '';
    my $partialRow = '';
    my $numFields = @$fields;
    my $fieldsNameRead = 0;
    my @arrData;
    my ($fieldsStr, $dataStr, $updateStr);
    my $db_scheme = C4::Context->config("db_scheme");
    my @fieldsPK = @$PKArray;
    shift @fieldsPK;
    my $ok = 0;
    my $numRow = 0;
    my $pos = 0;
    while (<$dom>) {
        $row = $_;
        # Check whether the line has an unfinished field, i.e., a field with CR/LF in its data
        if ($row =~ /,"[^"]*[\r\n]+$/ || $row =~ /^[^"]+[\r\n]+$/) {
            $row =~ s/[\r\n]+$//;
            $partialRow .= $row;
            next;
        }
        if ($partialRow) {
            $row = $partialRow . $row;
            $partialRow = '';
        }
        # Line OK, process it
        if ($row =~ /(?:".*?",?)+/) {
            @arrData = split('","', $row);
            $arrData[0] = substr($arrData[0], 1) if ($arrData[0] =~ /^"/);
            $arrData[$#arrData] =~ s/[\r\n]+$//;
            chop $arrData[$#arrData] if ($arrData[$#arrData] =~ /"$/);
            if (@arrData) {
                if ($arrData[0] eq '#-#' && $arrData[$#arrData] eq '#-#') {
                    # Change of table with separators #-#
                    return 1;
                } elsif ($fieldsNameRead && $arrData[0] eq 'tagfield') {
                    # Change of table because we begin with field name with former field names read
                    seek($dom, $pos, 0);
                    return 1;
                }
                if (scalar(@$fields) == scalar(@arrData)) {
                    if (!$fieldsNameRead) {
                        # New table, we read the field names
                        $fieldsNameRead = 1;
                        for (my $i=0; $i < @arrData; $i++) {
                            if ($arrData[$i] ne $fields->[$i]) {
                                $fieldsNameRead = 0;
                                last;
                            }
                        }
                        if ($fieldsNameRead) {
                            $fieldsStr = join(',', @$fields);
                            $dataStr = '';
                            map { $dataStr .= '?,';} @$fields;
                            chop($dataStr) if ($dataStr);
                            $updateStr = '';
                            map { $updateStr .= $_ . '=?,';} @$fields;
                            chop($updateStr) if ($updateStr);
                        }
                    } else {
                        # Read data
                        my $j = 0;
                        my %dataFields = ();
                        for (@arrData) {
                            if ($fields->[$j] eq 'frameworkcode' && $_ ne $frameworkcode) {
                                $dataFields{$fields->[$j]} = $frameworkcode;
                                $arrData[$j] = $frameworkcode;
                            } else {
                                $dataFields{$fields->[$j]} = $_;
                            }
                            $j++
                        }
                        $ok = _processRow_DB($dbh, $db_scheme, $table, $fieldsStr, $dataStr, $updateStr, \@arrData, \%dataFields, $PKArray, \@fieldsPK, $fields2Delete);
                    }
                }
                $pos = tell($dom);
            }
            @arrData = ();
        }
        $numRow++;
    }
    return $ok;
}#_import_table_csv


# Import worksheet from the ods content.xml file to the mysql table
sub _import_table_ods
{
    my ($dbh, $table, $frameworkcode, $dom, $PKArray, $fields2Delete) = @_;

    my $xc = XML::LibXML::XPathContext->new($dom);
    $xc->registerNs('xmlns:office','urn:oasis:names:tc:opendocument:xmlns:office:1.0');
    $xc->registerNs('xmlns:table','urn:oasis:names:tc:opendocument:xmlns:table:1.0');
    $xc->registerNs('xmlns:text','urn:oasis:names:tc:opendocument:xmlns:text:1.0');
    my @nodes;
    @nodes = $xc->findnodes('//table:table[@table:name="' . $table . '"]');
    if (@nodes == 1 && $nodes[0]->hasChildNodes()) {
        my $nodeR = $nodes[0]->firstChild;
        return _processRows_Table($dbh, $frameworkcode, $nodeR, $table, $PKArray, 'ods', $fields2Delete);
    } else {
        $debug and warn "Error _import_table_ods there's not worksheet for $table\n";
    }
    return 0;
}#_import_table_ods


# Import worksheet from the excel-xml file to the mysql table
sub _import_table_excel
{
    my ($dbh, $table, $frameworkcode, $dom, $PKArray, $fields2Delete) = @_;

    my $xc = XML::LibXML::XPathContext->new($dom);
    $xc->registerNs('xmlns','urn:schemas-microsoft-com:office:spreadsheet');
    $xc->registerNs('xmlns:ss','urn:schemas-microsoft-com:office:spreadsheet');
    $xc->registerNs('xmlns:x','urn:schemas-microsoft-com:office:excel');
    my @nodes;
    @nodes = $xc->findnodes('//ss:Worksheet[@ss:Name="' . $table . '"]');
    if (@nodes > 0) {
        for (my $i=0; $i < @nodes; $i++) {
            my @nodesT = $nodes[$i]->getElementsByTagNameNS('urn:schemas-microsoft-com:office:spreadsheet', 'Table');
            if (@nodesT == 1 && $nodesT[0]->hasChildNodes()) {
                my $nodeR = $nodesT[0]->firstChild;
                return _processRows_Table($dbh, $frameworkcode, $nodeR, $table, $PKArray, undef, $fields2Delete);
            }
        }
    } else {
        $debug and warn "Error _import_table_excel there's not worksheet for $table\n";
    }
    return 0;
}#_import_table_excel


# Get the data from a cell on a ods file through the value attribute or the text node
sub _getDataNodeODS
{
    my $node = shift;

    my $data;
    my $repeated = 0;
    if ($node->nodeType == 1 && $node->nodeName =~ /(?:table:)?table-cell/) {
        if ($node->hasAttributeNS('urn:oasis:names:tc:opendocument:xmlns:office:1.0', 'value')) {
            $data = $node->getAttributeNS('urn:oasis:names:tc:opendocument:xmlns:office:1.0', 'value');
        } elsif ($node->hasChildNodes()) {
            my @nodes2 = $node->getElementsByTagNameNS('urn:oasis:names:tc:opendocument:xmlns:text:1.0', 'p');
            if (@nodes2 == 1 && $nodes2[0]->hasChildNodes()) {
                $data = $nodes2[0]->firstChild->nodeValue;
            }
        }
        if ($node->hasAttributeNS('urn:oasis:names:tc:opendocument:xmlns:table:1.0', 'number-columns-repeated')) {
            $repeated = $node->getAttributeNS('urn:oasis:names:tc:opendocument:xmlns:table:1.0', 'number-columns-repeated');
        }
    }
    return ($data, $repeated);
}#_getDataNodeODS


# Get the data from a row of a spreadsheet
sub _getDataFields
{
    my ($frameworkcode, $node, $fields, $format) = @_;

    my $dataFields = {};
    my @dataFieldsA = ();
    if ($node && $node->hasChildNodes()) {
        my $node2 = $node->firstChild;
        my ($data, $repeated);
        my $i = 0;
        my $ok = 0;
        $repeated = 0;
        while ($node2) {
            if ($format && $format eq 'ods') {
                ($data, $repeated) = _getDataNodeODS($node2) if ($repeated <= 0);
                $repeated--;
                $ok = 1 if (defined($data));
            } else {
                if ($node2->nodeType == 1 && $node2->nodeName  =~ /(?:ss:)?Cell/) {
                    my @nodes3 = $node2->getElementsByTagNameNS('urn:schemas-microsoft-com:office:spreadsheet', 'Data');
                    if (@nodes3 == 1 && $nodes3[0]->hasChildNodes()) {
                        $data = $nodes3[0]->firstChild->nodeValue;
                        $ok = 1;
                    }
                }
            }
            if ($ok) {
                $data = '' if ($data eq '#');
                $data = $frameworkcode if ($fields->[$i] eq 'frameworkcode');
                $dataFields->{$fields->[$i]} = $data;
                push @dataFieldsA, $data;
                $i++;
            }
            $ok = 0;
            $node2 = $node2->nextSibling if ($repeated <= 0);
        }
    }
    return ($dataFields, \@dataFieldsA);
}#_getDataFields


# Get the data from the first row to know the column names
sub _getFields
{
    my ($node, $fields, $format) = @_;

    if ($node && $node->hasChildNodes()) {
        my $node2 = $node->firstChild;
        my ($data, $repeated);
        while ($node2) {
            if ($format && $format eq 'ods') {
                ($data, $repeated) = _getDataNodeODS($node2);
                push @$fields, $data if (defined($data));
            } else {
                if ($node2->nodeType == 1 && $node2->nodeName =~ /(?:ss:)?Cell/) {
                    my @nodes3 = $node2->getElementsByTagNameNS('urn:schemas-microsoft-com:office:spreadsheet', 'Data');
                    if (@nodes3 == 1 && $nodes3[0]->hasChildNodes()) {
                        $data = $nodes3[0]->firstChild->nodeValue;
                        push @$fields, $data;
                    }
                }
            }
            $node2 = $node2->nextSibling;
        }
    }
}#_getFields




1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut


