<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:marc="http://www.loc.gov/MARC21/slim"
 version="1.0">
<xsl:output indent="yes"
      method="xml"
      version="1.0"
      encoding="UTF-8"/>

 <xsl:template name="identity" match="node()|@*">
   <xsl:copy>
     <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
 </xsl:template>

 <xsl:template match="marc:datafield[@tag=880]">
    <xsl:element name="datafield" namespace="http://www.loc.gov/MARC21/slim">
        <xsl:attribute name="tag"><xsl:value-of select="substring(marc:subfield[@code=6],1,3)"/></xsl:attribute>
        <xsl:attribute name="ind1"><xsl:value-of select="@ind1"/></xsl:attribute>
        <xsl:attribute name="ind2"><xsl:value-of select="@ind2"/></xsl:attribute>
        <xsl:apply-templates select="marc:subfield[@code != '6']"/>
    </xsl:element>
</xsl:template>

</xsl:stylesheet>
