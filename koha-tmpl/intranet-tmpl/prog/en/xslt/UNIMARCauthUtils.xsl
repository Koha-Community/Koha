<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!-- ***************** Templates *************-->
  <xsl:template name="tag_152">
    <li class="authtype">
      <xsl:value-of select="marc:datafield[@tag='152']/marc:subfield[@code='b']"/>
    </li>
  </xsl:template>
  <xsl:template name="tag_3xx">
    <li class="note">
      <xsl:for-each select="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:text>. </xsl:text>
      </xsl:for-each>
    </li>
  </xsl:template>
  <xsl:template name="tag_4xx">
    <xsl:param name="tag" />
      <li class="usefor">
        <span class="leg">UF : </span>
        <xsl:for-each select="marc:datafield[@tag=$tag]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:if test="marc:subfield[@code='b']">
            <xsl:text> </xsl:text>
            <xsl:value-of select="marc:subfield[@code='b']"/>
          </xsl:if>
          <xsl:text> ; </xsl:text>
        </xsl:for-each>
      </li>
  </xsl:template>
  <xsl:template name="tag_5xx">
    <li class="related">
      <xsl:for-each select="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='5']='g'">
            <span class="leg">GT : </span>
          </xsl:when>
          <xsl:when test="marc:subfield[@code='5']='h'">
            <span class="leg">ST : </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="leg">RT : </span>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='9']">
            <a>
              <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="marc:subfield[@code='9']"/></xsl:attribute>
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
            </a>
          </xsl:when>
          <xsl:when test="marc:subfield[@code='3']">
            <a>
              <xsl:attribute name="href">/cgi-bin/koha/authorities/authorities-home.pl?op=do_search&amp;type=intranet&amp;value=identifier-standard%3A<xsl:value-of select="marc:subfield[@code='3']"/></xsl:attribute>
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="marc:subfield[@code='a']"/>
            <xsl:if test="marc:subfield[@code='b']">
              <xsl:text> </xsl:text>
              <xsl:value-of select="."/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> ; </xsl:text>
      </xsl:for-each>
    </li>
  </xsl:template>
  <!--*** End Templates **-->
</xsl:stylesheet>
