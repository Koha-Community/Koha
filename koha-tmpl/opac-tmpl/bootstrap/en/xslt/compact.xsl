<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  exclude-result-prefixes="xsi marc"
  version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//W3C//DTD Xhtml 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
      <xsl:template match="/">
        <html>
          <head>
	    <title>MARC Card View</title>
          </head>
          <body>
           <xsl:apply-templates/>
          </body>
        </html>
      </xsl:template>

      <xsl:template match="marc:record">
        <div class="cardimage">
        <xsl:apply-templates select="marc:datafield[@tag!='082' and @tag!='092' and @tag!='010']"/>
        <span class="bottom">
          <xsl:apply-templates select="marc:controlfield[@tag='001']"/>
          <xsl:apply-templates select="marc:datafield[@tag='082' or @tag='092' or @tag='010']"/>
        </span>
        </div>
      </xsl:template>

      <xsl:template match="marc:controlfield">
          <span class="oclc">#<xsl:value-of select="substring(.,4)"/></span>
      </xsl:template>

      <xsl:template match="marc:datafield">
        <xsl:if test="starts-with(@tag, '1')">
          <p class="mainheading"><xsl:value-of select="."/></p>
        </xsl:if>
        <xsl:if test="starts-with(@tag, '24') and /marc:record/marc:datafield[@tag='100']">
          <span class="title"><xsl:value-of select="."/></span>
        </xsl:if>
        <xsl:if test="starts-with(@tag, '24') and not(/marc:record/marc:datafield[@tag='100'])">
          <span class="titlemain"><xsl:value-of select="."/></span><br/>
        </xsl:if>
        <xsl:if test="@tag='260'">
          <xsl:value-of select="."/>
        </xsl:if>
        <xsl:if test="@tag='300'">
          <p class="extent"><xsl:value-of select="."/></p>
        </xsl:if>
        <xsl:if test="starts-with(@tag, '5')">
          <p class="note"><xsl:value-of select="."/></p>
        </xsl:if>
        <xsl:if test="@tag='650'">
          <span class='counter'><xsl:number count="marc:datafield[@tag='650']"/>.</span> <xsl:apply-templates select="marc:subfield"/>
        </xsl:if>
        <xsl:if test="@tag='653'">
          <span class="counter"><xsl:number format="i" count="marc:datafield[@tag='653']"/>.</span> <xsl:apply-templates select="marc:subfield"/>
        </xsl:if>
        <xsl:if test="@tag='010'">
          <xsl:variable name="LCCN.nospace" select="translate(., ' ', '')"/>
          <xsl:variable name="LCCN.length" select="string-length($LCCN.nospace)"/>
          <xsl:variable name="LCCN.display" select="concat(substring($LCCN.nospace, 1, $LCCN.length - 6), '-', format-number(substring($LCCN.nospace, $LCCN.length - 5),'#'))"/>
          <span class="LCCN">LCCN:<xsl:value-of select="$LCCN.display"/></span>
        </xsl:if>
        <xsl:if test="@tag='082' or @tag='092'">
          <span class="DDC"><xsl:value-of select="marc:subfield[@code='a']"/></span>
        </xsl:if>
        <xsl:if test="@tag='856'">
          <br/><xsl:apply-templates mode="link" select="marc:subfield" />
        </xsl:if>
      </xsl:template>
      <xsl:template match="marc:subfield" mode="link">
        <xsl:if test="@code='u'">
          <span class="link">
            <a class="url" href="{.}"/>
        </span>
        </xsl:if>
      </xsl:template>
      <xsl:template match="marc:subfield">
        <xsl:if test="@code!='2'">
        <xsl:if test="@code!='a'">--</xsl:if>
        <xsl:value-of select="."/>
      </xsl:if>
      </xsl:template>
    </xsl:stylesheet>
