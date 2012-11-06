<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>
<xsl:stylesheet version="1.0" xmlns:xlink="http://www.w3.org/TR/xlink" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns="http://www.loc.gov/mods/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="marc">
	<xsl:include href="MARC21slimUtils.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	
	<xsl:template match="/">
		<collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/	http://www.loc.gov/standards/marcxml/schema/mods.xsd">
			<xsl:apply-templates/>
		</collection>
	</xsl:template>

	<xsl:template match="marc:record">
		<mods>
			<xsl:variable name="leader" select="marc:leader"/>
			<xsl:variable name="leader6" select="substring($leader,7,1)"/>
			<xsl:variable name="leader7" select="substring($leader,8,1)"/>
			<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>

			<xsl:variable name="typeOf008">
				<xsl:choose>
					<xsl:when test="$leader6='a'">
						<xsl:choose>
							<xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
							<xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">SE</xsl:when>				
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$leader6='t'">BK</xsl:when>
					<xsl:when test="$leader6='p'">MM</xsl:when>
					<xsl:when test="$leader6='m'">CF</xsl:when>	
					<xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>	
					<xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">VM</xsl:when>				
					<xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">MU</xsl:when>				
				</xsl:choose>
			</xsl:variable>

			<xsl:for-each select="marc:datafield[@tag=245]">
				<titleInfo>
					<xsl:variable name="title">
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">abfghk</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="@ind2>0">
							<nonSort>
								<xsl:value-of select="substring($title,1,@ind2)"/>
							</nonSort>
							<title>
								<xsl:value-of select="substring($title,@ind2+1)"/>
							</title>
						</xsl:when>
						<xsl:otherwise>
							<title>
								<xsl:value-of select="$title"/>
							</title>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="part"/>
				</titleInfo>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=210]">
				<titleInfo type="abbreviated">
					<title>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">ab</xsl:with-param>
						</xsl:call-template>
					</title>
				</titleInfo>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=242]">
				<titleInfo type="translated">
					<title>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abh</xsl:with-param>
						</xsl:call-template>
					</title>
					<xsl:call-template name="part"/>
				</titleInfo>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=246]">
				<titleInfo type="alternative">
					<xsl:for-each select="marc:subfield[@code='i']">
						<xsl:attribute name="displayLabel">
							<xsl:value-of select="text()"/>
						</xsl:attribute>
					</xsl:for-each>
					<title>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abfh</xsl:with-param>
						</xsl:call-template>
					</title>
					<xsl:call-template name="part"/>			
				</titleInfo>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=130]|marc:datafield[@tag=240]|marc:datafield[@tag=730][@ind2!=2]">
				<titleInfo type="uniform">
					<title>
						<xsl:variable name="str">
							<xsl:for-each select="marc:subfield">
								<xsl:if test="(contains('adfhklmor',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
									<xsl:value-of select="text()"/><xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
					</title>
					<xsl:call-template name="part"/>			
				</titleInfo>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=740][@ind2!=2]">
				<titleInfo type="alternative">
					<title>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">ah</xsl:with-param>
						</xsl:call-template>
					</title>
					<xsl:call-template name="part"/>			
				</titleInfo>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=100]">
				<name type="personal">
					<xsl:call-template name="nameABCDQ"/>
					<xsl:call-template name="affiliation"/>
					<role>creator</role>
					<xsl:call-template name="role"/>
				</name>
			</xsl:for-each>


			<xsl:for-each select="marc:datafield[@tag=110]">
				<name type="corporate">
					<xsl:call-template name="nameABCDN"/>
					<role>creator</role>
					<xsl:call-template name="role"/>
				</name>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=111]">
				<name type="conference">
					<xsl:call-template name="nameACDEQ"/>
					<role>creator</role>
					<xsl:for-each select="marc:subfield[@code='4']">
						<role><xsl:value-of select="."/></role>
					</xsl:for-each>
				</name>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=700][not(marc:subfield[@code='t'])]">
				<name type="personal">
					<xsl:call-template name="nameABCDQ"/>
					<xsl:call-template name="affiliation"/>
					<xsl:call-template name="role"/>
				</name>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=710][not(marc:subfield[@code='t'])]">
				<name type="corporate">
					<xsl:call-template name="nameABCDN"/>
					<xsl:call-template name="role"/>
				</name>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=711][not(marc:subfield[@code='t'])]">
				<name type="conference">
					<xsl:call-template name="nameACDEQ"/>
					<xsl:for-each select="marc:subfield[@code='4']">
						<role><xsl:value-of select="."/></role>
					</xsl:for-each>
				</name>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=720][not(marc:subfield[@code='t'])]">
				<name>
					<xsl:if test="@ind1=1">
						<xsl:attribute name="type">personal</xsl:attribute>
					</xsl:if>
					<namePart>
						<xsl:value-of select="marc:subfield[@code='a']"/>
					</namePart>
					<xsl:call-template name="role"/>
				</name>
			</xsl:for-each>

			<typeOfResource>		
				<xsl:if test="$leader7='c'">
					<xsl:attribute name="collection">yes</xsl:attribute>
				</xsl:if>
				<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
					<xsl:attribute name="manuscript">yes</xsl:attribute>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
					<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
					<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
					<xsl:when test="$leader6='i' or $leader6='j'">sound recording</xsl:when>
					<xsl:when test="$leader6='k'">still image</xsl:when>
					<xsl:when test="$leader6='g'">moving image</xsl:when>
					<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
					<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
					<xsl:when test="$leader6='p'">mixed material</xsl:when>
				</xsl:choose>
			</typeOfResource>

				<xsl:if test="substring($controlField008,26,1)='d'">
					<genre authority="marc">globe</genre>
				</xsl:if>
			
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='r']">
					<genre authority="marc">remote sensing image</genre>
				</xsl:if>

				<xsl:if test="$typeOf008='MP'">
					<xsl:variable name="controlField008-25" select="substring($controlField008,26,1)"/>
					<xsl:choose>
						<xsl:when test="$controlField008-25='a' or $controlField008-25='b' or $controlField008-25='c' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='j']">
							<genre authority="marc">map</genre>
						</xsl:when>
						<xsl:when test="$controlField008-25='e' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='d']">
							<genre authority="marc">atlas</genre>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="$typeOf008='SE'">
					<xsl:variable name="controlField008-21" select="substring($controlField008,22,1)"/>
					<xsl:choose>
						<xsl:when test="$controlField008-21='d'">
							<genre authority="marc">database</genre>
						</xsl:when>
						<xsl:when test="$controlField008-21='l'">	
							<genre authority="marc">loose-leaf</genre>
						</xsl:when>
						<xsl:when test="$controlField008-21='m'">
							<genre authority="marc">series</genre>
						</xsl:when>
						<xsl:when test="$controlField008-21='n'">
							<genre authority="marc">newspaper</genre>	
						</xsl:when>
						<xsl:when test="$controlField008-21='p'">
							<genre authority="marc">periodical</genre>
						</xsl:when>
						<xsl:when test="$controlField008-21='w'">
							<genre authority="marc">web site</genre>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

	 			<xsl:if test="$typeOf008='BK' or $typeOf008='SE'">
					<xsl:variable name="controlField008-24" select="substring($controlField008,25,4)"/>
					<xsl:choose>
						<xsl:when test="contains($controlField008-24,'a')">
							<genre authority="marc">abstract or summary</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'b')">
							<genre authority="marc">bibliography</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'c')">
							<genre authority="marc">catalog</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'d')">
							<genre authority="marc">dictionary</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'e')">
							<genre authority="marc">encyclopedia</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'f')">
							<genre authority="marc">handbook</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'g')">
							<genre authority="marc">legal article</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'i')">
							<genre authority="marc">index</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'k')">
							<genre authority="marc">discography</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'l')">
							<genre authority="marc">legislation</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'m')">
							<genre authority="marc">theses</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'n')">
							<genre authority="marc">survey of literature</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'o')">
							<genre authority="marc">review</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'p')">
							<genre authority="marc">programmed text</genre>
						</xsl:when>					
						<xsl:when test="contains($controlField008-24,'q')">
							<genre authority="marc">filmography</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'r')">
							<genre authority="marc">directory</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'s')">
							<genre authority="marc">statistics</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'t')">
							<genre authority="marc">technical report</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'v')">
							<genre authority="marc">legal case and case notes</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'w')">
							<genre authority="marc">law report or digest</genre>
						</xsl:when>
						<xsl:when test="contains($controlField008-24,'z')">
							<genre authority="marc">treaty</genre>
						</xsl:when>	 
					</xsl:choose>
					<xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
					<xsl:choose>
						<xsl:when test="$controlField008-29='1'">
							<genre authority="marc">conference publication</genre>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="$typeOf008='CF'">
					<xsl:variable name="controlField008-26" select="substring($controlField008,27,1)"/>
					<xsl:choose>
						<xsl:when test="$controlField008-26='a'">
							<genre authority="marc">numeric data</genre>
						</xsl:when>
						<xsl:when test="$controlField008-26='e'">
							<genre authority="marc">database</genre>
						</xsl:when>
						<xsl:when test="$controlField008-26='f'">
							<genre authority="marc">font</genre>
						</xsl:when>
						<xsl:when test="$controlField008-26='g'">
							<genre authority="marc">game</genre>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="$typeOf008='BK'">
					<xsl:if test="substring($controlField008,25,1)='j'">
						<genre authority="marc">patent</genre>
					</xsl:if>
					<xsl:if test="substring($controlField008,31,1)='1'">
						<genre authority="marc">festschrift</genre>
					</xsl:if>

					<xsl:variable name="controlField008-34" select="substring($controlField008,35,1)"/>
					<xsl:if test="$controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d'">
						<genre authority="marc">biography</genre>
					</xsl:if>

					<xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
					<xsl:choose>
						<xsl:when test="$controlField008-33='e'">
							<genre authority="marc">essay</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='d'">
							<genre authority="marc">drama</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='c'">
							<genre authority="marc">comic strip</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='l'">
							<genre authority="marc">fiction</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='h'">
							<genre authority="marc">humor, satire</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='i'">
							<genre authority="marc">letter</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='f'">
							<genre authority="marc">novel</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='j'">
							<genre authority="marc">short story</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='s'">
							<genre authority="marc">speech</genre>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="$typeOf008='MU'">
					<xsl:variable name="controlField008-30-31" select="substring($controlField008,31,2)"/>
					<xsl:if test="contains($controlField008-30-31,'b')">
						<genre authority="marc">biography</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'c')">
						<genre authority="marc">conference publication</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'d')">
						<genre authority="marc">drama</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'e')">
						<genre authority="marc">essay</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'f')">
						<genre authority="marc">fiction</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'o')">
						<genre authority="marc">folktale</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'h')">
						<genre authority="marc">history</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'k')">
						<genre authority="marc">humor, satire</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'m')">
						<genre authority="marc">memoir</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'p')">
						<genre authority="marc">poetry</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'r')">
						<genre authority="marc">rehersal</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'g')">
						<genre authority="marc">reporting</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'s')">
						<genre authority="marc">sound</genre>
					</xsl:if>
					<xsl:if test="contains($controlField008-30-31,'l')">
						<genre authority="marc">speech</genre>
					</xsl:if>
				</xsl:if>

	 			<xsl:if test="$typeOf008='VM'">
					<xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
					<xsl:choose>
						<xsl:when test="$controlField008-33='a'">
							<genre authority="marc">art original</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='b'">
							<genre authority="marc">kit</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='c'">
							<genre authority="marc">art reproduction</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='d'">
							<genre authority="marc">diorama</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='f'">
							<genre authority="marc">filmstrip</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='g'">
							<genre authority="marc">legal article</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='i'">
							<genre authority="marc">picture</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='k'">
							<genre authority="marc">graphic</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='l'">
							<genre authority="marc">technical drawing</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='m'">
							<genre authority="marc">motion picture</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='n'">
							<genre authority="marc">chart</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='o'">
							<genre authority="marc">flash card</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='p'">
							<genre authority="marc">microscope slide</genre>
						</xsl:when>					
						<xsl:when test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
							<genre authority="marc">model</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='r'">
							<genre authority="marc">realia</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='s'">
							<genre authority="marc">slide</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='t'">
							<genre authority="marc">transparency</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='v'">
							<genre authority="marc">videorecording</genre>
						</xsl:when>
						<xsl:when test="$controlField008-33='w'">
							<genre authority="marc">toy</genre>
						</xsl:when> 
					</xsl:choose>
				</xsl:if>

				<xsl:for-each select="marc:datafield[@tag=655]">
					<genre authority="marc">
						<xsl:attribute name="authority">
							<xsl:value-of select="marc:subfield[@code='2']"/>
						</xsl:attribute>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abvxyz</xsl:with-param>
							<xsl:with-param name="delimeter">-</xsl:with-param>
						</xsl:call-template>
					</genre>
				</xsl:for-each>

			<publicationInfo>
				<xsl:variable name="MARCpublicationCode" select="normalize-space(substring($controlField008,16,3))"/>
				
				<xsl:if test="translate($MARCpublicationCode,'|','')">
					<placeCode authority="marc">
						<xsl:value-of select="$MARCpublicationCode"/>
					</placeCode>
				</xsl:if>
			
				<xsl:for-each select="marc:datafield[@tag=044]/marc:subfield[@code='c']">
					<placeCode authority="iso3166">
						<xsl:value-of select="."/>
					</placeCode>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='a' or @code='b' or @code='c' or @code='g']">
					<xsl:choose>
						<xsl:when test="@code='a'">
							<place>
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="."/>
								</xsl:call-template>
							</place>
						</xsl:when>
						<xsl:when test="@code='b'">
							<publisher>
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="."/>
								</xsl:call-template>
							</publisher>
						</xsl:when>
						<xsl:when test="@code='c'">
							<dateIssued>
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="."/>
								</xsl:call-template>
							</dateIssued>
						</xsl:when>
						<xsl:when test="@code='g'">
							<dateCreated>
								<xsl:value-of select="."/>
							</dateCreated>			
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<xsl:variable name="dataField260c">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="marc:datafield[@tag=260]/marc:subfield[@code='c']"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="controlField008-7-10" select="normalize-space(substring($controlField008, 8, 4))"/>
				<xsl:variable name="controlField008-11-14" select="normalize-space(substring($controlField008, 12, 4))"/>
				<xsl:variable name="controlField008-6" select="normalize-space(substring($controlField008, 7, 1))"/>
		
				<xsl:if test="$controlField008-6='e' or $controlField008-6='p' or $controlField008-6='r' or $controlField008-6='t' or $controlField008-6='s'">
					<xsl:if test="$controlField008-7-10 and ($controlField008-7-10 != $dataField260c)">
						<dateIssued encoding="marc">
							<xsl:value-of select="$controlField008-7-10"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>
		
				<xsl:if test="$controlField008-6='c' or $controlField008-6='d' or $controlField008-6='i' or $controlField008-6='k' or $controlField008-6='m' or $controlField008-6='q' or $controlField008-6='u'">
					<xsl:if test="$controlField008-7-10">
						<dateIssued encoding="marc" point="start">
							<xsl:value-of select="$controlField008-7-10"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>

				<xsl:if test="$controlField008-6='c' or $controlField008-6='d' or $controlField008-6='i' or $controlField008-6='k' or $controlField008-6='m' or $controlField008-6='q' or $controlField008-6='u'">
					<xsl:if test="$controlField008-11-14">
						<dateIssued encoding="marc" point="end">
							<xsl:value-of select="$controlField008-11-14"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>

				<xsl:for-each select="marc:datafield[@tag=033][@ind1=0 or @ind1=1]/marc:subfield[@code='a']">
					<dateCaptured encoding="iso8601">
						<xsl:value-of select="."/>
					</dateCaptured>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag=033][@ind1=2]/marc:subfield[@code='a'][1]">
					<dateCaptured encoding="iso8601" point="start">
						<xsl:value-of select="."/>
					</dateCaptured>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag=033][@ind1=2]/marc:subfield[@code='a'][2]">
					<dateCaptured encoding="iso8601" point="end">
						<xsl:value-of select="."/>
					</dateCaptured>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag=250]/marc:subfield[@code='a']">
					<edition>
						<xsl:value-of select="."/>
					</edition>
				</xsl:for-each>

				<xsl:for-each select="marc:leader">
					<issuance>
						<xsl:choose>
							<xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">monographic</xsl:when>
							<xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">continuing</xsl:when>							
						</xsl:choose>
					</issuance>
				</xsl:for-each>		
				
				<xsl:for-each select="marc:datafield[@tag=310]|marc:datafield[@tag=321]">
					<frequency>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">ab</xsl:with-param>
						</xsl:call-template>
					</frequency>
				</xsl:for-each>								
			</publicationInfo>


			<xsl:for-each select="marc:controlfield[@tag=041]">
				<xsl:for-each select="marc:subfield[@code='a' or @code='d' or @code='e']">
					<language>
						<xsl:choose>
							<xsl:when test="../marc:subfield[@code='2']">
								<xsl:attribute name="authority">rfc3066</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="authority">iso639-2b</xsl:attribute>						
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="text()"/>
					</language>
				</xsl:for-each>
			</xsl:for-each>			

			<xsl:variable name="controlField008-35-37" select="normalize-space(translate(substring($controlField008,36,3),'|#',''))"/>
			<xsl:if test="$controlField008-35-37">
				<language authority="iso639-2b">
					<xsl:value-of select="substring($controlField008,36,3)"/>
				</language>
			</xsl:if>

			<xsl:variable name="physicalDescription">
				<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a' or substring(.,12,1)='b']">
					<digitalOrigin>reformatted digital</digitalOrigin>
				</xsl:if>

				<xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"/>
				<xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>

				<xsl:variable name="check008-23">
					<xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='SE' or $typeOf008='MM'">
						<xsl:value-of select="true()"/>
					</xsl:if>
				</xsl:variable>

				<xsl:variable name="check008-29">
					<xsl:if test="$typeOf008='MP' or $typeOf008='VM'">
						<xsl:value-of select="true()"/>
					</xsl:if>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="($check008-23 and $controlField008-23='f') or ($check008-29 and $controlField008-29='f')">
						<form><controlled>braille</controlled></form>
					</xsl:when>
					<xsl:when test="$leader6 = 'm' or ($check008-23 and $controlField008-23='s') or ($check008-29 and $controlField008-29='s')">
						<form><controlled>electronic</controlled></form>
					</xsl:when>
					<xsl:when test="($check008-23 and $controlField008-23='b') or ($check008-29 and $controlField008-29='b')">
						<form><controlled>microfiche</controlled></form>
					</xsl:when>
					<xsl:when test="($check008-23 and $controlField008-23='a') or ($check008-29 and $controlField008-29='a')">
						<form><controlled>microfilm</controlled></form>
					</xsl:when>
				</xsl:choose>

				<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q'][string-length(.)>1]">
					<internetMediaType>
						<xsl:value-of select="."/>
					</internetMediaType>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag=256]/marc:subfield[@code='a']">
					<form>
						<unControlled>
							<xsl:value-of select="."/>
						</unControlled>
					</form>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag=300]">
					<extent>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abce</xsl:with-param>
						</xsl:call-template>
					</extent>
				</xsl:for-each>
			</xsl:variable>

			<xsl:if test="string-length(normalize-space($physicalDescription))">
				<physicalDescription>
					<xsl:copy-of select="$physicalDescription"/>
				</physicalDescription>
			</xsl:if>

			<xsl:for-each select="marc:datafield[@tag=520]">
				<abstract>
					<xsl:call-template name="uri"/>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</abstract>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=505]">
				<tableOfContents>
					<xsl:call-template name="uri"/>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">agrt</xsl:with-param>
					</xsl:call-template>
				</tableOfContents>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=521]">
				<targetAudience>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</targetAudience>
			</xsl:for-each>

			<xsl:if test="$typeOf008='BK' or $typeOf008='CF' or $typeOf008='MU' or $typeOf008='VM'">
				<xsl:variable name="controlField008-22" select="substring($controlField008,23,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-22='d'">
						<targetAudience>adolescent</targetAudience>
					</xsl:when>
					<xsl:when test="$controlField008-22='e'">
						<targetAudience>adult</targetAudience>
					</xsl:when>
					<xsl:when test="$controlField008-22='g'">
						<targetAudience>general</targetAudience>
					</xsl:when>
					<xsl:when test="$controlField008-22='b' or $controlField008-22='c' or $controlField008-22='j'">
						<targetAudience>juvenile</targetAudience>
					</xsl:when>
					<xsl:when test="$controlField008-22='a'">
						<targetAudience>preschool</targetAudience>
					</xsl:when>
					<xsl:when test="$controlField008-22='f'">
						<targetAudience>specialized</targetAudience>
					</xsl:when>
				</xsl:choose>
			</xsl:if>

			<!-- Not in mapping but in conversion -->
			<xsl:for-each select="marc:datafield[@tag=245]/marc:subfield[@code='c']">
				<note type="statement of responsibility">
					<xsl:value-of select="."/>
				</note>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=500]">
				<note>
					<xsl:value-of select="marc:subfield[@code='a']"/>
					<xsl:call-template name="uri"/>
				</note>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=511]">
				<note type="performers">
					<xsl:call-template name="uri"/>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</note>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=518]">
				<note type="venue">
					<xsl:call-template name="uri"/>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</note>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=501 or @tag=502 or @tag=504 or @tag=506 or @tag=507 or @tag=508 or @tag=510 or @tag=513 or @tag=514 or @tag=515 or @tag=516 or @tag=522 or @tag=524 or @tag=525 or @tag=526 or @tag=530 or @tag=533 or @tag=534 or @tag=535 or @tag=536 or @tag=538 or @tag=540 or @tag=541 or @tag=544 or @tag=545 or @tag=546 or @tag=547 or @tag=550 or @tag=552 or @tag=555 or @tag=556 or @tag=561 or @tag=562 or @tag=565 or @tag=567 or @tag=580 or @tag=581 or @tag=583 or @tag=584 or @tag=585 or @tag=586]">
				<note>
					<xsl:call-template name="uri"/>
					<xsl:variable name="str">
						<xsl:for-each select="marc:subfield[@code!='6' or @code!='8']">
							<xsl:value-of select="."/><xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
				</note>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=034][marc:subfield[@code='d' or @code='e' or @code='f' or @code='g']]">
				<cartographics>
					<coordinates>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">defg</xsl:with-param>
						</xsl:call-template>
					</coordinates>
				</cartographics>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=255]">
				<cartographics>
					<xsl:for-each select="marc:subfield[@code='c']">
						<coordinates>
							<xsl:value-of select="."/>
						</coordinates>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code='a']">
						<scale>
							<xsl:value-of select="."/>
						</scale>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code='b']">
						<projection>
							<xsl:value-of select="."/>
						</projection>	
					</xsl:for-each>
				</cartographics>
			</xsl:for-each>

			<xsl:apply-templates select="marc:datafield[653 >= @tag and @tag >= 600]"/>

			<xsl:for-each select="marc:datafield[@tag=752]">
				<subject>
					<hierarchicalGeographic>
						<xsl:for-each select="marc:subfield[@code='a']">
							<country>
								<xsl:value-of select="."/>
							</country>
						</xsl:for-each> 	
						<xsl:for-each select="marc:subfield[@code='b']">
							<state>
								<xsl:value-of select="."/>
							</state>
						</xsl:for-each> 	
						<xsl:for-each select="marc:subfield[@code='c']">
							<county>
								<xsl:value-of select="."/>
							</county>
						</xsl:for-each> 	
						<xsl:for-each select="marc:subfield[@code='d']">
							<city>
								<xsl:value-of select="."/>
							</city>
						</xsl:for-each> 	
					</hierarchicalGeographic>
				</subject>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=050]">
				<xsl:for-each select="marc:subfield[@code='b']">
					<classification authority="lcc">
						<xsl:value-of select="preceding-sibling::marc:subfield[@code='a'][1]"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="text()"/>
					</classification>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='a'][not(following-sibling::marc:subfield[@code='b'])]">
					<classification authority="lcc">
						<xsl:value-of select="text()"/>
					</classification>
				</xsl:for-each>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=082]">
				<classification authority="ddc">
					<xsl:if test="marc:subfield[@code='2']">
						<xsl:attribute name="edition">
							<xsl:value-of select="marc:subfield[@code='2']"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=080]">
				<classification authority="udc">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abx</xsl:with-param>
					</xsl:call-template>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=060]">
				<classification authority="nlm">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=086][@ind1=0]">
				<classification authority="sudocs">
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=086][@ind1=1]">
				<classification authority="candoc">
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=086]">
				<classification>
					<xsl:attribute name="authority">
						<xsl:value-of select="marc:subfield[@code='2']"/>
					</xsl:attribute>						
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=084]">
				<classification>
					<xsl:attribute name="authority">
						<xsl:value-of select="marc:subfield[@code='2']"/>
					</xsl:attribute>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</classification>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=440]">
				<relatedItem type="series">
					<titleInfo>
						<title>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">av</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="part"/>
						</title>
					</titleInfo>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=490][@ind1=0]">
				<relatedItem type="series">
					<titleInfo>
						<title>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">av</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="part"/>
						</title>
					</titleInfo>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=534]">
				<relatedItem type="original">
					<xsl:call-template name="relatedTitle"/>
					<xsl:call-template name="relatedName"/>
					<xsl:call-template name="relatedIdentifierISSN"/>
					<xsl:for-each select="marc:subfield[@code='z']">
						<identifier type="isbn">
							<xsl:value-of select="."/>
						</identifier>
					</xsl:for-each>
					<xsl:call-template name="relatedNote"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=700][marc:subfield[@code='t']]">
				<relatedItem>
					<xsl:call-template name="constituentOrRelatedType"/>
					<titleInfo>
						<title>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="afterCodes">g</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="part"/>
					</titleInfo>
					<name type="personal">
						<namePart>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">abcq</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="beforeCodes">g</xsl:with-param>
							</xsl:call-template>							
						</namePart>
						<xsl:call-template name="nameDate"/>
						<xsl:for-each select="marc:subfield[@code='e']">
							<role>
								<xsl:value-of select="."/>
							</role>
						</xsl:for-each>
					</name>
					<xsl:call-template name="relatedForm"/>
					<xsl:call-template name="relatedIdentifierISSN"/>
				</relatedItem>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=710][marc:subfield[@code='t']]">
				<relatedItem>
					<xsl:call-template name="constituentOrRelatedType"/>
					<titleInfo>
						<title>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="afterCodes">dg</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="relatedPart"/>
					</titleInfo>
					<name type="corporate">
						<xsl:for-each select="marc:subfield[@code='a']">
							<namePart>
								<xsl:value-of select="."/>
							</namePart>
						</xsl:for-each>
						<xsl:for-each select="marc:subfield[@code='b']">
							<namePart>
								<xsl:value-of select="."/>
							</namePart>
						</xsl:for-each>
						<xsl:variable name="tempNamePart">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">c</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="beforeCodes">dgn</xsl:with-param>
							</xsl:call-template>							
						</xsl:variable>
						<xsl:if test="normalize-space($tempNamePart)">
							<namePart>
								<xsl:value-of select="$tempNamePart"/>
							</namePart>
						</xsl:if>
						<xsl:for-each select="marc:subfield[@code='e']">
							<role>
								<xsl:value-of select="."/>
							</role>
						</xsl:for-each>
					</name>
					<xsl:call-template name="relatedForm"/>
					<xsl:call-template name="relatedIdentifierISSN"/>
				</relatedItem>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=711][marc:subfield[@code='t']]">
				<relatedItem>
					<xsl:call-template name="constituentOrRelatedType"/>
					<titleInfo>
						<title>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">tfklsv</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="afterCodes">g</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="relatedPart"/>
					</titleInfo>
					<name type="conference">
						<namePart>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">aqdc</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="beforeCodes">gn</xsl:with-param>
							</xsl:call-template>							
						</namePart>
					</name>
					<xsl:call-template name="relatedForm"/>
					<xsl:call-template name="relatedIdentifierISSN"/>
				</relatedItem>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=730][@ind2=2]">
				<relatedItem>
					<xsl:call-template name="constituentOrRelatedType"/>
					<titleInfo>
						<title>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">adfgklmorsv</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="part"/>
					</titleInfo>
					<xsl:call-template name="relatedForm"/>
					<xsl:call-template name="relatedIdentifierISSN"/>
				</relatedItem>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=740][@ind2=2]">
				<relatedItem>
					<xsl:call-template name="constituentOrRelatedType"/>
					<titleInfo>
						<title>					
							<xsl:value-of select="marc:subfield[@code='a']"/>
						</title>
						<xsl:call-template name="part"/>
					</titleInfo>
					<xsl:call-template name="relatedForm"/>
				</relatedItem>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=760]|marc:datafield[@tag=762]">
				<relatedItem type="series">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=765]|marc:datafield[@tag=767]|marc:datafield[@tag=775]|marc:datafield[@tag=777]|marc:datafield[@tag=787]">
				<relatedItem type="related">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=770]|marc:datafield[@tag=774]">
				<relatedItem type="constituent">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=772]|marc:datafield[@tag=773]">
				<relatedItem type="host">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=776]">
				<relatedItem type="reproduction">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=780]">
				<relatedItem type="preceding">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=785]">
				<relatedItem type="succeeding">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=786]">
				<relatedItem type="original">
					<xsl:call-template name="relatedItem76X-78X"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=800]">
				<relatedItem type="series">
					<titleInfo>
						<title>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="afterCodes">g</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="part"/>
					</titleInfo>
					<name type="personal">
						<namePart>
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString">
									<xsl:call-template name="specialSubfieldSelect">
										<xsl:with-param name="anyCodes">abcq</xsl:with-param>
										<xsl:with-param name="axis">t</xsl:with-param>
										<xsl:with-param name="beforeCodes">g</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</namePart>
						<xsl:call-template name="nameDate"/>
						<xsl:for-each select="marc:subfield[@code='e']">
							<role>
								<xsl:value-of select="."/>
							</role>
						</xsl:for-each>
					</name>
					<xsl:call-template name="relatedForm"/>
				</relatedItem>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=810]">
				<relatedItem type="series">
					<titleInfo>
						<title>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="afterCodes">dg</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="relatedPart"/>
					</titleInfo>
					<name type="corporate">
						<xsl:for-each select="marc:subfield[@code='a']">
							<namePart>
								<xsl:value-of select="."/>
							</namePart>
						</xsl:for-each>
						<xsl:for-each select="marc:subfield[@code='b']">
							<namePart>
								<xsl:value-of select="."/>
							</namePart>
						</xsl:for-each>
						<namePart>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">c</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="beforeCodes">dgn</xsl:with-param>
							</xsl:call-template>							
						</namePart>
						<xsl:for-each select="marc:subfield[@code='e']">
							<role>
								<xsl:value-of select="."/>
							</role>
						</xsl:for-each>
					</name>
					<xsl:call-template name="relatedForm"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=811]">
				<relatedItem type="series">
					<titleInfo>
						<title>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">tfklsv</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="afterCodes">g</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="relatedPart"/>
					</titleInfo>
					<name type="conference">
						<namePart>
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">aqdc</xsl:with-param>
								<xsl:with-param name="axis">t</xsl:with-param>
								<xsl:with-param name="beforeCodes">gn</xsl:with-param>
							</xsl:call-template>							
						</namePart>
					</name>
					<xsl:call-template name="relatedForm"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=830]">
				<relatedItem type="series">
					<titleInfo>
						<title>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">adfgklmorsv</xsl:with-param>
							</xsl:call-template>
						</title>
						<xsl:call-template name="part"/>
					</titleInfo>
					<xsl:call-template name="relatedForm"/>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=856][@ind2=2]/marc:subfield[@code='q']">
				<relatedItem>
					<internetMediaType>
						<xsl:value-of select="."/>
					</internetMediaType>
				</relatedItem>	
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=020]/marc:subfield[@code='a']">
				<identifier type="isbn">
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=024][@ind1=0]/marc:subfield[@code='a']">
				<identifier type="isrc">
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=024][@ind1=2]/marc:subfield[@code='a']">
				<identifier type="ismn">
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=022]/marc:subfield[@code='a']">
				<identifier type="issn">
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=010]/marc:subfield[@code='a']">
				<identifier type="lccn">
					<xsl:value-of select="normalize-space(text())"/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=028]">
				<identifier>
					<xsl:attribute name="type">
						<xsl:choose>
							<xsl:when test="@ind1=0">issue number</xsl:when>
							<xsl:when test="@ind1=1">matrix number</xsl:when>
							<xsl:when test="@ind1=2">music plate</xsl:when>
							<xsl:when test="@ind1=3">music publisher</xsl:when>
							<xsl:when test="@ind1=4">videorecording identifier</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</identifier>
			</xsl:for-each>
		
			<xsl:for-each select="marc:datafield[@tag=024][@ind1=4]">
				<identifier type="sici">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='u']">
				<identifier>
					<xsl:attribute name="type">
						<xsl:choose>
							<xsl:when test="starts-with(.,'urn:doi') or starts-with(.,'doi:')">doi</xsl:when>
							<xsl:otherwise>uri</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=024][@ind1=1]/marc:subfield[@code='a']">
				<identifier type="upc">
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=852]">
				<location>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abj</xsl:with-param>
					</xsl:call-template>
				</location>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=506]">
				<accessCondition type="restrictionOnAccess">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abcd35</xsl:with-param>
					</xsl:call-template>
				</accessCondition>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=540]">
				<accessCondition type="useAndReproduction">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abcde35</xsl:with-param>
					</xsl:call-template>
				</accessCondition>
			</xsl:for-each>

			<recordInfo>
				<xsl:for-each select="marc:datafield[@tag=040]">
					<recordContentSource>
						<xsl:value-of select="marc:subfield[@code='a']"/>
					</recordContentSource>
				</xsl:for-each>

				<xsl:for-each select="marc:controlfield[@tag=008]">
					<recordCreationDate encoding="marc">
						<xsl:value-of select="substring(.,1,6)"/>
					</recordCreationDate>
				</xsl:for-each>		
			
				<xsl:for-each select="marc:controlfield[@tag=005]">
					<recordChangeDate encoding="iso8601">
						<xsl:value-of select="."/>
					</recordChangeDate>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=999]">
                                        <recordIdentifier>
                                                <xsl:value-of select="marc:subfield[@code='c']"/>
                                        </recordIdentifier>
                                </xsl:for-each>
<!--
				<xsl:for-each select="marc:controlfield[@tag=001]">
					<recordIdentifier>
						<xsl:if test="../marc:controlfield[@tag=003]">
							<xsl:attribute name="source">
								<xsl:value-of select="../marc:controlfield[@tag=003]"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="."/>
					</recordIdentifier>
				</xsl:for-each>
-->
			</recordInfo>
		</mods>
	</xsl:template>

	<xsl:template name="displayForm">
		<xsl:for-each select="marc:subfield[@code='c']">
			<displayForm>
				<xsl:value-of select="."/>
			</displayForm>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="affiliation">
		<xsl:for-each select="marc:subfield[@code='u']">
			<affiliation>
				<xsl:value-of select="."/>
			</affiliation>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="uri">
		<xsl:for-each select="marc:subfield[@code='u']">
			<xsl:attribute name="xlink:href">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="role">
		<xsl:choose>
			<xsl:when test="marc:subfield[@code='e']">
				<role><xsl:value-of select="marc:subfield[@code='e']"/></role>
			</xsl:when>
			<xsl:when test="marc:subfield[@code='4']">
				<xsl:for-each select="marc:subfield[@code='4']">
					<role><xsl:value-of select="text()"/></role>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="part">
		<xsl:variable name="partNumber">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">n</xsl:with-param>
				<xsl:with-param name="anyCodes">n</xsl:with-param>
				<xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="partName">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">p</xsl:with-param>
				<xsl:with-param name="anyCodes">p</xsl:with-param>
				<xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($partNumber))">
			<partNumber>
				<xsl:value-of select="$partNumber"/>
			</partNumber>
		</xsl:if>
		<xsl:if test="string-length(normalize-space($partName))">
			<partName>
				<xsl:value-of select="$partName"/>
			</partName>
		</xsl:if>
	</xsl:template>

	<xsl:template name="relatedPart">
		<xsl:for-each select="marc:subfield[@code='n'][preceding-sibling::marc:subfield[@code='t']]">
			<partNumber>
				<xsl:value-of select="."/>
			</partNumber>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='p']">
			<partName>
				<xsl:value-of select="."/>
			</partName>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedName">
		<xsl:for-each select="marc:subfield[@code='a']">
			<name>
				<namePart>
					<xsl:value-of select="."/>
				</namePart>
			</name>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedForm">
		<xsl:for-each select="marc:subfield[@code='h']">
			<physicalDescription>
				<form>
					<unControlled>
						<xsl:value-of select="."/>
					</unControlled>
				</form>
			</physicalDescription>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedExtent">
		<xsl:for-each select="marc:subfield[@code='h']">
			<physicalDescription>
				<extent>
					<xsl:value-of select="."/>
				</extent>
			</physicalDescription>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedNote">
		<xsl:for-each select="marc:subfield[@code='n']">
			<note>
				<xsl:value-of select="."/>
			</note>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedIdentifierISSN">
		<xsl:for-each select="marc:subfield[@code='x']">
			<identifier type="issn">
				<xsl:value-of select="."/>
			</identifier>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedIdentifierLocal">
		<xsl:for-each select="marc:subfield[@code='w']">
			<identifier type="local">
				<xsl:value-of select="."/>
			</identifier>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedIdentifier">
		<xsl:for-each select="marc:subfield[@code='o']">
			<identifier>
				<xsl:value-of select="."/>
			</identifier>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedItem76X-78X">
		<xsl:call-template name="relatedTitle76X-78X"/>
		<xsl:call-template name="relatedName"/>
		<xsl:call-template name="relatedExtent"/>
		<xsl:call-template name="relatedIdentifier"/>
		<xsl:call-template name="relatedIdentifierISSN"/>
		<xsl:call-template name="relatedIdentifierLocal"/>
		<xsl:call-template name="relatedNote"/>
	</xsl:template>

	<xsl:template name="subjectGeographicZ">
		<geographic>
			<xsl:value-of select="."/>
		</geographic>			
	</xsl:template>

	<xsl:template name="subjectTemporalY">
		<temporal>
			<xsl:value-of select="."/>
		</temporal>			
	</xsl:template>

	<xsl:template name="subjectTopic">
		<topic>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</topic>
	</xsl:template>

	<xsl:template name="nameABCDN">
		<xsl:for-each select="marc:subfield[@code='a']">
			<namePart>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</namePart>					
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='b']">
			<namePart>
				<xsl:value-of select="."/>
			</namePart>					
		</xsl:for-each>
		<xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
			<namePart>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">cdn</xsl:with-param>
				</xsl:call-template>
			</namePart>
		</xsl:if>
	</xsl:template>

	<xsl:template name="nameABCDQ">
		<namePart>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abcq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</namePart>
		<xsl:call-template name="nameDate"/>
	</xsl:template>

	<xsl:template name="nameACDEQ">
		<namePart>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">acdeq</xsl:with-param>
			</xsl:call-template>
		</namePart>
	</xsl:template>

	<xsl:template name="constituentOrRelatedType">
		<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="@ind2=2">constituent</xsl:when>
				<xsl:otherwise>related</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="relatedTitle">
		<xsl:for-each select="marc:subfield[@code='t']">
			<titleInfo>
				<title>
					<xsl:value-of select="."/>
				</title>
			</titleInfo>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedTitle76X-78X">
		<titleInfo>
			<xsl:for-each select="marc:subfield[@code='t']">
				<title>
					<xsl:value-of select="."/>
				</title>
			</xsl:for-each>
			<xsl:for-each select="marc:subfield[@code='g']">
				<partNumber>
					<xsl:value-of select="."/>
				</partNumber>
			</xsl:for-each>
		</titleInfo>
	</xsl:template>

	<xsl:template name="nameDate">
		<xsl:for-each select="marc:subfield[@code='d']">
			<namePart type="date">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</namePart>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="subjectAuthority">
		<xsl:attribute name="authority">
			<xsl:choose>
			<xsl:when test="@ind2=0">lcsh</xsl:when>
			<xsl:when test="@ind2=1">lcshac</xsl:when>
			<xsl:when test="@ind2=2">mesh</xsl:when>
			<xsl:when test="@ind2=3">csh</xsl:when>
			<xsl:when test="@ind2=5">nal</xsl:when>
			<xsl:when test="@ind2=6">rvm</xsl:when>
			<xsl:when test="@ind2=7"><xsl:value-of select="marc:subfield[@code='2']"/></xsl:when>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="subjectAnyOrder">
		<xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
			<xsl:choose>
				<xsl:when test="@code='v'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='x'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='y'">
					<xsl:call-template name="subjectTemporalY"/>
				</xsl:when>
				<xsl:when test="@code='z'">
					<xsl:call-template name="subjectGeographicZ"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

<!--	<xsl:template name="subfieldSelect">
		<xsl:param name="codes"/>
		<xsl:param name="delimeter"><xsl:text> </xsl:text></xsl:param>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
					<xsl:value-of select="text()"/><xsl:value-of select="$delimeter"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))"/>
	</xsl:template>
-->

	<xsl:template name="specialSubfieldSelect">
		<xsl:param name="anyCodes"/>
		<xsl:param name="axis"/>
		<xsl:param name="beforeCodes"/>
		<xsl:param name="afterCodes"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($anyCodes, @code) or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis]) or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
					<xsl:value-of select="text()"/><xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=600]">
		<subject>
			<xsl:call-template name="subjectAuthority"/>
			<name type="personal">
				<namePart>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">abcq</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</namePart>
				<xsl:call-template name="nameDate"/>
				<xsl:call-template name="affiliation"/>
				<xsl:call-template name="role"/>
			</name>
			<xsl:call-template name="subjectAnyOrder"/>
		</subject>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=610]">
		<subject>
			<xsl:call-template name="subjectAuthority"/>
			<name type="corporate">
				<xsl:for-each select="marc:subfield[@code='a']">
					<namePart>
						<xsl:value-of select="."/>
					</namePart>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<namePart>
						<xsl:value-of select="."/>
					</namePart>
				</xsl:for-each>
				<xsl:if test="marc:subfield[@code='c' or @code='d' or @code='n' or @code='p']">
					<namePart>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">cdnp</xsl:with-param>
						</xsl:call-template>
					</namePart>
				</xsl:if>
				<xsl:call-template name="role"/>
			</name>
			<xsl:call-template name="subjectAnyOrder"/>
		</subject>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=611]">
		<subject>
			<xsl:call-template name="subjectAuthority"/>
			<name type="conference">
				<namePart>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abcdeqnp</xsl:with-param>
					</xsl:call-template>
				</namePart>
				<xsl:for-each select="marc:subfield[@code='4']">
					<role>
						<xsl:value-of select="."/>
					</role>
				</xsl:for-each>
			</name>
			<xsl:call-template name="subjectAnyOrder"/>
		</subject>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=630]">
		<subject>
			<xsl:call-template name="subjectAuthority"/>
			<titleInfo>
				<title>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">adfhklor</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="part"/>			
				</title>
			</titleInfo>
			<xsl:call-template name="subjectAnyOrder"/>
		</subject>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=650]">
		<subject>
			<xsl:call-template name="subjectAuthority"/>
			<topic>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abcd</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</topic>
			<xsl:call-template name="subjectAnyOrder"/>
		</subject>
	</xsl:template>


	<xsl:template match="marc:datafield[@tag=651]">
		<subject>
			<xsl:call-template name="subjectAuthority"/>
			<xsl:for-each select="marc:subfield[@code='a']">
				<geographic>
					<xsl:value-of select="."/>
				</geographic>			
			</xsl:for-each>
			<xsl:call-template name="subjectAnyOrder"/>
		</subject>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=653]">
		<subject>
			<xsl:for-each select="marc:subfield[@code='a']">
				<topic>
					<xsl:value-of select="."/>
				</topic>			
			</xsl:for-each>
		</subject>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="yes" name="modstst2" userelativepaths="yes" externalpreview="no" url="..\..\..\..\..\..\marcxml\modstst2.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="no" name="modstest" userelativepaths="yes" externalpreview="no" url="..\..\..\..\..\..\marcxml\modstest.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="no" name="Scenario1" userelativepaths="yes" externalpreview="no" url="..\..\..\..\..\..\marcxml\t.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
