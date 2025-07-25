<?xml version='1.0'?>

<!DOCTYPE stylesheet>

<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha-community.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="marc items str">

  <xsl:template name="datafield">
    <xsl:param name="tag"/>
    <xsl:param name="ind1"><xsl:text> </xsl:text></xsl:param>
    <xsl:param name="ind2"><xsl:text> </xsl:text></xsl:param>
    <xsl:param name="subfields"/>
    <xsl:element name="datafield">
      <xsl:attribute name="tag">
        <xsl:value-of select="$tag"/>
      </xsl:attribute>
      <xsl:attribute name="ind1">
        <xsl:value-of select="$ind1"/>
      </xsl:attribute>
      <xsl:attribute name="ind2">
       <xsl:value-of select="$ind2"/>
         </xsl:attribute>
       <xsl:copy-of select="$subfields"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="tag_210-214">
    <xsl:choose>
      <xsl:when test="marc:datafield[@tag=210] and marc:datafield[@tag=214]">
        <xsl:call-template name="tag_214" />
      </xsl:when>
      <xsl:when test="marc:datafield[@tag=214]">
        <xsl:call-template name="tag_214" />
      </xsl:when>
      <xsl:when test="marc:datafield[@tag=210]">
        <xsl:call-template name="tag_210" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="tag_210">
    <span class="results_summary publication">
      <span class="label">Publication: </span>
      <xsl:for-each select="marc:datafield[@tag=210]">
        <xsl:if test="not(position() = 1)">
          <br/>
        </xsl:if>
        <span class="value">
          <xsl:call-template name="addClassRtl" />
          <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='g']">
            <xsl:choose>
              <xsl:when test="@code='a'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text> : </xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@code='b'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@code='c' or @code='g'">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=pb:<xsl:value-of select="str:encode-uri(., true())"/></xsl:attribute>
                  <xsl:attribute name="title">Search for publisher</xsl:attribute>
                  <xsl:value-of select="."/>
                </a>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@code='d'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </span>
      </xsl:for-each>
    </span>
  </xsl:template>

  <xsl:template name="tag_214">
    <xsl:for-each select="marc:datafield[@tag=214]">
      <xsl:sort select="@ind2" data-type="number" />
      <span class="results_summary publication">
        <span class="label">
          <xsl:choose>
            <xsl:when test="@ind2=1">Production: </xsl:when>
            <xsl:when test="@ind2=2">Distribution: </xsl:when>
            <xsl:when test="@ind2=3">Manufacture: </xsl:when>
            <xsl:when test="@ind2=4">
              <xsl:choose>
                <xsl:when test="substring(marc:subfield[@code='d'],1,1)='C'">Copyright date: </xsl:when>
                <xsl:when test="substring(marc:subfield[@code='d'],1,1)='P'">Protection date: </xsl:when>
                <xsl:otherwise>Copyright date / protection date: </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>Publication: </xsl:otherwise>
          </xsl:choose>
        </span>
        <span>
          <xsl:call-template name="addClassRtl" />
          <xsl:for-each select="marc:subfield">
            <xsl:choose>
              <xsl:when test="@code='a'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text> : </xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@code='b'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@code='c'">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=pb:<xsl:value-of select="str:encode-uri(., true())"/></xsl:attribute>
                  <xsl:attribute name="title">Search for publisher</xsl:attribute>
                  <xsl:value-of select="."/>
                </a>
              </xsl:when>
              <xsl:when test="@code='d'">
                <xsl:if test="not(position()=1)">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="substring(.,1,1)='C'">
                    <xsl:value-of select="substring(.,2)"/>
                  </xsl:when>
                  <xsl:when test="substring(.,1,1)='P'">
                    <xsl:value-of select="substring(.,2)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </span>
      </span>
    </xsl:for-each>
    <xsl:call-template name="tag_214_r" />
    <xsl:call-template name="tag_214_s" />
  </xsl:template>

  <xsl:template name="tag_214_s">
    <xsl:if test="marc:datafield[@tag=214]/marc:subfield[@code='s']">
      <span class="results_summary tag_214_s">
        <span class="label">Printing and/or publishing information transcribed as found in the colophon: </span>
        <xsl:for-each select="marc:datafield[@tag=214]/marc:subfield[@code='s']">
          <xsl:value-of select="."/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>, </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag_214_r">
    <xsl:if test="marc:datafield[@tag=214]/marc:subfield[@code='r']">
      <span class="results_summary tag_214_r">
        <span class="label">Printing and/or publishing information transcribed as found in the main source of information: </span>
        <xsl:for-each select="marc:datafield[@tag=214]/marc:subfield[@code='r']">
          <xsl:value-of select="."/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>, </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag_215">
    <xsl:for-each select="marc:datafield[@tag=215]">
      <span class="results_summary description">
        <span class="label">Description: </span>
        <xsl:if test="marc:subfield[@code='a']">
          <xsl:value-of select="marc:subfield[@code='a']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='c']"> :
          <xsl:value-of select="marc:subfield[@code='c']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='d']"> ;
          <xsl:value-of select="marc:subfield[@code='d']"/>
        </xsl:if>
        <xsl:if test="marc:subfield[@code='e']"> +
          <xsl:value-of select="marc:subfield[@code='e']"/>
        </xsl:if>
      </span>
    </xsl:for-each>
  </xsl:template>

	<xsl:template name="tag_4xx">
    <xsl:for-each select="marc:datafield[@tag=464 or @tag=461]">
      <span class="results_summary linked_with">
        <span class="label">Linked with: </span>
        <span class="value">
          <xsl:call-template name="addClassRtl" />
          <xsl:if test="marc:subfield[@code='t']">
            <xsl:value-of select="marc:subfield[@code='t']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='e']"> :
            <xsl:value-of select="marc:subfield[@code='e']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='f']"> /
            <xsl:value-of select="marc:subfield[@code='f']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='v']">,
            <xsl:value-of select="marc:subfield[@code='v']"/>
          </xsl:if>
        </span>
      </span>
    </xsl:for-each>
  </xsl:template>

	<xsl:template name="subfieldSelect">
		<xsl:param name="codes"/>
		<xsl:param name="delimeter"><xsl:text> </xsl:text></xsl:param>
		<xsl:param name="subdivCodes"/>
		<xsl:param name="subdivDelimiter"/>
    <xsl:param name="urlencode"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
                    <xsl:if test="contains($subdivCodes, @code)">
                        <xsl:value-of select="$subdivDelimiter"/>
                    </xsl:if>
					<xsl:value-of select="text()"/><xsl:value-of select="$delimeter"/>
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

	<xsl:template name="buildSpaces">
		<xsl:param name="spaces"/>
		<xsl:param name="char"><xsl:text> </xsl:text></xsl:param>
		<xsl:if test="$spaces>0">
			<xsl:value-of select="$char"/>
			<xsl:call-template name="buildSpaces">
				<xsl:with-param name="spaces" select="$spaces - 1"/>
				<xsl:with-param name="char" select="$char"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

  <xsl:template name="buildBiblioDefaultViewURL">
      <xsl:param name="IntranetBiblioDefaultView"/>
      <xsl:choose>
          <xsl:when test="$IntranetBiblioDefaultView='normal'">
              <xsl:text>/cgi-bin/koha/catalogue/detail.pl?biblionumber=</xsl:text>
          </xsl:when>
          <xsl:when test="$IntranetBiblioDefaultView='isbd'">
              <xsl:text>/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=</xsl:text>
          </xsl:when>
          <xsl:when test="$IntranetBiblioDefaultView='labeled_marc'">
              <xsl:text>/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=</xsl:text>
          </xsl:when>
          <xsl:when test="$IntranetBiblioDefaultView='marc'">
              <xsl:text>/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=</xsl:text>
          </xsl:when>
          <xsl:otherwise>
              <xsl:text>/cgi-bin/koha/catalogue/detail.pl?biblionumber=</xsl:text>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

	<xsl:template name="chopSpecialCharacters">
        <xsl:param name="title" />
        <xsl:variable name="ntitle"
             select="translate($title, '&#x0098;&#x009C;&#xC29C;&#xC29B;&#xC298;&#xC288;&#xC289;','')"/>
        <xsl:value-of select="$ntitle" />
    </xsl:template>


	<xsl:template name="chopPunctuation">
		<xsl:param name="chopString"/>
		<xsl:variable name="length" select="string-length($chopString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="contains('.:,;/ ', substring($chopString,$length,1))">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="substring($chopString,1,$length - 1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not($chopString)"/>
			<xsl:otherwise><xsl:value-of select="$chopString"/></xsl:otherwise>
		</xsl:choose>
    <xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template name="addClassRtl">
    <xsl:variable name="lang" select="marc:subfield[@code='7']" />
    <xsl:if test="$lang = 'ha' or $lang = 'Hebrew' or $lang = 'fa' or $lang = 'Arabe'">
      <xsl:attribute name="class">rtl</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag_title">
    <xsl:param name="tag" />
    <xsl:param name="label" />
    <xsl:param name="spanclass" />
    <xsl:if test="marc:datafield[@tag=$tag]">
      <span class="results_summary {$spanclass}">
        <span class="label">
          <xsl:value-of select="$label"/>
          <xsl:text>: </xsl:text>
        </span>
        <xsl:for-each select="marc:datafield[@tag=$tag]">
          <xsl:value-of select="marc:subfield[@code='a']" />
          <xsl:if test="marc:subfield[@code='d']">
            <xsl:text> : </xsl:text>
            <xsl:value-of select="marc:subfield[@code='e']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='e']">
            <xsl:for-each select="marc:subfield[@code='e']">
              <xsl:text> </xsl:text>
              <xsl:value-of select="."/>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='f']">
            <xsl:text> / </xsl:text>
            <xsl:value-of select="marc:subfield[@code='f']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='h']">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="marc:subfield[@code='h']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='i']">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="marc:subfield[@code='i']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='v']">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="marc:subfield[@code='v']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='x']">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="marc:subfield[@code='x']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='z']">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="marc:subfield[@code='z']"/>
          </xsl:if>
        </xsl:for-each>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag_subject">
    <xsl:param name="tag" />
    <xsl:param name="label" />
    <xsl:param name="spanclass"/>
    <xsl:if test="marc:datafield[@tag=$tag]">
      <span class="results_summary subjects {$spanclass}">
        <span class="label">
          <xsl:value-of select="$label"/>
          <xsl:text>: </xsl:text>
        </span>
        <xsl:for-each select="marc:datafield[@tag=$tag]">
          <a>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code=9]">
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=su:<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abcdjptvxyz</xsl:with-param>
                    <xsl:with-param name="subdivCodes">jpxyz</xsl:with-param>
                    <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </a>
          <xsl:if test="not (position()=last())">
            <xsl:text> | </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag_7xx">
    <xsl:param name="tag" />
    <xsl:param name="label" />
    <xsl:param name="spanclass" />
    <xsl:param name="AuthorLinkSortBy"/>
    <xsl:param name="AuthorLinkSortOrder"/>
    <xsl:if test="marc:datafield[@tag=$tag]">
      <span class="results_summary author {$spanclass}">
        <span class="label">
          <xsl:value-of select="$label" />
          <xsl:text>: </xsl:text>
        </span>
        <span class="value">
          <xsl:for-each select="marc:datafield[@tag=$tag]">
            <xsl:call-template name="addClassRtl" />
            <a>
              <xsl:choose>
                <xsl:when test="marc:subfield[@code=9]">
                  <xsl:attribute name="href">
                    <xsl:text>/cgi-bin/koha/catalogue/search.pl?q=an:</xsl:text>
                    <xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/>
                    <xsl:if test="$AuthorLinkSortBy!='default'">
                        <xsl:text>&amp;sort_by=</xsl:text>
                        <xsl:value-of select="$AuthorLinkSortBy"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="$AuthorLinkSortOrder"/>
                    </xsl:if>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href">
                      <xsl:text>/cgi-bin/koha/catalogue/search.pl?q=au:</xsl:text>
                      <xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>
                      <xsl:text>%20</xsl:text>
                      <xsl:value-of select="str:encode-uri(marc:subfield[@code='b'], true())"/>
                      <xsl:if test="$AuthorLinkSortBy!='default'">
                        <xsl:text>&amp;sort_by=</xsl:text>
                        <xsl:value-of select="$AuthorLinkSortBy"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="$AuthorLinkSortOrder"/>
                    </xsl:if>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="marc:subfield[@code='a']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='b']">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='c']">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="marc:subfield[@code='c']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='d']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='d']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='f']">
                <span dir="ltr">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="marc:subfield[@code='f']"/>
                <xsl:text>)</xsl:text>
                </span>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='g']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='g']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='p']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='p']"/>
              </xsl:if>
            </a>
            <xsl:if test="not (position() = last())">
              <xsl:text> ; </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </span>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag_content_warning">
    <xsl:param name="tag" />
    <xsl:if test="marc:datafield[@tag=$tag]">
       <span class="results_summary content_warning">
           <span class="label">Content warning: </span>
           <xsl:for-each select="marc:datafield[@tag=$tag]">
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
  </xsl:template>

</xsl:stylesheet>
