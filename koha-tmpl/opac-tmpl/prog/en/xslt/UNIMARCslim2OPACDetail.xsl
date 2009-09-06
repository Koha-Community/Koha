<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">

<xsl:import href="UNIMARCslimUtils.xsl"/>
<xsl:output method = "xml" indent="yes" omit-xml-declaration = "yes" />
<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="marc:record">
  <xsl:variable name="leader" select="marc:leader"/>
  <xsl:variable name="leader6" select="substring($leader,7,1)"/>
  <xsl:variable name="leader7" select="substring($leader,8,1)"/>
  <xsl:variable name="biblionumber" select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>
  

  <xsl:if test="marc:datafield[@tag=200]">
    <xsl:for-each select="marc:datafield[@tag=200]">
      <h1>
        <xsl:call-template name="addClassRtl" />
        <xsl:variable name="title" select="marc:subfield[@code='a']"/>
        <xsl:variable name="ntitle"
         select="translate($title, '&#x0098;&#x009C;','')"/>
        <xsl:value-of select="$ntitle" />
        <xsl:if test="marc:subfield[@code='e']">
          <xsl:text> : </xsl:text>
          <xsl:for-each select="marc:subfield[@code='e']">
            <xsl:value-of select="."/>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='b']">
          <xsl:text> [</xsl:text>
          <xsl:value-of select="marc:subfield[@code='b']"/>
          <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='f']">
          <xsl:text> / </xsl:text>
          <xsl:value-of select="marc:subfield[@code='f']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='g']">
          <xsl:text> ; </xsl:text>
          <xsl:value-of select="marc:subfield[@code='g']"/>
        </xsl:if>
      </h1>
    </xsl:for-each>
  </xsl:if>

  <div id="views">
    <span class="view">
      <span id="Normalview">Normal View</span>
    </span>
    <span class="view">
      <a id="MARCviewPop" href="/cgi-bin/koha/opac-showmarc.pl?id={marc:datafield[@tag=090]/marc:subfield[@code='a']}" title="MARC" rel="gb_page_center[600,500]">MARC View</a>
    </span>
    <span class="view">
      <a id="MARCview" href="/cgi-bin/koha/opac-MARCdetail.pl?biblionumber={marc:datafield[@tag=090]/marc:subfield[@code='a']}" title="MARC">Expanded MARC View</a>
    </span>
    <span class="view">
      <a id="ISBDview" href="/cgi-bin/koha/opac-ISBDdetail.pl?biblionumber={marc:datafield[@tag=090]/marc:subfield[@code='a']}">Card View (ISBD)</a>
    </span>
  </div>
  
  <xsl:call-template name="tag_4xx" />

  <xsl:call-template name="tag_7xx">
    <xsl:with-param name="tag">700</xsl:with-param>
    <xsl:with-param name="label">Auteur principal</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_7xx">
    <xsl:with-param name="tag">710</xsl:with-param>
    <xsl:with-param name="label">Collectivité principale</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_7xx">
    <xsl:with-param name="tag">701</xsl:with-param>
    <xsl:with-param name="label">Co-auteur</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_7xx">
    <xsl:with-param name="tag">702</xsl:with-param>
    <xsl:with-param name="label">Auteur</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_7xx">
    <xsl:with-param name="tag">711</xsl:with-param>
    <xsl:with-param name="label">Collectivité co-auteur</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_7xx">
    <xsl:with-param name="tag">712</xsl:with-param>
    <xsl:with-param name="label">Collectivité secondaire</xsl:with-param>
  </xsl:call-template>

  <xsl:if test="marc:datafield[@tag=101]">
	  <span class="results_summary">
      <span class="label">Langue: </span>
      <xsl:for-each select="marc:datafield[@tag=101]">
        <xsl:for-each select="marc:subfield">
          <xsl:choose>
            <xsl:when test="@code='b'">de la trad. intermédiaire, </xsl:when>
            <xsl:when test="@code='c'">de l'œuvre originale, </xsl:when>
            <xsl:when test="@code='d'">du résumé, </xsl:when>
            <xsl:when test="@code='e'">de la table des matières, </xsl:when>
            <xsl:when test="@code='f'">de la page de titre, </xsl:when>
            <xsl:when test="@code='g'">du titre propre, </xsl:when>
            <xsl:when test="@code='h'">d'un livret, </xsl:when>
            <xsl:when test="@code='i'">des textes d'accompagnement, </xsl:when>
            <xsl:when test="@code='j'">des sous-titres, </xsl:when>
          </xsl:choose>
          <xsl:value-of select="text()"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> ; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=102]">
	  <span class="results_summary">
      <span class="label">Pays: </span>
      <xsl:for-each select="marc:datafield[@tag=102]">
        <xsl:for-each select="marc:subfield">
          <xsl:value-of select="text()"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
              <xsl:otherwise><xsl:text>, </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:call-template name="tag_210" />

  <xsl:call-template name="tag_215" />

  <abbr class="unapi-id" title="koha:biblionumber:{marc:datafield[@tag=090]/marc:subfield[@code='a']}"><!-- unAPI --></abbr>

  <xsl:if test="marc:datafield[@tag=010]/marc:subfield[@code='a']">
    <span class="results_summary"><span class="label">ISBN: </span>
    <xsl:for-each select="marc:datafield[@tag=010]">
      <xsl:variable name="isbn" select="marc:subfield[@code='a']"/>
      <xsl:value-of select="marc:subfield[@code='a']"/>
      <xsl:choose>
        <xsl:when test="position()=last()">
          <xsl:text>.</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> ; </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=011]">
    <span class="results_summary">
      <span class="label">ISSN: </span>
      <xsl:for-each select="marc:datafield[@tag=011]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:choose>
          <xsl:when test="position()=last()">
            <xsl:text>.</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>; </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:call-template name="tag_title">
    <xsl:with-param name="tag">225</xsl:with-param>
    <xsl:with-param name="label">Collection</xsl:with-param>
  </xsl:call-template>

  <xsl:if test="marc:datafield[@tag=676]">
    <span class="results_summary">
    <span class="label">Dewey: </span>
      <xsl:for-each select="marc:datafield[@tag=676]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:if test="marc:subfield[@code='v']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="marc:subfield[@code='v']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='z']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="marc:subfield[@code='z']"/>
        </xsl:if>
        <xsl:if test="not (position()=last())">
          <xsl:text> ; </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=686]">
    <span class="results_summary">
    <span class="label">Classification: </span>
      <xsl:for-each select="marc:datafield[@tag=686]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:if test="marc:subfield[@code='b']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="marc:subfield[@code='b']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='c']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="marc:subfield[@code='c']"/>
        </xsl:if>
        <xsl:if test="not (position()=last())"><xsl:text> ; </xsl:text></xsl:if>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=327]">
    <span class="results_summary">
      <span class="label">Note de contenu: </span>
      <xsl:for-each select="marc:datafield[@tag=327]">
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">abcdjpvxyz</xsl:with-param>
                <xsl:with-param name="subdivCodes">jpxyz</xsl:with-param>
                <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=330]">
    <span class="results_summary">
      <span class="label">Résumé: </span>
      <xsl:for-each select="marc:datafield[@tag=330]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:choose>
          <xsl:when test="position()=last()">
            <xsl:text>.</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>; </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=317]">
    <span class="results_summary">
      <span class="label">Note sur la provenance: </span>
      <xsl:for-each select="marc:datafield[@tag=317]">
          <xsl:value-of select="marc:subfield[@code='a']"/>      
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=320]">
    <span class="results_summary">
      <span class="label">Bibliographie: </span>
      <xsl:for-each select="marc:datafield[@tag=320]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=328]">
    <span class="results_summary">
      <span class="label">Thèse: </span>
      <xsl:for-each select="marc:datafield[@tag=328]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:if test="marc:datafield[@tag=333]">
    <span class="results_summary">
      <span class="label">Public: </span>
      <xsl:for-each select="marc:datafield[@tag=333]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:if>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">600</xsl:with-param>
    <xsl:with-param name="label">Sujet - Nom de personne</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">601</xsl:with-param>
    <xsl:with-param name="label">Sujet - Collectivité</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">602</xsl:with-param>
    <xsl:with-param name="label">Sujet - Famille</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">604</xsl:with-param>
    <xsl:with-param name="label">Sujet - Auteur/titre</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">606</xsl:with-param>
    <xsl:with-param name="label">Sujet - Nom commun</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">607</xsl:with-param>
    <xsl:with-param name="label">Sujet - Nom géographique</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">608</xsl:with-param>
    <xsl:with-param name="label">Sujet - Forme</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">610</xsl:with-param>
    <xsl:with-param name="label">Sujet</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">615</xsl:with-param>
    <xsl:with-param name="label">Catégorie sujet</xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="tag_subject">
    <xsl:with-param name="tag">616</xsl:with-param>
    <xsl:with-param name="label">Marque déposée</xsl:with-param>
  </xsl:call-template>

  <xsl:if test="marc:datafield[@tag=856]">
    <span class="results_summary">
      <span class="label">Online Resources: </span>
      <xsl:for-each select="marc:datafield[@tag=856]">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="marc:subfield[@code='u']"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">y3z</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
              Click here to access online
            </xsl:when>
          </xsl:choose>
        </a>
        <xsl:choose>
          <xsl:when test="position()=last()"></xsl:when>
          <xsl:otherwise> | </xsl:otherwise>
        </xsl:choose>      
      </xsl:for-each>
    </span>
  </xsl:if>

        <!-- 780 -->
        <xsl:if test="marc:datafield[@tag=780]">
        <xsl:for-each select="marc:datafield[@tag=780]">
        <span class="results_summary"><span class="label">
        <xsl:choose>
        <xsl:when test="@ind2=0">
            Continues:
        </xsl:when>
        <xsl:when test="@ind2=1">
            Continues in part:
        </xsl:when>
        <xsl:when test="@ind2=2">
            Supersedes:
        </xsl:when>
        <xsl:when test="@ind2=3">
            Supersedes in part:
        </xsl:when>
        <xsl:when test="@ind2=4">
            Formed by the union: ... and: ...
        </xsl:when>
        <xsl:when test="@ind2=5">
            Absorbed:
        </xsl:when>
        <xsl:when test="@ind2=6">
            Absorbed in part:
        </xsl:when>
        <xsl:when test="@ind2=7">
            Separated from:
        </xsl:when>
        </xsl:choose>
        </span>
                <xsl:variable name="f780">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">at</xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
             <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:value-of select="translate($f780, '()', '')"/></xsl:attribute>
                <xsl:value-of select="translate($f780, '()', '')"/>
            </a>
        </span>
 
        <xsl:choose>
        <xsl:when test="@ind1=0">
            <span class="results_summary"><xsl:value-of select="marc:subfield[@code='n']"/></span>
        </xsl:when>
        </xsl:choose>

        </xsl:for-each>
        </xsl:if>

        <!-- 785 -->
        <xsl:if test="marc:datafield[@tag=785]">
        <xsl:for-each select="marc:datafield[@tag=785]">
        <span class="results_summary"><span class="label">
        <xsl:choose>
        <xsl:when test="@ind2=0">
            Continued by:
        </xsl:when>
        <xsl:when test="@ind2=1">
            Continued in part by:
        </xsl:when>
        <xsl:when test="@ind2=2">
            Superseded by:
        </xsl:when>
        <xsl:when test="@ind2=3">
            Superseded in part by:
        </xsl:when>
        <xsl:when test="@ind2=4">
            Absorbed by:
        </xsl:when>
        <xsl:when test="@ind2=5">
            Absorbed in part by:
        </xsl:when>
        <xsl:when test="@ind2=6">
            Split into .. and ...:
        </xsl:when>
        <xsl:when test="@ind2=7">
            Merged with ... to form ...
        </xsl:when>
        <xsl:when test="@ind2=8">
            Changed back to:
        </xsl:when>

        </xsl:choose>
        </span>
                   <xsl:variable name="f785">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">at</xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>

                <a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:value-of select="translate($f785, '()', '')"/></xsl:attribute>
                <xsl:value-of select="translate($f785, '()', '')"/>
            </a>

        </span>
        </xsl:for-each>
        </xsl:if>

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
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partName"/>
                </xsl:call-template>
        </xsl:if>
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

</xsl:stylesheet>
