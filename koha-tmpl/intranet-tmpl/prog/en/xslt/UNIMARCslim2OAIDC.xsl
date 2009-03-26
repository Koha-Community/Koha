<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:marc="http://www.loc.gov/MARC21/slim" 
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="marc">
	<xsl:import href="MARC21slimUtils.xsl"/>
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<xsl:if test="marc:collection">
			<oai_dc:dcCollection xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
				<xsl:for-each select="marc:collection">
					<xsl:for-each select="marc:record">
						<oai_dc:dc>
							<xsl:apply-templates select="."/>
						</oai_dc:dc>
					</xsl:for-each>
				</xsl:for-each>
			</oai_dc:dcCollection>
		</xsl:if>
		<xsl:if test="marc:record">
			<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
				<xsl:apply-templates/>
			</oai_dc:dc>
		</xsl:if>
	</xsl:template>
	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>

		<xsl:for-each select="marc:datafield[@tag=200]">
			<dc:title>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=700]|marc:datafield[@tag=701]|marc:datafield[@tag=702]|marc:datafield[@tag=710]|marc:datafield[@tag=711]|marc:datafield[@tag=712]">
	      <dc:creator>
    	    <xsl:value-of select="marc:subfield[@code='a']"/>
    		<xsl:if test="marc:subfield[@code='b']">,
    		   <xsl:value-of select="marc:subfield[@code='b']"/>
    		</xsl:if>
			<xsl:choose>
    		  <xsl:when test="marc:subfield[@code='4']='010'">, adaptateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='020'">, annotatateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='075'">, postfacier</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='080'">, préfacier</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='100'">, auteur œuvre adapté</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='205'">, collaborateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='212'">, commentaire</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='220'">, compilateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='230'">, compositeur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='245'">, concepteur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='295'">, donneur de grades</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='340'">, éditeur scientifique</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='370'">, réalisateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='395'">, fondateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='440'">, illustrateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='520'">, parolier</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='557'">, organisateur congrès</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='570'">, autre</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='573'">, diffuseur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='574'">, présentateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='575'">, responsable</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='600'">, photographe</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='605'">, présentateur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='650'">, éditeur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='651'">, directeur de la publication</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='673'">, directeur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='675'">, critique</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='710'">, rédacteur</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='723'">, commenditaire</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='727'">, directeur de thèse</xsl:when>
    		  <xsl:when test="marc:subfield[@code='4']='730'">, traducteur</xsl:when>
    		</xsl:choose>
		  </dc:creator>
		</xsl:for-each>
		<dc:type>
		  <xsl:value-of select="marc:datafield[@tag=200]/marc:subfield[@code='b']"/>
		</dc:type>
		<xsl:for-each select="marc:datafield[@tag=210]/marc:subfield[@code='c']">
			<dc:publisher>
				<xsl:value-of select="."/>
			</dc:publisher>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=210]/marc:subfield[@code='d']">
			<dc:date>
				<xsl:value-of select="."/>
			</dc:date>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=101]/marc:subfield[@code='a']">
		  <dc:language>
			<xsl:value-of select="."/>
	      </dc:language>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q']">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=520]">
			<dc:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=521]">
			<dc:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[300&lt;@tag][@tag&lt;=345]">
			<dc:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=600]|marc:datafield[@tag=601]|marc:datafield[@tag=602]|marc:datafield[@tag=604]|marc:datafield[@tag=605]|marc:datafield[@tag=606]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=752]">
			<dc:coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcd</xsl:with-param>
				</xsl:call-template>
			</dc:coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=530]">
			<dc:relation type="original">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdu</xsl:with-param>
				</xsl:call-template>
			</dc:relation>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=461]|marc:datafield[@tag=464]">
			<dc:relation>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">t</xsl:with-param>
				</xsl:call-template>
			</dc:relation>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=856]">
			<dc:identifier>
				<xsl:value-of select="marc:subfield[@code='u']"/>
			</dc:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=010]">
			<dc:identifier>
				<xsl:text>URN:ISBN:</xsl:text>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=011]">
			<dc:identifier>
				<xsl:text>URN:ISSN:</xsl:text>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=090]">
   	      <dc:identifier>
		    <xsl:text>http://opac.mylibrary.org/bib/</xsl:text>
		    <xsl:value-of select="marc:subfield[@code='a']"/>
		  </dc:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=995]">
   	      <dc:identifier>
		    <xsl:text>LOC:</xsl:text>
		    <xsl:choose>
    		  <xsl:when test="marc:subfield[@code='c']='MAIN'">Main Branch</xsl:when>
    		  <xsl:when test="marc:subfield[@code='c']='BIB2'">Library 2</xsl:when>
    		</xsl:choose>
    		<xsl:foreach select="marc:subfield[@code='k']">
    	      <xsl:text>:</xsl:text>
		      <xsl:value-of select="."/>
		    </xsl:foreach>
		  </dc:identifier>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
