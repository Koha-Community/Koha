<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="record|marc:record">
      <record>
      <xsl:apply-templates/>
      <datafield tag="990" ind1='' ind2=''>
        <subfield code="a">
          <xsl:text>I saw you</xsl:text>
        </subfield>
      </datafield>
      </record>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:copy select=".">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
