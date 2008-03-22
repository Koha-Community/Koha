<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method="html" indent="yes"/>
    <xsl:key name="item-by-status" match="items:item" use="items:status"/>
    <xsl:key name="item-by-status-and-branch" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>

    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="marc:record">
        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="materialTypeCode">
            <xsl:choose>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">SE</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='p'">MM</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">VM</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">MU</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="materialTypeLabel">
            <xsl:choose>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">Book</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">Serial</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">Book</xsl:when>
                <xsl:when test="$leader6='p'">Mixed Materials</xsl:when>
                <xsl:when test="$leader6='m'">Computer File</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">Map</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">Visual Material</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">Music</xsl:when>
            </xsl:choose>
        </xsl:variable>

<style type="text/css">
    .results_summary {
        font-size: 80%;
        color: grey;
    }
    .select {
        border-bottom: 1px solid #ddd; padding: 6px 5px; vertical-align: top;
    }
    .holdings_summary {
        font-size: 90%;
    }
</style>

    <td class="select">
<input  type="checkbox" id="bib{marc:datafield[@tag=999]/marc:subfield[@code='c']}" name="biblionumber" value="{marc:datafield[@tag=999]/marc:subfield[@code='c']}" title="Click to add to cart" /> <label for="bib{marc:datafield[@tag=999]/marc:subfield[@code='c']}"></label>
    </td>
    <td>
     <a><xsl:attribute name="href">/cgi-bin/koha/opac-detail.pl?biblionumber=<xsl:value-of select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/></xsl:attribute>

        <xsl:if test="marc:datafield[@tag=245]">
        <xsl:for-each select="marc:datafield[@tag=245]">
            <xsl:variable name="title">
                <xsl:choose>
                <xsl:when test="marc:subfield[@code='b']">
                    <xsl:call-template name="specialSubfieldSelect">
                        <xsl:with-param name="axis">b</xsl:with-param>
                        <xsl:with-param name="beforeCodes">afghk</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abfgk</xsl:with-param>
                </xsl:call-template>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="titleChop">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="$title"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$titleChop"/>
            <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> : </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="specialSubfieldSelect">
                            <xsl:with-param name="axis">b</xsl:with-param>
                            <xsl:with-param name="anyCodes">b</xsl:with-param>
                            <xsl:with-param name="afterCodes">afghk</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="part"/>
        </xsl:for-each>.
        </xsl:if>
    </a>
    <p>

    <xsl:choose>
    <xsl:when test="marc:datafield[@tag=100] or marc:datafield[@tag=110] or marc:datafield[@tag=111] or marc:datafield[@tag=700] or marc:datafield[@tag=710] or marc:datafield[@tag=711]">

    by 
        <xsl:for-each select="marc:datafield[@tag=100 or @tag=700]">
            <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:call-template name="nameABCDQ"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="nameABCDQ"/>;
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marc:datafield[@tag=110 or @tag=710]">
            <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:call-template name="nameABCDN"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="nameABCDN"/>;
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marc:datafield[@tag=111 or @tag=711]">
            <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:call-template name="nameACDEQ"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="nameACDEQ"/>;
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </xsl:when>
    </xsl:choose>
    </p>
    <span class="results_summary">
    <xsl:if test="$materialTypeCode">
    <span class="label">Type: </span>
    <img src="/opac-tmpl/prog/famfamfam/{$materialTypeCode}.png"/><xsl:value-of select="$materialTypeLabel"/><br/>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=260]">
    <span class="label">Publisher: </span> 
            <xsl:for-each select="marc:datafield[@tag=260]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bcg</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>

    </xsl:if>
    </span>
               <div class="holdings_summary">
                   <xsl:if test="count(key('item-by-status', 'available'))>0">
                   <span class="available">
                       <xsl:text>Copies available at: </xsl:text>
                       <xsl:variable name="available_items"
                           select="key('item-by-status', 'available')"/>
                       <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch))[1])]">
                           <xsl:value-of select="items:homebranch"/>
                           <xsl:text> (</xsl:text>
                           <xsl:value-of select="count(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch)))"/>
                           <xsl:text>) </xsl:text>
                       </xsl:for-each>
                   </span>
                   </xsl:if>
                   <xsl:if test="count(key('item-by-status', 'On loan'))>0">
                   <span class="unavailable">
                       <xsl:text>On loan (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'On loan'))"/>
                       <xsl:text>)</xsl:text>
                   </span>
                   </xsl:if>
               </div>
    </td>
    </xsl:template>
    <xsl:template name="nameABCDQ">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">aq</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        <xsl:call-template name="termsOfAddress"/>
    </xsl:template>

    <xsl:template name="nameABCDN">
        <xsl:for-each select="marc:subfield[@code='a']">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
                <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">cdn</xsl:with-param>
                </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nameACDEQ">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">acdeq</xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="termsOfAddress">
        <xsl:if test="marc:subfield[@code='b' or @code='c']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bc</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nameDate">
        <xsl:for-each select="marc:subfield[@code='d']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="role">
        <xsl:for-each select="marc:subfield[@code='e']">
                    <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='4']">
                    <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="specialSubfieldSelect">
        <xsl:param name="anyCodes"/>
        <xsl:param name="axis"/>
        <xsl:param name="beforeCodes"/>
        <xsl:param name="afterCodes"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($anyCodes, @code) or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis]) or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
                    <xsl:value-of select="text()"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
    </xsl:template>

    <xsl:template name="subtitle">
        <xsl:if test="marc:subfield[@code='b']">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="marc:subfield[@code='b']"/>

                        <!--<xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">b</xsl:with-param>                                 
                        </xsl:call-template>-->
                    </xsl:with-param>
                </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="part">
        <xsl:variable name="partNumber">
            <xsl:call-template name="specialSubfieldSelect">
                <xsl:with-param name="axis">n</xsl:with-param>
                <xsl:with-param name="anyCodes">n</xsl:with-param>
                <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="partName">
            <xsl:call-template name="specialSubfieldSelect">
                <xsl:with-param name="axis">p</xsl:with-param>
                <xsl:with-param name="anyCodes">p</xsl:with-param>
                <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($partNumber))">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partNumber"/>
                </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($partName))">
        <xsl:if test="string-length(normalize-space($partName))">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partName"/>
                </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
