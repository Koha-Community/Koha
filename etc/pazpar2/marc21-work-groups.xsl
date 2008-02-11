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
  <xsl:include href="MARC21slimUtils.xsl" />
  <xsl:include href="pz2-ourl-marc21.xsl" />
  
  <xsl:template match="/marc:record">
    <xsl:variable name="title_medium" select="marc:datafield[@tag='245']/marc:subfield[@code='h']"/>
    <xsl:variable name="journal_title" select="marc:datafield[@tag='773']/marc:subfield[@code='t']"/>
    <xsl:variable name="electronic_location_url" select="marc:datafield[@tag='856']/marc:subfield[@code='u']"/>
    <xsl:variable name="medium">
      <xsl:choose>
	<xsl:when test="$title_medium">
	  <xsl:value-of select="substring-after(substring-before($title_medium,']'),'[')"/>
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

    <xsl:variable name="uniform_title_key">
        <xsl:choose>
            <xsl:when test="marc:datafield[@tag='130']">
                <xsl:for-each select="marc:datafield[@tag='130']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">adgknmpr</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag='240']">
                <xsl:for-each select="marc:datafield[@tag='240']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">adgknmpr</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag='243']">
                <xsl:for-each select="marc:datafield[@tag='243']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">adgknmpr</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="title_key">
        <xsl:for-each select="marc:datafield[@tag='245']">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">abnp</xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="work_title">
        <xsl:choose>
          <xsl:when test="$uniform_title_key != ''">
             <xsl:value-of select="$uniform_title_key" />
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="$title_key" />
          </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="non_ut_main_entry_key">
        <xsl:choose>
            <xsl:when test="marc:datafield[@tag='100']">
                <xsl:for-each select="marc:datafield[@tag='100']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcd</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag='110']">
                <xsl:for-each select="marc:datafield[@tag='110']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcd</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag='111']">
                <xsl:for-each select="marc:datafield[@tag='111']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdnq</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="mergekey">
        <xsl:text>titlekey </xsl:text>
        <xsl:value-of select="$work_title" />
        <xsl:if test="$non_ut_main_entry_key != ''">
            <xsl:text> namemainentry </xsl:text>
            <xsl:value-of select="$non_ut_main_entry_key" />
        </xsl:if>
    </xsl:variable>

    <pz:record>
      <xsl:attribute name="mergekey">
        <xsl:value-of select="$mergekey"/>
      </xsl:attribute>

      <xsl:for-each select="marc:datafield[@tag='999']">
        <pz:metadata type="kohaid">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
      </xsl:for-each>

<!--
      <xsl:for-each select="marc:datafield[@tag='020']">
        <pz:metadata type="isbn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>
-->

      <xsl:for-each select="marc:datafield[@tag='245']">
        <pz:metadata type="work-title">
          <xsl:value-of select="$work_title" />
        </pz:metadata>
      </xsl:for-each>

      <xsl:if test="$non_ut_main_entry_key != ''">
        <pz:metadata type="work-author">
          <xsl:value-of select="$non_ut_main_entry_key" />
        </pz:metadata>
      </xsl:if>
<!--
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
-->

<!--
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
-->

    </pz:record>

  </xsl:template>

</xsl:stylesheet>
