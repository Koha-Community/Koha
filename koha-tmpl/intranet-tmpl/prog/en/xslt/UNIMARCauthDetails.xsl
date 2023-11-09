<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="UNIMARCauthUtils.xsl"/>
  <xsl:output omit-xml-declaration="yes" method="html" />
  <!-- ****************** Authority display *************** -->
  <xsl:template match="marc:record">
    <xsl:variable name="authid" select="marc:controlfield[@tag='001']"/>
    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:text>authority-summary</xsl:text>
      </xsl:attribute>
      <!-- *********** Personal Name 200 ********* -->
      <xsl:if test="marc:datafield[@tag='200']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=200]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="marc:subfield[@code='b']"/>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>) </xsl:if>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=400]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">400</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Personal Name **-->
      <!-- *********** Corporate Name 210 ********* -->
      <xsl:if test="marc:datafield[@tag='210']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=210]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="marc:subfield[@code='b']"/>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>) </xsl:if>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=410]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">410</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Corporate Name **-->
      <!-- *********** Geographic Name 215 ********* -->
      <xsl:if test="marc:datafield[@tag='215']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=215]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=415]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">415</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Geographic Name **-->
      <!-- *********** Trademark 216 ********* -->
      <xsl:if test="marc:datafield[@tag='216']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=216]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>) </xsl:if>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=416]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">416</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Trademark **-->
      <!-- *********** Family Name 220 ********* -->
      <xsl:if test="marc:datafield[@tag='220']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=220]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>) </xsl:if>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=420]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">420</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Family Name **-->
      <!-- *********** Uniform Title 230 ********* -->
      <xsl:if test="marc:datafield[@tag='230']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=230]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> [</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>]</xsl:text>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='h']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='i']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=430]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">430</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Uniform Title **-->
      <!-- *********** Author Title 240 ********* -->
      <xsl:if test="marc:datafield[@tag='240']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=240]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="marc:subfield[@code='t']"/>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=440]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">440</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Author Title **-->
      <!-- *********** Subject 250 ********* -->
      <xsl:if test="marc:datafield[@tag='250']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=250]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=450]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">450</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Subject **-->
      <!-- *********** Genre/Form 280 ********* -->
      <xsl:if test="marc:datafield[@tag='280']">
        <ul>
          <xsl:for-each select="marc:datafield[@tag=280]">
            <li class="heading">
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='j'] or marc:subfield[@code='x'] or marc:subfield[@code='y'] or marc:subfield[@code='z']">
                <xsl:for-each select="marc:subfield[@code='j']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='x']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='y']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='z']">
                  <xsl:text> -- </xsl:text>
                  <xsl:value-of select="."/>
                </xsl:for-each>
              </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:if test="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
            <xsl:call-template name="tag_3xx"/>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag=480]">
            <xsl:call-template name="tag_4xx">
              <xsl:with-param name="tag">480</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Genre/Form **-->
      <!-- end div class authority-summary-->
    </xsl:element>
    <!-- end template -->
  </xsl:template>
</xsl:stylesheet>
