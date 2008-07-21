<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc">
	<xsl:import href="MARC21slimUtils.xsl"/>
	<xsl:output method="xml" indent="yes"/>
	
	<xsl:template match="/">
			<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="controlField001" select="marc:controlfield[@tag=001]"/>
		<xsl:variable name="controlField003" select="marc:controlfield[@tag=003]"/>
		<xsl:variable name="controlField005" select="marc:controlfield[@tag=005]"/>
		<xsl:variable name="controlField006" select="marc:controlfield[@tag=006]"/>
		<xsl:variable name="controlField007" select="marc:controlfield[@tag=007]"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
	<record>
			<xsl:if test="$leader"><leader><xsl:value-of select="$leader"/></leader></xsl:if>
			<xsl:if test="$controlField001">
			<controlfield><xsl:attribute name="tag">001</xsl:attribute><xsl:value-of select="$controlField001"/></controlfield>
			</xsl:if>
			<xsl:if test="$controlField003">
            <controlfield><xsl:attribute name="tag">003</xsl:attribute><xsl:value-of select="$controlField003"/></controlfield>
            </xsl:if>
			<xsl:if test="$controlField005">
            <controlfield><xsl:attribute name="tag">005</xsl:attribute><xsl:value-of select="$controlField005"/></controlfield>
            </xsl:if>
			<xsl:if test="$controlField006">
            <controlfield><xsl:attribute name="tag">006</xsl:attribute><xsl:value-of select="$controlField006"/></controlfield>
            </xsl:if>
			<xsl:if test="$controlField007">
            <controlfield><xsl:attribute name="tag">007</xsl:attribute><xsl:value-of select="$controlField007"/></controlfield>
            </xsl:if>
			<xsl:if test="$controlField008">
            <controlfield><xsl:attribute name="tag">008</xsl:attribute><xsl:value-of select="$controlField008"/></controlfield>
            </xsl:if>

			<xsl:for-each select="marc:datafield">
				<xsl:choose>
				<xsl:when test="@tag=952">
				<datafield tag="852" ind1=" " ind2=" ">

                    <xsl:for-each select="marc:subfield[@code='b']">
                    <subfield><xsl:attribute name="code">b</xsl:attribute>
                    <xsl:value-of select="."/>
                    </subfield>
                    </xsl:for-each>

                    <xsl:for-each select="marc:subfield[@code='p']">
                    <subfield><xsl:attribute name="code">p</xsl:attribute>
                    <xsl:value-of select="."/>
                    </subfield>
                    </xsl:for-each>

                    <xsl:for-each select="marc:subfield[@code='v']">
                    <subfield><xsl:attribute name="code">r</xsl:attribute>
                    <xsl:value-of select="."/>
                    </subfield>
                    </xsl:for-each>

                    <xsl:for-each select="marc:subfield[@code='y']">
                    <subfield><xsl:attribute name="code">w</xsl:attribute>
                    <xsl:value-of select="."/>
                    </subfield>
                    </xsl:for-each>

                    <xsl:for-each select="marc:subfield[@code='z']">
                    <subfield><xsl:attribute name="code">z</xsl:attribute>
                    <xsl:value-of select="."/>
                    </subfield>
                    </xsl:for-each>
				</datafield>
				</xsl:when>
				<xsl:otherwise>
					<datafield>
					<xsl:attribute name="tag"><xsl:value-of select="@tag"/></xsl:attribute>
					<xsl:attribute name="ind1"><xsl:value-of select="@ind1"/></xsl:attribute>
					<xsl:attribute name="ind2"><xsl:value-of select="@ind2"/></xsl:attribute>
						<xsl:for-each select="marc:subfield">
						<subfield><xsl:attribute name="code"><xsl:value-of select="@code"/></xsl:attribute><xsl:value-of select="."/></subfield>
						</xsl:for-each>
					</datafield>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

	</record>
	</xsl:template>
</xsl:stylesheet>
