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

<!-- There's nothing to do here for UNIMARC but we need this file since the dom-config.xml file is cross-format -->

</xsl:stylesheet>
