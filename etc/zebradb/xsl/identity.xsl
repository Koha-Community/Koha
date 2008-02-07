<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="1.0">
<!-- Identity transform stylesheet -->

<xsl:output indent="yes"
      method="xml"
      version="1.0"
      encoding="UTF-8"/>

 <xsl:template match="node()|@*">
   <xsl:copy>
     <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
 </xsl:template>

</xsl:stylesheet>
