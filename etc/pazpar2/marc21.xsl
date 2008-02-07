<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: marc21.xsl,v 1.22 2007-10-04 12:01:15 adam Exp $ -->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim">

  
  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

<!-- Extract metadata from MARC21/USMARC 
      http://www.loc.gov/marc/bibliographic/ecbdhome.html
-->  
  <xsl:include href="pz2-ourl-marc21.xsl" />
  
  <xsl:template match="/marc:record">
    <xsl:variable name="title_medium" select="marc:datafield[@tag='245']/marc:subfield[@code='h']"/>
    <xsl:variable name="journal_title" select="marc:datafield[@tag='773']/marc:subfield[@code='t']"/>
    <xsl:variable name="electronic_location_url" select="marc:datafield[@tag='856']/marc:subfield[@code='u']"/>
    <xsl:variable name="fulltext_a" select="marc:datafield[@tag='900']/marc:subfield[@code='a']"/>
    <xsl:variable name="fulltext_b" select="marc:datafield[@tag='900']/marc:subfield[@code='b']"/>
    <xsl:variable name="medium">
      <xsl:choose>
	<xsl:when test="$title_medium">
	  <xsl:value-of select="substring-after(substring-before($title_medium,']'),'[')"/>
	</xsl:when>
	<xsl:when test="$fulltext_a">
	  <xsl:text>electronic resource</xsl:text>
	</xsl:when>
	<xsl:when test="$fulltext_b">
	  <xsl:text>electronic resource</xsl:text>
	</xsl:when>
	<xsl:when test="$electronic_location_url">
	  <xsl:text>electronic resource</xsl:text>
	</xsl:when>
	<xsl:when test="$journal_title">
	  <xsl:text>article</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>book</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="mergekey">
        <xsl:text>title </xsl:text>
        <xsl:choose>
          <xsl:when test="marc:datafield[@tag='240']">
             <xsl:value-of select="marc:datafield[@tag='240']/marc:subfield[@code='a']"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='a']"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> author </xsl:text>
        <xsl:value-of select="marc:datafield[@tag='100']/marc:subfield[@code='a']"/>
<!--
        <xsl:text> medium </xsl:text>
        <xsl:value-of select="$medium"/>
-->
    </xsl:variable>

    <pz:record>
      <xsl:attribute name="mergekey">
        <xsl:value-of select="$mergekey"/>
      </xsl:attribute>

      
      <xsl:for-each select="marc:controlfield[@tag='001']">
        <pz:metadata type="id">
          <xsl:value-of select="."/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='010']">
        <pz:metadata type="lccn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='999']">
        <pz:metadata type="kohaid">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
      </xsl:for-each>


      <xsl:for-each select="marc:datafield[@tag='020']">
        <pz:metadata type="isbn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='022']">
        <pz:metadata type="issn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='027']">
        <pz:metadata type="tech-rep-nr">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='100']">
	<pz:metadata type="author">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="author-title">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="author-date">
	  <xsl:value-of select="marc:subfield[@code='d']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='110']">
	<pz:metadata type="corporate-name">
	    <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="corporate-location">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="corporate-date">
	    <xsl:value-of select="marc:subfield[@code='d']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='111']">
	<pz:metadata type="meeting-name">
	    <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="meeting-location">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="meeting-date">
	    <xsl:value-of select="marc:subfield[@code='d']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='260']">
	<pz:metadata type="date">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='245']">
        <pz:metadata type="title">
          <xsl:value-of select="marc:subfield[@code='a']"/>
        </pz:metadata>
        <pz:metadata type="title-remainder">
          <xsl:value-of select="marc:subfield[@code='b']"/>
        </pz:metadata>
        <pz:metadata type="title-responsibility">
          <xsl:value-of select="marc:subfield[@code='c']"/>
        </pz:metadata>
        <pz:metadata type="title-dates">
          <xsl:value-of select="marc:subfield[@code='f']"/>
        </pz:metadata>
        <pz:metadata type="title-medium">
          <xsl:value-of select="marc:subfield[@code='h']"/>
        </pz:metadata>
        <pz:metadata type="title-number-section">
          <xsl:value-of select="marc:subfield[@code='n']"/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='250']">
	<pz:metadata type="edition">
	    <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='260']">
        <pz:metadata type="publication-place">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
        <pz:metadata type="publication-name">
	  <xsl:value-of select="marc:subfield[@code='b']"/>
	</pz:metadata>
        <pz:metadata type="publication-date">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='300']">
	<pz:metadata type="physical-extent">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="physical-format">
	  <xsl:value-of select="marc:subfield[@code='b']"/>
	</pz:metadata>
	<pz:metadata type="physical-dimensions">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="physical-accomp">
	  <xsl:value-of select="marc:subfield[@code='e']"/>
	</pz:metadata>
	<pz:metadata type="physical-unittype">
	  <xsl:value-of select="marc:subfield[@code='f']"/>
	</pz:metadata>
	<pz:metadata type="physical-unitsize">
	  <xsl:value-of select="marc:subfield[@code='g']"/>
	</pz:metadata>
	<pz:metadata type="physical-specified">
	  <xsl:value-of select="marc:subfield[@code='3']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='440']">
	<pz:metadata type="series-title">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag &gt;= 500 and @tag &lt;= 599]
			    [@tag != '506' and @tag != '530' and
			    @tag != '540' and @tag != '546'
                            and @tag != '522']">
	<pz:metadata type="description">
            <xsl:value-of select="*/text()"/>
        </pz:metadata>
      </xsl:for-each>
      
      <xsl:for-each select="marc:datafield[@tag='650' or @tag='653']">
        <pz:metadata type="subject">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="subject-long">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text>, </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='856']">
	<pz:metadata type="electronic-url">
	  <xsl:value-of select="marc:subfield[@code='u']"/>
	</pz:metadata>
	<pz:metadata type="electronic-text">
	  <xsl:value-of select="marc:subfield[@code='y']"/>
	</pz:metadata>
	<pz:metadata type="electronic-note">
	  <xsl:value-of select="marc:subfield[@code='z']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='773']">
	<pz:metadata type="citation">
	  <xsl:for-each select="*">
	    <xsl:value-of select="normalize-space(.)"/>
	    <xsl:text> </xsl:text>
	  </xsl:for-each>
	</pz:metadata>
      </xsl:for-each>

      <pz:metadata type="medium">
	<xsl:value-of select="$medium"/>
      </pz:metadata>
      
      <xsl:if test="$fulltext_a">
	<pz:metadata type="fulltext">
	  <xsl:value-of select="$fulltext_a"/>
	</pz:metadata>
      </xsl:if>

      <xsl:if test="$fulltext_b">
	<pz:metadata type="fulltext">
	  <xsl:value-of select="$fulltext_b"/>
	</pz:metadata>
      </xsl:if>

      <xsl:if test="$open_url_resolver">
        <pz:metadata type="open-url">
            <xsl:call-template name="insert-md-openurl" />
        </pz:metadata>
      </xsl:if>

    </pz:record>

  </xsl:template>

</xsl:stylesheet>
