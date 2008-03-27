<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method="html" indent="yes"/>
    <xsl:key name="item-by-status" match="items:item" use="items:status"/>
    <xsl:key name="item-by-status-and-branch" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>

    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="marc:record">
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
        <xsl:variable name="materialTypeLabel">
            <xsl:choose>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">Book</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">Serial</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">Book</xsl:when>
                <xsl:when test="$leader6='p'">Mixed Materials</xsl:when>
                <xsl:when test="$leader6='m'">Computer File</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">Map</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">Visual Material</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">Music</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genre">
        <xsl:if test="$typeOf008='SE'">
            <xsl:variable name="controlField008-21" select="substring($controlField008,22,1)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="$controlField008-21='d'">
                    <span class="label">; Genre: </span>database;
                </xsl:when>
                <xsl:when test="$controlField008-21='l'">
                    <span class="label">; Genre: </span>loose-leaf;
                </xsl:when>
                <xsl:when test="$controlField008-21='m'">
                    <span class="label">; Genre: </span>series;
                </xsl:when>
                <xsl:when test="$controlField008-21='n'">
                    <span class="label">; Genre: </span>newspaper;
                </xsl:when>
                <xsl:when test="$controlField008-21='p'">
                    <span class="label">; Genre: </span>periodical;
                </xsl:when>
                <xsl:when test="$controlField008-21='w'">
                    <span class="label">; Genre: </span>web site;
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='BK' or $typeOf008='SE'">
            <xsl:variable name="controlField008-24" select="substring($controlField008,25,4)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="contains($controlField008-24,'a')">
                    <span class="label">; Genre: </span>abstract or summary;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'b')">
                    <span class="label">; Genre: </span>bibliography;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'c')">
                    <span class="label">; Genre: </span>catalog;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'d')">
                    <span class="label">; Genre: </span>dictionary;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'e')">
                    <span class="label">; Genre: </span>encyclopedia;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'f')">
                    <span class="label">; Genre: </span>handbook;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'g')">
                    <span class="label">; Genre: </span>legal article;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'i')">
                    <span class="label">; Genre: </span>index;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'k')">
                    <span class="label">; Genre: </span>discography;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'l')">
                    <span class="label">; Genre: </span>legislation;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'m')">
                    <span class="label">; Genre: </span>theses;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'n')">
                    <span class="label">; Genre: </span>survey of literature;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'o')">
                    <span class="label">; Genre: </span>review;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'p')">
                    <span class="label">; Genre: </span>programmed text;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'q')">
                    <span class="label">; Genre: </span>filmography;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'r')">
                    <span class="label">; Genre: </span>directory;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'s')">
                    <span class="label">; Genre: </span>statistics;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'t')">
                    <span class="label">; Genre: </span>technical report;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'v')">
                    <span class="label">; Genre: </span>legal case and case notes;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'w')">
                    <span class="label">; Genre: </span>law report or digest;
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'z')">
                    <span class="label">; Genre: </span>treaty;
                </xsl:when>
            </xsl:choose>
            <xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="$controlField008-29='1'">
                    <span class="label">; Genre: </span>conference publication;
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='CF'">
            <xsl:variable name="controlField008-26" select="substring($controlField008,27,1)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="$controlField008-26='a'">
                    <span class="label">; Genre: </span>numeric data;
                </xsl:when>
                <xsl:when test="$controlField008-26='e'">
                    <span class="label">; Genre: </span>database;
                </xsl:when>
                <xsl:when test="$controlField008-26='f'">
                    <span class="label">; Genre: </span>font;
                </xsl:when>
                <xsl:when test="$controlField008-26='g'">
                    <span class="label">; Genre: </span>game;
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='BK'">
            <xsl:if test="substring($controlField008,25,1)='j'">
                <span class="label">; Genre: </span>patent;
            </xsl:if>
            <xsl:if test="substring($controlField008,31,1)='1'">
                <span class="label">; Genre: </span>festschrift;
            </xsl:if>
            <xsl:variable name="controlField008-34" select="substring($controlField008,35,1)"></xsl:variable>
            <xsl:if test="$controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d'">
                <span class="label">; Genre: </span>biography;
            </xsl:if>
            <xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="$controlField008-33='e'">
                    <span class="label">; Genre: </span>essay;
                </xsl:when>
                <xsl:when test="$controlField008-33='d'">
                    <span class="label">; Genre: </span>drama;
                </xsl:when>
                <xsl:when test="$controlField008-33='c'">
                    <span class="label">; Genre: </span>comic strip;
                </xsl:when>
                <xsl:when test="$controlField008-33='l'">
                    <span class="label">; Genre: </span>fiction;
                </xsl:when>
                <xsl:when test="$controlField008-33='h'">
                    <span class="label">; Genre: </span>humor, satire;
                </xsl:when>
                <xsl:when test="$controlField008-33='i'">
                    <span class="label">; Genre: </span>letter;
                </xsl:when>
                <xsl:when test="$controlField008-33='f'">
                    <span class="label">; Genre: </span>novel;
                </xsl:when>
                <xsl:when test="$controlField008-33='j'">
                    <span class="label">; Genre: </span>short story;
                </xsl:when>
                <xsl:when test="$controlField008-33='s'">
                    <span class="label">; Genre: </span>speech;
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='MU'">
            <xsl:variable name="controlField008-30-31" select="substring($controlField008,31,2)"></xsl:variable>
            <xsl:if test="contains($controlField008-30-31,'b')">
                <span class="label">; Genre: </span>biography;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'c')">
                <span class="label">; Genre: </span>conference publication;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'d')">
                <span class="label">; Genre: </span>drama;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'e')">
                <span class="label">; Genre: </span>essay;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'f')">
                <span class="label">; Genre: </span>fiction;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'o')">
                <span class="label">; Genre: </span>folktale;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'h')">
                <span class="label">; Genre: </span>history;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'k')">
                <span class="label">; Genre: </span>humor, satire;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'m')">
                <span class="label">; Genre: </span>memoir;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'p')">
                <span class="label">; Genre: </span>poetry;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'r')">
                <span class="label">; Genre: </span>rehearsal;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'g')">
                <span class="label">; Genre: </span>reporting;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'s')">
                <span class="label">; Genre: </span>sound;
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'l')">
                <span class="label">; Genre: </span>speech;
            </xsl:if>
        </xsl:if>
        <xsl:if test="$typeOf008='VM'">
            <xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="$controlField008-33='a'">
                    <span class="label">; Genre: </span>art original;
                </xsl:when>
                <xsl:when test="$controlField008-33='b'">
                    <span class="label">; Genre: </span>kit;
                </xsl:when>
                <xsl:when test="$controlField008-33='c'">
                    <span class="label">; Genre: </span>art reproduction;
                </xsl:when>
                <xsl:when test="$controlField008-33='d'">
                    <span class="label">; Genre: </span>diorama;
                </xsl:when>
                <xsl:when test="$controlField008-33='f'">
                    <span class="label">; Genre: </span>filmstrip;
                </xsl:when>
                <xsl:when test="$controlField008-33='g'">
                    <span class="label">; Genre: </span>legal article;
                </xsl:when>
                <xsl:when test="$controlField008-33='i'">
                    <span class="label">; Genre: </span>picture;
                </xsl:when>
                <xsl:when test="$controlField008-33='k'">
                    <span class="label">; Genre: </span>graphic;
                </xsl:when>
                <xsl:when test="$controlField008-33='l'">
                    <span class="label">; Genre: </span>technical drawing;
                </xsl:when>
                <xsl:when test="$controlField008-33='m'">
                    <span class="label">; Genre: </span>motion picture;
                </xsl:when>
                <xsl:when test="$controlField008-33='n'">
                    <span class="label">; Genre: </span>chart;
                </xsl:when>
                <xsl:when test="$controlField008-33='o'">
                    <span class="label">; Genre: </span>flash card;
                </xsl:when>
                <xsl:when test="$controlField008-33='p'">
                    <span class="label">; Genre: </span>microscope slide;
                </xsl:when>
                <xsl:when test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
                    <span class="label">; Genre: </span>model;
                </xsl:when>
                <xsl:when test="$controlField008-33='r'">
                    <span class="label">; Genre: </span>realia;
                </xsl:when>
                <xsl:when test="$controlField008-33='s'">
                    <span class="label">; Genre: </span>slide;
                </xsl:when>
                <xsl:when test="$controlField008-33='t'">
                    <span class="label">; Genre: </span>transparency;
                </xsl:when>
                <xsl:when test="$controlField008-33='v'">
                    <span class="label">; Genre: </span>videorecording;
                </xsl:when>
                <xsl:when test="$controlField008-33='w'">
                    <span class="label">; Genre: </span>toy;
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        </xsl:variable>
<xsl:variable name="physicalDescription">
            <!--3.2 change tmee 007/11 -->
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
                <digitalOrigin>reformatted digital</digitalOrigin>
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
                <digitalOrigin>digitized microfilm</digitalOrigin>
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
                <digitalOrigin>digitized other analog</digitalOrigin>
            </xsl:if>
            <xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"></xsl:variable>
            <xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"></xsl:variable>
            <xsl:variable name="check008-23">
                <xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='SE' or $typeOf008='MM'">
                    <xsl:value-of select="true()"></xsl:value-of>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="check008-29">
                <xsl:if test="$typeOf008='MP' or $typeOf008='VM'">
                    <xsl:value-of select="true()"></xsl:value-of>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="($check008-23 and $controlField008-23='f') or ($check008-29 and $controlField008-29='f')">
                    <form authority="marcform">braille</form>
                </xsl:when>
                <xsl:when test="($controlField008-23=' ' and ($leader6='c' or $leader6='d')) or (($typeOf008='BK' or $typeOf008='SE') and ($controlField008-23=' ' or $controlField008='r'))">
                    <form authority="marcform">print</form>
                </xsl:when>
<xsl:when test="$leader6 = 'm' or ($check008-23 and $controlField008-23='s') or ($check008-29 and $controlField008-29='s')">
                    <form authority="marcform">electronic</form>
                </xsl:when>
                <xsl:when test="($check008-23 and $controlField008-23='b') or ($check008-29 and $controlField008-29='b')">
                    <form authority="marcform">microfiche</form>
                </xsl:when>
                <xsl:when test="($check008-23 and $controlField008-23='a') or ($check008-29 and $controlField008-29='a')">
                    <form authority="marcform">microfilm</form>
                </xsl:when>
            </xsl:choose>
            <!-- 1/04 fix -->
            <xsl:if test="marc:datafield[@tag=130]/marc:subfield[@code='h']">
                <form authority="gmd">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=130]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </form>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=240]/marc:subfield[@code='h']">
                <form authority="gmd">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=240]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </form>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=242]/marc:subfield[@code='h']">
                <form authority="gmd">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=242]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </form>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=245]/marc:subfield[@code='h']">
                <form authority="gmd">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=245]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </form>
</xsl:if>
            <xsl:if test="marc:datafield[@tag=246]/marc:subfield[@code='h']">
                <form authority="gmd">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=246]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </form>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=730]/marc:subfield[@code='h']">
                <form authority="gmd">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=730]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
                </form>
            </xsl:if>
            <xsl:for-each select="marc:datafield[@tag=256]/marc:subfield[@code='a']">
                <form>
                    <xsl:value-of select="."></xsl:value-of>
                </form>
            </xsl:for-each>
            <xsl:for-each select="marc:controlfield[@tag=007][substring(text(),1,1)='c']">
                <xsl:choose>
                    <xsl:when test="substring(text(),14,1)='a'">
                        <reformattingQuality>access</reformattingQuality>
                    </xsl:when>
                    <xsl:when test="substring(text(),14,1)='p'">
                        <reformattingQuality>preservation</reformattingQuality>
                    </xsl:when>
                    <xsl:when test="substring(text(),14,1)='r'">
                        <reformattingQuality>replacement</reformattingQuality>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!--3.2 change tmee 007/01 -->
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='b']">
                <form authority="smd">chip cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='c']">
                <form authority="smd">computer optical disc cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='j']">
                <form authority="smd">magnetic disc</form>
            </xsl:if>
 <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='m']">
                <form authority="smd">magneto-optical disc</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='o']">
                <form authority="smd">optical disc</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='r']">
                <form authority="smd">remote</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='a']">
                <form authority="smd">tape cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='f']">
                <form authority="smd">tape cassette</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='h']">
                <form authority="smd">tape reel</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='a']">
                <form authority="smd">celestial globe</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='e']">
                <form authority="smd">earth moon globe</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='b']">
                <form authority="smd">planetary or lunar globe</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='c']">
                <form authority="smd">terrestrial globe</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='o'][substring(text(),2,1)='o']">
                <form authority="smd">kit</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='d']">
                <form authority="smd">atlas</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='g']">
                <form authority="smd">diagram</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='j']">
                <form authority="smd">map</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
                <form authority="smd">model</form>
 </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='k']">
                <form authority="smd">profile</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='r']">
                <form authority="smd">remote-sensing image</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='s']">
                <form authority="smd">section</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='y']">
                <form authority="smd">view</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='a']">
                <form authority="smd">aperture card</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='e']">
                <form authority="smd">microfiche</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='f']">
                <form authority="smd">microfiche cassette</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='b']">
                <form authority="smd">microfilm cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='c']">
                <form authority="smd">microfilm cassette</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='d']">
                <form authority="smd">microfilm reel</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='g']">
                <form authority="smd">microopaque</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='c']">
                <form authority="smd">film cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='f']">
                <form authority="smd">film cassette</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='r']">
                <form authority="smd">film reel</form>
            </xsl:if>
<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='n']">
                <form authority="smd">chart</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='c']">
                <form authority="smd">collage</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='d']">
                <form authority="smd">drawing</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='o']">
                <form authority="smd">flash card</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='e']">
                <form authority="smd">painting</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='f']">
                <form authority="smd">photomechanical print</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='g']">
                <form authority="smd">photonegative</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='h']">
                <form authority="smd">photoprint</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='i']">
                <form authority="smd">picture</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='j']">
                <form authority="smd">print</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='l']">
                <form authority="smd">technical drawing</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='q'][substring(text(),2,1)='q']">
                <form authority="smd">notated music</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='d']">
                <form authority="smd">filmslip</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='c']">
                <form authority="smd">filmstrip cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='o']">
                <form authority="smd">filmstrip roll</form>
            </xsl:if>
<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='f']">
                <form authority="smd">other filmstrip type</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='s']">
                <form authority="smd">slide</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='t']">
                <form authority="smd">transparency</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='r'][substring(text(),2,1)='r']">
                <form authority="smd">remote-sensing image</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='e']">
                <form authority="smd">cylinder</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='q']">
                <form authority="smd">roll</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='g']">
                <form authority="smd">sound cartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='s']">
                <form authority="smd">sound cassette</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='d']">
                <form authority="smd">sound disc</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='t']">
                <form authority="smd">sound-tape reel</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='i']">
                <form authority="smd">sound-track film</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='w']">
                <form authority="smd">wire recording</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='c']">
                <form authority="smd">braille</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='b']">
                <form authority="smd">combination</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='a']">
                <form authority="smd">moon</form>
            </xsl:if>
 <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='d']">
                <form authority="smd">tactile, with no writing system</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='c']">
                <form authority="smd">braille</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='b']">
                <form authority="smd">large print</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='a']">
                <form authority="smd">regular print</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='d']">
                <form authority="smd">text in looseleaf binder</form>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='c']">
                <form authority="smd">videocartridge</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='f']">
                <form authority="smd">videocassette</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='d']">
                <form authority="smd">videodisc</form>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='r']">
                <form authority="smd">videoreel</form>
            </xsl:if>

            <xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q'][string-length(.)>1]">
                <internetMediaType>
                    <xsl:value-of select="."></xsl:value-of>
                </internetMediaType>
            </xsl:for-each>
            <xsl:for-each select="marc:datafield[@tag=300]">
                <extent>
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abce</xsl:with-param>
                    </xsl:call-template>
                </extent>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/>
        <xsl:variable name="isbn" select="marc:datafield[@tag=020]/marc:subfield[@code='a']"/>
    <td style="vertical-align:top;">
     <a><xsl:attribute name="href">/cgi-bin/koha/opac-detail.pl?biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>

        <xsl:if test="marc:datafield[@tag=245]">
        <xsl:for-each select="marc:datafield[@tag=245]">
            <xsl:variable name="title">
                <xsl:choose>
                <xsl:when test="marc:subfield[@code='b']">
                    <xsl:call-template name="specialSubfieldSelect">
                        <xsl:with-param name="axis">b</xsl:with-param>
                        <xsl:with-param name="beforeCodes">afghk</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abfgk</xsl:with-param>
                </xsl:call-template>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="titleChop">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="$title"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$titleChop"/>
            <xsl:if test="marc:subfield[@code='b']">
                <xsl:text> : </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="specialSubfieldSelect">
                            <xsl:with-param name="axis">b</xsl:with-param>
                            <xsl:with-param name="anyCodes">b</xsl:with-param>
                            <xsl:with-param name="afterCodes">afghk</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if><xsl:text> </xsl:text>
            <xsl:call-template name="part"/>
            <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
        </xsl:for-each>
        </xsl:if>
    </a>
    <p>

    <xsl:choose>
    <xsl:when test="marc:datafield[@tag=100] or marc:datafield[@tag=110] or marc:datafield[@tag=111] or marc:datafield[@tag=700] or marc:datafield[@tag=710] or marc:datafield[@tag=711]">

    by 
        <xsl:for-each select="marc:datafield[@tag=100 or @tag=700]">
            <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:call-template name="nameABCDQ"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="nameABCDQ"/>;
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marc:datafield[@tag=110 or @tag=710]">
            <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:call-template name="nameABCDN"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="nameABCDN"/>;
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="marc:datafield[@tag=111 or @tag=711]">
            <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:call-template name="nameACDEQ"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="nameACDEQ"/>;
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:when>
    </xsl:choose>
    </p>
    <span class="results_summary">
    <xsl:if test="$typeOf008">
        <span class="label">Type: </span>
        <img src="/opac-tmpl/prog/famfamfam/{$typeOf008}.png"/><xsl:value-of select="$materialTypeLabel"/>
        <xsl:if test="$genre"><xsl:value-of select="$genre"/></xsl:if>
        <xsl:if test="string-length(normalize-space($physicalDescription))">
                <span class="label">; Format: </span><xsl:copy-of select="$physicalDescription"></xsl:copy-of>
        </xsl:if>

    </xsl:if>

    <xsl:if test="$typeOf008='BK' or $typeOf008='CF' or $typeOf008='MU' or $typeOf008='VM'">
        <xsl:variable name="controlField008-22" select="substring($controlField008,23,1)"></xsl:variable>
        <xsl:choose>
            <xsl:when test="$controlField008-22='a'">
            <span class="label">; Audience: </span> Preschool;
            </xsl:when>
            <xsl:when test="$controlField008-22='b'">
            <span class="label">; Audience: </span> Primary;
            </xsl:when>
            <xsl:when test="$controlField008-22='c'">
            <span class="label">; Audience: </span> Pre-adolescent;
            </xsl:when>
            <xsl:when test="$controlField008-22='d'">
            <span class="label">; Audience: </span> Adolescent;
            </xsl:when>
            <xsl:when test="$controlField008-22='e'">
            <span class="label">; Audience: </span> Adult;
            </xsl:when>
            <xsl:when test="$controlField008-22='g'">
            <span class="label">; Audience: </span> General;
            </xsl:when>
            <xsl:when test="$controlField008-22='j'">
            <span class="label">; Audience: </span> Juvenile;
            </xsl:when>
            <xsl:when test="$controlField008-22='f'">
            <span class="label">; Audience: </span> Specialized;
            </xsl:when>
            </xsl:choose>
    </xsl:if>
    <br/> 
    <xsl:if test="marc:datafield[@tag=260]">
    <span class="label">Publisher: </span> 
            <xsl:for-each select="marc:datafield[@tag=260]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bcg</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>

    </xsl:if>
    </span>
               <div class="holdings_summary">
                   <xsl:if test="count(key('item-by-status', 'available'))>0">
                   <span class="available">
                       <xsl:text>Copies available at: </xsl:text>
                       <xsl:variable name="available_items"
                           select="key('item-by-status', 'available')"/>
                       <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch))[1])]">
                           <xsl:value-of select="items:homebranch"/>
                           <xsl:text> (</xsl:text>
                           <xsl:value-of select="count(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch)))"/>
                           <xsl:text>) </xsl:text>
                       </xsl:for-each>
                   </span>
                   </xsl:if>
                   <xsl:if test="count(key('item-by-status', 'On loan'))>0">
                   <span class="unavailable">
                       <xsl:text>On loan (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'On loan'))"/>
                       <xsl:text>)</xsl:text>
                   </span>
                   </xsl:if>
               </div>
    </td>
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

                        <!--<xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">b</xsl:with-param>                                 
                        </xsl:call-template>-->
                    </xsl:with-param>
                </xsl:call-template>
        </xsl:if>
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
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partNumber"/>
                </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($partName))">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="$partName"/>
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
