<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>

<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="marc">
	<xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	
	<!--Added ISBN and deleted attributes 6/04 jer-->
	
	<xsl:template match="/">
			<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>

	  <entry xmlns="http://www.w3.org/2005/Atom">

			<xsl:for-each select="marc:controlfield[@tag=001]">
				<id>
					<xsl:text>urn:tcn:</xsl:text>
					<xsl:value-of select="."/>
				</id>
			</xsl:for-each>

			<xsl:for-each select="marc:controlfield[@tag=005]">
				<updated>
					<xsl:value-of select="."/>
				</updated>
			</xsl:for-each>


			<xsl:for-each select="marc:datafield[@tag=245]">
				<title>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abfghk</xsl:with-param>
					</xsl:call-template>
				</title>
			</xsl:for-each>

	
			<xsl:for-each select="marc:datafield[@tag=100]">
				<author>
					<name>
						<xsl:value-of select="."/>
					</name>
				</author>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=110]|marc:datafield[@tag=111]|marc:datafield[@tag=700]|marc:datafield[@tag=710]|marc:datafield[@tag=711]|marc:datafield[@tag=720]">
				<author>
					<name>
						<xsl:value-of select="."/>
					</name>
				</author>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=655]">
				<category>
					<xsl:attribute name="term">
						<xsl:value-of select="./marc:subfield[@code='a' or @code='v']"/>
					</xsl:attribute>
				</category>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=260]">
				<rights type="html">
					<xsl:text>&#169; </xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">c</xsl:with-param>
					</xsl:call-template>
					<xsl:text>, </xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">b</xsl:with-param>
					</xsl:call-template>
				</rights>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
				<published>
					<xsl:value-of select="."/>
				</published>				
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[500&lt;@tag][@tag&lt;=599][not(@tag=506 or @tag=530 or @tag=540 or @tag=546)]">
				<summary>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</summary>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=600 or @tag=610 or @tag=611 or @tag=630 or @tag=650 or @tag=653]">
				<category>
					<xsl:attribute name="term">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abcdq</xsl:with-param>
						</xsl:call-template>
					</xsl:attribute>
				</category>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=856]">
				<dc:identifier>
					<xsl:value-of select="marc:subfield[@code='u']"/>
				</dc:identifier>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=020]">
				<dc:identifier>
					<xsl:text>URN:ISBN:</xsl:text>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</dc:identifier>
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
		</entry>
	</xsl:template>
</xsl:stylesheet>

