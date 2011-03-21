<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="marc">
	<xsl:import href="MARC21slimUtils.xsl"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- modification log 
	NT 01/04:  added collection level element
	and removed attributes

	JR 06/04:  Added ISBN identifier

   JR 09/05:  Added additional <subject> subfields and 651 for <coverage>
   RG 10/07/05: Corrected subject subfields; 10/12/05: added if statement for <language>
-->
	<xsl:template match="/">
		<xsl:if test="marc:collection">
			<srw_dc:dcCollection xmlns:srw_dc="info:srw/schema/1/dc-schema" xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/z3950/agency/zing/srw/dc-schema.xsd">
				<xsl:for-each select="marc:collection">
					<xsl:for-each select="marc:record">
						<srw_dc:dc>
							<xsl:apply-templates select="."/>
						</srw_dc:dc>
					</xsl:for-each>
				</xsl:for-each>
			</srw_dc:dcCollection>
		</xsl:if>
		<xsl:if test="marc:record">
			<srw_dc:dc xmlns:srw_dc="info:srw/schema/1/dc-schema" xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/z3950/agency/zing/srw/dc-schema.xsd">
				<xsl:apply-templates select="marc:record"/>
			</srw_dc:dc>
		</xsl:if>
	</xsl:template>
	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
		<xsl:for-each select="marc:datafield[@tag=245]">
			<title>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abfghk</xsl:with-param>
				</xsl:call-template>
			</title>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=100]|marc:datafield[@tag=110]|marc:datafield[@tag=111]|marc:datafield[@tag=700]|marc:datafield[@tag=710]|marc:datafield[@tag=711]|marc:datafield[@tag=720]">
			<creator>
				<xsl:value-of select="normalize-space(.)"/>
			</creator>
		</xsl:for-each>
		<type>
			<xsl:if test="$leader7='c'">
				<!-- nt fix 1/04 -->
				<!--<xsl:attribute name="collection">yes</xsl:attribute>-->
				<xsl:text>collection</xsl:text>
			</xsl:if>
			<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
				<!-- nt fix 1/04 -->
				<!--<xsl:attribute name="manuscript">yes</xsl:attribute> -->
				<xsl:text>manuscript</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
				<xsl:when test="$leader6='i' or $leader6='j'">sound recording</xsl:when>
				<xsl:when test="$leader6='k'">still image</xsl:when>
				<xsl:when test="$leader6='g'">moving image</xsl:when>
				<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
				<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
				<xsl:when test="$leader6='p'">mixed material</xsl:when>
			</xsl:choose>
		</type>
		<xsl:for-each select="marc:datafield[@tag=655]">
			<type>
				<xsl:value-of select="normalize-space(.)"/>
			</type>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=260]">
			<publisher>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ab</xsl:with-param>
				</xsl:call-template>
			</publisher>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
			<date>
				<xsl:value-of select="."/>
			</date>
		</xsl:for-each>
		<xsl:if test="substring($controlField008,36,3)">
			<language>
				<xsl:value-of select="substring($controlField008,36,3)"/>
			</language>
		</xsl:if>		
		<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q']">
			<format>
				<xsl:value-of select="."/>
			</format>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=520]">
			<description>
				<!-- nt fix 01/04 -->
				<xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
			</description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=521]">
			<description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[500&lt;@tag][@tag&lt;=599][not(@tag=506 or @tag=530 or @tag=540 or @tag=546)]">
			<description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=600]">
			<subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefghjklmnopqrstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
				<xsl:text>--</xsl:text>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">vxyz</xsl:with-param>
					<xsl:with-param name="delimeter">--</xsl:with-param>
				</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=610]">
			<subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefghklmnoprstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=611]">
			<subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">acdefghklnpqstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=630]">
			<subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">adfghklmnoprst</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=650]">
			<subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ae</xsl:with-param></xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=653]">
			<subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=651]">
			<coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=752]">
			<coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcd</xsl:with-param>
				</xsl:call-template>
			</coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=530]">
			<!-- nt 01/04 attribute fix -->
			<relation>
				<!--<xsl:attribute name="type">original</xsl:attribute>-->
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdu</xsl:with-param>
				</xsl:call-template>
			</relation>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=760]|marc:datafield[@tag=762]|marc:datafield[@tag=765]|marc:datafield[@tag=767]|marc:datafield[@tag=770]|marc:datafield[@tag=772]|marc:datafield[@tag=773]|marc:datafield[@tag=774]|marc:datafield[@tag=775]|marc:datafield[@tag=776]|marc:datafield[@tag=777]|marc:datafield[@tag=780]|marc:datafield[@tag=785]|marc:datafield[@tag=786]|marc:datafield[@tag=787]">
			<relation>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ot</xsl:with-param>
				</xsl:call-template>
			</relation>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=856]">
			<identifier>
				<xsl:value-of select="marc:subfield[@code='u']"/>
			</identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=020]">
			<identifier>
				<xsl:text>URN:ISBN:</xsl:text>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=506]">
			<rights>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</rights>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=540]">
			<rights>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</rights>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c)1998-2003 Copyright Sonic Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->