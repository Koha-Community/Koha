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
    <z:index name="Local-Number:w Local-Number:s Local-Number:n">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='200']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdfgjxyz', @code)">
        <z:index name="Personal-name:w Personal-name:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Personal-name-heading:w Personal-name-heading:p Personal-name-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='400']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdfgjxyz', @code)">
        <z:index name="Personal-name-see:w Personal-name-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='500']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdfgjxyz', @code)">
        <z:index name="Personal-name-see-also:w Personal-name-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='700']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Personal-name-parallel:w Personal-name-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='210']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefgjxyz', @code)">
        <z:index name="Corporate-name:w Corporate-name:p Conference-name:w Conference-name:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Corporate-name-heading:w Corporate-name-heading:p Corporate-name-heading:s Conference-name-heading:w Conference-name-heading:p Conference-name-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='410']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefgjxyz', @code)">
        <z:index name="Corporate-name-see:w Corporate-name-see:p Conference-name-see:w Conference-name-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='510']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefgjxyz', @code)">
        <z:index name="Corporate-name-see-also:w Corporate-name-see-also:p Conference-name-see-also:w Conference-name-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='710']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdefgjxyz', @code)">
        <z:index name="Corporate-name-parallel:w Corporate-name-parallel:s Conference-name-parallel:w Conference-name-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='215']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Name-geographic:w Name-geographic:p Name-geographic:s Term-geographic:w Term-geographic:p Term-geographic:s Heading:w Heading:p Heading:s Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading-Main:w Heading-Main:p Heading-Main:s Name-geographic-heading:w Name-geographic-heading:p Name-geographic-heading:s Term-geographic-heading:w Term-geographic-heading:p Term-geographic-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='415']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Name-geographic-see:w Name-geographic-see:p Term-geographic-see:w Term-geographic-see:p Term-geographic-see:s See:w See:p See:s Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='515']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Name-geographic-see-also:w Name-geographic-see-also:p Term-geographic-see-also:w Term-geographic-see-also:p Term-geographic-see-also:s See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='715']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Name-geographic-parallel:w Name-geographic-parallel:s Term-geographic-parallel:w Term-geographic-parallel:s Term-geographic-parallel:p Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='216']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afcjxyz', @code)">
        <z:index name="Trademark:w Trademark:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Trademark-heading:w Trademark-heading:p Trademark-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='416']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afcjxyz', @code)">
        <z:index name="Trademark-see:w Trademark-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='516']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afcjxyz', @code)">
        <z:index name="Trademark-see-also:w Trademark-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='716']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afcjxyz', @code)">
        <z:index name="Trademark-parallel:w Trademark-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='220']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afjxyz', @code)">
        <z:index name="Name:w Name:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Name-heading:w Name-heading:p Name-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='420']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afjxyz', @code)">
        <z:index name="Name-see:w Name-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='520']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afjxyz', @code)">
        <z:index name="Name-see-also:w Name-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='720']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('afjxyz', @code)">
        <z:index name="Name-parallel:w Name-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='230']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)">
        <z:index name="Title-uniform:w Title-uniform:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='430']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)">
        <z:index name="Title-uniform-see:w Title-uniform-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='530']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abhiklmnqrsuwjxyz', @code)">
        <z:index name="Title-uniform-see-also:w Title-uniform-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='730']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-uniform-parallel:w Title-uniform-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='235']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abekmrsuwjxyz', @code)">
        <z:index name="Title-uniform:w Title-uniform:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='435']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abekmrsuwjxyz', @code)">
        <z:index name="Title-uniform-see:w Title-uniform-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='535']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abekmrsuwjxyz', @code)">
        <z:index name="Title-uniform-see-also:w Title-uniform-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='735']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-uniform-parallel:w Title-uniform-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='240']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Name-Title:w Name-Title:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Name-Title-heading:w Name-Title-heading:p Name-Title-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='440']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Name-Title-see:w Name-Title-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='540']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Name-Title-see-also:w Name-Title-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='740']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-Title-parallel:w Name-Title-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='245']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Title-uniform:w Title-uniform:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='445']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Title-uniform-see:w Title-uniform-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='545']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('atjxyz', @code)">
        <z:index name="Title-uniform-see-also:w Title-uniform-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='745']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-uniform-parallel:w Title-uniform-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='250']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Subject:w Subject:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p Subject-heading:w Subject-heading:p Subject-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='450']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Subject-see:w Subject-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='550']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Subject-see-also:w Subject-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='750']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Subject-parallel:w Subject-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='260']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdjxyz', @code)">
        <z:index name="Place:w Place:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p Place-heading:w Place-heading:p Place-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='460']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdjxyz', @code)">
        <z:index name="Place-see:w Place-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='560']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('abcdjxyz', @code)">
        <z:index name="Place-see-also:w Place-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='760']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Place-parallel:w Place-parallel:s Parallel:w Parallel:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='280']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Form:w Form:p Heading:w Heading:p Match:w Match:p Match-heading:w Match-heading:p Form-heading:w Form-heading:p Form-heading:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='480']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Form-see:w Form-see:p See:w See:p Match:w Match:p Match-heading-see-form:w Match-heading-see-form:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='580']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('ajxyz', @code)">
        <z:index name="Form-see-also:w Form-see-also:p See-also:w See-also:p Match:w Match:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='780']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Form-parallel:w Form-parallel:s Parallel:w Parallel:p Match:w Match:p">
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
