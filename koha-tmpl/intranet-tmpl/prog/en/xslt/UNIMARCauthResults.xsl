<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output omit-xml-declaration="yes"/>
  <!-- ***************** Templates *************-->
  <xsl:template name="tag_152">
    <li class="authtype">
      <xsl:value-of select="marc:datafield[@tag='152']/marc:subfield[@code='b']"/>
    </li>
  </xsl:template>
  <xsl:template name="tag_3xx">
    <li class="note">
      <xsl:for-each select="marc:datafield[@tag &gt;= 300 and @tag &lt; 400]">
        <xsl:value-of select="marc:subfield[@code='a']"/>
        <xsl:text>. </xsl:text>
      </xsl:for-each>
    </li>
  </xsl:template>
  <xsl:template name="tag_5xx">
    <li class="related">
      <xsl:for-each select="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='5']='g'">
            <span class="leg">GT : </span>
          </xsl:when>
          <xsl:when test="marc:subfield[@code='5']='h'">
            <span class="leg">ST : </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="leg">RT : </span>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='9']">
            <a>
              <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="marc:subfield[@code='9']"/></xsl:attribute>
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
            </a>
          </xsl:when>
          <xsl:when test="marc:subfield[@code='3']">
            <a>
              <xsl:attribute name="href">/cgi-bin/koha/authorities/authorities-home.pl?op=do_search&amp;type=intranet&amp;value=identifier-standard%3A<xsl:value-of select="marc:subfield[@code='3']"/></xsl:attribute>
              <xsl:value-of select="marc:subfield[@code='a']"/>
              <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="marc:subfield[@code='a']"/>
            <xsl:if test="marc:subfield[@code='b']">
              <xsl:text> </xsl:text>
              <xsl:value-of select="."/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> ; </xsl:text>
      </xsl:for-each>
    </li>
  </xsl:template>
  <!--*** End Templates **-->
  <!-- ****************** Authority display *************** -->
  <xsl:template match="marc:record">
    <xsl:variable name="authid" select="marc:controlfield[@tag='001']"/>
    <div class="authority-summary">
      <!-- *********** Personal Name 200 ********* -->
      <xsl:if test="marc:datafield[@tag='200']">
        <ul>
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=200]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=400]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=210]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=410]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=215]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=415]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=216]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=416]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=220]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=420]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=230]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=430]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=240]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='t']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=440]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="marc:subfield[@code='b']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=250]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=450]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
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
          <xsl:call-template name="tag_152"/>
          <xsl:for-each select="marc:datafield[@tag=280]">
            <li class="heading">
              <a>
                <xsl:attribute name="href">/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="$authid"/></xsl:attribute>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </a>
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
            <li class="usefor">
              <span class="leg">UF : </span>
              <xsl:for-each select="marc:datafield[@tag=450]">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text> ; </xsl:text>
              </xsl:for-each>
            </li>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag &gt;= 500 and @tag &lt; 600]">
            <xsl:call-template name="tag_5xx"/>
          </xsl:if>
        </ul>
      </xsl:if>
      <!-- *** End Subject **-->
    </div> <!-- /div.authority-summary -->
    <!-- end template -->
  </xsl:template>
</xsl:stylesheet>
