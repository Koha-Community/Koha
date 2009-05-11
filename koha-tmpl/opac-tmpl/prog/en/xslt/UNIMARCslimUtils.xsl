<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="datafield">
		<xsl:param name="tag"/>
		<xsl:param name="ind1"><xsl:text> </xsl:text></xsl:param>
		<xsl:param name="ind2"><xsl:text> </xsl:text></xsl:param>
		<xsl:param name="subfields"/>
		<xsl:element name="datafield">
			<xsl:attribute name="tag">
				<xsl:value-of select="$tag"/>
			</xsl:attribute>
			<xsl:attribute name="ind1">
				<xsl:value-of select="$ind1"/>
			</xsl:attribute>
			<xsl:attribute name="ind2">
				<xsl:value-of select="$ind2"/>
			</xsl:attribute>
			<xsl:copy-of select="$subfields"/>
		</xsl:element>
	</xsl:template>

	<xsl:template name="tag_210">
    <xsl:for-each select="marc:datafield[@tag=210]">
  	    <span class="results_summary">
        <span class="label">Édition: </span> 
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:if test="marc:subfield[@code='c']">
          <xsl:if test="marc:subfield[@code='a']"> : </xsl:if>
          <xsl:value-of select="marc:subfield[@code='c']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='d']">
          <xsl:if test="marc:subfield[@code='a' or @code='c']">, </xsl:if>        
          <xsl:value-of select="marc:subfield[@code='d']"/>
        </xsl:if>
        <xsl:value-of select="marc:subfield[@code='e']"/>
        <xsl:if test="marc:subfield[@code='g']">
          <xsl:if test="marc:subfield[@code='e']"> : </xsl:if>
          <xsl:value-of select="marc:subfield[@code='g']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='h']">
          <xsl:if test="marc:subfield[@code='e' or @code='g']">, </xsl:if>        
          <xsl:value-of select="marc:subfield[@code='h']"/>
        </xsl:if>
      </span>
    </xsl:for-each>
  </xsl:template>

	<xsl:template name="tag_215">
    <xsl:for-each select="marc:datafield[@tag=215]">
  	  <span class="results_summary">
        <span class="label">Description: </span> 
        <xsl:if test="marc:subfield[@code='a']">
          <xsl:value-of select="marc:subfield[@code='a']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='c']"> :
          <xsl:value-of select="marc:subfield[@code='c']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='d']"> ;
          <xsl:value-of select="marc:subfield[@code='d']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='e']"> +
          <xsl:value-of select="marc:subfield[@code='e']"/>
        </xsl:if>
      </span>
    </xsl:for-each>
  </xsl:template>


	<xsl:template name="tag_4xx">
    <xsl:for-each select="marc:datafield[@tag=464 or @tag=461]">
    	  <span class="results_summary">
        <span class="label">Extrait de: </span> 
        <xsl:if test="marc:subfield[@code='t']">
          <xsl:value-of select="marc:subfield[@code='t']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='e']"> :
          <xsl:value-of select="marc:subfield[@code='e']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='f']"> /
          <xsl:value-of select="marc:subfield[@code='f']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='v']">,
          <xsl:value-of select="marc:subfield[@code='v']"/>
        </xsl:if>
      </span>
    </xsl:for-each>
  </xsl:template>

	<xsl:template name="subfieldSelect">
		<xsl:param name="codes"/>
		<xsl:param name="delimeter"><xsl:text> </xsl:text></xsl:param>
		<xsl:param name="subdivCodes"/>
		<xsl:param name="subdivDelimiter"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
                    <xsl:if test="contains($subdivCodes, @code)">
                        <xsl:value-of select="$subdivDelimiter"/>
                    </xsl:if>
					<xsl:value-of select="text()"/><xsl:value-of select="$delimeter"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))"/>
	</xsl:template>

	<xsl:template name="buildSpaces">
		<xsl:param name="spaces"/>
		<xsl:param name="char"><xsl:text> </xsl:text></xsl:param>
		<xsl:if test="$spaces>0">
			<xsl:value-of select="$char"/>
			<xsl:call-template name="buildSpaces">
				<xsl:with-param name="spaces" select="$spaces - 1"/>
				<xsl:with-param name="char" select="$char"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="chopPunctuation">
		<xsl:param name="chopString"/>
		<xsl:variable name="length" select="string-length($chopString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="contains('.:,;/ ', substring($chopString,$length,1))">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="substring($chopString,1,$length - 1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not($chopString)"/>
			<xsl:otherwise><xsl:value-of select="$chopString"/></xsl:otherwise>
		</xsl:choose>
<xsl:text> </xsl:text>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios/><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
