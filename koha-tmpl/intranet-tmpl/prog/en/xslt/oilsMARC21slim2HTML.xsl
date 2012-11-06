<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8"/>
	
	<xsl:template match="/">
		<html>
			<head>

				<style>

					.marc_table {}
					.marc_tag_row {}
					.marc_tag_data {}
					.marc_tag_col {}
					.marc_tag_ind {}
					.marc_subfields {}
					.marc_subfield_code { 
						color: blue; 
						padding-left: 5px;
						padding-right: 5px; 
					}

				</style>

				<link href='/css/opac_marc.css' rel='stylesheet' type='text/css'></link>
			</head>
			<body>
				<div><button onclick='window.print();'>Print Page</button></div>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="marc:record">
		<table class='marc_table'>
			<tr class='marc_tag_row'>
				<th class='marc_tag_col' NOWRAP="TRUE" ALIGN="RIGHT" VALIGN="middle">
					LDR
				</th>
				<td class='marc_tag_data' COLSPAN='3'>
					<xsl:value-of select="marc:leader"/>
				</td>
			</tr>
			<xsl:apply-templates select="marc:datafield|marc:controlfield"/>
		</table>
	</xsl:template>
	
	<xsl:template match="marc:controlfield">
		<tr class='marc_tag_row'>
			<th class='marc_tag_col' NOWRAP="TRUE" ALIGN="RIGHT" VALIGN="middle">
				<xsl:value-of select="@tag"/>
			</th>
			<td class='marc_tag_data' COLSPAN='3'>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="marc:datafield">
		<tr class='marc_tag_row'>
			<th class='marc_tag_col' NOWRAP="TRUE" ALIGN="RIGHT" VALIGN="middle">
				<xsl:value-of select="@tag"/>
			</th>
			<td class='marc_tag_ind'>
				<xsl:value-of select="@ind1"/>
			</td>

			<td class='marc_tag_ind' style='border-left: 1px solid #A0A0A0; padding-left: 3px;'>
				<xsl:value-of select="@ind2"/>
				<span style='color:#FFF'>.</span> 
			</td>

			<td class='marc_subfields'>
				<xsl:apply-templates select="marc:subfield"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="marc:subfield">
		<span class='marc_subfield_code' > 
			&#8225;<xsl:value-of select="@code"/>
		</span><xsl:value-of select="."/>	
	</xsl:template>

</xsl:stylesheet>

<!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="no" name="Ray Charles" userelativepaths="yes" externalpreview="no" url="..\xml\MARC21slim\raycharles.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="yes" name="s7" userelativepaths="yes" externalpreview="no" url="..\ifla\sally7.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
