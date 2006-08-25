<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:z="http://indexdata.dk/zebra/xslt/1" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNameSpaceSchemaLocation="http://library.neu.edu.tr/kohanamespace/KohaRecord.xsd" version="1.0">
	<!-- xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" -->
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
	<!-- disable all default text node output -->
	<xsl:template match="text()"/>
	<!-- match on koha xml record -->
	<xsl:template match="/">
		<xsl:if test="kohacollection">
			<kohacollection>
				<xsl:apply-templates select="kohacollection/koharecord"/>
			</kohacollection>
		</xsl:if>
		<xsl:if test="koharecord">
			<xsl:apply-templates select="koharecord"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="koharecord">
	<xsl:variable name="controlField001"   select="normalize-space(record/controlfield[@tag='001'])"/>

		<z:record z:id="{$controlField001}" z:type="update">
			<xsl:apply-templates/>
		</z:record>
	</xsl:template>
	<!-- KOHA indexing templates -->
	<!--biblionumber-->
	<xsl:template match="koharecord/record/controlfield[@tag='001']">
		<z:index name="Number-db" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Number-db" type="n">
			<xsl:value-of select="."/>
		</z:index>	
	</xsl:template>
	<xsl:template match="koharecord/record/controlfield[@tag='008']">
	<z:index name="Date/time-added-to-db" type="d">
			<xsl:value-of select="substring(.,1,6)"/>
		</z:index>
		<z:index name="Date/time-added-to-db" type="s">
			<xsl:value-of select="substring(.,1,6)"/>
		</z:index>
	</xsl:template>
	<!-- LC-card-number NOT USED BY NEU
	<xsl:template match="koharecord/record/datafield[@tag='010']">
		<z:index name="LC-card-number" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	</xsl:template>
 -->
	<xsl:template match="koharecord/record/datafield[@tag='020']">
		<z:index name="ISBN" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		<z:index name="Identifier-standard" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='022']">
		<z:index name="ISSN" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		<z:index name="Identifier-standard" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	</xsl:template>
	<!-- Cataloguing agency -->
	<xsl:template match="koharecord/record/datafield[@tag='040']">
		<z:index name="Record-source" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<!--language-->
	<xsl:template match="koharecord/record/datafield[@tag='041']">
		<z:index name="Code-language" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='050']">
		<z:index name="LC-call-number" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="LC-call-number" type="p">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='100']|koharecord/record/datafield[@tag='700']">
	<z:index name="Author" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	<z:index name="Personal-name" type="p">
			<xsl:value-of select="subfield[@code='a']"/>
			<xsl:text> </xsl:text>
		</z:index>
	<z:index name="Authority/format-id" type="w">
			<xsl:value-of select="subfield[@code='9']"/>
		</z:index>
		<z:index name="Author" type="s">
			<xsl:value-of select="subfield[@code='a']"/>
			<xsl:text> </xsl:text>
		</z:index>
		<z:index name="Author" type="p">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='110']">
		<z:index name="Author" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Corporate-name" type="p">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	<z:index name="Authority/format-id" type="w">
			<xsl:value-of select="subfield[@code='9']"/>
		</z:index>
		
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='111']">
	<z:index name="Author" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	<z:index name="Conference-name" type="p">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	<z:index name="Authority/format-id" type="w">
			<xsl:value-of select="subfield[@code='9']"/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='130']">
		<z:index name="Title-uniform" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Title" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='240']">
		<z:index name="Title-uniform" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Title" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='242']">
		<z:index name="Title-parallel" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Title" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='243']">
		<z:index name="Title-collective" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Title" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='245']|koharecord/record/datafield[@tag='740']">
		<z:index name="Title" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Title" type="s">
			<xsl:value-of select="subfield[@code='a']"/>
			<xsl:text> </xsl:text>
		</z:index>
		<z:index name="Title" type="p">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	<z:index name="Material-type" type="w">
			<xsl:value-of select="subfield[@code='h']"/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='260']">
	<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Place-publication" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		<z:index name="Publisher" type="w">
			<xsl:value-of select="subfield[@code='b']"/>
		</z:index>
		<z:index name="Date-of-Publication" type="w">
			<xsl:value-of select="subfield[@code='c']"/>
		</z:index>
	</xsl:template>
	<!--subscriptionid-->
	<xsl:template match="koharecord/record/datafield[@tag='310']/subfield[@code='6']">
	<z:index name="Thematic-number" type="n">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
<xsl:template match="koharecord/record/datafield[@tag='440']/subfield[@code='a']|koharecord/record/datafield[@tag='490']/subfield[@code='a']">
	<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Title-series" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='500']|koharecord/record/datafield[@tag='501']|koharecord/record/datafield[@tag='520']">
	<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Abstract" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/record/datafield[@tag='650']|koharecord/record/datafield[@tag='651']|koharecord/record/datafield[@tag='655']|koharecord/record/datafield[@tag='656']|koharecord/record/datafield[@tag='657']">
	<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="Subject-heading" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="LC-subject-heading" type="p">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
		<z:index name="Subject-subdivision" type="w">
			<xsl:value-of select="subfield[@code='v']|subfield[@code='x']|subfield[@code='y']|subfield[@code='z']"/>
		</z:index>
		<z:index name="Authority-format-id" type="w">
			<xsl:value-of select="subfield[@code='9']"/>
		</z:index>
	</xsl:template>
	<!--NEU Specific-->
	<xsl:template match="koharecord//record/datafield[@tag='942']">
	<!-- Padded LC number to sort lcsort-->
		<z:index name="Local-number" type="s">
			<xsl:value-of select="subfield[@code='k']"/>
			<xsl:text> </xsl:text>
		</z:index>
		<!--cataloguerid-->
		<z:index name="Indexed-by" type="w">
			<xsl:value-of select="subfield[@code='x']"/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>

	
	
	<!--Holdings specific indexing templates --><!--We use private indexing terms instead of Bib-1-->
	<!-- Itemnumber-->
	<xsl:template match="koharecord/holdings/record/controlfield[@tag='001']">
		<z:index name="itemnumber" type="w">
			<xsl:value-of select="."/>
		</z:index>
		<z:index name="itemnumber" type="n">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<!--Item biblionumber no need to index just to show concept-->
	<xsl:template match="koharecord/holdings/record/controlfield[@tag='004']">
		<z:index name="Number-db" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<!--datelastseen-->
	<xsl:template match="koharecord/holdings/record/controlfield[@tag='005']">
	<z:index name="datelastseen" type="d">
			<xsl:value-of select="substring(.,1,8)"/>
		</z:index>
	</xsl:template>
	<xsl:template match="koharecord/holdings/record/controlfield[@tag='008']">
	<z:index name="dateacquired" type="d">
			<xsl:value-of select="substring(.,1,6)"/>
		</z:index>
	<z:index name="dateacquired" type="s">
			<xsl:value-of select="substring(.,1,6)"/>
		</z:index>
	</xsl:template>
	<!--borrowernumber-->
	<xsl:template match="koharecord/holdings/record/datafield[@tag='887']/subfield[@code='a']">
		<z:index name="borrowernumber" type="w">
			<xsl:value-of select="."/>
		</z:index>
	</xsl:template>
	<!--lost & lwithdrawn-->
	<xsl:template match="koharecord/holdings/record/datafield[@tag='952']">
	<!--wthdrawn-->
		<z:index name="wthdrawn" type="n">
			<xsl:value-of select="subfield[@code='0']"/>
		</z:index>
		<!--itemlost-->
		<z:index name="itemlost" type="n">
			<xsl:value-of select="subfield[@code='1']"/>
		</z:index>
		<!--date_due-->
		<z:index name="date_due" type="d">
			<xsl:value-of select="subfield[@code='4']"/>
		</z:index>
		<z:index name="date_due" type="s">
			<xsl:value-of select="subfield[@code='4']"/>
		</z:index>

	
		<!--homebranch-->
	
		<z:index name="homebranch" type="w">
			<xsl:value-of select="subfield[@code='a']"/>
		</z:index>
	
	<!--holdingbranch-->
	
		<z:index name="holdingbranch" type="w">
			<xsl:value-of select="subfield[@code='b']"/>
		</z:index>
	
	<!--booksellerid-->
	
		<z:index name="booksellerid" type="w">
			<xsl:value-of select="subfield[@code='e']"/>
		</z:index>
	
	
	
	<!--shelf-->
		<z:index name="shelf" type="w">
			<xsl:value-of select="subfield[@code='f']"/>
		</z:index>
	<!--location-->
		<z:index name="location" type="w">
			<xsl:value-of select="subfield[@code='g']"/>
		</z:index>
	
	<!--cutter extra sorting bits-->
	
		<z:index name="cutterextra" type="s">
			<xsl:value-of select="."/>
		</z:index>
	
	<!--itemcallnumber-->

<z:index name="itemcallnumber" type="p">
			<xsl:value-of select="subfield[@code='o']"/>
		</z:index>
		<z:index name="itemcallnumber" type="s">
			<xsl:value-of select="subfield[@code='o']"/>
			<xsl:text> </xsl:text>
		</z:index>
	
	<!--circulation-desk-id-->
	
		<z:index name="circid" type="w">
			<xsl:value-of select="subfield[@code='x']"/>
		</z:index>
	
	<!--barcode-->
	
		<z:index name="barcode" type="w">
			<xsl:value-of select="subfield[@code='p']"/>
		</z:index>
	
	<!--itemnotes-->
	
		<z:index name="itemnotes" type="w">
			<xsl:value-of select="subfield[@code='z']"/>
		</z:index>
		<z:index name="any" type="w">
			<xsl:value-of select="subfield[@code='z']"/>
		</z:index>
	</xsl:template>
</xsl:stylesheet>
