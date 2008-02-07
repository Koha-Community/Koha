<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str">  
  
  <xsl:import href="pz2-ourl-base.xsl"/>

  <xsl:template name="ou-author" >
  <!-- what to do with multiple authors??-->
    <xsl:for-each select="marc:datafield[@tag='100' or @tag='700']">
      <xsl:value-of select="marc:subfield[@code='a']"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="ou-title" >
  <!-- if 773 exists its a journal/article -->
    <xsl:choose>
    
      <xsl:when test="marc:datafield[@tag='773']/marc:subfield[@code='t']">
        <xsl:value-of select="marc:datafield[@tag='773']/marc:subfield[@code='t']"/>
      </xsl:when>

      <xsl:when test="marc:datafield[@tag='245']/marc:subfield[@code='a']">
        <xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='a']"/>
      </xsl:when>

    </xsl:choose>
  </xsl:template>

  
  <xsl:template name="ou-atitle" >
    <!-- return value only if article or journal -->
    <xsl:if test="marc:datafield[@tag='773']">
      <xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='a']"/>
    </xsl:if>
  </xsl:template>


  <xsl:template name="ou-date" >
    <xsl:for-each select="marc:datafield[@tag='260']">
      <xsl:value-of select="marc:subfield[@code='c']"/>
    </xsl:for-each>
  </xsl:template>

  
  <xsl:template name="ou-isbn" >
  <!-- if 773 exists its a journal/article -->
    <xsl:choose>  
    
      <xsl:when test="marc:datafield[@tag='773']/marc:subfield[@code='z']">
        <xsl:value-of select="marc:datafield[@tag='773']/marc:subfield[@code='z']"/>
      </xsl:when>
      
      <xsl:when test="marc:datafield[@tag='020']/marc:subfield[@code='a']">
        <xsl:value-of select="marc:datafield[@tag='020']/marc:subfield[@code='a']"/>
      </xsl:when>

    </xsl:choose>
  </xsl:template>

  
  <xsl:template name="ou-issn" >
  <!-- if 773 exists its a journal/article -->
    <xsl:choose>
    
      <xsl:when test="marc:datafield[@tag='773']/marc:subfield[@code='x']">
        <xsl:value-of select="marc:datafield[@tag='773']/marc:subfield[@code='x']"/>
      </xsl:when>

      <xsl:when test="marc:datafield[@tag='022']/marc:subfield[@code='a']">
        <xsl:value-of select="marc:datafield[@tag='022']/marc:subfield[@code='a']"/>
      </xsl:when>

      </xsl:choose>
  </xsl:template>

  
  <xsl:template name="ou-volume" >
    <xsl:if test="marc:datafield[@tag='773']">
	  <xsl:value-of select="marc:datafield[@tag='773']/marc:subfield[@code='g']"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
<!--
/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 * vim: shiftwidth=2 tabstop=4 expandtab
 */
-->
