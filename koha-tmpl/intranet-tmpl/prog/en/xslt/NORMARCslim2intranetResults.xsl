<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha-community.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method = "html" indent="yes" omit-xml-declaration = "yes" />
    <xsl:key name="item-by-status" match="items:item" use="items:status"/>
    <xsl:key name="item-by-status-and-branch" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>

    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="marc:record">

        <xsl:variable name="hidelostitems" select="marc:sysprefs/marc:syspref[@name='hidelostitems']"/>
        <xsl:variable name="URLLinkText" select="marc:sysprefs/marc:syspref[@name='URLLinkText']"/>
        <xsl:variable name="Show856uAsImage" select="marc:sysprefs/marc:syspref[@name='Display856uAsImage']"/>
        <xsl:variable name="AlternateHoldingsField" select="substring(marc:sysprefs/marc:syspref[@name='AlternateHoldingsField'], 1, 3)"/>
        <xsl:variable name="AlternateHoldingsSubfields" select="substring(marc:sysprefs/marc:syspref[@name='AlternateHoldingsField'], 4)"/>
        <xsl:variable name="AlternateHoldingsSeparator" select="marc:sysprefs/marc:syspref[@name='AlternateHoldingsSeparator']"/>
        <xsl:variable name="UseAuthoritiesForTracings" select="marc:sysprefs/marc:syspref[@name='UseAuthoritiesForTracings']"/>
        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="leader19" select="substring($leader,20,1)"/>
        <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/>
        <xsl:variable name="controlField007" select="marc:controlfield[@tag=007]"/>
        <xsl:variable name="controlField007-00" select="substring($controlField007,1,1)"/>
        <xsl:variable name="controlField007-01" select="substring($controlField007,2,1)"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="field019b" select="marc:datafield[@tag=019]/marc:subfield[@code='b']"/>

        <xsl:variable name="typeOf008">
        <!-- Codes with upper case first letter below are from the NORMARC standard, lower case first letter are made up. -->
            <xsl:choose>
                <xsl:when test="$field019b='b' or $field019b='k' or $field019b='l' or $leader6='b'">Mon</xsl:when>
                <xsl:when test="$field019b='e' or contains($field019b,'ec') or contains($field019b,'ed') or contains($field019b,'ee') or contains($field019b,'ef') or $leader6='g'">FV</xsl:when>
                <xsl:when test="$field019b='c' or $field019b='d' or contains($field019b,'da') or contains($field019b,'db') or contains($field019b,'dc') or contains($field019b,'dd') or contains($field019b,'dg') or contains($field019b,'dh') or contains($field019b,'di') or contains($field019b,'dj') or contains($field019b,'dk') or $leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">Mus</xsl:when>
                <xsl:when test="$field019b='a' or contains($field019b,'ab') or contains($field019b,'aj') or $leader6='e' or $leader6='f'">Kar</xsl:when>
                <xsl:when test="$field019b='f' or $field019b='i' or contains($field019b,'ib') or contains($field019b,'ic') or contains($field019b,'fd') or contains($field019b,'ff') or contains($field019b,'fi') or $leader6='k'">gra</xsl:when>
                <xsl:when test="$field019b='g' or contains($field019b,'gb') or contains($field019b,'gd') or contains($field019b,'ge') or $leader6='m'">Fil</xsl:when>
                <xsl:when test="$leader6='o'">kom</xsl:when>
                <xsl:when test="$field019b='h' or $leader6='r'">trd</xsl:when>
                <xsl:when test="$field019b='j' or $leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='m' or $leader7='p'">Mon</xsl:when>
                        <xsl:when test="$field019b='j' or $leader7='b' or $leader7='s'">Per</xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"/>
        <xsl:variable name="controlField008-21" select="substring($controlField008,22,1)"/>
        <xsl:variable name="controlField008-22" select="substring($controlField008,23,1)"/>
        <xsl:variable name="controlField008-24" select="substring($controlField008,25,4)"/>
        <xsl:variable name="controlField008-26" select="substring($controlField008,27,1)"/>
        <xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
        <xsl:variable name="controlField008-34" select="substring($controlField008,35,1)"/>
        <xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
        <xsl:variable name="controlField008-30-31" select="substring($controlField008,31,2)"/>

        <xsl:variable name="physicalDescription">

            <!-- 019$b from BSMARC -->

            <xsl:if test="$field019b">
				<xsl:if test="$field019b='a'"> Kartografisk materiale</xsl:if>
				<xsl:if test="contains($field019b,'ab')"> Atlas</xsl:if>
				<xsl:if test="contains($field019b,'aj')"> Kart</xsl:if>
				<xsl:if test="$field019b='b'"> Manuskripter</xsl:if>
				<xsl:if test="$field019b='c'"> Musikktrykk</xsl:if>
				<xsl:if test="$field019b='d'"> Lydopptak</xsl:if>
				<xsl:if test="contains($field019b,'da')"> Grammofonplate</xsl:if>
				<xsl:if test="contains($field019b,'db')"> Kassett</xsl:if>
				<xsl:if test="contains($field019b,'dc')"> Kompaktplate</xsl:if>
				<xsl:if test="contains($field019b,'dd')"> Avspiller med lydfil (eks. Digibøker)</xsl:if>
				<xsl:if test="contains($field019b,'dg')"> Musikk</xsl:if>
				<xsl:if test="contains($field019b,'dh')"> Språkkurs</xsl:if>
				<xsl:if test="contains($field019b,'di')"> Lydbok</xsl:if>
				<xsl:if test="contains($field019b,'dj')"> Annen tale/annet</xsl:if>
				<xsl:if test="contains($field019b,'dk')"> Kombidokument</xsl:if>
				<xsl:if test="$field019b='e'"> Film og video</xsl:if>
				<xsl:if test="contains($field019b,'ec')"> Filmspole</xsl:if>
				<xsl:if test="contains($field019b,'ed')"> Videokassett (VHS)</xsl:if>
				<xsl:if test="contains($field019b,'ee')"> Videoplate (DVD)</xsl:if>
				<xsl:if test="contains($field019b,'ef')"> Blu-ray-plate</xsl:if>
				<xsl:if test="$field019b='f'"> Grafisk materiale</xsl:if>
				<xsl:if test="contains($field019b,'fd')"> Dias</xsl:if>
				<xsl:if test="contains($field019b,'ff')"> Fotografi</xsl:if>
				<xsl:if test="contains($field019b,'fi')"> Kunstreproduksjon</xsl:if>
				<xsl:if test="$field019b='g'"> Elektroniske ressurser</xsl:if>
				<xsl:if test="contains($field019b,'gb')"> Diskett</xsl:if>
				<xsl:if test="contains($field019b,'gd')"> Optiske lagringsmedia (CD-ROM)</xsl:if>
				<xsl:if test="contains($field019b,'ge')"> Nettressurser</xsl:if>
				<xsl:if test="$field019b='h'"> Tredimensjonale gjenstander</xsl:if>
				<xsl:if test="$field019b='i'"> Mikroformer</xsl:if>
				<xsl:if test="contains($field019b,'ib')"> Mikrofilmspole</xsl:if>
				<xsl:if test="contains($field019b,'ic')"> Mikrofilmkort</xsl:if>
				<xsl:if test="$field019b='j'"> Periodika</xsl:if>
				<xsl:if test="$field019b='k'"> Artikler (i bøker eller periodika)</xsl:if>
				<xsl:if test="$field019b='l'"> Fysiske bøker</xsl:if>
            </xsl:if>

            <!-- Check positions 00 and 01 of controlfield 007 -->

            <xsl:if test="$controlField007-00='a'">
		<!-- Kartografisk materiale (unntatt globus) -->
				<xsl:if test="$controlField007-01='a'">Anamorfisk kart</xsl:if>
				<xsl:if test="$controlField007-01='b'">Atlas</xsl:if>
				<xsl:if test="$controlField007-01='c'">Fantasikart</xsl:if>
				<xsl:if test="$controlField007-01='d'">Flykart</xsl:if>
				<xsl:if test="$controlField007-01='e'">Sjøkart</xsl:if>
				<xsl:if test="$controlField007-01='f'">Navigasjonskart</xsl:if>
				<xsl:if test="$controlField007-01='g'">Blokkdiagram</xsl:if>
				<xsl:if test="$controlField007-01='h'">Stjernekart</xsl:if>
				<xsl:if test="$controlField007-01='j'">Kart</xsl:if>
				<xsl:if test="$controlField007-01='k'">Kartprofil</xsl:if>
				<xsl:if test="$controlField007-01='l'">Fotokart</xsl:if>
				<xsl:if test="$controlField007-01='m'">Fotomosaikk</xsl:if>
				<xsl:if test="$controlField007-01='n'">Ortofoto</xsl:if>
				<xsl:if test="$controlField007-01='o'">Tegnet kart</xsl:if>
				<xsl:if test="$controlField007-01='p'">Trykt kart</xsl:if>
				<xsl:if test="$controlField007-01='q'">Terrengmodell</xsl:if>
				<xsl:if test="$controlField007-01='r'">Fjernanalysebilde</xsl:if>
				<xsl:if test="$controlField007-01='s'">Kartseksjon</xsl:if>
				<xsl:if test="$controlField007-01='t'">Plan</xsl:if>
				<xsl:if test="$controlField007-01='y'">Perspektivkart</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen karttype</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='c'">
		<!-- Maskinlesbar fil -->
				<xsl:if test="$controlField007-01='a'">Magnetisk-optisk plate</xsl:if>
				<xsl:if test="$controlField007-01='b'">Lagringsbrikke</xsl:if>
				<xsl:if test="$controlField007-01='c'">Optisk kassett</xsl:if>
				<xsl:if test="$controlField007-01='d'">Diskett</xsl:if>
				<xsl:if test="$controlField007-01='h'">Platelager (harddisk)</xsl:if>
				<xsl:if test="$controlField007-01='k'">Magnetbåndkassett</xsl:if>
				<xsl:if test="$controlField007-01='m'">Magnetbåndspole</xsl:if>
				<xsl:if test="$controlField007-01='n'">Fjerntilgang (online)</xsl:if>
				<xsl:if test="$controlField007-01='o'">Optisk plate</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annet lagringsmedium</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='d'">
		<!-- Globus -->
				<xsl:if test="$controlField007-01='a'">Stjerneglobus</xsl:if>
				<xsl:if test="$controlField007-01='b'">Planet- eller måneglobus</xsl:if>
				<xsl:if test="$controlField007-01='c'">Jordglobus</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen globustype</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='g'">
		<!-- Grafisk materiale som er tenkt projisert eller gjennomlyst -->
				<xsl:if test="$controlField007-01='h'">Hologram</xsl:if>
				<xsl:if test="$controlField007-01='o'">Billedbånd</xsl:if>
				<xsl:if test="$controlField007-01='p'">Stereobilde</xsl:if>
				<xsl:if test="$controlField007-01='r'">Røntgenbilde</xsl:if>
				<xsl:if test="$controlField007-01='s'">Dia</xsl:if>
				<xsl:if test="$controlField007-01='t'">Transparent</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen materialtype</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='h'">
		<!-- Mikroform -->
				<xsl:if test="$controlField007-01='a'">Vinduskort</xsl:if>
				<xsl:if test="$controlField007-01='c'">Mikrofilmkassett</xsl:if>
				<xsl:if test="$controlField007-01='d'">Mikrofilmspole</xsl:if>
				<xsl:if test="$controlField007-01='e'">Mikrofilmkort</xsl:if>
				<xsl:if test="$controlField007-01='g'">Mikro-opak</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen mikroformtype</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='k'">
		<!-- Grafisk materiale som er ugjennomtrengelig for lys -->
				<xsl:if test="$controlField007-01='c'">Collage</xsl:if> <!-- Originalt kunstverk -->
				<xsl:if test="$controlField007-01='d'">Tegning</xsl:if> <!-- Originalt kunstverk -->
				<xsl:if test="$controlField007-01='e'">Maleri</xsl:if> <!-- Originalt kunstverk -->
				<xsl:if test="$controlField007-01='g'">Fotografi - negativ</xsl:if>
				<xsl:if test="$controlField007-01='h'">Fotografi</xsl:if> <!-- Brukes også om ugjennomsiktige stereobilder. -->
				<xsl:if test="$controlField007-01='i'">Bilde</xsl:if> <!-- Brukes når en mer spesifikk betegnelse er ukjent eller uønsket. -->
				<xsl:if test="$controlField007-01='j'">Grafisk blad</xsl:if>
				<xsl:if test="$controlField007-01='k'">Flipover</xsl:if>
				<xsl:if test="$controlField007-01='l'">Teknisk tegning</xsl:if>
				<xsl:if test="$controlField007-01='m'">Studieplansje</xsl:if>
				<xsl:if test="$controlField007-01='n'">Plansje</xsl:if>
				<xsl:if test="$controlField007-01='o'">Billedkort</xsl:if>
				<xsl:if test="$controlField007-01='p'">Ordkort</xsl:if>
				<xsl:if test="$controlField007-01='q'">Symbolkort</xsl:if>
				<xsl:if test="$controlField007-01='r'">Kunstreproduksjon</xsl:if>
				<xsl:if test="$controlField007-01='s'">Postkort</xsl:if>
				<xsl:if test="$controlField007-01='t'">Plakat</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen materialtype</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='m'">
		<!-- Film -->
				<xsl:if test="$controlField007-01='c'">Filmsløyfe</xsl:if>
				<xsl:if test="$controlField007-01='f'">Filmkassett</xsl:if>
				<xsl:if test="$controlField007-01='r'">Filmspole</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen filmtype</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='s'">
		<!-- Lydopptak -->
				<xsl:if test="$controlField007-01='c'">Kompaktplate</xsl:if>
				<xsl:if test="$controlField007-01='d'">Grammofonplate</xsl:if>
				<xsl:if test="$controlField007-01='e'">Sylinder</xsl:if> <!-- Lydrull, voksrull, fonografsylinder -->
				<xsl:if test="$controlField007-01='g'">Sløyfekassett</xsl:if>
				<xsl:if test="$controlField007-01='i'">Filmlydspor</xsl:if>
				<xsl:if test="$controlField007-01='q'">Rull (pianorull/orgelrull)</xsl:if>
				<xsl:if test="$controlField007-01='s'">Lydkassett</xsl:if>
				<xsl:if test="$controlField007-01='t'">Lydbånd</xsl:if>
				<xsl:if test="$controlField007-01='w'">Wire</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annet lydmateriale</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='u'">
		<!-- Tre-dimensjonal gjenstand -->
				<xsl:if test="$controlField007-01='a'">Originalt kunstverk</xsl:if> <!-- F.eks. en skulptur. -->
				<xsl:if test="$controlField007-01='c'">Kunstreproduksjon</xsl:if>
				<xsl:if test="$controlField007-01='d'">Diorama</xsl:if>
				<xsl:if test="$controlField007-01='e'">Øvelsesmodell</xsl:if>
				<xsl:if test="$controlField007-01='g'">Spill</xsl:if>
				<xsl:if test="$controlField007-01='p'">Mikroskopdia</xsl:if>
				<xsl:if test="$controlField007-01='q'">Modell</xsl:if>
				<xsl:if test="$controlField007-01='r'">Realia</xsl:if>
				<xsl:if test="$controlField007-01='u'">Utstilling</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen type gjenstand</xsl:if>
            </xsl:if>

            <xsl:if test="$controlField007-00='v'">
		<!-- Videoopptak -->
				<xsl:if test="$controlField007-01='d'">Videoplate</xsl:if>
				<xsl:if test="$controlField007-01='f'">Videokassett</xsl:if>
				<xsl:if test="$controlField007-01='r'">Videospole</xsl:if>
				<xsl:if test="$controlField007-01='z'">Annen type videoopptak</xsl:if>
            </xsl:if>

        </xsl:variable>

	<a><xsl:attribute name="href">/cgi-bin/koha/catalogue/detail.pl?biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute><xsl:attribute name="class">title</xsl:attribute>

        <xsl:if test="marc:datafield[@tag=245]">
        <xsl:for-each select="marc:datafield[@tag=245]">
            <xsl:variable name="title">
                     <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">a</xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="marc:subfield[@code='b']">
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">b</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="marc:subfield[@code='h']">
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">h</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                <xsl:text> </xsl:text>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">np</xsl:with-param>
                     </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="titleChop">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="$title"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$titleChop"/>
        </xsl:for-each>
        </xsl:if>
    </a>

    <xsl:choose>
    <xsl:when test="marc:datafield[@tag=100] or marc:datafield[@tag=110] or marc:datafield[@tag=111] or marc:datafield[@tag=700] or marc:datafield[@tag=710] or marc:datafield[@tag=711]">
    <p class="author">av
    <xsl:for-each select="marc:datafield[@tag=100 or @tag=700]">
    <a>
    <xsl:choose>
        <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
            <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
        <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=au:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="nameABCDQ"/></a>
    <xsl:choose>
    <xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="marc:datafield[@tag=110 or @tag=710]">
    <a>
    <xsl:choose>
        <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
            <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
        <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=au:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="nameABCDN"/></a>
    <xsl:choose><xsl:when test="position()=last()"><xsl:text> </xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="marc:datafield[@tag=111 or @tag=711]">
        <xsl:choose>
        <xsl:when test="marc:subfield[@code='n']">
           <xsl:text> </xsl:text>
           <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">n</xsl:with-param>                              </xsl:call-template>
           <xsl:text> </xsl:text>
        </xsl:when>
        </xsl:choose>
    <a>
    <xsl:choose>
        <xsl:when test="marc:subfield[@code=9] and $UseAuthoritiesForTracings='1'">
            <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
        <xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=au:"<xsl:value-of select="marc:subfield[@code='a']"/>"</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="nameACDEQ"/></a>
    <xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>

    </xsl:for-each>
    </p>
    </xsl:when>
    </xsl:choose>

    <xsl:if test="marc:datafield[@tag=300]">
    <span class="results_summary description"><span class="label">Beskrivelse: </span>
        <xsl:for-each select="marc:datafield[@tag=300]">
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abce</xsl:with-param>
                </xsl:call-template>
               </xsl:with-param>
           </xsl:call-template>
                <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
        </xsl:for-each>
    </span>
   </xsl:if>

    <xsl:if test="marc:datafield[@tag=020]">
    <span class="results_summary isbn"><span class="label">ISBN: </span>
    <xsl:for-each select="marc:datafield[@tag=020]">
    <xsl:variable name="isbn" select="marc:subfield[@code='a']"/>
            <xsl:value-of select="marc:subfield[@code='a']"/>
            <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
    </xsl:for-each>
    </span>
    </xsl:if>

    <xsl:if test="marc:datafield[@tag=022]">
    <span class="results_summary issn"><span class="label">ISSN: </span>
    <xsl:for-each select="marc:datafield[@tag=022]">
            <xsl:value-of select="marc:subfield[@code='a']"/>
            <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
    </xsl:for-each>
    </span>
    </xsl:if>

    <xsl:if test="marc:datafield[@tag=250]">
	<span class="results_summary">
    <span class="label">Utgave: </span>
            <xsl:for-each select="marc:datafield[@tag=250]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>
	</span>
    </xsl:if>

    <span class="results_summary">
    <xsl:if test="$typeOf008!=''">
        <span class="label">Type: </span>

            <xsl:choose>
                <xsl:when test="$typeOf008='Mon'"><img src="/opac-tmpl/prog/famfamfam/silk/book.png" alt="Bok" title="Bok"/> Bok</xsl:when>
                <xsl:when test="$typeOf008='Per'"><img src="/opac-tmpl/prog/famfamfam/silk/newspaper.png" alt="Periodika" title="Periodika"/> Periodika</xsl:when>
                <xsl:when test="$typeOf008='Fil'"><img src="/opac-tmpl/prog/famfamfam/silk/computer_link.png" alt="Fil" title="Fil"/> Fil</xsl:when>
                <xsl:when test="$typeOf008='Kar'"><img src="/opac-tmpl/prog/famfamfam/silk/map.png" alt="Kart" title="Kart"/> Kart</xsl:when>
                <xsl:when test="$typeOf008='FV'"><img src="/opac-tmpl/prog/famfamfam/silk/film.png" alt="Film og video" title="Film og video"/> Film og video</xsl:when>
                <xsl:when test="$typeOf008='Mus'"><img src="/opac-tmpl/prog/famfamfam/silk/sound.png" alt="Musikktrykk og lydopptak" title="Musikktrykk og lydopptak"/> Musikk</xsl:when>
                <xsl:when test="$typeOf008='gra'"> Grafisk materiale</xsl:when>
                <xsl:when test="$typeOf008='kom'"> Kombidokumenter</xsl:when>
                <xsl:when test="$typeOf008='trd'"> Tre-dimensjonale gjenstander</xsl:when>
            </xsl:choose>
    </xsl:if>
    <xsl:if test="string-length(normalize-space($physicalDescription))">
        <span class="label">; Format: </span><xsl:copy-of select="$physicalDescription"></xsl:copy-of>
    </xsl:if>

        <xsl:if test="$controlField008-21 or $controlField008-22 or $controlField008-24 or $controlField008-26 or $controlField008-29 or $controlField008-34 or $controlField008-33 or $controlField008-30-31 or $controlField008-33">

        <xsl:if test="$typeOf008='Per'">
        <xsl:if test="$controlField008-21 and contains($controlField008-21,'amnpz')">
        <span class="label">; Type periodikum: </span>
        </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-21='a'">Årbok</xsl:when>
				<xsl:when test="$controlField008-21='m'">Monografiserie</xsl:when>
				<xsl:when test="$controlField008-21='n'">Avis</xsl:when>
				<xsl:when test="$controlField008-21='p'">Tidsskrift</xsl:when>
				<xsl:when test="$controlField008-21='z'">Andre typer periodika</xsl:when>
            </xsl:choose>
        </xsl:if>

        <xsl:if test="$typeOf008='Mon' or $typeOf008='Per'">
        <span class="label">; Innhold: </span>
            <xsl:choose>
                <xsl:when test="contains($controlField008-24,'a')"> Sammendrag(abstracts)/Referatorganer</xsl:when>
                <xsl:when test="contains($controlField008-24,'b')"> Bibliografier</xsl:when>
                <xsl:when test="contains($controlField008-24,'c')"> Kataloger</xsl:when>
                <xsl:when test="contains($controlField008-24,'d')"> Ordbøker</xsl:when>
                <xsl:when test="contains($controlField008-24,'e')"> Konversasjonsleksika</xsl:when>
                <xsl:when test="contains($controlField008-24,'f')"> Håndbøker</xsl:when>
                <xsl:when test="contains($controlField008-24,'h')"> Referanseverk</xsl:when>
                <xsl:when test="contains($controlField008-24,'i')"> Registre</xsl:when>
                <xsl:when test="contains($controlField008-24,'k')"> Diskografier</xsl:when>
                <xsl:when test="contains($controlField008-24,'l')"> Lover og forskrifter</xsl:when>
                <xsl:when test="contains($controlField008-24,'m')"> Hovedoppgaver/diplomoppgaver</xsl:when>
                <xsl:when test="contains($controlField008-24,'n')"> Oversiktsverker innenfor et emne</xsl:when>
                <xsl:when test="contains($controlField008-24,'o')"> Anmeldelser</xsl:when>
                <xsl:when test="contains($controlField008-24,'q')"> Filmografier</xsl:when>
                <xsl:when test="contains($controlField008-24,'r')"> Adressebøker</xsl:when>
                <xsl:when test="contains($controlField008-24,'s')"> Statistikker</xsl:when>
                <xsl:when test="contains($controlField008-24,'t')"> Tekniske rapporter</xsl:when>
                <xsl:when test="contains($controlField008-24,'x')"> Doktoravhandlinger/lisensiat-avhandlinger</xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$controlField008-29='1'">
                    Konferansepublikasjon
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='CF'">
            <xsl:if test="$controlField008-26='a' or $controlField008-26='b' or $controlField008-26='c' or $controlField008-26='d' or $controlField008-26='e' or $controlField008-26='f' or $controlField008-26='g' or $controlField008-26='h' or $controlField008-26='i' or $controlField008-26='j'">
            <span class="label">; Type maskinlesbar fil: </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-26='a'">Numeriske data</xsl:when>
                <xsl:when test="$controlField008-26='b'">Programvare</xsl:when>
                <xsl:when test="$controlField008-26='c'">Grafiske data</xsl:when>
                <xsl:when test="$controlField008-26='d'">Tekst</xsl:when>
                <xsl:when test="$controlField008-26='e'">Bibliografiske data</xsl:when>
                <xsl:when test="$controlField008-26='f'">Font</xsl:when>
                <xsl:when test="$controlField008-26='g'">Spill</xsl:when>
                <xsl:when test="$controlField008-26='h'">Lyd</xsl:when>
                <xsl:when test="$controlField008-26='i'">Interaktivt multimedium</xsl:when>
                <xsl:when test="$controlField008-26='j'">Online tjeneste</xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='Mon'">
            <xsl:if test="(substring($controlField008,25,1)='j') or (substring($controlField008,25,1)='1') or ($controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d')">
            <span class="label">; Innhold: </span>
            </xsl:if>
            <xsl:if test="substring($controlField008,31,1)='1' or substring($controlField008,31,1)='a' or substring($controlField008,31,1)='b'">
                Festskrift
            </xsl:if>
            <xsl:if test="$controlField008-34='a' or $controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d'">
                Biografi
            </xsl:if>

            <xsl:if test="$controlField008-33 and $controlField008-33!='^' and $controlField008-33!=' '">
            <span class="label">; Litterær form: </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-33='0'">Ikke skjønnlitteratur</xsl:when>
                <xsl:when test="$controlField008-33='l'">Lærebok, brevkurs</xsl:when>
                <xsl:when test="$controlField008-33='1'">Skjønnlitteratur</xsl:when>
                <xsl:when test="$controlField008-33='r'">Roman</xsl:when>
                <xsl:when test="$controlField008-33='n'">Novelle / fortelling</xsl:when>
                <xsl:when test="$controlField008-33='d'">Dikt</xsl:when>
                <xsl:when test="$controlField008-33='s'">Skuespill</xsl:when>
                <xsl:when test="$controlField008-33='t'">Tegneserie</xsl:when>
                <xsl:when test="$controlField008-33='a'">Antologi</xsl:when>
                <xsl:when test="$controlField008-33='p'">Pekebok</xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='Mus' and $controlField008-30-31 and $controlField008-30-31!='^^' and $controlField008-30-31!='  '">
            <span class="label">; Litterær form: </span> <!-- Literary text for sound recordings -->
            <xsl:if test="contains($controlField008-30-31,'a')">Selvbiografier</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'b')">Biografier</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'c')">Samtaler og diskusjoner</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'d')">Drama</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'e')">Essays</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'f')">Romaner</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'g')">Rapporter, referater</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'h')">Fortellinger, noveller</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'i')">Undervisning</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'j')">Språkundervisning</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'k')">Komedier</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'l')">Foredrag, taler</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'m')">Memoarer</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'o')">Eventyr</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'p')">Dikt</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'r')">Fremføring av alle typer ikke-musikalske produksjoner</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'s')">Lyder (f.eks. fuglelyder)</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'t')">Intervjuer</xsl:if>
            <xsl:if test="contains($controlField008-30-31,'z')">Andre typer innhold</xsl:if>
        </xsl:if>

        </xsl:if>

    <xsl:if test="$typeOf008='Mon'">
        <span class="label">; Målgruppe: </span>
        <xsl:choose>
			<xsl:when test="$controlField008-22='a'">Voksne;</xsl:when>
			<xsl:when test="$controlField008-22='b'">Billedbøker for voksne;</xsl:when>
			<xsl:when test="$controlField008-22='j'">Barn og ungdom;</xsl:when>
			<xsl:when test="$controlField008-22='k'">Billedbøker;</xsl:when>
			<xsl:when test="$controlField008-22='l'">Barn i alderen til og med 5 år;</xsl:when>
			<xsl:when test="$controlField008-22='m'">Elever på 1. til 3. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='n'">Elever på 4. og 5. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='o'">Elever på 6. og 7. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='p'">Elever på ungdomstrinnet;</xsl:when>
			<xsl:when test="$controlField008-22='v'">Billedbøker for barn i alderen til og med 5 år;</xsl:when>
			<xsl:when test="$controlField008-22='w'">Billedbøker for elever på 1. til 3. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='x'">Billedbøker for elever på 4. og 5. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='y'">Billedbøker for elever på 6. og 7. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='z'">Billedbøker for elever på ungdomstrinnet;</xsl:when>
			<xsl:when test="$controlField008-22='f'">Spesialisert;</xsl:when>
			<xsl:when test="$controlField008-22='q'">Lettlest;</xsl:when>
			<xsl:when test="$controlField008-22='r'">For psykisk utviklingshemmede;</xsl:when>
			<xsl:when test="$controlField008-22='s'">Storskrift;</xsl:when>
			<xsl:when test="$controlField008-22='g'">Generell;</xsl:when>
			<xsl:when test="$controlField008-22='u'">Ukjent;</xsl:when>
        </xsl:choose>
    </xsl:if>
    <xsl:if test="$typeOf008='Per'">
        <span class="label">; Målgruppe: </span>
        <xsl:choose>
			<xsl:when test="$controlField008-22='a'">Voksne;</xsl:when>
			<xsl:when test="$controlField008-22='b'">Tegneserier for voksne;</xsl:when>
			<xsl:when test="$controlField008-22='j'">Barn og ungdom;</xsl:when>
			<xsl:when test="$controlField008-22='k'">Tegneserier;</xsl:when>
			<xsl:when test="$controlField008-22='l'">Barn i alderen til og med 5 år;</xsl:when>
			<xsl:when test="$controlField008-22='m'">Elever på 1. til 3. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='n'">Elever på 4. og 5. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='o'">Elever på 6. og 7. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='p'">Elever på ungdomstrinnet;</xsl:when>
			<xsl:when test="$controlField008-22='v'">Tegneserier for barn i alderen til og med 5 år;</xsl:when>
			<xsl:when test="$controlField008-22='w'">Tegneserier for elever på 1. til 3. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='x'">Tegneserier for elever på 4. og 5. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='y'">Tegneserier for elever på 6. og 7. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='z'">Tegneserier for elever på ungdomstrinnet;</xsl:when>
			<xsl:when test="$controlField008-22='f'">Spesialisert;</xsl:when>
			<xsl:when test="$controlField008-22='q'">Lettlest;</xsl:when>
			<xsl:when test="$controlField008-22='r'">For psykisk utviklingshemmede;</xsl:when>
			<xsl:when test="$controlField008-22='s'">Storskrift;</xsl:when>
			<xsl:when test="$controlField008-22='g'">Generell;</xsl:when>
			<xsl:when test="$controlField008-22='u'">Ukjent;</xsl:when>
        </xsl:choose>
    </xsl:if>
    <xsl:if test="$typeOf008='Fil' or $typeOf008='Mus'">
        <span class="label">; Målgruppe: </span>
        <xsl:choose>
			<xsl:when test="$controlField008-22='a'">Voksne;</xsl:when>
			<xsl:when test="$controlField008-22='j'">Barn og ungdom;</xsl:when>
			<xsl:when test="$controlField008-22='1'">Barn i alderen til og med 5 år;</xsl:when>
			<xsl:when test="$controlField008-22='m'">Elever på 1. til 3. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='n'">Elever på 4. og 5. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='o'">Elever på 6. og 7. klassetrinn;</xsl:when>
			<xsl:when test="$controlField008-22='p'">Elever på ungdomstrinnet;</xsl:when>
			<xsl:when test="$controlField008-22='f'">Spesialisert;</xsl:when>
			<xsl:when test="$controlField008-22='q'">Lettlest;</xsl:when>
			<xsl:when test="$controlField008-22='r'">For psykisk utviklingshemmede;</xsl:when>
			<xsl:when test="$controlField008-22='s'">Storskrift;</xsl:when>
			<xsl:when test="$controlField008-22='g'">Generell;</xsl:when>
			<xsl:when test="$controlField008-22='u'">Ukjent;</xsl:when>
        </xsl:choose>
    </xsl:if>
    <xsl:if test="$typeOf008='FV'">
        <span class="label">; Målgruppe: </span>
        <xsl:choose>
			<xsl:when test="$controlField008-22='a'">Voksne;</xsl:when>
			<xsl:when test="$controlField008-22='1'">Voksne over 18 år;</xsl:when>
			<xsl:when test="$controlField008-22='2'">Voksne over 15 år;</xsl:when>
			<xsl:when test="$controlField008-22='j'">Barn og ungdom;</xsl:when>
			<xsl:when test="$controlField008-22='4'">Ungdom over 12 år;</xsl:when>
			<xsl:when test="$controlField008-22='5'">Barn over 7 år;</xsl:when>
			<xsl:when test="$controlField008-22='6'">Småbarn;</xsl:when>
			<xsl:when test="$controlField008-22='f'">Spesialisert;</xsl:when>
			<xsl:when test="$controlField008-22='g'">Generell;</xsl:when>
			<xsl:when test="$controlField008-22='u'">Ukjent;</xsl:when>
        </xsl:choose>
    </xsl:if>
	</span>

  <!-- Utgivelse, distribusjon osv -->
    <xsl:if test="marc:datafield[@tag=260]">
	<span class="results_summary">
    <span class="label">Utgiver: </span>
            <xsl:for-each select="marc:datafield[@tag=260]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcefg</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>
	</span>
    </xsl:if>

  <!-- Parallelltittel (R) -->
  <xsl:if test="marc:datafield[@tag=246]">
	<span class="results_summary">
    <span class="label">Parallelltittel: </span>
            <xsl:for-each select="marc:datafield[@tag=246]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>
	</span>
  </xsl:if>

    <xsl:if test="marc:datafield[@tag=856]">
         <span class="results_summary">
			   <span class="label">Online tilgang: </span>
                            <xsl:for-each select="marc:datafield[@tag=856]">
                            <xsl:variable name="SubqText"><xsl:value-of select="marc:subfield[@code='q']"/></xsl:variable>
				   <a><xsl:attribute name="href"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute>
                                    <xsl:choose>
                                     <xsl:when test="($Show856uAsImage='Results' or $Show856uAsImage='Both') and (substring($SubqText,1,6)='image/' or $SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
                                        <xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="marc:subfield[@code='y']"/></xsl:attribute><xsl:attribute name="height">100</xsl:attribute></xsl:element><xsl:text></xsl:text>
                                    </xsl:when>
                                    <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
                                        <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">y3z</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
					<xsl:choose>
					<xsl:when test="$URLLinkText!=''">
						<xsl:value-of select="$URLLinkText"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Klikk her for online tilgang</xsl:text>
					</xsl:otherwise>
					</xsl:choose>
                                    </xsl:when>
                                    </xsl:choose>
                                    </a>
                                    <xsl:choose>
                                    <xsl:when test="position()=last()"><xsl:text> </xsl:text></xsl:when>
                                    <xsl:otherwise> | </xsl:otherwise>
                                    </xsl:choose>
                            </xsl:for-each>
                            </span>
                        </xsl:if>
    </xsl:template>

    <xsl:template name="nameABCDQ">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">aq</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        <xsl:call-template name="termsOfAddress"/>
    </xsl:template>

    <xsl:template name="nameABCDN">
        <xsl:for-each select="marc:subfield[@code='a']">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
                <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">cdn</xsl:with-param>
                </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nameACDEQ">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">acdeq</xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="termsOfAddress">
        <xsl:if test="marc:subfield[@code='b' or @code='c']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bc</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nameDate">
        <xsl:for-each select="marc:subfield[@code='d']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="role">
        <xsl:for-each select="marc:subfield[@code='e']">
                    <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='4']">
                    <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="specialSubfieldSelect">
        <xsl:param name="anyCodes"/>
        <xsl:param name="axis"/>
        <xsl:param name="beforeCodes"/>
        <xsl:param name="afterCodes"/>
        <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
                <xsl:if test="contains($anyCodes, @code) or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis]) or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
                    <xsl:value-of select="text()"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
    </xsl:template>

    <xsl:template name="subtitle">
        <xsl:if test="marc:subfield[@code='b']">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="marc:subfield[@code='b']"/>
                    </xsl:with-param>
                </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="chopBrackets">
        <xsl:param name="chopString"></xsl:param>
        <xsl:variable name="string">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="$chopString"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="substring($string, 1,1)='['">
            <xsl:value-of select="substring($string,2, string-length($string)-2)"></xsl:value-of>
        </xsl:if>
        <xsl:if test="substring($string, 1,1)!='['">
            <xsl:value-of select="$string"></xsl:value-of>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
