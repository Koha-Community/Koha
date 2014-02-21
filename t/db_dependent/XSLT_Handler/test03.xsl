<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>

  <xsl:template match="/">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:copy select=".">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
