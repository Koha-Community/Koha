<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE stylesheet>

<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<!-- Edited: Bug 1807 [ENH] XSLT enhancements sponsored by bywater solutions 2015/01/19 WS wsalesky@gmail.com  -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="marc str">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method = "html" indent="yes" omit-xml-declaration = "yes" encoding="UTF-8"/>
    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="marc:record">

        <!-- Option: Display Alternate Graphic Representation (MARC 880)  -->
        <xsl:variable name="display880" select="boolean(marc:datafield[@tag=880])"/>
        <xsl:variable name="UseControlNumber" select="marc:sysprefs/marc:syspref[@name='UseControlNumber']"/>
        <xsl:variable name="URLLinkText" select="marc:sysprefs/marc:syspref[@name='URLLinkText']"/>
        <xsl:variable name="OPACBaseURL" select="marc:sysprefs/marc:syspref[@name='OPACBaseURL']"/>
        <xsl:variable name="SubjectModifier"><xsl:if test="marc:sysprefs/marc:syspref[@name='TraceCompleteSubfields']='1'">,complete-subfield</xsl:if></xsl:variable>
        <xsl:variable name="UseAuthoritiesForTracings" select="marc:sysprefs/marc:syspref[@name='UseAuthoritiesForTracings']"/>
        <xsl:variable name="TraceSubjectSubdivisions" select="marc:sysprefs/marc:syspref[@name='TraceSubjectSubdivisions']"/>
        <xsl:variable name="Show856uAsImage" select="marc:sysprefs/marc:syspref[@name='Display856uAsImage']"/>
        <xsl:variable name="DisplayIconsXSLT" select="marc:sysprefs/marc:syspref[@name='DisplayIconsXSLT']"/>
        <xsl:variable name="OpacSuppression" select="marc:sysprefs/marc:syspref[@name='OpacSuppression']"/>
        <xsl:variable name="TracingQuotesLeft">
           <xsl:choose>
             <xsl:when test="marc:sysprefs/marc:syspref[@name='UseICUStyleQuotes']='1'">{</xsl:when>
             <xsl:otherwise>"</xsl:otherwise>
           </xsl:choose>
        </xsl:variable>
        <xsl:variable name="TracingQuotesRight">
          <xsl:choose>
            <xsl:when test="marc:sysprefs/marc:syspref[@name='UseICUStyleQuotes']='1'">}</xsl:when>
            <xsl:otherwise>"</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="leader19" select="substring($leader,20,1)"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="materialTypeCode">
            <xsl:choose>
                <xsl:when test="$leader19='a'">ST</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='i' or $leader7='s'">SE</xsl:when>
                        <xsl:when test="$leader7='a' or $leader7='b'">AR</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='o' or $leader6='p'">MX</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g'">VM</xsl:when>
                <xsl:when test="$leader6='k'">PK</xsl:when>
                <xsl:when test="$leader6='r'">OB</xsl:when>
                <xsl:when test="$leader6='i'">MU</xsl:when>
                <xsl:when test="$leader6='j'">MU</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">PR</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="materialTypeLabel">
            <xsl:choose>
                <xsl:when test="$leader19='a'">Set</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='c' or $leader7='d' or $leader7='m'">Text</xsl:when>
                        <xsl:when test="$leader7='i' or $leader7='s'">
                            <xsl:choose>
                                <xsl:when test="substring($controlField008,22,1)!='m'">Continuing resource</xsl:when>
                                <xsl:otherwise>Series</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$leader7='a' or $leader7='b'">Article</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">Text</xsl:when>
                <xsl:when test="$leader6='o'">Kit</xsl:when>
                <xsl:when test="$leader6='p'">Mixed materials</xsl:when>
                <xsl:when test="$leader6='m'">Computer file</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">Map</xsl:when>
                <xsl:when test="$leader6='g'">Film</xsl:when>
                <xsl:when test="$leader6='k'">Picture</xsl:when>
                <xsl:when test="$leader6='r'">Object</xsl:when>
                <xsl:when test="$leader6='j'">Music</xsl:when>
                <xsl:when test="$leader6='i'">Sound</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">Score</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Title Statement -->
        <!-- Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <h1 class="title">
                <xsl:call-template name="m880Select">
                    <xsl:with-param name="basetags">245</xsl:with-param>
                    <xsl:with-param name="codes">abhfgknps</xsl:with-param>
                </xsl:call-template>
            </h1>
        </xsl:if>

        <!--Bug 13381 -->
        <xsl:if test="marc:datafield[@tag=245]">
            <h1 class="title" property="name">
                <xsl:for-each select="marc:datafield[@tag=245]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <!-- 13381 add additional subfields-->
                    <!-- bz 17625 adding subfields f and g -->
                    <xsl:for-each select="marc:subfield[contains('bcfghknps', @code)]">
                        <xsl:choose>
                            <xsl:when test="@code='h'">
                                <!--  13381 Span class around subfield h so it can be suppressed via css -->
                                <span class="title_medium"><xsl:apply-templates/> <xsl:text> </xsl:text> </span>
                            </xsl:when>
                            <xsl:when test="@code='c'">
                                <!--  13381 Span class around subfield c so it can be suppressed via css -->
                                <span class="title_resp_stmt"><xsl:apply-templates/> <xsl:text> </xsl:text> </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates/>
                                <xsl:text> </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </h1>
        </xsl:if>

        <!-- Author Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <h5 class="author">
                <xsl:call-template name="m880Select">
                    <xsl:with-param name="basetags">100,110,111,700,710,711</xsl:with-param>
                    <xsl:with-param name="codes">abc</xsl:with-param>
                    <xsl:with-param name="index">au</xsl:with-param>
                    <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
                    <!-- do not use label 'by ' here, it would be repeated for every occurrence of 100,110,111,700,710,711 -->
                </xsl:call-template>
            </h5>
        </xsl:if>

        <!-- Author Statement -->
        <xsl:call-template name="showAuthor">
            <xsl:with-param name="authorfield" select="marc:datafield[@tag=100 or @tag=110 or @tag=111]"/>
            <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
        </xsl:call-template>

        <!-- #13382 Suppress 700$i and 7xx/@ind2=2 -->
        <xsl:call-template name="showAuthor">
            <xsl:with-param name="authorfield" select="marc:datafield[(@tag=700 or @tag=710 or @tag=711) and not(@ind2=2) and not(marc:subfield[@code='i'])]"/>
            <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
        </xsl:call-template>

    <xsl:if test="$DisplayIconsXSLT!='0' and $materialTypeCode!=''">
        <span class="results_summary type"><span class="label">Material type: </span>
    <xsl:element name="img"><xsl:attribute name="class">materialtype mt_icon_<xsl:value-of select="$materialTypeCode"/></xsl:attribute><xsl:attribute name="src">/intranet-tmpl/prog/img/famfamfam/<xsl:value-of select="$materialTypeCode"/>.png</xsl:attribute><xsl:attribute name="alt"></xsl:attribute></xsl:element>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$materialTypeLabel"/>
        </span>
    </xsl:if>

    <xsl:call-template name="show-lang-041"/>

        <!--Series: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">440,490</xsl:with-param>
                <xsl:with-param name="codes">av</xsl:with-param>
                <xsl:with-param name="class">results_summary series</xsl:with-param>
                <xsl:with-param name="label">Series: </xsl:with-param>
                <xsl:with-param name="index">se</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    <xsl:call-template name="show-series">
        <xsl:with-param name="searchurl">/cgi-bin/koha/catalogue/search.pl</xsl:with-param>
        <xsl:with-param name="UseControlNumber" select="$UseControlNumber"/>
        <xsl:with-param name="UseAuthoritiesForTracings" select="$UseAuthoritiesForTracings"/>
    </xsl:call-template>

        <!-- Analytics information -->
        <xsl:variable name="leader7_class">
            <xsl:choose>
                <!--xsl:when test="$leader7='a'">analytic_mcp</xsl:when-->
                <!--xsl:when test="$leader7='b'">analytic_scp</xsl:when-->
                <xsl:when test="$leader7='c'">analytic_collection</xsl:when>
                <xsl:when test="$leader7='d'">analytic_subunit</xsl:when>
                <xsl:when test="$leader7='i'">analytic_ires</xsl:when>
                <xsl:when test="$leader7='m'">analytic_monograph</xsl:when>
                <xsl:when test="$leader7='s'">analytic_serial</xsl:when>
                <xsl:otherwise>analytic_undefined</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="show_analytics_link" select="marc:variables/marc:variable[@name='show_analytics_link']" />
        <xsl:if test="$show_analytics_link='1'">
            <xsl:element name="span">
                <xsl:attribute name="class">results_summary analytics <xsl:value-of select="$leader7_class"/></xsl:attribute>
                <span class="label">Analytics: </span>
                <a>
                <xsl:choose>
                    <xsl:when test="$UseControlNumber = '1' and marc:controlfield[@tag=001]">
                        <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=rcn:<xsl:value-of select="str:encode-uri(marc:controlfield[@tag=001], true())"/>+AND+(bib-level:a+OR+bib-level:b)</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="title_query">
                            <xsl:text>Host-item:(</xsl:text>
                            <xsl:call-template name="quote_search_term">
                                <xsl:with-param name="term"><xsl:value-of select="marc:datafield[@tag=245]/marc:subfield[@code='a']"/></xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>)</xsl:text>
                        </xsl:variable>
                        <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:value-of select="str:encode-uri($title_query, true())"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>Show analytics</xsl:text>
                </a>
            </xsl:element>
        </xsl:if>

        <!-- Volumes of sets and traced series -->
        <xsl:if test="$materialTypeCode='ST' or substring($controlField008,22,1)='m'">
        <span class="results_summary volumes"><span class="label">Volumes: </span>
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:controlfield[@tag=001]">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=rcn:<xsl:value-of select="str:encode-uri(marc:controlfield[@tag=001], true())"/>+NOT+(bib-level:a+OR+bib-level:b)</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate(marc:datafield[@tag=245]/marc:subfield[@code='a'], '/', ''), true())"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:text>Show volumes</xsl:text>
            </a>
        </span>
        </xsl:if>

        <!-- Set -->
        <xsl:if test="$leader19='c'">
        <span class="results_summary set"><span class="label">Set: </span>
        <xsl:for-each select="marc:datafield[@tag=773]">
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate(//marc:datafield[@tag=245]/marc:subfield[@code='a'], '.', ''), true())"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="translate(//marc:datafield[@tag=245]/marc:subfield[@code='a'], '.', '')" />
            </a>
            <xsl:choose>
                <xsl:when test="position()=last()"></xsl:when>
                <xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </span>
        </xsl:if>

        <!-- Publisher Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">260,264</xsl:with-param>
                <xsl:with-param name="codes">abcg</xsl:with-param>
                <xsl:with-param name="class">results_summary publisher</xsl:with-param>
                <xsl:with-param name="label">Publication details: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!-- Publisher info and RDA related info from tags 260, 264 -->
        <xsl:choose>
            <xsl:when test="marc:datafield[@tag=264]">
                <xsl:call-template name="showRDAtag264">
                   <xsl:with-param name="show_url">1</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="marc:datafield[@tag=260]">
                <span class="results_summary publisher"><span class="label">Publication details: </span>
                    <xsl:for-each select="marc:datafield[@tag=260]">
                        <xsl:for-each select="marc:subfield">
                            <xsl:if test="@code='a'">
                                <a>
                                    <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=pl:"<xsl:value-of select="str:encode-uri(current(), true())"/>"</xsl:attribute>
                                    <xsl:value-of select="current()"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="@code='b'">
                                <a>
                                    <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Provider:"<xsl:value-of select="str:encode-uri(current(), true())"/>"</xsl:attribute>
                                    <xsl:value-of select="current()"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="@code='c'">
                                <a>
                                    <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=copydate:"<xsl:value-of select="str:encode-uri(current(), true())"/>"</xsl:attribute>
                                    <xsl:value-of select="current()"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="@code='g'">
                                <xsl:call-template name="chopPunctuation">
                                   <xsl:with-param name="chopString">
                                      <xsl:value-of select="current()"/>
                                   </xsl:with-param>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="position() != last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:when>
        </xsl:choose>

        <!-- Edition Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">250</xsl:with-param>
                <xsl:with-param name="codes">ab</xsl:with-param>
                <xsl:with-param name="class">results_summary edition</xsl:with-param>
                <xsl:with-param name="label">Edition: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="marc:datafield[@tag=250]">
        <span class="results_summary edition"><span class="label">Edition: </span>
            <xsl:for-each select="marc:datafield[@tag=250]">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
                   </xsl:with-param>
               </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </span>
        </xsl:if>

        <!-- Description: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">300</xsl:with-param>
                <xsl:with-param name="codes">abceg</xsl:with-param>
                <xsl:with-param name="class">results_summary description</xsl:with-param>
                <xsl:with-param name="label">Description: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="marc:datafield[@tag=300]">
        <span class="results_summary description"><span class="label">Description: </span>
            <xsl:for-each select="marc:datafield[@tag=300]">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcefg</xsl:with-param>
                    </xsl:call-template>
                   </xsl:with-param>
               </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </span>
       </xsl:if>

        <!-- Content Type -->
        <xsl:if test="marc:datafield[@tag=336] or marc:datafield[@tag=337] or marc:datafield[@tag=338]">
            <span class="results_summary" id="content_type">
                <xsl:if test="marc:datafield[@tag=336]">
                    <span class="label">Content type: </span>
                    <xsl:for-each select="marc:datafield[@tag=336]">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">a</xsl:with-param>
                            <xsl:with-param name="delimeter">, </xsl:with-param>
                        </xsl:call-template>
                        <xsl:if test="position() != last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                    </xsl:for-each>
                </xsl:if>
                <xsl:text> </xsl:text>
                <!-- Media Type -->
                <xsl:if test="marc:datafield[@tag=337]">
                    <span class="label">Media type: </span>
                    <xsl:for-each select="marc:datafield[@tag=337]">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">a</xsl:with-param>
                            <xsl:with-param name="delimeter">, </xsl:with-param>
                        </xsl:call-template>
                        <xsl:if test="position() != last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                    </xsl:for-each>
                </xsl:if>
                <xsl:text> </xsl:text>
                <!-- Media Type -->
                <xsl:if test="marc:datafield[@tag=338]">
                    <span class="label">Carrier type: </span>
                    <xsl:for-each select="marc:datafield[@tag=338]">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">a</xsl:with-param>
                            <xsl:with-param name="delimeter">, </xsl:with-param>
                        </xsl:call-template>
                        <xsl:if test="position() != last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </span>
        </xsl:if>

        <!-- 385 - Audience -->
        <xsl:if test="marc:datafield[@tag=385]">
            <span class="results_summary audience">
                <span class="label">Audience: </span>
                <xsl:for-each select="marc:datafield[@tag=385]">
                    <xsl:if test="marc:subfield[@code='m']">
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">m</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>: </xsl:text>
                    </xsl:if>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a</xsl:with-param>
                                    <xsl:with-param name="delimeter">, </xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text> | </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <xsl:call-template name="showISBNISSN"/>

        <xsl:if test="marc:datafield[@tag=013]">
            <span class="results_summary patent_info">
                <span class="label">Patent information: </span>
                <xsl:for-each select="marc:datafield[@tag=013]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">acdef</xsl:with-param>
                        <xsl:with-param name="delimeter">, </xsl:with-param>
                    </xsl:call-template>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=088]">
            <span class="results_summary report_number">
                <span class="label">Report number: </span>
                <xsl:for-each select="marc:datafield[@tag=088]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a</xsl:with-param>
                    </xsl:call-template>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- Other Title  Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">246</xsl:with-param>
                <xsl:with-param name="codes">abhfgnp</xsl:with-param>
                <xsl:with-param name="class">results_summary other_title</xsl:with-param>
                <xsl:with-param name="label">Other title: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=246]">
            <span class="results_summary other_title"><span class="label">Other title: </span>
                <xsl:for-each select="marc:datafield[@tag=246]">
                    <xsl:if test="marc:subfield[@code='i']">
                            <xsl:call-template name="subfieldSelect">
				    <xsl:with-param name="codes">i</xsl:with-param>
			    </xsl:call-template>
                    </xsl:if>
                       <xsl:text> </xsl:text>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">abhfgnp</xsl:with-param>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="@ind1=1 and not(marc:subfield[@code='i'])">
                        <xsl:choose>
                            <xsl:when test="@ind2=0"> [Portion of title]</xsl:when>
                            <xsl:when test="@ind2=1"> [Parallel title]</xsl:when>
                            <xsl:when test="@ind2=2"> [Distinctive title]</xsl:when>
                            <xsl:when test="@ind2=3"> [Other title]</xsl:when>
                            <xsl:when test="@ind2=4"> [Cover title]</xsl:when>
                            <xsl:when test="@ind2=5"> [Added title page title]</xsl:when>
                            <xsl:when test="@ind2=6"> [Caption title]</xsl:when>
                            <xsl:when test="@ind2=7"> [Running title]</xsl:when>
                            <xsl:when test="@ind2=8"> [Spine title]</xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <!-- #13386 added separator | -->
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise></xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=242]">
        <span class="results_summary translated_title"><span class="label">Title translated: </span>
            <xsl:for-each select="marc:datafield[@tag=242]">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abchnp</xsl:with-param>
                    </xsl:call-template>
                   </xsl:with-param>
               </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </span>
       </xsl:if>

        <!-- Uniform Title  Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
            <xsl:call-template name="m880Select">
                <xsl:with-param name="basetags">130,240</xsl:with-param>
                <xsl:with-param name="codes">adfklmor</xsl:with-param>
                <xsl:with-param name="class">results_summary uniform_title</xsl:with-param>
                <xsl:with-param name="label">Uniform title: </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="marc:datafield[@tag=130]|marc:datafield[@tag=240]|marc:datafield[@tag=730][@ind2!=2]">
            <span class="results_summary uniform_title"><span class="label">Uniform titles: </span>
                <xsl:for-each select="marc:datafield[@tag=130]|marc:datafield[@tag=240]|marc:datafield[@tag=730][@ind2!=2]">
                    <xsl:if test="marc:subfield[@code='i']">
			    <xsl:call-template name="subfieldSelect">
				    <xsl:with-param name="codes">i</xsl:with-param>
			    </xsl:call-template>
		    </xsl:if>
		    <xsl:text> </xsl:text>
                    <xsl:for-each select="marc:subfield">
                        <xsl:if test="contains('adfghklmnoprst',@code)">
                            <xsl:value-of select="text()"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="position() != last()">
                        <span class="separator"><xsl:text> | </xsl:text></span>
                    </xsl:if>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- #13382 Added Related works 700$i -->
        <xsl:if test="marc:datafield[@tag=700][marc:subfield[@code='i']] or marc:datafield[@tag=710][marc:subfield[@code='i']] or marc:datafield[@tag=711][marc:subfield[@code='i']]">
            <span class="results_summary related_works"><span class="label">Related works: </span>
                <xsl:for-each select="marc:datafield[@tag=700][marc:subfield[@code='i']] | marc:datafield[@tag=710][marc:subfield[@code='i']] | marc:datafield[@tag=711][marc:subfield[@code='i']]">
                    <xsl:variable name="str">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">abcdfghiklmnporstux</xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="$str"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <!-- add relator code too between brackets-->
                    <xsl:if test="marc:subfield[@code='4' or @code='e']">
                        <span class="relatorcode">
                            <xsl:text> [</xsl:text>
                            <xsl:choose>
                                <xsl:when test="marc:subfield[@code='e']">
                                    <xsl:for-each select="marc:subfield[@code='e']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="marc:subfield[@code='4']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>]</xsl:text>
                        </span>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- #13382 Added Contained Works 7xx@ind2=2 -->
        <xsl:if test="marc:datafield[@tag=700][@ind2=2 and not(marc:subfield[@code='i'])] or marc:datafield[@tag=710][@ind2=2 and not(marc:subfield[@code='i'])] or marc:datafield[@tag=711][@ind2=2 and not(marc:subfield[@code='i'])]">
            <span class="results_summary contained_works"><span class="label">Contained works: </span>
                <xsl:for-each select="marc:datafield[@tag=700][@ind2=2][not(marc:subfield[@code='i'])] | marc:datafield[@tag=710][@ind2=2][not(marc:subfield[@code='i'])] | marc:datafield[@tag=711][@ind2=2][not(marc:subfield[@code='i'])]">
                    <xsl:variable name="str">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">abcdfghiklmnporstux</xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="$str"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <!-- add relator code too between brackets-->
                    <xsl:if test="marc:subfield[@code='4' or @code='e']">
                        <span class="relatorcode">
                            <xsl:text> [</xsl:text>
                            <xsl:choose>
                                <xsl:when test="marc:subfield[@code='e']">
                                    <xsl:for-each select="marc:subfield[@code='e']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="marc:subfield[@code='4']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>]</xsl:text>
                        </span>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>


        <xsl:if test="marc:datafield[substring(@tag, 1, 1) = '6' and not(@tag=655)]">
            <span class="results_summary subjects"><span class="label">Subject(s): </span>
            <xsl:for-each select="marc:datafield[substring(@tag, 1, 1) = '6'][not(@tag=655)]">
            <a>
            <xsl:choose>
            <!-- #1807 Strip unwanted parenthesis from subjects for searching -->
            <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="$TraceSubjectSubdivisions='1'">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:call-template name="subfieldSelectSubject">
                        <xsl:with-param name="codes">abcdfgklmnopqrstvxyz</xsl:with-param>
                        <xsl:with-param name="delimeter"> AND </xsl:with-param>
                        <xsl:with-param name="prefix">(su<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/></xsl:with-param>
                        <xsl:with-param name="suffix"><xsl:value-of select="$TracingQuotesRight"/>)</xsl:with-param>
                        <xsl:with-param name="urlencode">1</xsl:with-param>
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:when>

            <!-- #1807 Strip unwanted parenthesis from subjects for searching -->
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=su<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/><xsl:value-of select="str:encode-uri(translate(marc:subfield[@code='a'],'()',''), true())"/><xsl:value-of select="$TracingQuotesRight"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdfgklmnopqrstvxyz</xsl:with-param>
                        <xsl:with-param name="subdivCodes">vxyz</xsl:with-param>
                        <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
            </a>

            <xsl:if test="marc:subfield[@code=9]">
                <xsl:call-template name="showAuthlink">
                    <xsl:with-param name="authid"><xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:with-param>
                </xsl:call-template>
            </xsl:if>

            <xsl:choose>
            <xsl:when test="position()=last()"></xsl:when>
            <xsl:otherwise> | </xsl:otherwise>
            </xsl:choose>

            </xsl:for-each>
            </span>
        </xsl:if>

        <!-- Genre/Form -->
        <xsl:if test="marc:datafield[@tag=655]">
            <span class="results_summary genre"><span class="label">Genre/Form: </span>
                <xsl:for-each select="marc:datafield[@tag=655]">
                    <a>
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$TraceSubjectSubdivisions='1'">
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">avxyz</xsl:with-param>
                                    <xsl:with-param name="delimeter"> AND </xsl:with-param>
                                    <xsl:with-param name="prefix">(index-term-genre<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/></xsl:with-param>
                                    <xsl:with-param name="suffix"><xsl:value-of select="$TracingQuotesRight"/>)</xsl:with-param>
                                    <xsl:with-param name="urlencode">1</xsl:with-param>
                                </xsl:call-template>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=index-term-genre<xsl:value-of select="$SubjectModifier"/>:<xsl:value-of select="$TracingQuotesLeft"/><xsl:value-of select="marc:subfield[@code='a']"/><xsl:value-of select="$TracingQuotesRight"/></xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">avxyz</xsl:with-param>
                        <xsl:with-param name="subdivCodes">vxyz</xsl:with-param>
                        <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
                    </xsl:call-template>
                    </a>


                    <xsl:if test="marc:subfield[@code=9]">
                        <xsl:call-template name="showAuthlink">
                            <xsl:with-param name="authid"><xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position()!=last()"><span class="separator"> | </span></xsl:if>
                </xsl:for-each>
            </span>
        </xsl:if>

<!-- MARC21 776 Additional Physical Form Entry -->
    <xsl:if test="marc:datafield[@tag=776]">
        <span class="results_summary add_physical_form">
            <span class="label">Additional physical formats: </span>
            <xsl:for-each select="marc:datafield[@tag=776]">
                <xsl:variable name="linktext">
                    <xsl:choose>
                    <xsl:when test="marc:subfield[@code='t']">
                        <xsl:value-of select="marc:subfield[@code='t']"/>
                    </xsl:when>
                    <xsl:when test="marc:subfield[@code='a']">
                        <xsl:value-of select="marc:subfield[@code='a']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>No title</xsl:text>
                    </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="@ind2=8 and marc:subfield[@code='i']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">i</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:choose>
                <xsl:when test="marc:subfield[@code='w']">
                    <a>
                    <xsl:attribute name="href">
                        <xsl:text>/cgi-bin/koha/catalogue/search.pl?q=control-number:</xsl:text>
                        <xsl:call-template name="extractControlNumber">
                            <xsl:with-param name="subfieldW">
                                <xsl:value-of select="marc:subfield[@code='w']"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="$linktext"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$linktext"/>
                </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="position() != last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:if>

<!-- MARC21 777 - Issued With Entry -->
    <xsl:if test="marc:datafield[@tag=777]">
        <xsl:for-each select="marc:datafield[@tag=777]">
            <xsl:if test="@ind1 != 1">
                <span class="results_summary issued_with">
                    <span class="label">
                        <xsl:choose>
                            <xsl:when test="@ind2=8 and marc:subfield[@code='i']">
                                <xsl:value-of select="marc:subfield[@code='i']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Issued with:</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                    </span>
                    <xsl:variable name="f777">
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                            <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                            <xsl:value-of select="translate($f777, '()', '')"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(marc:subfield[@code='t'], true())"/></xsl:attribute>
                            <xsl:value-of select="$f777"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="marc:subfield[@code='g']">
                        <xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='g']"/>
                    </xsl:if>
                </span>
                <xsl:if test="marc:subfield[@code='n']">
                    <xsl:text> </xsl:text><span class="results_summary in_note"><xsl:value-of select="marc:subfield[@code='n']"/></span>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:if>

<!-- Publisher or Distributor Number -->
    <xsl:if test="marc:datafield[@tag=028]">
        <span class="results_summary publisher_number ">
            <span class="label">Publisher number: </span>
            <xsl:for-each select="marc:datafield[@tag=028]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abq</xsl:with-param>
                    <xsl:with-param name="delimeter"><xsl:text> | </xsl:text></xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </span>
    </xsl:if>

<!-- DDC classification -->
    <xsl:if test="marc:datafield[@tag=082]">
        <span class="results_summary ddc">
            <span class="label">DDC classification: </span>
            <xsl:for-each select="marc:datafield[@tag=082]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                    <xsl:with-param name="delimeter"><xsl:text> | </xsl:text></xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="position()=last()"><xsl:text>  </xsl:text></xsl:when>
                    <xsl:otherwise> | </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </span>
    </xsl:if>

<!-- LOC classification -->
    <xsl:if test="marc:datafield[@tag=050]">
        <span class="results_summary loc">
            <span class="label">LOC classification: </span>
            <xsl:for-each select="marc:datafield[@tag=050]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">ab</xsl:with-param>
                    <xsl:with-param name="delimeter"><xsl:text> | </xsl:text></xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </span>
    </xsl:if>

<!-- NLM classification -->
    <xsl:if test="marc:datafield[@tag=060]">
        <span class="results_summary nlm">
            <span class="label">NLM classification: </span>
            <xsl:for-each select="marc:datafield[@tag=060]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                    <xsl:with-param name="delimeter"><xsl:text> | </xsl:text></xsl:with-param>
                </xsl:call-template>
                <xsl:if test="not(position()=last())"><xsl:text> | </xsl:text></xsl:if>
            </xsl:for-each>
        </span>
    </xsl:if>

<!-- Other classification -->
    <xsl:if test="marc:datafield[@tag=084]">
       <span class="results_summary oc">
           <span class="label">Other classification: </span>
          <xsl:for-each select="marc:datafield[@tag=084]">
                <xsl:call-template name="subfieldSelect">
                   <xsl:with-param name="codes">a</xsl:with-param>
                   <xsl:with-param name="delimeter"><xsl:text> | </xsl:text></xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                   <xsl:when test="position()=last()"><xsl:text>  </xsl:text></xsl:when>
                   <xsl:otherwise> | </xsl:otherwise>
                </xsl:choose>
          </xsl:for-each>
       </span>
    </xsl:if>

    <xsl:if test="marc:datafield[@tag=856]">
        <span class="results_summary online_resources"><span class="label">Online resources: </span>
        <xsl:for-each select="marc:datafield[@tag=856]">
            <xsl:variable name="SubqText"><xsl:value-of select="marc:subfield[@code='q']"/></xsl:variable>
            <a>
                <xsl:attribute name="href">
                    <xsl:call-template name="AddMissingProtocol">
                        <xsl:with-param name="resourceLocation" select="marc:subfield[@code='u']"/>
                        <xsl:with-param name="indicator1" select="@ind1"/>
                        <xsl:with-param name="accessMethod" select="marc:subfield[@code='2']"/>
                    </xsl:call-template>
                    <xsl:value-of select="marc:subfield[@code='u']"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="($Show856uAsImage='Details' or $Show856uAsImage='Both') and (substring($SubqText,1,6)='image/' or $SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
                        <xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="marc:subfield[@code='y']"/></xsl:attribute><xsl:attribute name="height">100</xsl:attribute></xsl:element><xsl:text></xsl:text>
                    </xsl:when>
                    <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">y3z</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
                        <xsl:choose>
                            <xsl:when test="$URLLinkText!=''">
                                <xsl:value-of select="$URLLinkText"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Click here to access online</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </a>
            <xsl:choose>
                <xsl:when test="position()=last()"><xsl:text>  </xsl:text></xsl:when>
                <xsl:otherwise> | </xsl:otherwise>
            </xsl:choose>

        </xsl:for-each>
        </span>
    </xsl:if>

        <!-- 505 - Formatted contents note -->
        <xsl:if test="marc:datafield[@tag=505]">
            <div class="results_summary contents">
            <xsl:choose>
                <xsl:when test="marc:datafield[@tag=505]/@ind1=0">
                    <span class="label">Contents:</span>
                </xsl:when>
                <xsl:when test="marc:datafield[@tag=505]/@ind1=1">
                    <span class="label">Incomplete contents:</span>
                </xsl:when>
                <xsl:when test="marc:datafield[@tag=505]/@ind1=2">
                    <span class="label">Partial contents:</span>
                </xsl:when>
            </xsl:choose>
                <xsl:for-each select="marc:datafield[@tag=505]">
                    <div class='contentblock'>
                        <xsl:choose>
                        <xsl:when test="@ind2=0">
                            <xsl:call-template name="subfieldSelectSpan">
                                <xsl:with-param name="newline">1</xsl:with-param>
                                <xsl:with-param name="codes">trug</xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="subfieldSelectSpan">
                                <xsl:with-param name="newline">1</xsl:with-param>
                                <xsl:with-param name="codes">atrug</xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>

        <!-- 586 -->
        <xsl:if test="marc:datafield[@tag=586]">
            <span class="results_summary awardsnote">
                <xsl:if test="marc:datafield[@tag=586]/@ind1=' '">
                    <span class="label">Awards: </span>
                </xsl:if>
                <xsl:for-each select="marc:datafield[@tag=586]">
                    <xsl:value-of select="marc:subfield[@code='a']"/>
                    <xsl:if test="position()!=last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- 508 -->
        <xsl:if test="marc:datafield[@tag=508]">
            <span class="results_summary prod_credits">
                <span class="label">Production credits: </span>
                <xsl:for-each select="marc:datafield[@tag=508]">
                    <xsl:call-template name="subfieldSelectSpan">
                        <xsl:with-param name="codes">a</xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="position()!=last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                </xsl:for-each>
            </span>
        </xsl:if>

         <!-- 583 -->
         <xsl:if test="marc:datafield[@tag=583]">
            <span class="results_summary actionnote">
                <span class="label">Action note: </span>
                <xsl:for-each select="marc:datafield[@tag=583]">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code='z']">
                            <xsl:value-of select="marc:subfield[@code='z']"/><xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">abcdefgijklnou</xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position()!=last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
                </xsl:for-each>
            </span>
         </xsl:if>

        <xsl:call-template name="host-item-entries">
            <xsl:with-param name="UseControlNumber" select="$UseControlNumber"/>
        </xsl:call-template>

        <xsl:if test="marc:datafield[@tag=502]">
            <span class="results_summary diss_note">
                <span class="label">Dissertation note: </span>
                <xsl:for-each select="marc:datafield[@tag=502]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdgo</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise></xsl:choose>
            </span>
        </xsl:if>

        <!-- Content Warning -->
        <xsl:variable name="ContentWarningField" select="marc:sysprefs/marc:syspref[@name='ContentWarningField']"/>
        <xsl:if test="marc:datafield[@tag=$ContentWarningField]">
           <span class="results_summary content_warning">
               <span class="label">Content warning: </span>
               <xsl:for-each select="marc:datafield[@tag=$ContentWarningField]">
                   <xsl:choose>
                       <xsl:when test="marc:subfield[@code='u']">
                           <a>
                               <xsl:attribute name="href">
                                   <xsl:value-of select="marc:subfield[@code='u']"/>
                               </xsl:attribute>
                               <xsl:choose>
                                   <xsl:when test="marc:subfield[@code='a']">
                                       <xsl:value-of select="marc:subfield[@code='a']"/>
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:value-of select="marc:subfield[@code='u']"/>
                                   </xsl:otherwise>
                               </xsl:choose>
                           </a>
                           <xsl:text> </xsl:text>
                       </xsl:when>
                       <xsl:when test="not(marc:subfield[@code='u']) and marc:subfield[@code='a']">
                           <xsl:value-of select="marc:subfield[@code='a']"/><xsl:text> </xsl:text>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bcdefghijklmnopqrstvwxyz</xsl:with-param>
                   </xsl:call-template>
                   <xsl:if test="position()!=last()"><span class="separator"><xsl:text> | </xsl:text></span></xsl:if>
               </xsl:for-each>
           </span>
        </xsl:if>

        <!-- 866 textual holdings -->
        <xsl:if test="marc:datafield[@tag=866]">
            <span class="results_summary holdings_note basic_bibliographic_unit"><span class="label">Holdings: </span>
                <xsl:for-each select="marc:datafield[@tag=866]">
                    <span class="holdings_note_data">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">axz</xsl:with-param>
                        </xsl:call-template>
                        <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                    </span>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- 867 textual holdings -->
        <xsl:if test="marc:datafield[@tag=867]">
            <span class="results_summary holdings_note supplementary_material"><span class="label">Supplements: </span>
                <xsl:for-each select="marc:datafield[@tag=867]">
                    <span class="holdings_note_data">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">axz</xsl:with-param>
                        </xsl:call-template>
                        <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                    </span>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- 868 textual holdings -->
        <xsl:if test="marc:datafield[@tag=868]">
            <span class="results_summary holdings_note indexes"><span class="label">Indexes: </span>
                <xsl:for-each select="marc:datafield[@tag=868]">
                    <span class="holdings_note_data">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">axz</xsl:with-param>
                        </xsl:call-template>
                        <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text><br /></xsl:otherwise></xsl:choose>
                    </span>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- 770 - Supplement/Special issue entry -->
        <xsl:if test="marc:datafield[@tag=770]">
            <span class="results_summary supplement"><span class="label">Supplement: </span>
                <xsl:for-each select="marc:datafield[@tag=770]">
                    <xsl:if test="marc:subfield[@code='i']">
                        <span class="770_rel_info">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">i</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:if>
                    <a>
                        <xsl:choose>
                            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                                <xsl:attribute name="href">
                                    /cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate(marc:subfield[@code='t'], '()', ''),true())"/></xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code='a'] or marc:subfield[@code='t']">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </a>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bdghkmnr9usxyz</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="position()=last()"></xsl:when>
                        <xsl:otherwise><span class="separator"> | </span></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!-- 772 - Supplement parent entry -->
        <xsl:if test="marc:datafield[@tag=772]">
            <span class="results_summary supplement_parent"><span class="label">Supplement to: </span>
                <xsl:for-each select="marc:datafield[@tag=772]">
                    <xsl:if test="marc:subfield[@code='i']">
                        <span class="772_rel_info">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">i</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:if>
                    <a>
                        <xsl:choose>
                            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                                <xsl:attribute name="href">
                                    /cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate(marc:subfield[@code='t'], '()', ''),true())"/></xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code='a'] or marc:subfield[@code='t']">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </a>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bdghkmnr9usxyz</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="position()=last()"></xsl:when>
                        <xsl:otherwise><span class="separator"> | </span></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </span>
        </xsl:if>

        <!--  775 Other Edition  -->
        <xsl:if test="marc:datafield[@tag=775]">
        <span class="results_summary other_editions"><span class="label">Other editions: </span>
        <xsl:for-each select="marc:datafield[@tag=775]">
            <xsl:variable name="f775">
                <xsl:call-template name="chopPunctuation"><xsl:with-param name="chopString"><xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">a_t</xsl:with-param>
                </xsl:call-template></xsl:with-param></xsl:call-template>
            </xsl:variable>
            <xsl:if test="marc:subfield[@code='i']">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">i</xsl:with-param>
                </xsl:call-template>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <a>
            <xsl:choose>
            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate($f775, '()', ''), true())"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">a_t</xsl:with-param>
            </xsl:call-template>
            </a>
            <xsl:choose>
                <xsl:when test="position()=last()"></xsl:when>
                <xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </span>
        </xsl:if>

        <!-- 780 -->
        <xsl:if test="marc:datafield[@tag=780]">
            <xsl:for-each select="marc:datafield[@tag=780]">
                <xsl:if test="@ind1=0">
                    <span class="results_summary preceeding_entry">
                        <xsl:choose>
                            <xsl:when test="@ind2=0">
                               <span class="label">Continues:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=1">
                               <span class="label">Continues in part:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=2">
                               <span class="label">Supersedes:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=3">
                               <span class="label">Supersedes in part:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=4">
                               <span class="label">Formed by the union: ... and: ...</span>
                            </xsl:when>
                            <xsl:when test="@ind2=5">
                               <span class="label">Absorbed:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=6">
                               <span class="label">Absorbed in part:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=7">
                               <span class="label">Separated from:</span>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text> </xsl:text>

                        <xsl:if test="marc:subfield[@code='i']">
                            <span class="780_rel_info">
                                <xsl:value-of select="marc:subfield[@code='i']"/>
                                <xsl:text> </xsl:text>
                            </span>
                        </xsl:if>

                        <xsl:variable name="f780">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a_t</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                                <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                                    <xsl:value-of select="$f780"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate($f780, '()', ''), true())"/></xsl:attribute>
                                    <xsl:value-of select="$f780"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>

                    <xsl:if test="marc:subfield[@code='n']">
                        <span class="results_summary preceeding_entry_note"><xsl:value-of select="marc:subfield[@code='n']"/></span>
                    </xsl:if>

                </xsl:if>
            </xsl:for-each>
        </xsl:if>

        <!-- 785 -->
        <xsl:if test="marc:datafield[@tag=785]">
            <xsl:for-each select="marc:datafield[@tag=785]">
                <xsl:if test="@ind1=0">
                    <span class="results_summary succeeding_entry">
                        <xsl:choose>
                            <xsl:when test="@ind2=0">
                                <span class="label">Continued by:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=1">
                                <span class="label">Continued in part by:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=2">
                                <span class="label">Superseded by:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=3">
                                <span class="label">Superseded in part by:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=4">
                                <span class="label">Absorbed by:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=5">
                                <span class="label">Absorbed in part by:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=6">
                                <span class="label">Split into .. and ...:</span>
                            </xsl:when>
                            <xsl:when test="@ind2=7">
                                <span class="label">Merged with ... to form ...</span>
                            </xsl:when>
                            <xsl:when test="@ind2=8">
                                <span class="label">Changed back to:</span>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text> </xsl:text>

                        <xsl:if test="marc:subfield[@code='i']">
                            <span class="785_rel_info">
                                <xsl:value-of select="marc:subfield[@code='i']"/>
                                <xsl:text> </xsl:text>
                            </span>
                        </xsl:if>

                        <xsl:variable name="f785">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">a_t</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:choose>
                            <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                                <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                                    <xsl:value-of select="$f785"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=ti,phr:<xsl:value-of select="str:encode-uri(translate($f785, '()', ''), true())"/></xsl:attribute>
                                    <xsl:value-of select="$f785"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>

                    </span>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>

        <!--  787 Other Relationship Entry  -->
        <xsl:if test="marc:datafield[@tag=787]">
        <span class="results_summary other_relationship_entry"><span class="label">Other related works: </span>
        <xsl:for-each select="marc:datafield[@tag=787]">
            <span class="other_relationship_entry">
                <xsl:variable name="f787">
                    <xsl:call-template name="chopPunctuation"><xsl:with-param name="chopString"><xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a_t</xsl:with-param>
                    </xsl:call-template></xsl:with-param></xsl:call-template>
                </xsl:variable>
                <xsl:if test="marc:subfield[@code='i']">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">i</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:choose>
                <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                    <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                        <xsl:value-of select="$f787"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="relation_query">
                        <xsl:text>ti,phr:(</xsl:text>
                        <xsl:call-template name="quote_search_term">
                            <xsl:with-param name="term"><xsl:value-of select="marc:subfield[@code='t']"/></xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>)</xsl:text>
                        <xsl:if test="marc:subfield[@code='a']">
                            <xsl:text> AND au:(</xsl:text>
                            <xsl:call-template name="quote_search_term">
                                <xsl:with-param name="term">
                                    <xsl:value-of select="marc:subfield[@code='a']"/>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <a>
                    <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:value-of select="str:encode-uri($relation_query, true())" />
                    </xsl:attribute>
                        <xsl:value-of select="$f787"/>
                    </a>
                </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="position()=last()"></xsl:when>
                    <xsl:otherwise><span class="separator"><xsl:text>; </xsl:text></span></xsl:otherwise>
                </xsl:choose>
            </span>
        </xsl:for-each>
        </span>
        </xsl:if>

        <!-- Indicate if record is suppressed in OPAC -->
        <xsl:choose>
            <xsl:when test="$OpacSuppression = 1 and marc:datafield[@tag=942][marc:subfield[@code='n'] = '1']">
                <span class="results_summary suppressed_opac">
                    <span class="label">OPAC view: </span>
                    Suppressed in OPAC
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$OPACBaseURL!=''">
                    <span class="results_summary opac_view"><span class="label">OPAC view: </span>
                        <a><xsl:attribute name="href"><xsl:value-of select="$OPACBaseURL"/>/cgi-bin/koha/opac-detail.pl?biblionumber=<xsl:value-of select="str:encode-uri(marc:datafield[@tag=999]/marc:subfield[@code='c'], true())"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute>Open in new window</a>.
                    </span>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>



    </xsl:template>

    <xsl:template name="nameABCQ">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcq</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameABCDN">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdn</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameACDEQ">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">acdeq</xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="specialSubfieldSelect">
        <xsl:param name="anyCodes"/>
        <xsl:param name="axis"/>
        <xsl:param name="beforeCodes"/>
        <xsl:param name="afterCodes"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($anyCodes, @code)      or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
                    <xsl:value-of select="text()"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
    </xsl:template>

    <xsl:template name="showAuthor">
	<xsl:param name="authorfield"/>
    <xsl:param name="UseAuthoritiesForTracings"/>
	<xsl:if test="count($authorfield)&gt;0">
        <h5 class="author">
        <xsl:for-each select="$authorfield">
        <xsl:choose>
          <xsl:when test="position()&gt;1"/>
          <!-- #13383 -->
          <xsl:when test="@tag&lt;700"><span class="byAuthor">By: </span></xsl:when>
          <!--#13382 Changed Additional author to contributor -->
          <xsl:otherwise>Contributor(s): </xsl:otherwise>
        </xsl:choose>
        <a>
        <xsl:choose>
            <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
            <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=au:"<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>"</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="@tag=100 or @tag=110 or @tag=111">
                <!-- #13383 -->
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">
                                <xsl:choose>
                                    <!-- #13383 include subfield e for field 111, Display only name portion in 1XX -->
                                    <xsl:when test="@tag=111">aeq</xsl:when>
                                    <xsl:when test="@tag=110">ab</xsl:when>
                                    <xsl:otherwise>abcjq</xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="punctuation">
                        <xsl:text>:,;/ </xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                    <!-- Display only name and title portion in 110 field -->
                    <xsl:if test="@tag=110 and boolean(marc:subfield[@code='c' or @code='d' or @code='n' or @code='t'])">
                    <span class="titleportion">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code='c' or @code='d' or @code='n'][not(marc:subfield[@code='t'])]"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">cdnt</xsl:with-param>
                        </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    </span>
                    </xsl:if>
                    <!-- Display only name and title portion in 111 field -->
            <xsl:if test="@tag=111 and boolean(marc:subfield[@code='c' or @code='d' or @code='g' or @code='n' or @code='t'])">
                    <span class="titleportion">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code='c' or @code='d' or @code='g' or @code='n'][not(marc:subfield[@code='t'])]"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
                    </xsl:choose>

                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">cdgnt</xsl:with-param>
                        </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    </span>
            </xsl:if>
            <!-- Display only dates in 100 field -->
            <xsl:if test="@tag=100 and marc:subfield[@code='d']">
                <span class="authordates">
                <xsl:text>, </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                           <xsl:with-param name="codes">d</xsl:with-param>
                        </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    </span>
            </xsl:if>

            </xsl:when>
            <!-- #13382 excludes 700$i and ind2=2, displayed as Related Works -->
            <!--#13382 Added all relevant subfields 4, e, and d are handled separately -->
            <xsl:when test="@tag=700 or @tag=710 or @tag=711">
                    <!-- Includes major changes for 7XX fields; display name portion in 710 and 711 fields -->
                    <xsl:if test="@tag=710 or @tag=711">
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">
                            <xsl:choose>
                                <xsl:when test="@tag=711">aeq</xsl:when>
                                <xsl:otherwise>ab</xsl:otherwise>
                            </xsl:choose>
                            </xsl:with-param>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="punctuation">
                            <xsl:text>:,;/ </xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                    <!-- Display only name and title portion in 711 field -->
                    <xsl:if test="@tag=711 and boolean(marc:subfield[@code='c' or @code='d' or @code='g' or @code='n' or @code='t'])">
                    <span class="titleportion">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code='c' or @code='d' or @code='g' or @code='n'][not(marc:subfield[@code='t'])]"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
                    </xsl:choose>

                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">cdgnt</xsl:with-param>
                        </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    </span>
                    </xsl:if>
                    <!-- Display only name and title portion in 710 field -->
                    <xsl:if test="@tag=710 and boolean(marc:subfield[@code='c' or @code='d' or @code='n' or @code='t'])">
                    <span class="titleportion">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code='c' or @code='d' or @code='n'][not(marc:subfield[@code='t'])]"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">cdnt</xsl:with-param>
                        </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    </span>
                    </xsl:if>

                    </xsl:if>
                        <!-- Display only name portion in 700 field -->
                        <xsl:if test="@tag=700">
                           <xsl:call-template name="chopPunctuation">
                               <xsl:with-param name="chopString">
                               <xsl:call-template name="subfieldSelect">
                                  <xsl:with-param name="codes">abcq</xsl:with-param>
                               </xsl:call-template>
                               </xsl:with-param>
                        </xsl:call-template>
                        </xsl:if>
                        <!-- Display class "authordates" in 700 field -->
                        <xsl:if test="@tag=700 and marc:subfield[@code='d']">
                        <span class="authordates">
                        <xsl:text>, </xsl:text>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                            <xsl:call-template name="subfieldSelect">
                               <xsl:with-param name="codes">d</xsl:with-param>
                            </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                        </span>
                        </xsl:if>
                        <!-- Display class "titleportion" in 700 field -->
                        <xsl:variable name="titleportionfields" select="boolean(marc:subfield[@code='t' or @code='j' or @code='k' or @code='u'])"/>
                        <xsl:if test="@tag=700 and $titleportionfields">
                        <span class="titleportion">
                        <xsl:text>. </xsl:text>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">fghjklmnoprstux</xsl:with-param>
                            </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                        </span>
                        </xsl:if>

        </xsl:when>
        </xsl:choose>

    <!-- add relator code too between brackets-->
    <!-- #13383 include relator code j for field 111 -->
            <xsl:if test="(@tag!=111 and @tag!=711 and marc:subfield[@code='4' or @code='e']) or ((@tag=111 or @tag=711) and marc:subfield[@code='4' or @code='j'])">
                <span class="relatorcode">
                    <xsl:text> [</xsl:text>
                    <xsl:choose>
                        <xsl:when test="@tag=111 or @tag=711">
                            <xsl:choose>
                                <!-- Prefer j over 4 for fields 111 and 711-->
                                <xsl:when test="marc:subfield[@code='j']">
                                    <xsl:for-each select="marc:subfield[@code='j']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="marc:subfield[@code=4]">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <!-- Prefer e over 4 for fields 111 and 711-->
                        <xsl:when test="marc:subfield[@code='e'][not(@tag=111) or not(@tag=711)]">
                            <xsl:for-each select="marc:subfield[@code='e']">
                                <xsl:value-of select="."/>
                                <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="marc:subfield[@code=4]">
                                <xsl:value-of select="."/>
                                <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>]</xsl:text>
                </span>
            </xsl:if>
        </a>
        <xsl:if test="marc:subfield[@code=9]">
            <xsl:call-template name="showAuthlink">
                <xsl:with-param name="authid"><xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>
        </h5>
	</xsl:if>
    </xsl:template>

    <xsl:template name="showAuthlink">
        <xsl:param name="authid"/>
        <xsl:text> </xsl:text>
        <a class='authlink'>
            <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
            <xsl:attribute name="title">View authority record</xsl:attribute>
            <xsl:attribute name="target">_blank</xsl:attribute>
            <xsl:element name="i">
                <xsl:attribute name="class">fa fa-search</xsl:attribute>
                <xsl:attribute name="aria-label">View authority record</xsl:attribute>
            </xsl:element>
        </a>
    </xsl:template>

    <!-- #1807 Strip unwanted parenthesis from subjects for searching -->
    <xsl:template name="subfieldSelectSubject">
        <xsl:param name="codes"/>
        <xsl:param name="delimeter"><xsl:text> </xsl:text></xsl:param>
        <xsl:param name="subdivCodes"/>
        <xsl:param name="subdivDelimiter"/>
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>
        <xsl:param name="urlencode"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($codes, @code)">
                    <xsl:if test="contains($subdivCodes, @code)">
                        <xsl:value-of select="$subdivDelimiter"/>
                    </xsl:if>
                    <xsl:value-of select="$prefix"/><xsl:value-of select="translate(text(),'()','')"/><xsl:value-of select="$suffix"/><xsl:value-of select="$delimeter"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$urlencode=1">
                <xsl:value-of select="str:encode-uri(substring($str,1,string-length($str)-string-length($delimeter)), true())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
