<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes"/>
    <!-- ************* Templates ****************-->


    <!-- ****************************************-->

    <xsl:template match="marc:record">
        <xsl:variable name="authid" select="marc:controlfield[@tag='001']" />
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>

        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:text>authority-summary</xsl:text>
            </xsl:attribute>

            <!-- *********** Personal Name 100 ********* -->
            <xsl:if test="marc:datafield[@tag='100']">
              <xsl:element name="span">
                <xsl:attribute name="class">
                  <xsl:text>authorizedheading</xsl:text>
                </xsl:attribute>
                <a>
                  <xsl:attribute name="data-authid"><xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='100']/marc:subfield[@code='a']"/>
                </a>
              </xsl:element>

              <xsl:if test="marc:datafield[@tag='400']">
                <xsl:element name="div">
                  <xsl:attribute name="class">
                    <xsl:text>seefrom</xsl:text>
                  </xsl:attribute>
                  <xsl:element name="span">
                      used for/see from:
                  </xsl:element>

                  <xsl:for-each select="marc:datafield[@tag=400]">
                    <xsl:element name="div">
                      <xsl:attribute name="class">
                        <xsl:text>authref</xsl:text>
                      </xsl:attribute>
                      <xsl:element name="span">
                        <xsl:attribute name="class">
                          <xsl:text>heading</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:element>
              </xsl:if>

              <xsl:if test="marc:datafield[@tag='500'] or marc:datafield[@tag='550']">
                <xsl:element name="div">
                  <xsl:attribute name="class">
                    <xsl:text>seealso</xsl:text>
                  </xsl:attribute>
                  <xsl:element name="span">
                      see also:
                  </xsl:element>

                  <xsl:for-each select="marc:datafield[@tag=400]">
                    <xsl:element name="div">
                      <xsl:attribute name="class">
                        <xsl:text>authref</xsl:text>
                      </xsl:attribute>
                      <xsl:element name="span">
                        <xsl:attribute name="class">
                          <xsl:text>heading</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>

                  <xsl:for-each select="marc:datafield[@tag=550]">
                    <xsl:element name="div">
                      <xsl:attribute name="class">
                        <xsl:text>authref</xsl:text>
                      </xsl:attribute>
                      <xsl:element name="span">
                        <xsl:attribute name="class">
                          <xsl:text>heading</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:element>
              </xsl:if>
            </xsl:if>
            <!-- *** End Personal Name **-->

            <!-- *********** Corporate Name 110 ********* -->
            <xsl:if test="marc:datafield[@tag='110']">
              <xsl:element name="span">
                <xsl:attribute name="class">
                  <xsl:text>authorizedheading</xsl:text>
                </xsl:attribute>
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='110']/marc:subfield[@code='a']"/>
                </a>
              </xsl:element>


              <xsl:if test="marc:datafield[@tag='410']">
                <xsl:element name="div">
                  <xsl:attribute name="class">
                    <xsl:text>seefrom</xsl:text>
                  </xsl:attribute>
                  <xsl:element name="span">
                      used for/see from:
                  </xsl:element>

                  <xsl:for-each select="marc:datafield[@tag=410]">
                    <xsl:element name="div">
                      <xsl:attribute name="class">
                        <xsl:text>authref</xsl:text>
                      </xsl:attribute>
                      <xsl:element name="span">
                        <xsl:attribute name="class">
                          <xsl:text>heading</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:element>
              </xsl:if>

              <xsl:if test="marc:datafield[@tag='500'] or marc:datafield[@tag='550']">
                <xsl:element name="div">
                  <xsl:attribute name="class">
                    <xsl:text>seealso</xsl:text>
                  </xsl:attribute>
                  <xsl:element name="span">
                      see also:
                  </xsl:element>

                  <xsl:for-each select="marc:datafield[@tag=500]">
                    <xsl:element name="div">
                      <xsl:attribute name="class">
                        <xsl:text>authref</xsl:text>
                      </xsl:attribute>
                      <xsl:element name="span">
                        <xsl:attribute name="class">
                          <xsl:text>heading</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>

                  <xsl:for-each select="marc:datafield[@tag=550]">
                    <xsl:element name="div">
                      <xsl:attribute name="class">
                        <xsl:text>authref</xsl:text>
                      </xsl:attribute>
                      <xsl:element name="span">
                        <xsl:attribute name="class">
                          <xsl:text>heading</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>

                </xsl:element>
              </xsl:if>

            </xsl:if>
            <!-- *** End Corporate Name **-->

            <!-- *********** Meeting Name 111 ********* -->
            <xsl:if test="marc:datafield[@tag='111']">
              <xsl:element name="span">
                <xsl:attribute name="class">
                  <xsl:text>authorizedheading</xsl:text>
                </xsl:attribute>
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='111']/marc:subfield[@code='a']"/>
                </a>
              </xsl:element>

              <ul>
              <xsl:for-each select="marc:datafield[@tag=400]">
                  <li class="heading">
                    <xsl:if test="marc:subfield[@code='a']"> <xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:if>
            <!-- *** End Meeting Name **-->

            <!-- *********** Uniform Title 130 ********* -->
            <xsl:if test="marc:datafield[@tag='130']">
              <xsl:element name="span">
                <xsl:attribute name="class">
                  <xsl:text>authorizedheading</xsl:text>
                </xsl:attribute>
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='130']/marc:subfield[@code='a']"/>
                </a>
              </xsl:element>
              <ul>
              <xsl:for-each select="marc:datafield[@tag=400]">
                  <li class="heading">
                    <xsl:if test="marc:subfield[@code='a']"> <xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:if>
            <!-- *** End Uniform Title **-->

            <!-- *********** Topical Term 150 ********* -->
            <xsl:if test="marc:datafield[@tag='150']">
              <xsl:element name="span">
                <xsl:attribute name="class">
                  <xsl:text>authorizedheading</xsl:text>
                </xsl:attribute>
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='150']/marc:subfield[@code='a']"/>
                </a>
              </xsl:element>
              <ul>
              <xsl:for-each select="marc:datafield[@tag=400]">
                  <li class="heading">
                    <xsl:if test="marc:subfield[@code='a']"> <xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:if>
            <!-- *** End Topic Term **-->

            <!-- *********** Geographic Name 151 ********* -->
            <xsl:if test="marc:datafield[@tag='151']">
              <xsl:element name="span">
                <xsl:attribute name="class">
                  <xsl:text>authorizedheading</xsl:text>
                </xsl:attribute>
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='151']/marc:subfield[@code='a']"/>
                </a>
              </xsl:element>
              <ul>
              <xsl:for-each select="marc:datafield[@tag=400]">
                  <li class="heading">
                    <xsl:if test="marc:subfield[@code='a']"> <xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:if>
            <!-- *** End Geographic Name **-->

        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
