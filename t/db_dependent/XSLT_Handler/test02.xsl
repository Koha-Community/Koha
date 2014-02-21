<!-- This is BAD coded xslt stylesheet to test XSLT_Handler -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:variable name="redefine" select="0"/>
  <xsl:variable name="redefine" select="1"/>
      <!-- Intentional redefine to generate parsing error -->
  <xsl:template match="record">
  </xsl:template>
</xsl:stylesheet>
