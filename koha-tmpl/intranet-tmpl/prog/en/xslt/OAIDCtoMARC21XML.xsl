<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/1.1"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/
        http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.loc.gov/MARC21/slim"  exclude-result-prefixes="dc dcterms oai_dc">

    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>


    <xsl:template match="/">
        <collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" >
            <xsl:apply-templates />
        </collection>
    </xsl:template>

    <xsl:template name="OAI-PMH">
             <xsl:for-each select = "ListRecords/record/metadata/oai_dc:dc">
                <xsl:apply-templates  />
             </xsl:for-each>
             <xsl:for-each select = "GetRecord/record/metadata/oai_dc:dc">
                <xsl:apply-templates  />
             </xsl:for-each>
    </xsl:template>

    <xsl:template match="text()" />
    <xsl:template match="oai_dc:dc">
        <record>
            <xsl:element name="leader">
                <xsl:variable name="type" select="dc:type"/>
                <xsl:variable name="leader06">
                    <xsl:choose>
                        <xsl:when test="$type='collection'">p</xsl:when>
                        <xsl:when test="$type='dataset'">m</xsl:when>
                        <xsl:when test="$type='event'">r</xsl:when>
                        <xsl:when test="$type='image'">k</xsl:when>
                        <xsl:when test="$type='interactive resource'">m</xsl:when>
                        <xsl:when test="$type='service'">m</xsl:when>
                        <xsl:when test="$type='software'">m</xsl:when>
                        <xsl:when test="$type='sound'">i</xsl:when>
                        <xsl:when test="$type='text'">a</xsl:when>
                        <xsl:otherwise>a</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="leader07">
                    <xsl:choose>
                        <xsl:when test="$type='collection'">c</xsl:when>
                        <xsl:otherwise>m</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat('      ',$leader06,$leader07,' a       3u     ')"/>
            </xsl:element>

            <datafield tag="042" ind1=" " ind2=" ">
                <subfield code="a">dc</subfield>
            </datafield>



            <xsl:for-each select="dc:creator">
                <xsl:choose>
                    <xsl:when test="(.!='') and (position()=1)">
                        <xsl:call-template name="persname_template">
                            <xsl:with-param name="string" select="." />
                            <xsl:with-param name="field" select="'100'" />
                            <xsl:with-param name="ind1" select = "'1'" />
                            <xsl:with-param name="ind2" select = "'0'" />
                            <xsl:with-param name="type" select="'author'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test=".!=''">
                            <xsl:call-template name="persname_template">
                                <xsl:with-param name="string" select="." />
                                <xsl:with-param name="field" select="'700'" />
                                <xsl:with-param name="ind1" select = "'1'" />
                                <xsl:with-param name="ind2" select = "'0'" />
                                <xsl:with-param name="type" select="'author'" />
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>


            <xsl:for-each select="dc:title[1]">
                <datafield tag="245" ind1="0" ind2="0">
                    <subfield code="a">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>

            <xsl:for-each select="dc:title[position()>1]">
                <xsl:if test=".!=''">
                    <datafield tag="246" ind1="3" ind2="3">
                        <subfield code="a">
                            <xsl:value-of select="."/>
                        </subfield>
                    </datafield>
                </xsl:if>
            </xsl:for-each>

            <xsl:choose>
                <xsl:when test="dc:publisher">
                    <xsl:if test="translate(dc:publisher/.,'.,:;','')!=''">
                        <datafield tag="260" ind1=" " ind2=" ">
                        <xsl:choose>
                            <xsl:when test="dc:date">
                                <subfield code="b"><xsl:value-of select="dc:publisher[1]"/>, </subfield>
                                <xsl:if test="translate(dc:date[1]/., '.,:;','')!=''">
                                    <subfield code="c"><xsl:value-of select="dc:date[1]" />.</subfield>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <subfield code="b"><xsl:value-of select="dc:publisher[1]"/>.</subfield>
                            </xsl:otherwise>
                        </xsl:choose>
                        </datafield>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="translate(dc:date[1],'.,:;','')!=''">
                        <datafield tag="260" ind1=" " ind2=" ">
                            <subfield code="c"><xsl:value-of select="dc:date[1]" />.</subfield>
                        </datafield>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:for-each select="dc:coverage">
                <xsl:choose>
                    <xsl:when test="translate(., '0123456789-.?','')=''">
                        <!--Likely;this is a date-->
                        <datafield tag="500" ind1=" " ind2=" ">
                            <subfield code="a"><xsl:value-of select="."/></subfield>
                        </datafield>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--likely a geographic subject, we will print this later-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="dc:identifier">
                <xsl:if test="position()!=last()">
                    <datafield tag="500" ind1=" " ind2=" ">
                        <subfield code="a"><xsl:value-of select="." /></subfield>
                    </datafield>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="dc:description">
                <datafield tag="520" ind1=" " ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="normalize-space(.)"/>
                    </subfield>
                </datafield>
            </xsl:for-each>


            <xsl:for-each select="dc:rights">
                <datafield tag="540" ind1=" " ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>


            <xsl:for-each select="dc:language">
                <datafield tag="546" ind1=" " ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>



            <xsl:for-each select="dc:subject">
                <datafield tag="690" ind1=" " ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>

            <xsl:for-each select="dc:coverage">
                <xsl:choose>
                    <xsl:when test="translate(., '0123456789-.?','')=''">
                        <!--Likely; this is a date-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!--likely a geographic subject-->
                        <datafield tag="691" ind1=" " ind2=" ">
                            <subfield code="a"><xsl:value-of select="." /></subfield>
                        </datafield>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>


            <xsl:for-each select="dc:type">
                <datafield tag="655" ind1="7" ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="."/>
                    </subfield>
                    <subfield code="2">local</subfield>
                </datafield>
            </xsl:for-each>



            <xsl:for-each select="dc:contributer">
                    <xsl:call-template name="persname_template">
                        <xsl:with-param name="string" select="." />
                        <xsl:with-param name="field" select="'100'" />
                        <xsl:with-param name="ind1" select = "'1'" />
                        <xsl:with-param name="ind2" select = "'0'" />
                        <xsl:with-param name="type" select="'contributor'" />
                    </xsl:call-template>
            </xsl:for-each>

            <xsl:for-each select="dc:source">
                <datafield tag="786" ind1="0" ind2=" ">
                    <subfield code="n">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>

            <xsl:for-each select="dc:relation">
                <datafield tag="787" ind1="0" ind2=" ">
                    <subfield code="n">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>

            <xsl:if test="dc:identifier">
                <datafield tag="856" ind1="4" ind2="1">
                    <subfield code="u"><xsl:value-of select="dc:identifier[last()]" /></subfield>
                    <subfield code="z">Connect to this object online.</subfield>
                </datafield>
            </xsl:if>
        </record>

    </xsl:template>
<xsl:template name="persname_template">
      <xsl:param name="string" />
      <xsl:param name="field" />
      <xsl:param name="ind1" />
      <xsl:param name="ind2" />
      <xsl:param name="type" />
      <datafield>
         <xsl:attribute name="tag">
            <xsl:value-of select="$field" />
         </xsl:attribute>
         <xsl:attribute name="ind1">
            <xsl:value-of select="$ind1" />
         </xsl:attribute>
         <xsl:attribute name="ind2">
            <xsl:value-of select="$ind2" />
         </xsl:attribute>

         <!-- Sample input: Brightman, Samuel C. (Samuel Charles), 1911-1992 -->
         <!-- Sample output: $aBrightman, Samuel C. $q(Samuel Charles), $d1911-. -->
         <!-- will handle names with dashes e.g. Bourke-White, Margaret -->

         <!-- CAPTURE PRIMARY NAME BY LOOKING FOR A PAREN OR A DASH OR NEITHER -->
         <xsl:choose>
            <!-- IF A PAREN, STOP AT AN OPENING PAREN -->
            <xsl:when test="contains($string, '(')!=0">
               <subfield code="a">
                  <xsl:value-of select="substring-before($string, '(')" />
               </subfield>
            </xsl:when>
            <!-- IF A DASH, CHECK IF IT'S A DATE OR PART OF THE NAME -->
            <xsl:when test="contains($string, '-')!=0">
               <xsl:variable name="name_1" select="substring-before($string, '-')" />
               <xsl:choose>
                  <!-- IF IT'S A DATE REMOVE IT -->
                  <xsl:when test="translate(substring($name_1, (string-length($name_1)), 1), '0123456789', '9999999999') = '9'">
                     <xsl:variable name="name" select="substring($name_1, 1, (string-length($name_1)-6))" />
                     <subfield code="a">
                        <xsl:value-of select="$name" />
                     </subfield>
                  </xsl:when>
                  <!-- IF IT'S NOT A DATE, CHECK WHETHER THERE IS A DATE LATER -->
                  <xsl:otherwise>
                     <xsl:variable name="remainder" select="substring-after($string, '-')" />
                     <xsl:choose>
                        <!-- IF THERE'S A DASH, ASSUME IT'S A DATE AND REMOVE IT -->
                        <xsl:when test="contains($remainder, '-')!=0">
                           <xsl:variable name="tmp" select="substring-before($remainder, '-')" />
                           <xsl:variable name="name_2" select="substring($tmp, 1, (string-length($tmp)-6))" />
                           <subfield code="a">
                              <xsl:value-of select="$name_1" />-<xsl:value-of select="$name_2" />
                           </subfield>
                        </xsl:when>
                        <!-- IF THERE'S NO DASH IN THE REMAINDER, OUTPUT IT -->
                        <xsl:otherwise>
                           <subfield code="a">
                              <xsl:value-of select="$string" />
                           </subfield>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <!-- NO DASHES, NO PARENS, JUST OUTPUT THE NAME -->
            <xsl:otherwise>
               <subfield code="a">
                  <xsl:value-of select="$string" />
               </subfield>
            </xsl:otherwise>
         </xsl:choose>

         <!-- CAPTURE SECONDARY NAME IN PARENS FOR SUBFIELD Q -->
         <xsl:if test="contains($string, '(')!=0">
            <xsl:variable name="subq_tmp" select="substring-after($string, '(')" />
            <xsl:variable name="subq" select="substring-before($subq_tmp, ')')" />
            <subfield code="q">
               (<xsl:value-of select="$subq" />)
            </subfield>
         </xsl:if>

         <!-- CAPTURE DATE FOR SUBFIELD D, ASSUME DATE IS LAST ITEM IN FIELD -->
         <!-- Note: does not work if name has a dash in it -->
         <xsl:if test="contains($string, '-')!=0">
            <xsl:variable name="date_tmp" select="substring-before($string, '-')" />
            <xsl:variable name="remainder" select="substring-after($string, '-')" />
            <xsl:choose>
               <!-- CHECK SECOND HALF FOR ANOTHER DASH; IF PRESENT, ASSUME THAT IS DATE -->
               <xsl:when test="contains($remainder, '-')!=0">
                  <xsl:variable name="tmp" select="substring-before($remainder, '-')" />
                  <xsl:variable name="date_1" select="substring($remainder, (string-length($tmp)-3))" />
                  <!-- CHECK WHETHER IT HAS A NUMBER BEFORE IT AND IF SO, OUTPUT IT AS DATE -->
                  <xsl:if test="translate(substring($date_1, 1, 1), '0123456789', '9999999999') = '9'">
                     <subfield code="d">
                        <xsl:value-of select="$date_1" />.
                     </subfield>
                  </xsl:if>
               </xsl:when>
               <!-- OTHERWISE THIS IS THE ONLY DASH SO TAKE IT -->
               <xsl:otherwise>
                  <xsl:variable name="date_2" select="substring($string, (string-length($date_tmp)-3))" />
                  <!-- CHECK WHETHER IT HAS A NUMBER BEFORE IT AND IF SO, OUTPUT IT AS DATE -->
                  <xsl:if test="translate(substring($date_2, 1, 1), '0123456789', '9999999999') = '9'">
                     <subfield code="d">
                        <xsl:value-of select="$date_2" />.
                     </subfield>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
         <subfield code="e"><xsl:value-of select="$type" /></subfield>
      </datafield>
   </xsl:template>

</xsl:stylesheet>
