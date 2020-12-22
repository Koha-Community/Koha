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
  <xslo:template match="marc:controlfield[@tag='001']">
    <z:index name="Local-Number:w Local-Number:p Local-Number:n Local-Number:s">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='200']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdfgjxyz', @code)">
        <z:index name="Personal-name:w Personal-name:p Personal-name:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='210']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefgjxyz', @code)">
        <z:index name="Corporate-name:w Corporate-name:p Corporate-name:s Conference-name:w Conference-name:p Conference-name:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='215']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Name-geographic:w Name-geographic:p Name-geographic:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='216']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afcjxyz', @code)">
        <z:index name="Trademark:w Trademark:p Trademark:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='220']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afjxyz', @code)">
        <z:index name="Name:w Name:p Name:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='230']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)">
        <z:index name="Title-uniform:w Title-uniform:p Title-uniform:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='235']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abekmrsuwjxyz', @code)">
        <z:index name="Title-uniform:w Title-uniform:p Title-uniform:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='240']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Name-Title:w Name-Title:p Name-Title:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='250']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Subject-topical:w Subject-topical:p Subject-topical:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='260']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdjxyz', @code)">
        <z:index name="Place:w Place:p Place:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='280']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Form:w Form:p Form:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='300']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='305']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='310']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='320']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='330']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='340']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='356']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='152']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="authtype:w authtype:p">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='200']">
    <z:index name="Personal-name-heading:w Personal-name-heading:p Personal-name-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Personal-name-heading:w Personal-name-heading:p Personal-name-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Personal-name-see-from:w Personal-name-see-from:p Personal-name-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Personal-name-see-also-from:w Personal-name-see-also-from:p Personal-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='700']">
    <z:index name="Personal-name-parallel:w Personal-name-parallel:p Personal-name-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Personal-name-parallel:w Personal-name-parallel:p Personal-name-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='210']">
    <z:index name="Corporate-name-heading:w Corporate-name-heading:p Corporate-name-heading:s Conference-name-heading:w Conference-name-heading:p Conference-name-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Corporate-name-heading:w Corporate-name-heading:p Corporate-name-heading:s Conference-name-heading:w Conference-name-heading:p Conference-name-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Corporate-name-see-from:w Corporate-name-see-from:p Corporate-name-see-from:s Conference-name-see-from:w Conference-name-see-from:p Conference-name-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Corporate-name-see-from:w Corporate-name-see-from:p Corporate-name-see-from:s Conference-name-see-from:w Conference-name-see-from:p Conference-name-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Corporate-name-see-also-from:w Corporate-name-see-also-from:p Corporate-name-see-also-from:s Conference-name-see-also-from:w Conference-name-see-also-from:p Conference-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Corporate-name-see-also-from:w Corporate-name-see-also-from:p Corporate-name-see-also-from:s Conference-name-see-also-from:w Conference-name-see-also-from:p Conference-name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='710']">
    <z:index name="Corporate-name-parallel:w Corporate-name-parallel:p Corporate-name-parallel:s Conference-name-parallel:w Conference-name-parallel:p Conference-name-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Corporate-name-parallel:w Corporate-name-parallel:p Corporate-name-parallel:s Conference-name-parallel:w Conference-name-parallel:p Conference-name-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='215']">
    <z:index name="Name-geographic-heading:w Name-geographic-heading:p Name-geographic-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Name-geographic-heading:w Name-geographic-heading:p Name-geographic-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='415']">
    <z:index name="Name-geographic-see-from:w Name-geographic-see-from:p Name-geographic-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Name-geographic-see-from:w Name-geographic-see-from:p Name-geographic-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='515']">
    <z:index name="Name-geographic-see-also-from:w Name-geographic-see-also-from:p Name-geographic-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Name-geographic-see-also-from:w Name-geographic-see-also-from:p Name-geographic-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='715']">
    <z:index name="Name-geographic-parallel:w Name-geographic-parallel:p Name-geographic-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Name-geographic-parallel:w Name-geographic-parallel:p Name-geographic-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='216']">
    <z:index name="Trademark-heading:w Trademark-heading:p Trademark-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Trademark-heading:w Trademark-heading:p Trademark-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='416']">
    <z:index name="Trademark-see-from:w Trademark-see-from:p Trademark-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Trademark-see-from:w Trademark-see-from:p Trademark-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='516']">
    <z:index name="Trademark-see-also-from:w Trademark-see-also-from:p Trademark-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Trademark-see-also-from:w Trademark-see-also-from:p Trademark-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='716']">
    <z:index name="Trademark-parallel:w Trademark-parallel:p Trademark-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Trademark-parallel:w Trademark-parallel:p Trademark-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='220']">
    <z:index name="Name-heading:w Name-heading:p Name-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Name-heading:w Name-heading:p Name-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='420']">
    <z:index name="Name-see-from:w Name-see-from:p Name-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Name-see-from:w Name-see-from:p Name-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='520']">
    <z:index name="Name-see-also-from:w Name-see-also-from:p Name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Name-see-also-from:w Name-see-also-from:p Name-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='720']">
    <z:index name="Name-parallel:w Name-parallel:p Name-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Name-parallel:w Name-parallel:p Name-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='230']">
    <z:index name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Title-uniform-see-from:w Title-uniform-see-from:p Title-uniform-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Title-uniform-see-also-from:w Title-uniform-see-also-from:p Title-uniform-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='730']">
    <z:index name="Title-uniform-parallel:w Title-uniform-parallel:p Title-uniform-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Title-uniform-parallel:w Title-uniform-parallel:p Title-uniform-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='235']">
    <z:index name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='435']">
    <z:index name="Title-uniform-see-from:w Title-uniform-see-from:p Title-uniform-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Title-uniform-see-from:w Title-uniform-see-from:p Title-uniform-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='535']">
    <z:index name="Title-uniform-see-also-from:w Title-uniform-see-also-from:p Title-uniform-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Title-uniform-see-also-from:w Title-uniform-see-also-from:p Title-uniform-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='735']">
    <z:index name="Title-uniform-parallel:w Title-uniform-parallel:p Title-uniform-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Title-uniform-parallel:w Title-uniform-parallel:p Title-uniform-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='240']">
    <z:index name="Name-Title-heading:w Name-Title-heading:p Name-Title-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Name-Title-heading:w Name-Title-heading:p Name-Title-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='440']">
    <z:index name="Name-Title-see-from:w Name-Title-see-from:p Name-Title-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Name-Title-see-from:w Name-Title-see-from:p Name-Title-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='540']">
    <z:index name="Name-Title-see-also-from:w Name-Title-see-also-from:p Name-Title-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Name-Title-see-also-from:w Name-Title-see-also-from:p Name-Title-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='740']">
    <z:index name="Name-Title-parallel:w Name-Title-parallel:p Name-Title-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Name-Title-parallel:w Name-Title-parallel:p Name-Title-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='250']">
    <z:index name="Subject-topical-heading:w Subject-topical-heading:p Subject-topical-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Subject-topical-heading:w Subject-topical-heading:p Subject-topical-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('ajxyz', @code)" name="Subject-topical-see-from:w Subject-topical-see-from:p Subject-topical-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('ajxyz', @code)" name="Subject-topical-see-also-from:w Subject-topical-see-also-from:p Subject-topical-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='750']">
    <z:index name="Subject-topical-parallel:w Subject-topical-parallel:p Subject-topical-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Subject-topical-parallel:w Subject-topical-parallel:p Subject-topical-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='260']">
    <z:index name="Place-heading:w Place-heading:p Place-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Place-heading:w Place-heading:p Place-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='460']">
    <z:index name="Place-see-from:w Place-see-from:p Place-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Place-see-from:w Place-see-from:p Place-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='560']">
    <z:index name="Place-see-also-from:w Place-see-also-from:p Place-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Place-see-also-from:w Place-see-also-from:p Place-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='760']">
    <z:index name="Place-parallel:w Place-parallel:p Place-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Place-parallel:w Place-parallel:p Place-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='280']">
    <z:index name="Form-heading:w Form-heading:p Form-heading:s Heading:w Heading:p Heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Form-heading:w Form-heading:p Form-heading:s Heading:w Heading:p Heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='480']">
    <z:index name="Form-see-from:w Form-see-from:p Form-see-from:s See-from:w See-from:p See-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Form-see-from:w Form-see-from:p Form-see-from:s See-from:w See-from:p See-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Form-see-also-from:w Form-see-also-from:p Form-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Form-see-also-from:w Form-see-also-from:p Form-see-also-from:s See-also-from:w See-also-from:p See-also-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_heading" match="marc:datafield[@tag='780']">
    <z:index name="Form-parallel:w Form-parallel:p Form-parallel:s Parallel:w Parallel:p Parallel:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Form-parallel:w Form-parallel:p Form-parallel:s Parallel:w Parallel:p Parallel:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='200']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='700']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdfgjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='210']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='710']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='215']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='415']">
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='515']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='715']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdefgjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='216']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='416']">
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='516']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='716']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afcjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='220']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='420']">
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='520']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='720']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('afjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='230']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='730']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='235']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='435']">
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='535']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='735']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abekmrsuwjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='240']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='440']">
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='540']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='740']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('atjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='250']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='750']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='260']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='460']">
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='560']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='760']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('abcdjxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='280']">
    <z:index name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p Match-heading:w Match-heading:p Match-heading:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
    <z:index name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p Match-heading-see-from:w Match-heading-see-from:p Match-heading-see-from:s">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='580']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:template mode="index_match_heading" match="marc:datafield[@tag='780']">
    <z:index name="Match:w Match:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="contains('ajxyz', @code)" name="Match:w Match:p">
            <xslo:if test="position() &gt; 1">
              <xslo:choose>
                <xslo:when test="contains('jxyz', @code)">
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
  <xslo:variable name="form_subdivision_subfield">j</xslo:variable>
  <xslo:variable name="general_subdivision_subfield">x</xslo:variable>
  <xslo:variable name="geographic_subdivision_subfield">y</xslo:variable>
  <xslo:variable name="chronological_subdivision_subfield">z</xslo:variable>
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
