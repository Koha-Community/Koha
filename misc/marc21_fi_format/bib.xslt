<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="common.xslt"/>

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="/">
  <xsl:element name="fields">
  <xsl:copy>
    <xsl:apply-templates select="document('data/bib-000.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-001-006.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-007.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-008.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-01X-04X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-05X-08X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-1XX.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-20X-24X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-250-270.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-3XX.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-4XX.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-50X-53X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-53X-58X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-6XX.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-70X-75X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-76X-78X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-80X-830.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-841-88X.xml')/fields"/>
    <xsl:apply-templates select="document('data/bib-9XX.xml')/fields"/>
  </xsl:copy>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
