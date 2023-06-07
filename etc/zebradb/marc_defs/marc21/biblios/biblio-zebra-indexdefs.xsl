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
  <xslo:template match="text()" mode="index_sort_title"/>
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
    <xslo:variable name="idfield" select="normalize-space(marc:datafield[@tag='999']/marc:subfield[@code='c'])"/>
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
      <xslo:apply-templates mode="index_sort_title"/>
    </z:record>
  </xslo:template>
  <xslo:template match="marc:leader">
    <z:index name="llength:w">
      <xslo:value-of select="substring(., 1, 5)"/>
    </z:index>
    <z:index name="rtype:w">
      <xslo:value-of select="substring(., 7, 1)"/>
    </z:index>
    <z:index name="Bib-level:w">
      <xslo:value-of select="substring(., 8, 1)"/>
    </z:index>
    <z:index name="Multipart-resource-level:w">
      <xslo:value-of select="substring(., 20, 1)"/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='001']">
    <z:index name="Control-number:w">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='003']">
    <z:index name="Control-number-identifier:w">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='005']">
    <z:index name="Date/time-last-modified:w">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='007']">
    <z:index name="Microform-generation:n">
      <xslo:value-of select="substring(., 12, 1)"/>
    </z:index>
    <z:index name="Material-type:w">
      <xslo:value-of select="."/>
    </z:index>
    <z:index name="ff7-00:w">
      <xslo:value-of select="substring(., 1, 1)"/>
    </z:index>
    <z:index name="ff7-01:w">
      <xslo:value-of select="substring(., 2, 1)"/>
    </z:index>
    <z:index name="ff7-02:w">
      <xslo:value-of select="substring(., 3, 1)"/>
    </z:index>
    <z:index name="ff7-01-02:w">
      <xslo:value-of select="substring(., 1, 2)"/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='008']">
    <z:index name="date-entered-on-file:n">
      <xslo:value-of select="substring(., 1, 6)"/>
    </z:index>
    <z:index name="date-entered-on-file:s">
      <xslo:value-of select="substring(., 1, 6)"/>
    </z:index>
    <z:index name="pubdate:w">
      <xslo:value-of select="substring(., 8, 4)"/>
    </z:index>
    <z:index name="pubdate:n">
      <xslo:value-of select="substring(., 8, 4)"/>
    </z:index>
    <z:index name="pubdate:y">
      <xslo:value-of select="substring(., 8, 4)"/>
    </z:index>
    <z:index name="pubdate:s">
      <xslo:value-of select="substring(., 8, 4)"/>
    </z:index>
    <z:index name="pl:w">
      <xslo:value-of select="substring(., 16, 3)"/>
    </z:index>
    <z:index name="ta:w">
      <xslo:value-of select="substring(., 23, 1)"/>
    </z:index>
    <z:index name="ff8-23:w">
      <xslo:value-of select="substring(., 24, 1)"/>
    </z:index>
    <z:index name="ff8-29:w">
      <xslo:value-of select="substring(., 30, 1)"/>
    </z:index>
    <z:index name="lf:w">
      <xslo:value-of select="substring(., 34, 1)"/>
    </z:index>
    <z:index name="bio:w">
      <xslo:value-of select="substring(., 35, 1)"/>
    </z:index>
    <z:index name="ln:w">
      <xslo:value-of select="substring(., 36, 3)"/>
    </z:index>
    <z:index name="ctype:w">
      <xslo:value-of select="substring(., 25, 4)"/>
    </z:index>
    <z:index name="Record-source:w">
      <xslo:value-of select="substring(., 40, 0)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='020']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="ISBN:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('z', @code)">
        <z:index name="ISBN:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='022']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="ISSN:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('y', @code)">
        <z:index name="ISSN:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('z', @code)">
        <z:index name="ISSN:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='024']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Identifier-other:w Identifier-other:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:if test="marc:subfield[@code='2' and text()='uri']">
      <xslo:for-each select="marc:subfield">
        <xslo:if test="contains('a', @code)">
          <z:index name="Identifier-other:u">
            <xslo:value-of select="."/>
          </z:index>
        </xslo:if>
      </xslo:for-each>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='041']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="ln:w ln-audio:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="ln:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('e', @code)">
        <z:index name="ln:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('h', @code)">
        <z:index name="language-original:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('j', @code)">
        <z:index name="ln:w ln-subtitle:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='050']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="LC-call-number:w LC-call-number:p LC-call-number:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='100']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Cross-Reference:w Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Author:w Author:p Author:s Editor:w Author-personal-bibliography:w Author-personal-bibliography:p Author-personal-bibliography:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='110']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='111']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='130']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Thematic-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Music-key:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='240']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Music-key:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Thematic-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='243']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Thematic-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Music-key:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='245']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-cover:w Title-cover:p Title-cover:s Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="Author:w Author-in-order:w Author-in-order:p Author-in-order:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Cross-Reference:w Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='260']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="pl:w pl:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="Publisher:w Publisher:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="copydate:w copydate:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='264']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="pl:w pl:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="Publisher:w Publisher:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="copydate:w copydate:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='400']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Name-and-title:w Title:w Title-series:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='410']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Title:w Title-series:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='411']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Title-series:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='440']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='490']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='505']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Author:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='521']">
    <xslo:if test="@ind1='0'">
      <xslo:for-each select="marc:subfield">
        <xslo:if test="contains('a', @code)">
          <z:index name="Reading-grade-level:w Reading-grade-level:p Reading-grade-level:n">
            <xslo:value-of select="."/>
          </z:index>
        </xslo:if>
      </xslo:for-each>
    </xslo:if>
    <xslo:if test="@ind1='1'">
      <xslo:for-each select="marc:subfield">
        <xslo:if test="contains('a', @code)">
          <z:index name="Interest-age-level:w Interest-age-level:p Interest-age-level:n">
            <xslo:value-of select="."/>
          </z:index>
        </xslo:if>
      </xslo:for-each>
    </xslo:if>
    <xslo:if test="@ind1='2'">
      <xslo:for-each select="marc:subfield">
        <xslo:if test="contains('a', @code)">
          <z:index name="Interest-grade-level:w Interest-grade-level:p Interest-grade-level:n">
            <xslo:value-of select="."/>
          </z:index>
        </xslo:if>
      </xslo:for-each>
    </xslo:if>
    <xslo:if test="@ind1='8'">
      <xslo:for-each select="marc:subfield">
        <xslo:if test="contains('a', @code)">
          <z:index name="lexile-number:w lexile-number:p lexile-number:n">
            <xslo:value-of select="."/>
          </z:index>
        </xslo:if>
      </xslo:for-each>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='526']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="arl:w arl:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="arp:w arp:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='600']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w Name:w Personal-name:w Subject-name-personal:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Name-and-title:w Title:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='610']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Name-and-title:w Title:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='611']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Name-and-title:w Title:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='630']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Thematic-number:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Music-key:w Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='648']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='650']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='651']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='652']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='653']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Index-term-uncontrolled:w Index-term-uncontrolled:p Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='654']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='655']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('axvyz', @code)">
        <z:index name="Index-term-genre:w Index-term-genre:p Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='656']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='657']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='658']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="curriculum:w curriculum:p Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="curriculum:w curriculum:p Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="curriculum:w curriculum:p Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='662']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='690']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='691']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='696']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='697']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='698']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='699']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='700']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Cross-Reference:w Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Author:w Author:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Thematic-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Music-key:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Name-and-title:w Title:w Title-uniform:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='710']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Name-and-title:w Title:w Title-uniform:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='711']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Title:w Title-uniform:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='730']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Thematic-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="Music-key:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='751']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-geographic:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='770']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='772']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='773']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Host-item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Host-Item-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Host-item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='774']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='775']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='776']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='777']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='780']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='785']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='787']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='796']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='797']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='798']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='799']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='800']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Name-and-title:w Title:w Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='810']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Name-and-title:w Title:w Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='811']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Name-and-title:w Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Author-title:w Name-and-title:w Title:w Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='830']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="Record-control-number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='896']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='897']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='898']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='899']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='999']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="Local-Number:n Local-Number:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="Local-Number:s">
          <xslo:value-of select="format-number(.,&quot;00000000000&quot;)"/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="biblioitemnumber:n biblioitemnumber:w biblioitemnumber:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('x', @code)">
        <z:index name="not-onloan-count:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='942']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('0', @code)">
        <z:index name="totalissues:n totalissues:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('2', @code)">
        <z:index name="cn-bib-source:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('6', @code)">
        <z:index name="cn-bib-sort:n cn-bib-sort:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="itemtype:w itemtype:p itype:w itype:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="Suppress:w Suppress:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('h', @code)">
        <z:index name="cn-class:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('i', @code)">
        <z:index name="cn-item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('k', @code)">
        <z:index name="cn-prefix:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('m', @code)">
        <z:index name="cn-suffix:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='952']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('0', @code)">
        <z:index name="withdrawn:n withdrawn:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('1', @code)">
        <z:index name="lost:w lost:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('2', @code)">
        <z:index name="classification-source:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('3', @code)">
        <z:index name="materials-specified:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('4', @code)">
        <z:index name="damaged:n damaged:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('5', @code)">
        <z:index name="restricted:n restricted:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('6', @code)">
        <z:index name="cn-sort:n cn-sort:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('7', @code)">
        <z:index name="notforloan:n notforloan:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('8', @code)">
        <z:index name="ccode:w ccode:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="itemnumber:n itemnumber:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="homebranch:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="holdingbranch:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="location:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="Date-of-acquisition:w Date-of-acquisition:d Date-of-acquisition:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('e', @code)">
        <z:index name="acqsource:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('f', @code)">
        <z:index name="coded-location-qualifier:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('g', @code)">
        <z:index name="price:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('i', @code)">
        <z:index name="Number-local-acquisition:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('j', @code)">
        <z:index name="stack:n stack:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('l', @code)">
        <z:index name="issues:n issues:w issues:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('m', @code)">
        <z:index name="renewals:n renewals:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="reserves:n reserves:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('o', @code)">
        <z:index name="Local-classification:w Local-classification:p Local-classification:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('p', @code)">
        <z:index name="barcode:w barcode:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('q', @code)">
        <z:index name="onloan:n onloan:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="datelastseen:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('s', @code)">
        <z:index name="datelastborrowed:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="copynumber:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('u', @code)">
        <z:index name="uri:u">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('v', @code)">
        <z:index name="replacementprice:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('w', @code)">
        <z:index name="replacementpricedate:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('y', @code)">
        <z:index name="itype:w itype:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('z', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='010']">
    <z:index name="LC-card-number:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='011']">
    <z:index name="LC-card-number:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='015']">
    <z:index name="BNB-card-number:w BGF-number:w Number-db:w Number-natl-biblio:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='017']">
    <z:index name="Number-legal-deposit:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='018']">
    <z:index name="Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='020']">
    <z:index name="Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='022']">
    <z:index name="Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='023']">
    <z:index name="Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='024']">
    <z:index name="Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='025']">
    <z:index name="Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='027']">
    <z:index name="Report-number:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='028']">
    <z:index name="Identifier-publisher-for-music:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='030']">
    <z:index name="CODEN:w Identifier-standard:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='034']">
    <z:index name="Map-scale:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='035']">
    <z:index name="Other-control-number:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='037']">
    <z:index name="Identifier-standard:w Stock-number:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='040']">
    <z:index name="Code-institution:w Record-source:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='043']">
    <z:index name="Code-geographic:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='050']">
    <z:index name="LC-call-number:w LC-call-number:p LC-call-number:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='052']">
    <z:index name="Geographic-class:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='060']">
    <z:index name="NLM-call-number:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='070']">
    <z:index name="NAL-call-number:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='080']">
    <z:index name="UDC-classification:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='082']">
    <z:index name="Dewey-classification:w Dewey-classification:s">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='086']">
    <z:index name="Number-govt-pub:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='100']">
    <z:index name="Author:w Author:p Author:s Author-title:w Author-name-personal:w Name:w Name-and-title:w Personal-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='110']">
    <z:index name="Author:w Author:p Author:s Author-title:w Author-name-corporate:w Name:w Name-and-title:w Corporate-name:w Corporate-name:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='111']">
    <z:index name="Author:w Author:p Author:s Author-title:w Author-name-corporate:w Name:w Name-and-title:w Conference-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='130']">
    <z:index name="Title:w Title:p Title-uniform:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='210']">
    <z:index name="Title:w Title:p Title-abbreviated:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='211']">
    <z:index name="Title:w Title:p Title-abbreviated:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='212']">
    <z:index name="Title:w Title:p Title-other-variant:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='214']">
    <z:index name="Title:w Title:p Title-expanded:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='222']">
    <z:index name="Title:w Title:p Title-key:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='240']">
    <z:index name="Title:w Title:p Title-uniform:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='243']">
    <z:index name="Title:w Title:p Title-collective:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='245']">
    <z:index name="Title:w Title:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='246']">
    <z:index name="Title:w Title:p Title-abbreviated:w Title-expanded:w Title-former:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='247']">
    <z:index name="Title:w Title:p Title-former:w Title-other-variant:w Related-periodical:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='260']">
    <z:index name="pl:w Provider:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='264']">
    <z:index name="pl:w Provider:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='300']">
    <z:index name="Extent:w Extent:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='400']">
    <z:index name="Author:w Author-name-personal:w Name:w Personal-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='410']">
    <z:index name="Author:w Corporate-name:w Corporate-name:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='411']">
    <z:index name="Author:w Conference-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='440']">
    <z:index name="Title-series:w Title-series:p Title:w Title-series:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='490']">
    <z:index name="Title:w Title-series:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='500']">
    <z:index name="Note:w Note:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='502']">
    <z:index name="Material-type:w Dissertation-information:p Dissertation-information:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='505']">
    <z:index name="Note:w Note:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='510']">
    <z:index name="Indexed-by:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='520']">
    <z:index name="Abstract:w Abstract:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='590']">
    <z:index name="Note:w Note:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='600']">
    <z:index name="Name:w Personal-name:w Subject-name-personal:w Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='610']">
    <z:index name="Name:w Subject:w Subject:p Corporate-name:w Corporate-name:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='611']">
    <z:index name="Conference-name:w Name:w Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='630']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='650']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='651']">
    <z:index name="Name-geographic:w Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='653']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='654']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='655']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='656']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='657']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='658']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='690']">
    <z:index name="Subject:w Subject:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='700']">
    <z:index name="Author:w Author:p Author-name-personal:w Name:w Editor:w Personal-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='710']">
    <z:index name="Author:w Author:p Corporate-name:w Corporate-name:p Name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='711']">
    <z:index name="Author:w Author:p Author-name-corporate:w Name:w Conference-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='730']">
    <z:index name="Title:w Title:p Title-uniform:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='740']">
    <z:index name="Title:w Title:p Title-other-variant:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='751']">
    <z:index name="Name-geographic:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='780']">
    <z:index name="Title:w Title:p Title-former:w Related-periodical:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='785']">
    <z:index name="Title:w Title:p Title-later:w Related-periodical:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='800']">
    <z:index name="Author:w Author-name-personal:w Name:w Personal-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='810']">
    <z:index name="Author:w Corporate-name:w Corporate-name:p Author-name-corporate:w Name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='811']">
    <z:index name="Author:w Author-name-corporate:w Name:w Conference-name:w">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='830']">
    <z:index name="Title:w Title-series:w Title-series:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='840']">
    <z:index name="Title:w Title-series:w Title-series:p">
      <xslo:variable name="raw_heading">
        <xslo:for-each select="marc:subfield">
          <xslo:if test="position() &gt; 1">
            <xslo:value-of select="substring(' ', 1, 1)"/>
          </xslo:if>
          <xslo:value-of select="."/>
        </xslo:for-each>
      </xslo:variable>
      <xslo:value-of select="normalize-space($raw_heading)"/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='100']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="au:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='110']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="au:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='440']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="se:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='490']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="se:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='630']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="su-ut:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='650']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="su-to:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='651']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="su-geo:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='700']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="au:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='942']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="itype:0">
        <xslo:value-of select="marc:subfield[@code='c']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_facets" match="marc:datafield[@tag='952']">
    <xslo:if test="not(@ind1='z')">
      <z:index name="homebranch:0">
        <xslo:value-of select="marc:subfield[@code='a']"/>
      </z:index>
      <z:index name="holdingbranch:0">
        <xslo:value-of select="marc:subfield[@code='b']"/>
      </z:index>
      <z:index name="location:0">
        <xslo:value-of select="marc:subfield[@code='c']"/>
      </z:index>
      <z:index name="itype:0">
        <xslo:value-of select="marc:subfield[@code='y']"/>
      </z:index>
      <z:index name="ccode:0">
        <xslo:value-of select="marc:subfield[@code='8']"/>
      </z:index>
    </xslo:if>
  </xslo:template>
  <xslo:template mode="index_sort_title" match="marc:datafield[@tag='245']">
    <xslo:variable name="chop">
      <xslo:choose>
        <xslo:when test="not(number(@ind2))">0</xslo:when>
        <xslo:otherwise>
          <xslo:value-of select="number(@ind2)"/>
        </xslo:otherwise>
      </xslo:choose>
    </xslo:variable>
    <z:index name="Title:s">
      <xslo:value-of select="substring(marc:subfield[@code='a'], $chop+1)"/>
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
