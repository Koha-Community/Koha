<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2006 rel. 3 sp1 (http://www.altova.com) by T Garip (Near East University) -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNameSpaceSchemaLocation="http://library.neu.edu.tr/kohanamespace/KohaRecord.xsd" version="1.0" >
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:template match="/">
	<xsl:if test="kohacollection">
		<collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" xmlns="http://www.loc.gov/MARC21/slim">
			<xsl:for-each select="kohacollection/koharecord/holdings/record">
				<record>
					<xsl:apply-templates/>
				</record>
			</xsl:for-each>
		</collection>
		</xsl:if>
		 <xsl:if test="koharecord">
		<collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" xmlns="http://www.loc.gov/MARC21/slim">
					<xsl:for-each select="koharecord/holdings/record">
				<record>
					<xsl:apply-templates/>
				</record>
			</xsl:for-each>
		</collection>
		</xsl:if>
	</xsl:template>
	<xsl:template match="koharecord/holdings/record/node()">
		<xsl:copy-of select="."/>
	</xsl:template>
</xsl:stylesheet>
