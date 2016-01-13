<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;">]>
<xsl:stylesheet
 xmlns:marc="http://www.loc.gov/MARC21/slim"
 xmlns:srw_dc="info:srw/schema/1/dc-schema"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns="http://purl.org/dc/elements/1.1/"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="1.0"
 exclude-result-prefixes="marc">
  <xsl:import href="UNIMARCslimUtils.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:template match="/">
    <xsl:if test="marc:collection">
      <srw_dc:dcCollection xmlns:srw_dc="info:srw/schema/1/dc-schema" xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/z3950/agency/zing/srw/dc-schema.xsd">
        <xsl:for-each select="marc:collection">
          <xsl:for-each select="marc:record">
            <srw_dc:dc>
              <xsl:apply-templates select="."/>
            </srw_dc:dc>
          </xsl:for-each>
        </xsl:for-each>
      </srw_dc:dcCollection>
    </xsl:if>
    <xsl:if test="marc:record">
      <srw_dc:dc xmlns:srw_dc="info:srw/schema/1/dc-schema" xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/z3950/agency/zing/srw/dc-schema.xsd">
        <xsl:apply-templates select="marc:record"/>
      </srw_dc:dc>
    </xsl:if>
  </xsl:template>
  <xsl:template match="marc:record">
    <xsl:for-each select="marc:datafield[@tag=200]">
      <title>
        <xsl:variable name="title" select="marc:subfield[@code='a']"/>
        <xsl:variable name="ntitle"
         select="translate($title, '&#x0098;&#x009C;&#xC29C;&#xC29B;&#xC298;&#xC288;&#xC289;','')"/>
        <xsl:value-of select="$ntitle" />
        <xsl:if test="marc:subfield[@code='e']">
          <xsl:text> : </xsl:text>
          <xsl:for-each select="marc:subfield[@code='e']">
            <xsl:value-of select="."/>
          </xsl:for-each>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code='h' or @code='i' or @code='v']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="."/>
        </xsl:for-each>
      </title>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=700 or @tag=701 or @tag=702 or @tag=710 or @tag=711 or @tag=712]">
      <creator>
        <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d']">
          <xsl:value-of select="." />
          <xsl:if test="not(position()=last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='4']='010'">, adapter</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='020'">, annotator</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='075'">, author of afterword</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='080'">, prefacer</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='100'">, bibliographic antecedent</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='205'">, collaborator</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='212'">, commentator</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='220'">, compiler</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='230'">, composer</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='245'">, conceptor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='295'">, degree-grantor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='340'">, editor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='370'">, film editor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='395'">, founder</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='440'">, illustrator</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='520'">, lyricist</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='557'">, organiser of meeting</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='570'">, other</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='600'">, photographer</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='605'">, presenter</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='650'">, publisher</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='651'">, publishing director</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='673'">, research team head</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='675'">, reviewer</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='710'">, redactor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='723'">, sponsor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='727'">, thesis advisor</xsl:when>
          <xsl:when test="marc:subfield[@code='4']='730'">, translator</xsl:when>
        </xsl:choose>
      </creator>
    </xsl:for-each>
    <type>
      <xsl:value-of select="marc:datafield[@tag=200]/marc:subfield[@code='b']"/>
    </type>
    <xsl:for-each select="marc:datafield[@tag=210]">
      <publisher>
        <xsl:for-each select="marc:subfield[@code='c']">
          <xsl:value-of select="."/>
          <xsl:if test="not(position()=last())">, </xsl:if>
        </xsl:for-each>
        <xsl:if test="marc:subfield[@code='a']">
          <xsl:text> / </xsl:text>
          <xsl:for-each select="marc:subfield[@code='a']">
            <xsl:value-of select="."/>
            <xsl:if test="not(position()=last())">, </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </publisher>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=210]/marc:subfield[@code='d']">
      <date>
        <xsl:value-of select="."/>
      </date>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=101]">
      <xsl:for-each select="marc:subfield[@code='a']">
        <language>
          <xsl:value-of select="."/>
        </language>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q']">
      <format>
        <xsl:value-of select="."/>
      </format>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[300&lt;@tag][@tag&lt;=337]">
      <description>
        <xsl:value-of select="marc:subfield[@code='a']"/>
      </description>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[600&lt;=@tag][@tag&lt;=610]">
      <subject>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">abcdq</xsl:with-param>
        </xsl:call-template>
      </subject>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=461 or @tag=464]">
      <relation>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">t</xsl:with-param>
        </xsl:call-template>
      </relation>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=856]">
      <identifier>
        <xsl:value-of select="marc:subfield[@code='u']"/>
      </identifier>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=010]">
      <identifier>
        <xsl:text>URN:ISBN:</xsl:text>
        <xsl:value-of select="marc:subfield[@code='a']"/>
      </identifier>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=011]">
      <identifier>
        <xsl:text>URN:ISSN:</xsl:text>
        <xsl:value-of select="marc:subfield[@code='a']"/>
      </identifier>
    </xsl:for-each>
    <xsl:for-each select="marc:datafield[@tag=995]">
      <identifier>
        <xsl:text>LOC:</xsl:text>
        <xsl:for-each select="marc:subfield[@code='k']">
          <xsl:text>:</xsl:text>
          <xsl:value-of select="."/>
        </xsl:for-each>
      </identifier>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
