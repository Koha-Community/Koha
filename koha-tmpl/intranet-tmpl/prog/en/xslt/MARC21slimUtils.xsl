<?xml version='1.0'?>
<!DOCTYPE stylesheet>
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="marc str">
  <xsl:include href="MARC21Languages.xsl"/>
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

	<xsl:template name="subfieldSelect">
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
					<xsl:value-of select="$prefix"/><xsl:value-of select="text()"/><xsl:value-of select="$suffix"/><xsl:value-of select="$delimeter"/>
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

    <xsl:template name="subfieldSelectSpan">
        <xsl:param name="codes"/>
        <xsl:param name="delimeter"><xsl:text> </xsl:text></xsl:param>
        <xsl:param name="subdivCodes"/>
        <xsl:param name="subdivDelimiter"/>
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>
        <xsl:param name="newline"/>
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($codes, @code)">
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="@code"/>
                            <xsl:if test="$newline = 1 and contains(text(), '--')">
                                <xsl:text> newline</xsl:text>
                            </xsl:if>
                        </xsl:attribute>
                        <xsl:if test="contains($subdivCodes, @code)">
                            <xsl:value-of select="$subdivDelimiter"/>
                        </xsl:if>
                        <xsl:value-of select="$prefix"/><xsl:value-of select="text()"/><xsl:value-of select="$suffix"/><xsl:if test="position()!=last()"><xsl:value-of select="$delimeter"/></xsl:if>
                    </span>
                </xsl:if>
            </xsl:for-each>
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
	</xsl:template>

	<!-- Function extractControlNumber is used to extract the control number (record number) from MARC tags 773/80/85 [etc.] subfield $w.
	     Parameter: control number string.
	     Assumes LOC convention: (OrgCode)recordNumber.
	     If OrgCode is not present, return full string.
	     Additionally, handle various brackets/parentheses. Chop leading and trailing spaces.
         Returns the value URI-encoded.
	-->
	<xsl:template name="extractControlNumber">
	    <xsl:param name="subfieldW"/>
	    <xsl:variable name="tranW" select="translate($subfieldW,']})&gt;','))))')"/>
	    <xsl:choose>
	      <xsl:when test="contains($tranW,')')">
	        <xsl:value-of select="str:encode-uri(normalize-space(translate(substring-after($tranW,')'),'[]{}()&lt;&gt;','')), true())"/>
	      </xsl:when>
	      <xsl:otherwise>
	        <xsl:value-of select="str:encode-uri(normalize-space($subfieldW), true())"/>
	      </xsl:otherwise>
	    </xsl:choose>
	</xsl:template>

    <!-- Function m880Select:  Display Alternate Graphic Representation (MARC 880) for selected latin "base"tags
        - should be called immediately before the corresonding latin tags are processed 
        - tags in right-to-left languages are displayed floating right
        * Parameter:
           + basetags: display these tags if found in linkage section ( subfield 6) of tag 880
           + codes: display these subfields codes
        * Options: 
            - class: wrap output in <span class="$class">...</span>
            - label: prefix each(!) tag with label $label
            - bibno: link to biblionumber $bibno
            - index: build a search link using index $index with subfield $a as key; if subfield $9 is present use index 'an' with key $9 instead.
         * Limitations:
            - displays every field on a separate line (to switch between rtl and ltr)
         * Pitfalls:
           (!) output might be empty
    --> 
    <xsl:template name="m880Select">
         <xsl:param name="basetags"/> <!-- e.g.  100,700,110,710 -->
        <xsl:param name="codes"/> <!-- e.g. abc  -->
        <xsl:param name="class"/> <!-- e.g. results_summary -->
        <xsl:param name="label"/> <!-- e.g.  Edition -->
        <xsl:param name="bibno"/>
        <xsl:param name="index"/> <!-- e.g.  au -->
        <xsl:param name="UseAuthoritiesForTracings"/>

        <xsl:for-each select="marc:datafield[@tag=880]">
            <xsl:variable name="code6" select="marc:subfield[@code=6]"/>
            <xsl:if test="contains(string($basetags), substring($code6,1,3))">
                <span>
                    <xsl:choose>
                    <xsl:when test="boolean($class) and substring($code6,string-length($code6)-1,2) ='/r'">
                        <xsl:attribute name="class"><xsl:value-of select="$class"/> m880</xsl:attribute>
                        <xsl:attribute name="dir">rtl</xsl:attribute>
                    </xsl:when>
                     <xsl:when test="boolean($class)">
                        <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
                        <xsl:attribute name="style">display:block; </xsl:attribute>
                    </xsl:when>    
                     <xsl:when test="substring($code6,string-length($code6)-1,2) ='/r'">
                        <xsl:attribute name="class"><xsl:value-of select="$class"/> m880</xsl:attribute>
                    </xsl:when>                                    
                    </xsl:choose>
                    <xsl:if test="boolean($label)">
                        <span class="label">
                            <xsl:value-of select="$label"/>
                        </span>
                    </xsl:if>
                    <xsl:variable name="str">
                        <xsl:for-each select="marc:subfield">
                            <xsl:if test="contains($codes, @code)">
                                <xsl:value-of select="text()"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="boolean($bibno)">
                            <a>
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/detail.pl?biblionumber=<xsl:value-of  select="str:encode-uri($bibno, true())"/></xsl:attribute>
                                <xsl:value-of select="$str"/>
                            </a>
                        </xsl:when>
                       <xsl:when test="boolean($index) and boolean(marc:subfield[@code=9]) and $UseAuthoritiesForTracings='1'">
                            <a>
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of  select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
                                  <xsl:value-of select="$str"/>
                            </a>
                        </xsl:when>
                        <xsl:when test="boolean($index)">
                            <a>
                                <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:value-of select="str:encode-uri($index, true())"/>:<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/></xsl:attribute>
                                <xsl:value-of select="$str"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$str"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="showRDAtag264">
    <!-- Function showRDAtag264 shows selected information from tag 264
         on the Publisher line (used by OPAC Detail and Results)
         Depending on how many tags you have, we will pick by preference
         Publisher-latest or Publisher or 'Other'-latest or 'Other'
         The preferred tag is saved in the fav variable and passed to a
         helper named-template -->
    <!-- Amended  to show all 264 fields (filtered by ind1=3 if ind1=3 is present in the record)  -->
        <xsl:param name="show_url"/>
        <xsl:choose>
            <xsl:when test="marc:datafield[@tag=264 and @ind1=3]">
                <xsl:for-each select="marc:datafield[@tag=264 and @ind1=3]">
                    <xsl:call-template name="showRDAtag264helper">
                        <xsl:with-param name="field" select="."/>
                        <xsl:with-param name="url" select="$show_url"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="marc:datafield[@tag=264]">
                    <xsl:call-template name="showRDAtag264helper">
                        <xsl:with-param name="field" select="."/>
                        <xsl:with-param name="url" select="$show_url"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="showRDAtag264helper">
        <xsl:param name="field"/>
        <xsl:param name="url"/>
        <xsl:variable name="ind2" select="$field/@ind2"/>
        <span class="results_summary rda264">
            <xsl:choose>
                <xsl:when test="$ind2='0'">
                    <span class="label">Producer: </span>
                </xsl:when>
                <xsl:when test="$ind2='1'">
                    <span class="label">Publisher: </span>
                </xsl:when>
                <xsl:when test="$ind2='2'">
                    <span class="label">Distributor: </span>
                </xsl:when>
                <xsl:when test="$ind2='3'">
                    <span class="label">Manufacturer: </span>
                </xsl:when>
                <xsl:when test="$ind2='4'">
                    <span class="label">Copyright date: </span>
                </xsl:when>
            </xsl:choose>

            <xsl:if test="$field/marc:subfield[@code='a']">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:text> </xsl:text>

            <xsl:choose>
                <xsl:when test="$url='1'">
                    <xsl:if test="$field/marc:subfield[@code='b']">
                         <a>
                         <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Provider:<xsl:value-of select="str:encode-uri($field/marc:subfield[@code='b'], true())"/></xsl:attribute>
                         <xsl:call-template name="subfieldSelect">
                             <xsl:with-param name="codes">b</xsl:with-param>
                         </xsl:call-template>
                         </a>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$field/marc:subfield[@code='b']">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">b</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">c</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>

        </span>
    </xsl:template>

    <xsl:template name="showISBNISSN">
      <xsl:call-template name="showSingleSubfield">
        <xsl:with-param name="tag">020</xsl:with-param>
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="class">isbn</xsl:with-param>
        <xsl:with-param name="label">ISBN: </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="showSingleSubfield">
        <xsl:with-param name="tag">022</xsl:with-param>
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="class">issn</xsl:with-param>
        <xsl:with-param name="label">ISSN: </xsl:with-param>
      </xsl:call-template>
    </xsl:template>

    <xsl:template name="showSingleSubfield">
      <xsl:param name="tag"/>
      <xsl:param name="code"/>
      <xsl:param name="class"/>
      <xsl:param name="label"/>
      <xsl:if test="marc:datafield[@tag=$tag]/marc:subfield[@code=$code]">
        <span><xsl:attribute name="class"><xsl:value-of select="concat('results_summary ', $class)"/></xsl:attribute>
        <span class="label"><xsl:value-of select="$label"/></span>
            <xsl:for-each select="marc:datafield[@tag=$tag]/marc:subfield[@code=$code]">
              <span><xsl:attribute name="property"><xsl:value-of select="$class"/></xsl:attribute>
                <xsl:value-of select="."/>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
              </span>
            </xsl:for-each>
          </span>
      </xsl:if>
    </xsl:template>

    <xsl:template name="show-lang-041">
      <xsl:if test="marc:datafield[@tag=041]">
	<xsl:for-each select="marc:datafield[@tag=041]">
	  <span class="results_summary languages">
	    <xsl:call-template name="show-lang-node">
	      <xsl:with-param name="langNode" select="marc:subfield[@code='a']"/>
	      <xsl:with-param name="langLabel">Language: </xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="show-lang-node">
	      <xsl:with-param name="langNode" select="marc:subfield[@code='b']"/>
	      <xsl:with-param name="langLabel">Summary language: </xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="show-lang-node">
	      <xsl:with-param name="langNode" select="marc:subfield[@code='d']"/>
	      <xsl:with-param name="langLabel">Spoken language: </xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="show-lang-node">
	      <xsl:with-param name="langNode" select="marc:subfield[@code='h']"/>
	      <xsl:with-param name="langLabel">Original language: </xsl:with-param>
	    </xsl:call-template>
	    <xsl:call-template name="show-lang-node">
	      <xsl:with-param name="langNode" select="marc:subfield[@code='j']"/>
	      <xsl:with-param name="langLabel">Subtitle language: </xsl:with-param>
	    </xsl:call-template>
	  </span>
	</xsl:for-each>
      </xsl:if>
    </xsl:template>

    <xsl:template name="show-lang-node">
      <xsl:param name="langNode"/>
      <xsl:param name="langLabel"/>
      <xsl:if test="$langNode">
	<span class="language">
	  <span class="label"><xsl:value-of select="$langLabel"/></span>
	  <xsl:for-each select="$langNode">
	    <span>
	      <xsl:attribute name="class">lang_code-<xsl:value-of select="translate(., ' .-;|#', '_')"/></xsl:attribute>
	      <xsl:call-template name="languageCodeText">
		<xsl:with-param name="code" select="."/>
	      </xsl:call-template>
	      <xsl:if test="position() != last()">
	        <span class="sep"><xsl:text>, </xsl:text></span>
	      </xsl:if>
	    </span>
	  </xsl:for-each>
	  <span class="sep"><xsl:text>. </xsl:text></span>
	</span>
      </xsl:if>
    </xsl:template>

    <xsl:template name="show-series">
        <xsl:param name="searchurl"/>
        <xsl:param name="UseControlNumber"/>
        <xsl:param name="UseAuthoritiesForTracings"/>
        <!-- Series -->
        <xsl:if test="marc:datafield[@tag=440 or @tag=490 or @tag=800 or @tag=801 or @tag=811 or @tag=830]">
        <span class="results_summary series"><span class="label">Series: </span>
        <!-- 440 -->
        <xsl:for-each select="marc:datafield[@tag=440 and @ind1!='z']">
            <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=se,phr:"<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>"</xsl:attribute>
            <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
            </a>
            <xsl:call-template name="part"/>
            <xsl:if test="marc:subfield[@code='v']">
                <xsl:text> ; </xsl:text><xsl:value-of select="marc:subfield[@code='v']" />
            </xsl:if>
            <xsl:choose>
                <xsl:when test="position()=last()">
                    <xsl:if test="../marc:datafield[@tag=490][@ind1!=1] or ../marc:datafield[(@tag=800 or @tag=810 or @tag=811) and @ind1!='z'] or ../marc:datafield[@tag=830 and @ind1!='z']">
                        <span class="separator"> | </span>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise><span class="separator"> | </span></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <!-- 490 Series not traced, Ind1 = 0 -->
        <xsl:for-each select="marc:datafield[@tag=490][@ind1!=1]">
            <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=se,phr:"<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>"</xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
            </a>
            <xsl:call-template name="part"/>
            <xsl:if test="marc:subfield[@code='v']">
                <xsl:text> ; </xsl:text><xsl:value-of select="marc:subfield[@code='v']" />
            </xsl:if>
            <xsl:choose>
                <xsl:when test="position()=last()">
                    <xsl:if test="../marc:datafield[(@tag=800 or @tag=810 or @tag=811) and @ind1!='z'] or ../marc:datafield[@tag=830 and @ind1!='z']">
                        <span class="separator"> | </span>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise><span class="separator"> | </span></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!-- 800,810,811,830 always display. -->

        <xsl:for-each select="marc:datafield[(@tag=800 or @tag=810 or @tag=811) and @ind1!='z']">
            <xsl:choose>
                <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                    <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=rcn:<xsl:value-of select="str:encode-uri(marc:subfield[@code='w'], true())"/></xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                    <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=an:<xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=se,phr:"<xsl:value-of select="str:encode-uri(marc:subfield[@code='t'], true())"/>"&amp;q=au:"<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>"</xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="part"/>
            <xsl:text> ; </xsl:text>
            <xsl:value-of  select="marc:subfield[@code='v']" />
        <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:if test="../marc:datafield[@tag=830 and @ind1!='z']">
                    <span class="separator"> | </span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <span class="separator"> | </span>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marc:datafield[@tag=830 and @ind1!='z']">
            <xsl:choose>
                <xsl:when test="$UseControlNumber = '1' and marc:subfield[@code='w']">
                    <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=rcn:<xsl:value-of select="marc:subfield[@code='w']"/></xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
                    <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=an:<xsl:value-of select="str:encode-uri(marc:subfield[@code=9], true())"/></xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a><xsl:attribute name="href"><xsl:value-of select="$searchurl"/>?q=se,phr:"<xsl:value-of select="str:encode-uri(marc:subfield[@code='a'], true())"/>"</xsl:attribute>
                        <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes">a_t</xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="part"/>
            <xsl:if test="marc:subfield[@code='v']">
                <xsl:text> ; </xsl:text><xsl:value-of select="marc:subfield[@code='v']" />
            </xsl:if>
        <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><span class="separator"> | </span></xsl:otherwise></xsl:choose>
        </xsl:for-each>

        </span>
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
        <xsl:if test="string-length(normalize-space($partNumber)) or string-length(normalize-space($partName))" >
            <xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($partNumber))">
            <xsl:value-of select="$partNumber" />
        </xsl:if>
        <xsl:if test="string-length(normalize-space($partNumber))"><xsl:text> </xsl:text></xsl:if>
        <xsl:if test="string-length(normalize-space($partName))">
            <xsl:value-of select="$partName" />
        </xsl:if>
    </xsl:template>

    <xsl:template name="quote_search_term">
        <xsl:param name="term" />
        <xsl:text>"</xsl:text>
        <xsl:call-template name="escape_quotes">
            <xsl:with-param name="text">
                <xsl:value-of select="$term"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template name="escape_quotes">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text, '&quot;')">
                <xsl:variable name="before" select="substring-before($text,'&quot;')"/>
                <xsl:variable name="next" select="substring-after($text,'&quot;')"/>
                <xsl:value-of select="$before"/>
                <xsl:text>\&quot;</xsl:text>
                <xsl:call-template name="escape_quotes">
                    <xsl:with-param name="text" select="$next"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="host-item-entries">
        <xsl:param name="UseControlNumber"/>
        <!-- 773 -->
        <xsl:if test="marc:datafield[@tag=773]">
            <xsl:for-each select="marc:datafield[@tag=773]">
                <xsl:if test="@ind1 !=1">
                    <span class="results_summary in"><span class="label">
                    <xsl:choose>
                        <xsl:when test="@ind2=' '">
                            In:
                        </xsl:when>
                        <xsl:when test="@ind2=8 and marc:subfield[@code='i']">
                            <xsl:call-template name="subfieldSelect">
                                <xsl:with-param name="codes">i</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    </span>
                    <xsl:variable name="f773">
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
                            <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=Control-number:<xsl:call-template name="extractControlNumber"><xsl:with-param name="subfieldW" select="marc:subfield[@code='w']"/></xsl:call-template></xsl:attribute>
                            <xsl:value-of select="translate($f773, '()', '')"/>
                            </a>
                        </xsl:when>
                        <xsl:when test="marc:subfield[@code='0']">
                            <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/detail.pl?biblionumber=<xsl:value-of select="str:encode-uri(marc:subfield[@code='0'], true())"/></xsl:attribute>
                            <xsl:value-of select="$f773"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="host_query">
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
                            <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:value-of select="str:encode-uri($host_query, true())" />
                            </xsl:attribute>
                                <xsl:value-of select="$f773"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="marc:subfield[@code='g']">
                        <xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='g']"/>
                    </xsl:if>
                    </span>
                    <xsl:if test="marc:subfield[@code='n']">
                        <span class="results_summary in_note"><xsl:value-of select="marc:subfield[@code='n']"/></span>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="AddMissingProtocol">
        <xsl:param name="resourceLocation"/>
        <xsl:param name="indicator1"/>
        <xsl:param name="accessMethod"/>
        <xsl:param name="delimiter" select="':'"/>
        <xsl:if test="not(contains($resourceLocation, $delimiter))">
            <xsl:choose>
                <xsl:when test="$indicator1=7 and ( $accessMethod='mailto' or $accessMethod='tel' )">
                    <xsl:value-of select="$accessMethod"/><xsl:text>:</xsl:text>
                </xsl:when>
                <xsl:when test="$indicator1=7">
                    <xsl:value-of select="$accessMethod"/><xsl:text>://</xsl:text>
                </xsl:when>
                <xsl:when test="$indicator1=0">
                    <xsl:text>mailto:</xsl:text>
                </xsl:when>
                <xsl:when test="$indicator1=1">
                    <xsl:text>ftp://</xsl:text>
                </xsl:when>
                <xsl:when test="$indicator1=2">
                    <xsl:text>telnet://</xsl:text>
                </xsl:when>
                <xsl:when test="$indicator1=3">
                    <xsl:text>tel:</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>http://</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="GetCnumSearchURL">
        <xsl:param name="title_subfield" select="'t'"/>
        <xsl:param name="cnum_subfield" select="'w'"/>
        <xsl:param name="opac_url" select="1"/>
        <xsl:param name="UseControlNumber"/>

        <xsl:variable name="orgcode">
            <xsl:choose>
                <xsl:when test="$UseControlNumber!='1'"/>
                <xsl:when test="substring-before(marc:subfield[@code=$cnum_subfield],')')">
                    <!-- substring before closing parenthesis, remove parentheses and spaces -->
                    <xsl:value-of select="normalize-space(translate(substring-before(marc:subfield[@code=$cnum_subfield],')'),'()',''))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="controlnumber">
            <xsl:choose>
                <xsl:when test="$UseControlNumber!='1'"/>
                <xsl:when test="substring-after(marc:subfield[@code=$cnum_subfield],')')">
                    <!-- substring after closing parenthesis, remove spaces -->
                    <xsl:value-of select="normalize-space(substring-after(marc:subfield[@code=$cnum_subfield],')'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- consider whole subfield now as controlnumber -->
                    <xsl:value-of select="normalize-space(marc:subfield[@code=$cnum_subfield])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="scriptname">
            <xsl:choose>
                <xsl:when test="$opac_url=1"><xsl:text>/cgi-bin/koha/opac-search.pl</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>/cgi-bin/koha/catalogue/search.pl</xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- search for (1) controlnumber AND orgcode, or (2) only controlnumber, or (3) title -->
            <xsl:when test="$controlnumber!='' and $orgcode!=''">
                <xsl:value-of select="str:encode-uri(concat($scriptname,'?q=Control-number:',$controlnumber,' AND Control-number-identifier:',$orgcode),false())"/>
            </xsl:when>
            <xsl:when test="$controlnumber!=''">
                <xsl:value-of select="str:encode-uri(concat($scriptname,'?q=Control-number:',$controlnumber),false())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="quoted_title">
                    <xsl:call-template name="quote_search_term">
                        <xsl:with-param name="term"><xsl:value-of select="marc:subfield[@code=$title_subfield]"/></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="str:encode-uri(concat($scriptname,'?q=ti,phr:',translate($quoted_title, '()', '')),false())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

<!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios/><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
