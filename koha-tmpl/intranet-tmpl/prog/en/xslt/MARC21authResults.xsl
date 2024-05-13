<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes"/>
    <!-- ************* Templates ****************-->


    <!-- ****************************************-->

    <xsl:template match="marc:record">
        <xsl:variable name="authid" select="marc:controlfield[@tag='001']" />
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>

        <div class="authority-summary">
            <!-- *********** Personal Name 100 ********* -->
            <xsl:if test="marc:datafield[@tag='100']">
              <span class="authorizedheading">
                <a>
                  <xsl:attribute name="data-authid"><xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='100']/marc:subfield[@code='a']"/>
                </a>
              </span>

              <xsl:if test="marc:datafield[@tag='400']">
                <div class="seefrom">
                  <span>used for/see from:</span>
                  <xsl:for-each select="marc:datafield[@tag=400]">
                    <div class="authref">
                      <span class="heading">
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </span>
                    </div>
                  </xsl:for-each>
                </div> <!-- /div.seefrom -->
              </xsl:if>

              <xsl:if test="marc:datafield[@tag='500'] or marc:datafield[@tag='550']">
                <div class="seealso">
                  <span>see also:</span>
                  <xsl:for-each select="marc:datafield[@tag=400]">
                    <div class="authref">
                      <span class="heading">
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </span>
                    </div>
                  </xsl:for-each>

                  <xsl:for-each select="marc:datafield[@tag=550]">
                    <div class="authref">
                      <span class="heading">
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </span>
                    </div>
                  </xsl:for-each>
                </div> <!-- /div.seealso -->
              </xsl:if> <!-- test="marc:datafield[@tag='500'] or marc:datafield[@tag='550']" -->
            </xsl:if> <!-- test="marc:datafield[@tag='100']" -->
            <!-- *** End Personal Name **-->

            <!-- *********** Corporate Name 110 ********* -->
            <xsl:if test="marc:datafield[@tag='110']">
              <span class="authorizedheading">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='110']/marc:subfield[@code='a']"/>
                </a>
              </span>

              <xsl:if test="marc:datafield[@tag='410']">
                <div class="seefrom">
                  <span>used for/see from:</span>

                  <xsl:for-each select="marc:datafield[@tag=410]">
                    <div class="authref">
                      <span class="heading">
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </span>
                    </div>
                  </xsl:for-each>
                </div>
              </xsl:if>

              <xsl:if test="marc:datafield[@tag='500'] or marc:datafield[@tag='550']">
                <div class="seealso">
                  <span>see also:</span>

                  <xsl:for-each select="marc:datafield[@tag=500]">
                    <div class="authref">
                      <span class="heading">
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </span>
                    </div>
                  </xsl:for-each>

                  <xsl:for-each select="marc:datafield[@tag=550]">
                    <div class="authref">
                      <span class="heading">
                        <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                        <xsl:if test="marc:subfield[@code='b']"><xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
                      </span>
                    </div>
                  </xsl:for-each>
                </div>
              </xsl:if> <!-- test="marc:datafield[@tag='500'] or marc:datafield[@tag='550']" -->
            </xsl:if> <!-- test="marc:datafield[@tag='110']" -->
            <!-- *** End Corporate Name **-->

            <!-- *********** Meeting Name 111 ********* -->
            <xsl:if test="marc:datafield[@tag='111']">
              <span class="authorizedheading">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='111']/marc:subfield[@code='a']"/>
                </a>
              </span>

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
              <span class="authorizedheading">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='130']/marc:subfield[@code='a']"/>
                </a>
              </span>
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
              <span class="authorizedheading">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='150']/marc:subfield[@code='a']"/>
                </a>
              </span>
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
              <span class="authorizedheading">
                <a>
                  <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                  <xsl:value-of select="marc:datafield[@tag='151']/marc:subfield[@code='a']"/>
                </a>
              </span>
              <ul>
              <xsl:for-each select="marc:datafield[@tag=400]">
                  <li class="heading">
                    <xsl:if test="marc:subfield[@code='a']"> <xsl:value-of select="marc:subfield[@code='a']"/> </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:if>
            <!-- *** End Geographic Name **-->
        </div> <!-- /.authority-summary -->
    </xsl:template>
</xsl:stylesheet>
