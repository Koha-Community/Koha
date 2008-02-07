<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str">

  <xsl:param name="open_url_resolver"/>
  <!--<xsl:variable name="resolver">http://zeus.lib.uoc.gr:3210/sfxtst3</xsl:variable>-->
 
  <xsl:template name="insert-md-openurl">
  
    <xsl:value-of select="$open_url_resolver" /><xsl:text>?generatedby=pz2</xsl:text>
    <xsl:call-template name="ou-parse-author" />
    <xsl:call-template name="ou-parse-date" />
    <xsl:call-template name="ou-parse-volume" />
    <xsl:call-template name="ou-parse-any">
      <xsl:with-param name="field_name" select="string('isbn')" />
    </xsl:call-template>
    <xsl:call-template name="ou-parse-any">
      <xsl:with-param name="field_name" select="string('issn')" />
    </xsl:call-template>
    <xsl:call-template name="ou-parse-any">
      <xsl:with-param name="field_name" select="string('title')" />
    </xsl:call-template>
    <xsl:call-template name="ou-parse-any">
      <xsl:with-param name="field_name" select="string('atitle')" />
    </xsl:call-template>

  </xsl:template>
 
  <!-- parsing raw string data -->
  
  <xsl:template name="ou-parse-author" >
    <xsl:variable name="author">
      <xsl:call-template name="ou-author" />
    </xsl:variable>
    
    <xsl:variable name="aulast" select="normalize-space(substring-before($author, ','))"/>

    <xsl:variable name="aufirst" 
      select="substring-before( normalize-space(substring-after($author, ',')), ' ')"/>

    <xsl:if test="$aulast != ''">
      <xsl:text>&amp;aulast=</xsl:text>
      <xsl:value-of select="$aulast" />
    </xsl:if>

    <xsl:if test="string-length( translate($aufirst, '.', '') ) &gt; 1" >
      <xsl:text>&amp;aufirst=</xsl:text>
      <xsl:value-of select="$aufirst" />
    </xsl:if>

  </xsl:template>

  <xsl:template name="ou-parse-volume">
    <xsl:variable name="volume">
      <xsl:call-template name="ou-volume" />
    </xsl:variable>

    <xsl:variable name="vol" select="substring-after($volume, 'Vol')"/>
    <xsl:variable name="issue" select="false()" />
    <xsl:variable name="spage" select="false()" />

    <xsl:if test="$vol">
      <xsl:text>&amp;volume=</xsl:text>
      <xsl:value-of select="$vol" />
    </xsl:if>

    <xsl:if test="$issue">
      <xsl:text>&amp;issue=</xsl:text>
      <xsl:value-of select="$issue" />
    </xsl:if>
    
    <xsl:if test="$spage">
      <xsl:text>&amp;spage=</xsl:text>
      <xsl:value-of select="$vol" />
    </xsl:if>

  </xsl:template>


  <xsl:template name="ou-parse-date">
    <xsl:variable name="date">
      <xsl:call-template name="ou-date" />
    </xsl:variable>

    <xsl:variable name="parsed_date" select="translate($date, '.[]c;', '')"/>

    <xsl:if test="$parsed_date">
      <xsl:text>&amp;date=</xsl:text>
      <xsl:value-of select="$parsed_date" />
    </xsl:if>

  </xsl:template>

  
  <xsl:template name="ou-parse-any">
    <xsl:param name="field_name" />

    <xsl:variable name="field_value">
      <xsl:choose>

      <xsl:when test="$field_name = 'isbn'">
        <xsl:call-template name="ou-isbn"/>
      </xsl:when>

      <xsl:when test="$field_name = 'issn'">
        <xsl:call-template name="ou-issn"/>
      </xsl:when>
      
      <xsl:when test="$field_name = 'atitle'">
        <xsl:call-template name="ou-atitle"/>
      </xsl:when>
     
      <xsl:when test="$field_name = 'title'">
        <xsl:call-template name="ou-title"/>
      </xsl:when>

      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="digits" select="1234567890"/>

    <xsl:variable name="parsed_value">
      <xsl:choose>

      <xsl:when test="$field_name = 'isbn'">
        <xsl:value-of select="translate($field_value, translate($field_value, concat($digits, 'X'), ''), '')"/>
      </xsl:when>

      <xsl:when test="$field_name = 'issn'">
        <xsl:value-of select="translate($field_value, translate($field_value, concat($digits, '-', 'X'), ''), '')"/>
      </xsl:when>
      
      <xsl:when test="$field_name = 'atitle'">
        <xsl:value-of select="translate(normalize-space($field_value), '.', '')"/>
      </xsl:when>
     
      <xsl:when test="$field_name = 'title'">
        <xsl:value-of select="translate(normalize-space($field_value), '.', '')"/>
      </xsl:when>

      </xsl:choose>
    </xsl:variable>


    <xsl:if test="$parsed_value != ''">
      <xsl:text>&amp;</xsl:text>
      <xsl:value-of select="$field_name" />
      <xsl:text>=</xsl:text>
      <xsl:value-of select="$parsed_value" />
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
