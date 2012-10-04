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
      <xslo:apply-templates mode="index_heading"/>
      <xslo:apply-templates mode="index_heading_conditional"/>
      <xslo:apply-templates mode="index_match_heading"/>
      <xslo:apply-templates mode="index_subject_thesaurus"/>
    </z:record>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='001']">
    <z:index name="Local-number:w">
      <xslo:value-of select="."/>
    </z:index>
    <z:index name="Local-number:n">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template match="marc:controlfield[@tag='009']">
    <z:index name="Identifier-standard:w">
      <xslo:value-of select="."/>
    </z:index>
    <z:index name="Identifier-standard:n">
      <xslo:value-of select="."/>
    </z:index>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='090']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Local-number:w Local-number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='099']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="date-entered-on-file:s date-entered-on-file:n date-entered-on-file:y Date-of-acquisition:w Date-of-acquisition:d Date-of-acquisition:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="Date/time-last-modified:s Date/time-last-modified:n Date/time-last-modified:y">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="ccode:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='010']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="ISBN:w">
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
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='011']">
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
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='200']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="itemtype:w itemtype:p itype:w itype:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="itype:w itype:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('f', @code)">
        <z:index name="Author:w Author:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('g', @code)">
        <z:index name="Author:w Author:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title:w Title:p Title:s Title-cover:w Title-cover:p Title-cover:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('e', @code)">
        <z:index name="Title:w Title:p Title-cover:w Title-cover:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('i', @code)">
        <z:index name="title:w title:p Title-cover:w Title-cover:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='995']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('r', @code)">
        <z:index name="itemtype:w itemtype:p itype:w itype:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('2', @code)">
        <z:index name="lost:w lost:n item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="homebranch:w Host-item:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="homebranch:w Host-item:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="holdingbranch:w Record-Source:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="holdingbranch:w Record-Source:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('e', @code)">
        <z:index name="location:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('f', @code)">
        <z:index name="barcode:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('h', @code)">
        <z:index name="ccode:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('j', @code)">
        <z:index name="LC-card-number:s item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('k', @code)">
        <z:index name="Call-Number:w Local-classification:w lcn:w Call-Number:p Local-classification:p lcn:p item:w Local-classification:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('n', @code)">
        <z:index name="onloan:d onloan:n onloan:s onloan:w item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('u', @code)">
        <z:index name="Note:w Note:p item:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='071']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Music-number:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='072']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="UPC:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='073']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="EAN:w Identifier-standard:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='100']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="tpubdate:s ta:w ta:w ta:w Modified-code:n ln:s char-encoding:n char-encoding:n char-encoding:n script-Title:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='101']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="ln:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='102']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Country-heading:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='105']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Illustration-code:w Content-type:w Content-type:w Content-type:w Content-type:w Conference-code:w Festschrift-indicator:w Index-indicator:w Literature-Code:w Biography-Code:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='106']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="itype:w itype:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='110']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Type-Of-Serial:w Frequency-code:w Regularity-code:w Content-type:w Content-type:w Conference-publication-Code:w Title-Page-availability-Code:w Index-availability-Code:w Cumulative-Index-availability-Code:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='115']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Video-mt:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='116']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Graphics-type:w Graphics-support:w Graphics-support:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='680']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('b', @code)">
        <z:index name="LC-call-number:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='700']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Author:w Personal-name:w Author:p Personal-name:p Personal-name:w Author:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='701']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='702']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='710']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='711']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='712']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='210']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="pl:w pl:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('c', @code)">
        <z:index name="Publisher:w Publisher:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n pubdate:y pubdate:s">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='225']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('e', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('f', @code)">
        <z:index name="Author:w Author:p Name-and-title:w Name-and-title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('h', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('i', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('v', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('x', @code)">
        <z:index name="ISSN:w">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='230']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Electronic-ressource:w">
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
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='301']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='302']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='303']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='304']">
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
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='306']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='307']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='308']">
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
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='311']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='312']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='313']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='314']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='315']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='316']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='317']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='318']">
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
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='321']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='322']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='323']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='324']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='325']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='326']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='327']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='328']">
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
        <z:index name="Abstract:w Note:w Abstract:p Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='332']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='333']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='336']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='337']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='345']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Note:w Note:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='400']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='401']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='403']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p Title-Uniform:w Title-Uniform:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='410']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title-series:w Title-series:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='412']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='413']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='414']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='415']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='416']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='417']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='418']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='419']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='420']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='430']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='431']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='432']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='440']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='441']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='445']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='461']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title-host:w title-host:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('d', @code)">
        <z:index name="pubdate:n">
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
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='464']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('t', @code)">
        <z:index name="Title:w Title-host:w title-host:p Title:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='500']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='501']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='503']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='510']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='512']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='513']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='514']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='515']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='516']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='517']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='518']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='519']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='520']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='530']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='531']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='532']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='540']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='541']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='545']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='600']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Personal-name:w Personal-name:p Subject:w Subject:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='601']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Corporate-name:w Conference-name:w Corporate-name:p Conference-name:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='602']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Personal-name:w Personal-name:p">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='603']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='604']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='605']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='606']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='607']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='610']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='630']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='631']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='632']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='633']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='634']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='635']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='636']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('9', @code)">
        <z:index name="Koha-Auth-Number:w Koha-Auth-Number:n">
          <xslo:value-of select="."/>
        </z:index>
      </xslo:if>
    </xslo:for-each>
  </xslo:template>
  <xslo:template mode="index_subfields" match="marc:datafield[@tag='676']">
    <xslo:for-each select="marc:subfield">
      <xslo:if test="contains('a', @code)">
        <z:index name="Dewey-classification:w Dewey-classification:s">
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
  </xslo:template>
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='680']">
    <z:index name="LC-call-number:w">
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
    <z:index name="Author:w Personal-name:w Author:p Personal-name:p Personal-name:p">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='701']">
    <z:index name="Author:w Personal-name:w Author:p Personal-name:p Personal-name:p">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='702']">
    <z:index name="Author:w Personal-name:w Author:p Personal-name:p Personal-name:p">
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
    <z:index name="Author:w Author-name-corporate:w Author-name-conference:w Corporate-name:w Conference-name:w Author:p Author-name-corporate:p Author-name-conference:p Corporate-name:p Conference-name:p">
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
    <z:index name="Author:w Author-name-corporate:w Author-name-conference:w Corporate-name:w Conference-name:w Author:p Author-name-corporate:p Author-name-conference:p Corporate-name:p Conference-name:p">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='712']">
    <z:index name="Author:w Author-name-corporate:w Author-name-conference:w Corporate-name:w Conference-name:w Author:p Author-name-corporate:p Author-name-conference:p Corporate-name:p Conference-name:p">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='205']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='208']">
    <z:index name="Serials:w Serials:p">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='207']">
    <z:index name="Printed-music:w Printed-music:p">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='215']">
    <z:index name="Extent:w">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='308']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='328']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='500']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='501']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='503']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='510']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='512']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='513']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='514']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='515']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='516']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='517']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='518']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='519']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='520']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='530']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='531']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='532']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='540']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='541']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='545']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='600']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='601']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='602']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='604']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='605']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='606']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='607']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='631']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='632']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='633']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='634']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='635']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='636']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='610']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='640']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='641']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='642']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='643']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='644']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='645']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='646']">
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
  <xslo:template mode="index_data_field" match="marc:datafield[@tag='995']">
    <z:index name="item # just to index every subfield:w">
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
  <xslo:template match="*">
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
