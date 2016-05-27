<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>

<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha-community.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">
<xsl:import href="UNIMARCslimUtils.xsl"/>
<xsl:output method = "html" indent="yes" omit-xml-declaration = "yes" encoding="UTF-8"/>
<xsl:key name="item-by-status" match="items:item" use="items:status"/>
<xsl:key name="item-by-status-and-branch" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="marc:record">
  <xsl:variable name="IntranetBiblioDefaultView" select="marc:sysprefs/marc:syspref[@name='IntranetBiblioDefaultView']"/>
  <xsl:variable name="leader" select="marc:leader"/>
  <xsl:variable name="leader6" select="substring($leader,7,1)"/>
  <xsl:variable name="leader7" select="substring($leader,8,1)"/>
  <xsl:variable name="biblionumber" select="marc:controlfield[@tag=001]"/>
  <xsl:variable name="isbn" select="marc:datafield[@tag=010]/marc:subfield[@code='a']"/>

  <xsl:if test="marc:datafield[@tag=200]">
    <xsl:for-each select="marc:datafield[@tag=200]">
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="buildBiblioDefaultViewURL">
            <xsl:with-param name="IntranetBiblioDefaultView">
              <xsl:value-of select="$IntranetBiblioDefaultView"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:value-of select="$biblionumber"/>
        </xsl:attribute>
        <xsl:attribute name="class">title</xsl:attribute>

        <xsl:variable name="title" select="marc:subfield[@code='a']"/>
        <xsl:variable name="ntitle"
            select="translate($title, '&#x0098;&#x009C;&#xC29C;&#xC29B;&#xC298;&#xC288;&#xC289;','')"/>
        <xsl:value-of select="$ntitle" />
      </a>
      <xsl:if test="marc:subfield[@code='e']">
        <xsl:text> : </xsl:text>
        <xsl:value-of select="marc:subfield[@code='e']"/>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='b']">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="marc:subfield[@code='b']"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='h']">
        <xsl:text> : </xsl:text>
        <xsl:value-of select="marc:subfield[@code='h']"/>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='i']">
        <xsl:text> : </xsl:text>
        <xsl:value-of select="marc:subfield[@code='i']"/>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='f']">
        <xsl:text> / </xsl:text>
        <xsl:value-of select="marc:subfield[@code='f']"/>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='g']">
        <xsl:text> ; </xsl:text>
        <xsl:value-of select="marc:subfield[@code='g']"/>
      </xsl:if>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </xsl:if>

  <xsl:call-template name="tag_4xx" />

  <xsl:call-template name="tag_210" />

  <xsl:call-template name="tag_215" />

</xsl:template>
</xsl:stylesheet>
