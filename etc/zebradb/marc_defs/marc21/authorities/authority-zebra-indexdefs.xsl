<?xml version="1.0" encoding="UTF-8"?>
<!--
This file has been automatically generated from a Koha index definition file
with the stylesheet koha-indexdefs-to-zebra.xsl. Do not manually edit this file,
as it may be overwritten. To regenerate, edit the appropriate Koha index
definition file (probably something like {biblio,authority}-koha-indexdefs.xml) and run:
`xsltproc koha-indexdefs-to-zebra.xsl {biblio,authority}-koha-indexdefs.xml >
{biblio,authority}-zebra-indexdefs.xsl` (substituting the appropriate file names).
-->
<xslo:stylesheet xmlns:xslo="http://www.w3.org/1999/XSL/Transform" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:z="http://indexdata.com/zebra-2.0" xmlns:kohaidx="http://www.koha-community.org/schemas/index-defs" version="1.0">
  <xslo:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
  <xslo:template match="text()"/>
  <xslo:template match="text()" mode="index_subfields"/>
  <xslo:template match="text()" mode="index_data_field"/>
  <xslo:template match="text()" mode="index_facets"/>
  <xslo:template match="text()" mode="index_heading"/>
  <xslo:template match="text()" mode="index_heading_conditional"/>
  <xslo:template match="text()" mode="index_match_heading"/>
  <xslo:template match="text()" mode="index_subject_thesaurus"/>
  <xslo:template match="/">
    <xslo:if test="marc:collection">
      <collection>
        <xslo:apply-templates select="marc:collection/marc:record"/>
      </collection>
    </xslo:if>
    <xslo:if test="marc:record">
      <xslo:apply-templates select="marc:record"/>
    </xslo:if>
  </xslo:template>
  <xslo:template match="marc:record">
    <xslo:variable name="idfield" select="normalize-space(marc:controlfield[@tag='001'])"/>
    <z:record type="update">
      <xslo:attribute name="z:id">
        <xslo:value-of select="$idfield"/>
      </xslo:attribute>
      <xslo:apply-templates/>
      <xslo:apply-templates mode="index_subfields"/>
      <xslo:apply-templates mode="index_data_field"/>
      <xslo:apply-templates mode="index_facets"/>
      <xslo:apply-templates mode="index_heading"/>
      <xslo:apply-templates mode="index_heading_conditional"/>
      <xslo:apply-templates mode="index_match_heading"/>
      <xslo:apply-templates mode="index_subject_thesaurus"/>
      <xslo:apply-templates mode="index_all"/>
    </z:record>
  </xslo:template>
  <xslo:template match="marc:leader">
    <z:index name="Record-status:w">
      <xslo:value-of select="substring(., 6, 1)"/>
    </z:index>
    <z:index name="Encoding-level:w">
      <xslo:value-of select="substring(., 18, 1)"/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='001']">
    <z:index name="Local-Number:w Local-Number:p Local-Number:n Local-Number:s">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='008']">
    <z:index name="Kind-of-record:w">
      <xslo:value-of select="substring(., 10, 1)"/>
    </z:index>
    <z:index name="Descriptive-cataloging-rules:w">
      <xslo:value-of select="substring(., 11, 1)"/>
    </z:index>
    <z:index name="Heading-use-main-or-added-entry:w">
      <xslo:value-of select="substring(., 15, 1)"/>
    </z:index>
    <z:index name="Heading-use-subject-added-entry:w">
      <xslo:value-of select="substring(., 16, 1)"/>
    </z:index>
    <z:index name="Heading-use-series-added-entry:w">
      <xslo:value-of select="substring(., 17, 1)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='010']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('az', @code)">
        <z:index name="LC-card-number:w LC-card-number:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='035']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('az', @code)">
        <z:index name="Other-control-number:w Other-control-number:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='040']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('acd', @code)">
        <z:index name="Record-source:w Record-source:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='100']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)">
        <z:index name="Personal-name:w Personal-name:p Personal-name:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='110']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)">
        <z:index name="Corporate-name:w Corporate-name:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='111']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('acdefghjklnpqstvxyz', @code)">
        <z:index name="Meeting-name:w Meeting-name:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='130']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('adfghklmnoprstvxyz', @code)">
        <z:index name="Title-uniform:w Title-uniform:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='148']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('avxyz', @code)">
        <z:index name="Chronological-term:w Chronological-term:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='150']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abvxyz', @code)">
        <z:index name="Subject-topical:w Subject-topical:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='151']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('avxyz', @code)">
        <z:index name="Name-geographic:w Name-geographic:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='155']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('avxyz', @code)">
        <z:index name="Term-genre-form:w Term-genre-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='942']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="authtype:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='100']">
    <z:index name="Personal-name-heading:w Personal-name-heading:p Personal-name-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)" name="Personal-name-heading:w Personal-name-heading:p Personal-name-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='400']">
    <z:index name="Personal-name-see-from:w Personal-name-see-from:p Personal-name-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)" name="Personal-name-see-from:w Personal-name-see-from:p Personal-name-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='500']">
    <z:index name="Personal-name-see-also-from:w Personal-name-see-also-from:p Personal-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)" name="Personal-name-see-also-from:w Personal-name-see-also-from:p Personal-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='110']">
    <z:index name="Corporate-name-heading:w Corporate-name-heading:p Corporate-name-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)" name="Corporate-name-heading:w Corporate-name-heading:p Corporate-name-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='410']">
    <z:index name="Corporate-name-see-from:w Corporate-name-see-from:p Corporate-name-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)" name="Corporate-name-see-from:w Corporate-name-see-from:p Corporate-name-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='510']">
    <z:index name="Corporate-name-see-also-from:w Corporate-name-see-also-from:p Corporate-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)" name="Corporate-name-see-also-from:w Corporate-name-see-also-from:p Corporate-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='111']">
    <z:index name="Meeting-name-heading:w Meeting-name-heading:p Meeting-name-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('acdefghjklnpqstvxyz', @code)" name="Meeting-name-heading:w Meeting-name-heading:p Meeting-name-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='411']">
    <z:index name="Meeting-name-see-from:w Meeting-name-see-from:p Meeting-name-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('acdefghjklnpqstvxyz', @code)" name="Meeting-name-see-from:w Meeting-name-see-from:p Meeting-name-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='511']">
    <z:index name="Meeting-name-see-also-from:w Meeting-name-see-also-from:p Meeting-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('acdefghjklnpqstvxyz', @code)" name="Meeting-name-see-also-from:w Meeting-name-see-also-from:p Meeting-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='130']">
    <z:index name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('adfghklmnoprstvxyz', @code)" name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='430']">
    <z:index name="Title-uniform-see-from:w Title-uniform-see-from:p Title-uniform-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('adfghklmnoprstvxyz', @code)" name="Title-uniform-see-from:w Title-uniform-see-from:p Title-uniform-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='530']">
    <z:index name="Title-uniform-see-also-from:w Title-uniform-see-also-from:p Title-uniform-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('adfghklmnoprstvxyz', @code)" name="Title-uniform-see-also-from:w Title-uniform-see-also-from:p Title-uniform-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='148']">
    <z:index name="Chronological-term-heading:w Chronological-term-heading:p Chronological-term-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Chronological-term-heading:w Chronological-term-heading:p Chronological-term-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='448']">
    <z:index name="Chronological-term-see-from:w Chronological-term-see-from:p Chronological-term-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Chronological-term-see-from:w Chronological-term-see-from:p Chronological-term-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='548']">
    <z:index name="Chronological-term-see-also-from:w Chronological-term-see-also-from:p Chronological-term-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Chronological-term-see-also-from:w Chronological-term-see-also-from:p Chronological-term-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='150']">
    <z:index name="Subject-topical-heading:w Subject-topical-heading:p Subject-topical-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abvxyz', @code)" name="Subject-topical-heading:w Subject-topical-heading:p Subject-topical-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='450']">
    <z:index name="Subject-topical-see-from:w Subject-topical-see-from:p Subject-topical-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abvxyz', @code)" name="Subject-topical-see-from:w Subject-topical-see-from:p Subject-topical-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='550']">
    <z:index name="Subject-topical-see-also-from:w Subject-topical-see-also-from:p Subject-topical-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abvxyz', @code)" name="Subject-topical-see-also-from:w Subject-topical-see-also-from:p Subject-topical-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='151']">
    <z:index name="Name-geographic-heading:w Name-geographic-heading:p Name-geographic-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Name-geographic-heading:w Name-geographic-heading:p Name-geographic-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='451']">
    <z:index name="Name-geographic-see-from:w Name-geographic-see-from:p Name-geographic-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Name-geographic-see-from:w Name-geographic-see-from:p Name-geographic-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='551']">
    <z:index name="Name-geographic-see-also-from:w Name-geographic-see-also-from:p Name-geographic-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Name-geographic-see-also-from:w Name-geographic-see-also-from:p Name-geographic-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='155']">
    <z:index name="Term-genre-form-heading:w Term-genre-form-heading:p Term-genre-form-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Term-genre-form-heading:w Term-genre-form-heading:p Term-genre-form-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
    <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('a', @code)" name="Heading-Main:w Heading-Main:p Heading-Main:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='455']">
    <z:index name="Term-genre-form-see-from:w Term-genre-form-see-from:p Term-genre-form-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Term-genre-form-see-from:w Term-genre-form-see-from:p Term-genre-form-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='555']">
    <z:index name="Term-genre-form-see-also-from:w Term-genre-form-see-also-from:p Term-genre-form-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Term-genre-form-see-also-from:w Term-genre-form-see-also-from:p Term-genre-form-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='180']">
    <z:index name="General-subdivision:w General-subdivision:p General-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="General-subdivision:w General-subdivision:p General-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='480']">
    <z:index name="General-subdivision-see-from:w General-subdivision-see-from:p General-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="General-subdivision-see-from:w General-subdivision-see-from:p General-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='580']">
    <z:index name="General-subdivision-see-also-from:w General-subdivision-see-also-from:p General-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="General-subdivision-see-also-from:w General-subdivision-see-also-from:p General-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='181']">
    <z:index name="Geographic-subdivision:w Geographic-subdivision:p Geographic-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Geographic-subdivision:w Geographic-subdivision:p Geographic-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='481']">
    <z:index name="Geographic-subdivision-see-from:w Geographic-subdivision-see-from:p Geographic-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Geographic-subdivision-see-from:w Geographic-subdivision-see-from:p Geographic-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='581']">
    <z:index name="Geographic-subdivision-see-also-from:w Geographic-subdivision-see-also-from:p Geographic-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Geographic-subdivision-see-also-from:w Geographic-subdivision-see-also-from:p Geographic-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='182']">
    <z:index name="Chronological-subdivision:w Chronological-subdivision:p Chronological-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Chronological-subdivision:w Chronological-subdivision:p Chronological-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='482']">
    <z:index name="Chronological-subdivision-see-from:w Chronological-subdivision-see-from:p Chronological-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Chronological-subdivision-see-from:w Chronological-subdivision-see-from:p Chronological-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='582']">
    <z:index name="Chronological-subdivision-see-also-from:w Chronological-subdivision-see-also-from:p Chronological-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Chronological-subdivision-see-also-from:w Chronological-subdivision-see-also-from:p Chronological-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='185']">
    <z:index name="Form-subdivision:w Form-subdivision:p Form-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Form-subdivision:w Form-subdivision:p Form-subdivision:s Subdivision:w Subdivision:p Subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='485']">
    <z:index name="Form-subdivision-see-from:w Form-subdivision-see-from:p Form-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Form-subdivision-see-from:w Form-subdivision-see-from:p Form-subdivision-see-from:s Subdivision-see-from:w Subdivision-see-from:p Subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading" match="marc:datafield[@tag='585']">
    <z:index name="Form-subdivision-see-also-from:w Form-subdivision-see-also-from:p Form-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Form-subdivision-see-also-from:w Form-subdivision-see-also-from:p Form-subdivision-see-also-from:s Subdivision-see-also-from:w Subdivision-see-also-from:p Subdivision-see-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:text>--</xslo:text>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:value-of select="."/>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_heading_conditional" match="marc:datafield[@tag='450']">
    <xslo:if test="substring(marc:subfield[@code='w']/text(), 2, 1)">
      <z:index name="Previous-heading-see-from:p">
        <xslo:variable name="raw_heading">
          <xslo:for-each select="marc:subfield">
            <xslo:if test="contains('abvxyz', @code)" name="Previous-heading-see-from:p">
              <xslo:if test="position() &gt; 1">
                <xslo:choose>
                  <xslo:when test="contains('vxyz', @code)">
                    <xslo:text>--</xslo:text>
                  </xslo:when>
                  <xslo:otherwise>
                    <xslo:value-of select="substring(' ', 1, 1)"/>
                  </xslo:otherwise>
                </xslo:choose>
              </xslo:if>
              <xslo:value-of select="."/>
            </xslo:if>
          </xslo:for-each>
        </xslo:variable>
        <xslo:value-of select="normalize-space($raw_heading)"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='100']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='400']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='500']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghjklmnopqrstvxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='110']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='410']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='510']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefghklmnoprstvxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='111']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('acdefghjklnpqstvxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='411']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('acdefghjklnpqstvxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='511']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('acdefghjklnpqstvxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='130']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('adfghklmnoprstvxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='430']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('adfghklmnoprstvxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='530']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('adfghklmnoprstvxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='148']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='448']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='548']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='150']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abvxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='450']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abvxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='550']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abvxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='151']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='451']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='551']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='155']">
    <z:index name="Match:w Match:p Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='455']">
    <z:index name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='555']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('avxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='180']">
    <z:index name="Match-subdivision:p Match-subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision:p Match-subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='480']">
    <z:index name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='181']">
    <z:index name="Match-subdivision:p Match-subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision:p Match-subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='481']">
    <z:index name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='182']">
    <z:index name="Match-subdivision:p Match-subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision:p Match-subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='482']">
    <z:index name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='485']">
    <z:index name="Match-subdivision:p Match-subdivision:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision:p Match-subdivision:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='185']">
    <z:index name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('vxyz', @code)" name="Match-subdivision-see-from:p Match-subdivision-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('vxyz', @code)">
                  <xslo:choose>
                    <xslo:when test="@code = $general_subdivision_subfield">
                      <xslo:text> generalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $form_subdivision_subfield">
                      <xslo:text> formsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $chronological_subdivision_subfield">
                      <xslo:text> chronologicalsubdiv </xslo:text>
                    </xslo:when>
                    <xslo:when test="@code = $geographic_subdivision_subfield">
                      <xslo:text> geographicsubdiv </xslo:text>
                    </xslo:when>
                  </xslo:choose>
                </xslo:when>
                <xslo:otherwise>
                  <xslo:value-of select="substring(' ', 1, 1)"/>
                </xslo:otherwise>
              </xslo:choose>
            </xslo:if>
            <xslo:call-template name="chopPunctuation">
              <xslo:with-param name="chopString">
                <xslo:value-of select="."/>
              </xslo:with-param>
            </xslo:call-template>
          </xslo:if>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:variable name="form_subdivision_subfield">v</xslo:variable>
  <xslo:variable name="general_subdivision_subfield">x</xslo:variable>
  <xslo:variable name="chronological_subdivision_subfield">y</xslo:variable>
  <xslo:variable name="geographic_subdivision_subfield">z</xslo:variable>
  <xslo:template mode="index_subject_thesaurus" match="marc:controlfield[@tag='008']">
    <xslo:variable name="thesaurus_code1" select="substring(., 12, 1)"/>
    <xslo:variable name="full_thesaurus_code">
      <xslo:choose>
        <xslo:when test="$thesaurus_code1 = 'a'">
          <xslo:text>lcsh</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'b'">
          <xslo:text>lcac</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'c'">
          <xslo:text>mesh</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'd'">
          <xslo:text>nal</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'k'">
          <xslo:text>cash</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'n'">
          <xslo:text>notapplicable</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'r'">
          <xslo:text>aat</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 's'">
          <xslo:text>sears</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'v'">
          <xslo:text>rvm</xslo:text>
        </xslo:when>
        <xslo:when test="$thesaurus_code1 = 'z'">
          <xslo:choose>
            <xslo:when test="//marc:datafield[@tag='040']/marc:subfield[@code='f']">
              <xslo:value-of select="//marc:datafield[@tag='040']/marc:subfield[@code='f']"/>
            </xslo:when>
            <xslo:otherwise>
              <xslo:text>notdefined</xslo:text>
            </xslo:otherwise>
          </xslo:choose>
        </xslo:when>
        <xslo:otherwise>
          <xslo:text>notspecified</xslo:text>
        </xslo:otherwise>
      </xslo:choose>
    </xslo:variable>
    <z:index name="Subject-heading-thesaurus:w">
      <xslo:value-of select="$full_thesaurus_code"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_all" match="text()">
    <z:index name="Any:w Any:p">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template name="chopPunctuation">
    <xslo:param name="chopString"/>
    <xslo:variable name="length" select="string-length($chopString)"/>
    <xslo:choose>
      <xslo:when test="$length=0"/>
      <xslo:when test="contains('-,.:=;!%/', substring($chopString,$length,1))">
        <xslo:call-template name="chopPunctuation">
          <xslo:with-param name="chopString" select="substring($chopString,1,$length - 1)"/>
        </xslo:call-template>
      </xslo:when>
      <xslo:when test="not($chopString)"/>
      <xslo:otherwise>
        <xslo:value-of select="$chopString"/>
      </xslo:otherwise>
    </xslo:choose>
    <xslo:text/>
  </xslo:template>
</xslo:stylesheet>
