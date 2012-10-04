<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:marc="http://www.loc.gov/MARC21/slim" 
  version="1.0">
  <xsl:output method="html" doctype-public="-//W3C/DTD html 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" encoding="UTF-8"/>
      <xsl:template match="/">
        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html" charset="utf-8"/>
            <link href="/koha-tmpl/opac-tmpl/prog/en/css/xsl.css" rel="stylesheet" type="text/css" />
          </head>
          <body>
           <xsl:apply-templates/>
          </body>
        </html>
      </xsl:template>
      
      <xsl:template match="marc:record">
        <div class="cardimage">
        <xsl:apply-templates select="marc:datafield[@tag!='680' and @tag!='676' and @tag!='010']"/>
        <span class="bottom">
          <xsl:apply-templates select="marc:controlfield[@tag='001']"/>
          <xsl:apply-templates select="marc:datafield[@tag='680' or @tag='676' or @tag='010']"/>
        </span>
        </div>
      </xsl:template>
      
      <xsl:template match="marc:controlfield">
          <span class="oclc">#<xsl:value-of select="substring(.,4)"/></span>
      </xsl:template>
      
      <xsl:template match="marc:datafield">
        <xsl:if test="starts-with(@tag, '7')">
          <p class="mainheading"><xsl:value-of select="."/></p>
        </xsl:if>
        <xsl:if test="@tag='200'">
          <span class="title"><xsl:value-of select="."/></span>
        </xsl:if>
        <xsl:if test="@tag='200'">
          <span class="titlemain"><xsl:value-of select="."/></span><br/>
        </xsl:if>
        <xsl:if test="@tag='205'">
          <xsl:value-of select="."/>
        </xsl:if>
        <xsl:if test="@tag='215'">
          <p class="extent"><xsl:value-of select="."/></p>
        </xsl:if>
        <xsl:if test="starts-with(@tag, '3')">
          <p class="note"><xsl:value-of select="."/></p>
        </xsl:if>
        <xsl:if test="@tag='606'">
          <span class='counter'><xsl:number count="marc:datafield[@tag='606']"/>.</span> <xsl:apply-templates select="marc:subfield"/>
        </xsl:if>
        <xsl:if test="@tag='610'">
          <span class="counter"><xsl:number format="i" count="marc:datafield[@tag='610']"/>.</span> <xsl:apply-templates select="marc:subfield"/>
        </xsl:if>
        <xsl:if test="@tag='680'">
          <xsl:variable name="LCCN.nospace" select="translate(marc:subfield[@code='a'], ' ', '')"/>
          <xsl:variable name="LCCN.length" select="string-length($LCCN.nospace)"/>
          <xsl:variable name="LCCN.display" select="concat(substring($LCCN.nospace, 1, $LCCN.length - 6), '-', format-number(substring($LCCN.nospace, $LCCN.length - 5),'#'))"/>
          <span class="LCCN">LCCN:<xsl:value-of select="$LCCN.display"/></span>
        </xsl:if>
        <xsl:if test="@tag='676'">
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
