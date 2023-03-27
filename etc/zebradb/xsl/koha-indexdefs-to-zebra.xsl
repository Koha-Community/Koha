<?xml version='1.0'?>
<xsl:stylesheet version="1.0" 
                xmlns:marc="http://www.loc.gov/MARC21/slim" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xslo="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:z="http://indexdata.com/zebra-2.0"
                xmlns:kohaidx="http://www.koha-community.org/schemas/index-defs">

    <xsl:namespace-alias stylesheet-prefix="xslo" result-prefix="xsl"/>
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
    <!-- disable all default text node output -->
    <xsl:template match="text()"/>

    <!-- Keys on tags referenced in the index definitions -->
    <xsl:key name="index_control_field_tag" match="kohaidx:index_control_field" use="@tag"/>
    <xsl:key name="index_subfields_tag"     match="kohaidx:index_subfields"     use="@tag"/>
    <xsl:key name="index_facet_tag"         match="kohaidx:facet"               use="@tag"/>
    <xsl:key name="index_heading_tag"       match="kohaidx:index_heading"       use="@tag"/>
    <xsl:key name="index_data_field_tag"    match="kohaidx:index_data_field"    use="@tag"/>
    <xsl:key name="index_heading_conditional_tag" match="kohaidx:index_heading_conditional" use="@tag"/>
    <xsl:key name="index_match_heading_tag" match="kohaidx:index_match_heading" use="@tag"/>
    <xsl:key name="index_sort_title_tag"    match="kohaidx:index_sort_title"    use="@tag"/>

    <xsl:template match="kohaidx:index_defs">
    <xsl:comment>
This file has been automatically generated from a Koha index definition file
with the stylesheet koha-indexdefs-to-zebra.xsl. Do not manually edit this file,
as it may be overwritten. To regenerate, edit the appropriate Koha index
definition file (probably something like {biblio,authority}-koha-indexdefs.xml) and run:
`xsltproc koha-indexdefs-to-zebra.xsl {biblio,authority}-koha-indexdefs.xml >
{biblio,authority}-zebra-indexdefs.xsl` (substituting the appropriate file names).
</xsl:comment>
        <xslo:stylesheet version="1.0">
            <xslo:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
            <xslo:template match="text()"/>
            <xslo:template match="text()" mode="index_subfields"/>
            <xslo:template match="text()" mode="index_data_field"/>
            <xslo:template match="text()" mode="index_facets"/>
            <xslo:template match="text()" mode="index_heading"/>
            <xslo:template match="text()" mode="index_heading_conditional"/>
            <xslo:template match="text()" mode="index_match_heading"/>
            <xslo:template match="text()" mode="index_subject_thesaurus"/>
        <xsl:if test="//kohaidx:index_sort_title">
            <xslo:template match="text()" mode="index_sort_title"/>
        </xsl:if>
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
                <xslo:variable name="idfield">
                    <xsl:attribute name="select">normalize-space(<xsl:value-of select="//kohaidx:id"/>)</xsl:attribute>
                </xslo:variable>
                <z:record type="update">
                    <xslo:attribute name="z:id"><xslo:value-of select="$idfield"/></xslo:attribute>
                    <xslo:apply-templates/>
                    <xslo:apply-templates mode="index_subfields"/>
                    <xslo:apply-templates mode="index_data_field"/>
                    <xslo:apply-templates mode="index_facets"/>
                    <xslo:apply-templates mode="index_heading"/>
                    <xslo:apply-templates mode="index_heading_conditional"/>
                    <xslo:apply-templates mode="index_match_heading"/>
                    <xslo:apply-templates mode="index_subject_thesaurus"/>
                    <xslo:apply-templates mode="index_all"/>
                <xsl:if test="//kohaidx:index_sort_title">
                    <xslo:apply-templates mode="index_sort_title"/>
                </xsl:if>
                </z:record>
            </xslo:template>

            <xsl:call-template name="handle-index-leader"/>
            <xsl:call-template name="handle-index-control-field"/>
            <xsl:call-template name="handle-index-subfields"/>
            <xsl:call-template name="handle-index-data-field"/>
            <xsl:call-template name="handle-index-facets"/>
            <xsl:call-template name="handle-index-heading"/>
            <xsl:call-template name="handle-index-heading-conditional"/>
            <xsl:call-template name="handle-index-match-heading"/>
            <xsl:call-template name="handle-index-sort-title"/>
            <xsl:apply-templates/>
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
                <xslo:otherwise><xslo:value-of select="$chopString"/></xslo:otherwise>
                </xslo:choose>
                <xslo:text> </xslo:text>
            </xslo:template>
        </xslo:stylesheet>
    </xsl:template>

    <!-- map kohaidx:var to stylesheet variables -->
    <xsl:template match="kohaidx:var">
        <xslo:variable>
            <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
            <xsl:value-of select="."/>
        </xslo:variable>
    </xsl:template>

    <xsl:template match="kohaidx:index_subject_thesaurus">
        <xsl:variable name="tag"><xsl:value-of select="@tag"/></xsl:variable>
        <xsl:variable name="offset"><xsl:value-of select="@offset"/></xsl:variable>
        <xsl:variable name="length"><xsl:value-of select="@length"/></xsl:variable>
        <xsl:variable name="detail_tag"><xsl:value-of select="@detail_tag"/></xsl:variable>
        <xsl:variable name="detail_subfields"><xsl:value-of select="@detail_subfields"/></xsl:variable>
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>
        <xslo:template mode="index_subject_thesaurus">
            <xsl:attribute name="match">
                <xsl:text>marc:controlfield[@tag='</xsl:text>
                <xsl:value-of select="$tag"/>
                <xsl:text>']</xsl:text>
            </xsl:attribute>
            <xslo:variable name="thesaurus_code1">
                <xsl:attribute name="select">
                    <xsl:text>substring(., </xsl:text>
                    <xsl:value-of select="$offset + 1" />
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$length" />
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
            </xslo:variable>
            <xsl:variable name="alt_select">
                <xsl:text>//marc:datafield[@tag='</xsl:text>
                <xsl:value-of select="$detail_tag"/>
                <xsl:text>']/marc:subfield[@code='</xsl:text>
                <xsl:value-of select="$detail_subfields"/>
                <xsl:text>']</xsl:text>
            </xsl:variable>
            <xslo:variable name="full_thesaurus_code">
                <xslo:choose>
                    <xslo:when test="$thesaurus_code1 = 'a'"><xslo:text>lcsh</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'b'"><xslo:text>lcac</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'c'"><xslo:text>mesh</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'd'"><xslo:text>nal</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'k'"><xslo:text>cash</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'n'"><xslo:text>notapplicable</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'r'"><xslo:text>aat</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 's'"><xslo:text>sears</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'v'"><xslo:text>rvm</xslo:text></xslo:when>
                    <xslo:when test="$thesaurus_code1 = 'z'">
                        <xslo:choose>
                            <xslo:when>
                                <xsl:attribute name="test"><xsl:value-of select="$alt_select"/></xsl:attribute>
                                <xslo:value-of>
                                    <xsl:attribute name="select"><xsl:value-of select="$alt_select"/></xsl:attribute>
                                </xslo:value-of>
                            </xslo:when>
                            <xslo:otherwise><xslo:text>notdefined</xslo:text></xslo:otherwise>
                        </xslo:choose>
                    </xslo:when>
                    <xslo:otherwise><xslo:text>notspecified</xslo:text></xslo:otherwise>
                </xslo:choose>
            </xslo:variable>
            <z:index>
                <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
                <xslo:value-of select="$full_thesaurus_code"/>
            </z:index>
        </xslo:template>
    </xsl:template>

    <xsl:template name="handle-index-leader">
        <xsl:if test="kohaidx:index_leader">
            <xslo:template match="marc:leader">
                <xsl:apply-templates select="kohaidx:index_leader" mode="secondary"/>
            </xslo:template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="kohaidx:index_leader" mode="secondary">
        <xsl:variable name="offset"><xsl:value-of select="@offset"/></xsl:variable>
        <xsl:variable name="length"><xsl:value-of select="@length"/></xsl:variable>
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>
        <z:index>
            <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
            <xslo:value-of>
                <xsl:attribute name="select">
                    <xsl:text>substring(., </xsl:text>
                    <xsl:value-of select="$offset + 1" />
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$length" />
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
            </xslo:value-of>
        </z:index>
    </xsl:template>

    <xsl:template name="handle-index-control-field">
        <xsl:for-each select="//kohaidx:index_control_field[generate-id() = generate-id(key('index_control_field_tag', @tag)[1])]">
            <xslo:template>
                <xsl:attribute name="match">
                    <xsl:text>marc:controlfield[@tag='</xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text>']</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="key('index_control_field_tag', @tag)">
                    <xsl:call-template name="handle-one-index-control-field"/>
                </xsl:for-each>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-one-index-control-field">
        <xsl:variable name="offset"><xsl:value-of select="@offset"/></xsl:variable>
        <xsl:variable name="length"><xsl:value-of select="@length"/></xsl:variable>
        <xsl:variable name="zeropad"><xsl:value-of select="@zeropad"/></xsl:variable>
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>
        <z:index>
            <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
            <xslo:value-of>
                <xsl:attribute name="select">
                    <xsl:choose>
                        <xsl:when test="@length">
                            <xsl:text>substring(., </xsl:text>
                            <xsl:value-of select="$offset + 1" />
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="$length"/>
                            <xsl:text>)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@zeropad">
                            <xsl:text>format-number(.,"00000000000")</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>.</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xslo:value-of>
        </z:index>
    </xsl:template>

    <xsl:template name="handle-index-subfields">
        <xsl:for-each select="//kohaidx:index_subfields[generate-id() = generate-id(key('index_subfields_tag', @tag)[1])]">
            <xslo:template mode="index_subfields">
                <xsl:attribute name="match">
                    <xsl:text>marc:datafield[@tag='</xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text>']</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="key('index_subfields_tag', @tag)">
                    <xsl:choose>
                        <xsl:when test="@condition">
                            <xslo:if>
                                <xsl:attribute name="test">
                                    <xsl:value-of select="@condition"/>
                                </xsl:attribute>
                                <xsl:call-template name="handle-one-index-subfields" />
                            </xslo:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="handle-one-index-subfields" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-one-index-subfields">
        <xsl:variable name="offset"><xsl:value-of select="@offset"/></xsl:variable>
        <xsl:variable name="length"><xsl:value-of select="@length"/></xsl:variable>
        <xsl:variable name="zeropad"><xsl:value-of select="@zeropad"/></xsl:variable>
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>

        <xslo:for-each select="marc:subfield">
            <xslo:if>
                <xsl:attribute name="test">
                    <xsl:text>contains('</xsl:text>
                    <xsl:value-of select="@subfields"/>
                    <xsl:text>', @code)</xsl:text>
                </xsl:attribute>
                <z:index>
                    <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
                    <xslo:value-of>
                        <xsl:attribute name="select">
                            <xsl:choose>
                                <xsl:when test="@length">
                                    <xsl:text>substring(., </xsl:text>
                                    <xsl:value-of select="$offset + 1" />
                                    <xsl:text>, </xsl:text>
                                    <xsl:value-of select="$length"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:when>
                                <xsl:when test="@zeropad">
                                    <xsl:text>format-number(.,"00000000000")</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xslo:value-of>
                </z:index>
            </xslo:if>
        </xslo:for-each>
    </xsl:template>

    <xsl:template name="handle-index-facets">
      <xsl:for-each select="//kohaidx:facet[generate-id() = generate-id(key('index_facet_tag', @tag)[1])]">
          <xslo:template mode="index_facets">
            <xsl:attribute name="match">
            <xsl:text>marc:datafield[@tag='</xsl:text>
            <xsl:value-of select="@tag"/>
            <xsl:text>']</xsl:text>
            </xsl:attribute>
            <xslo:if>
              <xsl:attribute name="test">
                <xsl:text>not(@ind1='z')</xsl:text>
              </xsl:attribute>
              <xsl:for-each select="key('index_facet_tag', @tag)">
                <xsl:variable name="indexes">
                  <xsl:call-template name="get-facets-target-indexes"/>
                </xsl:variable>
                  <xsl:if test="not($indexes='')">
                  <z:index>
                  <xsl:attribute name="name">
                    <xsl:value-of select="normalize-space($indexes)"/>
                  </xsl:attribute>
                  <xsl:call-template name="build-facet-value">
                    <xsl:with-param name="subfields" select="@subfields"/>
                  </xsl:call-template>
                  </z:index>
                </xsl:if>
              </xsl:for-each>
            </xslo:if>
          </xslo:template>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-index-data-field">
        <xsl:for-each select="//kohaidx:index_data_field[generate-id() = generate-id(key('index_data_field_tag', @tag)[1])]">
            <xslo:template mode="index_data_field">
                <xsl:attribute name="match">
                    <xsl:text>marc:datafield[@tag='</xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text>']</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="key('index_data_field_tag', @tag)">
                    <xsl:call-template name="handle-one-data-field"/>
                </xsl:for-each>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-index-heading-conditional">
        <xsl:for-each select="//kohaidx:index_heading_conditional[generate-id() = generate-id(key('index_heading_conditional_tag', @tag)[1])]">
            <xslo:template mode="index_heading_conditional">
                <xsl:attribute name="match">marc:datafield[@tag='<xsl:value-of select="@tag"/>']</xsl:attribute>
                <xslo:if>
                    <xsl:attribute name="test"><xsl:value-of select="@test"/></xsl:attribute>
                    <xsl:for-each select="key('index_heading_conditional_tag', @tag)">
                        <xsl:call-template name="handle-one-index-heading"/>
                    </xsl:for-each>
                </xslo:if>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-one-data-field">
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>
        <z:index>
            <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
            <xslo:variable name="raw_heading">
                <xslo:for-each select="marc:subfield">
                        <xslo:if test="position() > 1">
                            <xslo:value-of select="substring(' ', 1, 1)"/> <!-- FIXME surely there's a better way  to specify a space -->
                        </xslo:if>
                        <xslo:value-of select="."/>
                </xslo:for-each>
            </xslo:variable>
            <xslo:value-of select="normalize-space($raw_heading)"/>
        </z:index>
    </xsl:template>

    <xsl:template name="handle-index-heading">
        <xsl:for-each select="//kohaidx:index_heading[generate-id() = generate-id(key('index_heading_tag', @tag)[1])]">
            <xslo:template mode="index_heading">
                <xsl:attribute name="match">
                    <xsl:text>marc:datafield[@tag='</xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text>']</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="key('index_heading_tag', @tag)">
                    <xsl:call-template name="handle-one-index-heading"/>
                </xsl:for-each>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-one-index-heading">
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>
        <z:index>
            <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
            <xslo:variable name="raw_heading">
                <xslo:for-each select="marc:subfield">
                    <xslo:if>
                        <xsl:attribute name="test">
                            <xsl:text>contains('</xsl:text>
                            <xsl:value-of select="@subfields"/>
                            <xsl:text>', @code)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
                        <xslo:if test="position() > 1">
                            <xslo:choose>
                                <xslo:when>
                                    <xsl:attribute name="test">
                                        <xsl:text>contains('</xsl:text>
                                        <xsl:value-of select="@subdivisions"/>
                                        <xsl:text>', @code)</xsl:text>
                                    </xsl:attribute>
                                    <xslo:text>--</xslo:text>
                                </xslo:when>
                                <xslo:otherwise>
                                    <xslo:value-of select="substring(' ', 1, 1)"/> <!-- FIXME surely there's a better way  to specify a space -->
                                </xslo:otherwise>
                            </xslo:choose>
                        </xslo:if>
                        <xslo:value-of select="."/>
                    </xslo:if>
                </xslo:for-each>
            </xslo:variable>
            <xslo:value-of select="normalize-space($raw_heading)"/>
        </z:index>
    </xsl:template>

    <xsl:template name="handle-index-sort-title">
        <xsl:for-each select="//kohaidx:index_sort_title[generate-id() = generate-id(key('index_sort_title_tag', @tag)[1])]">
            <xslo:template mode="index_sort_title">
                <xsl:attribute name="match">
                    <xsl:text>marc:datafield[@tag='</xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text>']</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="key('index_sort_title_tag', @tag)">
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
                </xsl:for-each>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-index-match-heading">
        <xsl:for-each select="//kohaidx:index_match_heading[generate-id() = generate-id(key('index_match_heading_tag', @tag)[1])]">
            <xslo:template mode="index_match_heading">
                <xsl:attribute name="match">
                    <xsl:text>marc:datafield[@tag='</xsl:text>
                    <xsl:value-of select="@tag"/>
                    <xsl:text>']</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="key('index_match_heading_tag', @tag)">
                    <xsl:call-template name="handle-one-index-match-heading"/>
                </xsl:for-each>
            </xslo:template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="handle-one-index-match-heading">
        <xsl:variable name="indexes">
            <xsl:call-template name="get-target-indexes"/>
        </xsl:variable>
        <z:index>
            <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
            <xslo:variable name="raw_heading">
                <xslo:for-each select="marc:subfield">
                    <xslo:if>
                        <xsl:attribute name="test">
                            <xsl:text>contains('</xsl:text>
                            <xsl:value-of select="@subfields"/>
                            <xsl:text>', @code)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="name"><xsl:value-of select="normalize-space($indexes)"/></xsl:attribute>
                        <xslo:if test="position() > 1">
                            <xslo:choose>
                                <xslo:when>
                                    <xsl:attribute name="test">
                                        <xsl:text>contains('</xsl:text>
                                        <xsl:value-of select="@subdivisions"/>
                                        <xsl:text>', @code)</xsl:text>
                                    </xsl:attribute>
                                    <xslo:choose>
                                        <xslo:when>
                                            <xsl:attribute name="test">
                                                <xsl:text>@code = $general_subdivision_subfield</xsl:text>
                                            </xsl:attribute>
                                            <xslo:text> generalsubdiv </xslo:text>
                                        </xslo:when>
                                        <xslo:when>
                                            <xsl:attribute name="test">
                                                <xsl:text>@code = $form_subdivision_subfield</xsl:text>
                                            </xsl:attribute>
                                            <xslo:text> formsubdiv </xslo:text>
                                        </xslo:when>
                                        <xslo:when>
                                            <xsl:attribute name="test">
                                                <xsl:text>@code = $chronological_subdivision_subfield</xsl:text>
                                            </xsl:attribute>
                                            <xslo:text> chronologicalsubdiv </xslo:text>
                                        </xslo:when>
                                        <xslo:when>
                                            <xsl:attribute name="test">
                                                <xsl:text>@code = $geographic_subdivision_subfield</xsl:text>
                                            </xsl:attribute>
                                            <xslo:text> geographicsubdiv </xslo:text>
                                        </xslo:when>
                                    </xslo:choose>
                                </xslo:when>
                                <xslo:otherwise>
                                    <xslo:value-of select="substring(' ', 1, 1)"/> <!-- FIXME surely there's a better way  to specify a space -->
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
    </xsl:template>

    <xsl:template name="get-target-indexes">
        <xsl:for-each select="kohaidx:target_index">
            <xsl:value-of select="." /><xsl:text> </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="get-facets-target-indexes">
        <xsl:for-each select="kohaidx:target_index">
            <xsl:value-of select="." /><xsl:text> </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <!-- traverse subfields string character-wise -->
    <xsl:template name="build-facet-value">
      <xsl:param name="subfields"/>
      <xsl:if test="string-length($subfields) &gt; 0">
        <xslo:value-of>
          <xsl:attribute name="select">
              <xsl:text>marc:subfield[@code='</xsl:text>
              <xsl:value-of select="substring($subfields,1,1)"/>
              <xsl:text>']</xsl:text>
          </xsl:attribute>
        </xslo:value-of>
        <xsl:call-template name="build-facet-value-cont">
          <xsl:with-param name="prev" select="substring($subfields,1,1)"/>
          <xsl:with-param name="subfields" select="substring($subfields,2)"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:template>
    <!-- traverse the remainder of @subfields, with context information
         i.e previous char. Introduces a separator character if needed -->
    <xsl:template name="build-facet-value-cont">
      <xsl:param name="prev"/>
      <xsl:param name="subfields"/>
      <xsl:if test="string-length($subfields) &gt; 0">
        <xslo:if>
            <xsl:attribute name="test">
                <xsl:text>marc:subfield[@code='</xsl:text>
                <xsl:value-of select="$prev"/>
                <xsl:text>'] and marc:subfield[@code='</xsl:text>
                <xsl:value-of select="substring($subfields,1,1)"/>
                <xsl:text>']</xsl:text>
            </xsl:attribute>
            <xslo:text>&lt;*&gt;</xslo:text>
        </xslo:if>
        <xslo:value-of>
          <xsl:attribute name="select">
              <xsl:text>marc:subfield[@code='</xsl:text>
              <xsl:value-of select="substring($subfields,1,1)"/>
              <xsl:text>']</xsl:text>
          </xsl:attribute>
        </xslo:value-of>
        <xsl:call-template name="build-facet-value-cont">
          <xsl:with-param name="prev" select="substring($subfields,1,1)"/>
          <xsl:with-param name="subfields" select="substring($subfields,2)"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:template>

</xsl:stylesheet>
