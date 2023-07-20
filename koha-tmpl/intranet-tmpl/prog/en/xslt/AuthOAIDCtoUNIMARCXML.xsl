<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/1.1"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/
        http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.loc.gov/MARC21/slim"  exclude-result-prefixes="dc dcterms oai_dc">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" >
            <xsl:apply-templates />
        </collection>
    </xsl:template>

    <xsl:template match="oai_dc:dc">
        <record>

            <xsl:for-each select="dc:FamilyName">
                <datafield tag="200" ind1="0" ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>

            <xsl:for-each select="dc:GivenName">
                <datafield tag="200" ind1="0" ind2=" ">
                    <subfield code="b">
                        <xsl:value-of select="."/>
                    </subfield>
                </datafield>
            </xsl:for-each>

        </record>
   </xsl:template>

</xsl:stylesheet>
