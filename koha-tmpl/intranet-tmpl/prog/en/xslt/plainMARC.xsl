<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8"/>

    <xsl:template match="/">
        <html>
          <head><title>MARC View</title></head>
          <body>
           <xsl:apply-templates/>
          </body>
        </html>
    </xsl:template>

    <xsl:template match="marc:record">
        <table>
            <tr>
                <th style="white-space:nowrap">
                    000
                </th>
                <td colspan="2"></td>
                <td>
                    <xsl:value-of select="marc:leader"/>
                </td>
            </tr>
            <xsl:apply-templates select="marc:datafield|marc:controlfield"/>
        </table>
    </xsl:template>

    <xsl:template match="marc:controlfield">
        <tr>
            <th style="white-space:nowrap">
                <xsl:value-of select="@tag"/>
            </th>
            <td colspan="2"></td>
            <td>
                <xsl:value-of select="."/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="marc:datafield">
        <tr>
            <th style="white-space:nowrap">
                <xsl:value-of select="@tag"/>
            </th>
            <td><xsl:value-of select="@ind1"/></td>
            <td><xsl:value-of select="@ind2"/></td>
            <td><xsl:apply-templates select="marc:subfield"/></td>
        </tr>
    </xsl:template>

    <xsl:template match="marc:subfield">
        <strong>_<xsl:value-of select="@code"/></strong>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="@code = '9'">
                <a>
                    <xsl:attribute name='href'>/cgi-bin/koha/authorities/detail.pl?authid=<xsl:value-of select="."/></xsl:attribute>
                    <xsl:attribute name="title">View authority record</xsl:attribute>
                    <xsl:attribute name='target'>_blank</xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
        <xsl:when test="position()=last()"><xsl:text> </xsl:text></xsl:when><xsl:otherwise><br /></xsl:otherwise></xsl:choose>
    </xsl:template>

</xsl:stylesheet>
