<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method = "xml" indent="yes" omit-xml-declaration = "yes" />
    <xsl:key name="item-by-status" match="items:item" use="items:status"/>
    <xsl:key name="item-by-status-and-branch" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>

    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="marc:record">
        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/>
        <xsl:variable name="isbn" select="marc:datafield[@tag=020]/marc:subfield[@code='a']"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="typeOf008">
            <xsl:choose>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">CR</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='p'">MX</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">VM</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">MU</xsl:when>
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
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
                reformatted digital
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
                digitized microfilm
            </xsl:if>
            <xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
                digitized other analog
            </xsl:if>

            <xsl:variable name="check008-23">
                <xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='CR' or $typeOf008='MX'">
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
                    braille
                </xsl:when>
                <xsl:when test="($controlField008-23=' ' and ($leader6='c' or $leader6='d')) or (($typeOf008='BK' or $typeOf008='CR') and ($controlField008-23=' ' or $controlField008='r'))">
                    print
                </xsl:when>
                <xsl:when test="$leader6 = 'm' or ($check008-23 and $controlField008-23='s') or ($check008-29 and $controlField008-29='s')">
                    electronic
                </xsl:when>
                <xsl:when test="($check008-23 and $controlField008-23='b') or ($check008-29 and $controlField008-29='b')">
                    microfiche
                </xsl:when>
                <xsl:when test="($check008-23 and $controlField008-23='a') or ($check008-29 and $controlField008-29='a')">
                    microfilm
                </xsl:when>
            </xsl:choose>
<!--
            <xsl:if test="marc:datafield[@tag=130]/marc:subfield[@code='h']">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=130]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=240]/marc:subfield[@code='h']">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=240]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=242]/marc:subfield[@code='h']">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=242]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=245]/marc:subfield[@code='h']">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=245]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=246]/marc:subfield[@code='h']">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=246]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:if>
            <xsl:if test="marc:datafield[@tag=730]/marc:subfield[@code='h']">
                    <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:datafield[@tag=730]/marc:subfield[@code='h']"></xsl:value-of>
                        </xsl:with-param>
                    </xsl:call-template>
            </xsl:if>
            <xsl:for-each select="marc:datafield[@tag=256]/marc:subfield[@code='a']">
                    <xsl:value-of select="."></xsl:value-of>
            </xsl:for-each>
            <xsl:for-each select="marc:controlfield[@tag=007][substring(text(),1,1)='c']">
                <xsl:choose>
                    <xsl:when test="substring(text(),14,1)='a'">
                        access
                    </xsl:when>
                    <xsl:when test="substring(text(),14,1)='p'">
                        preservation
                    </xsl:when>
                    <xsl:when test="substring(text(),14,1)='r'">
                        replacement
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
-->
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='b']">
                chip cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='c']">
                <img src="/opac-tmpl/prog/famfamfam/silk/cd.png" alt="computer optical disc cartridge" title="computer optical disc cartridge"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='j']">
                magnetic disc
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='m']">
                magneto-optical disc
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='o']">
                <img src="/opac-tmpl/prog/famfamfam/silk/cd.png" alt="optical disc" title="optical disc"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='r']">
                <img src="/opac-tmpl/prog/famfamfam/silk/drive_remote.png" alt="remote" title="remote"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='a']">
                tape cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='f']">
                tape cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='h']">
                tape reel
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='a']">
                <img src="/opac-tmpl/prog/famfamfam/silk/globe.png" alt="celestial globe" title="celestial globe"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='e']">
                <img src="/opac-tmpl/prog/famfamfam/silk/globe.png" alt="earth moon globe" title="earth moon globe"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='b']">
                <img src="/opac-tmpl/prog/famfamfam/silk/globe.png" alt="planetary or lunar globe" title="planetary or lunar globe"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='c']">
                <img src="/opac-tmpl/prog/famfamfam/silk/globe.png" alt="terrestrial globe" title="terrestrial globe"/>
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='o'][substring(text(),2,1)='o']">
                kit
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='d']">
                atlas
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='g']">
                diagram
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='j']">
                map
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
                model
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='k']">
                profile
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='r']">
                remote-sensing image
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='s']">
                section
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='y']">
                view
            </xsl:if>

            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='a']">
                aperture card
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='e']">
                microfiche
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='f']">
                microfiche cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='b']">
                microfilm cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='c']">
                microfilm cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='d']">
                microfilm reel
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='g']">
                microopaque
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='c']">
                film cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='f']">
                film cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='r']">
                film reel
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='n']">
                <img src="/opac-tmpl/prog/famfamfam/silk/chart_curve.png" alt="chart" title="chart"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='c']">
                collage
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='d']">
                 <img src="/opac-tmpl/prog/famfamfam/silk/pencile.png" alt="drawing" title="drawing"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='o']">
                <img src="/opac-tmpl/prog/famfamfam/silk/note.png" alt="flash card" title="flash card"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='e']">
                <img src="/opac-tmpl/prog/famfamfam/silk/paintbrush.png" alt="painting" title="painting"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='f']">
                photomechanical print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='g']">
                photonegative
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='h']">
                photoprint
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='i']">
                <img src="/opac-tmpl/prog/famfamfam/silk/picture.png" alt="picture" title="picture"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='j']">
                print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='l']">
                technical drawing
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='q'][substring(text(),2,1)='q']">
                <img src="/opac-tmpl/prog/famfamfam/silk/script.png" alt="notated musci" title="notated music"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='d']">
                filmslip
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='c']">
                filmstrip cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='o']">
                filmstrip roll
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='f']">
                other filmstrip type
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='s']">
                <img src="/opac-tmpl/prog/famfamfam/silk/pictures.png" alt="slide" title="slide"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='t']">
                transparency
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='r'][substring(text(),2,1)='r']">
                remote-sensing image
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='e']">
                cylinder
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='q']">
                roll
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='g']">
                sound cartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='s']">
                sound cassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='d']">
                <img src="/opac-tmpl/prog/famfamfam/silk/cd.png" alt="sound disc" title="sound disc"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='t']">
                sound-tape reel
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='i']">
                sound-track film
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='w']">
                wire recording
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='c']">
                braille
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='b']">
                combination
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='a']">
                moon
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='d']">
                tactile, with no writing system
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='c']">
                braille
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='b']">
                <img src="/opac-tmpl/prog/famfamfam/silk/magnifier.png" alt="large print" title="large print"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='a']">
                regular print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='d']">
                text in looseleaf binder
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='c']">
                videocartridge
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='f']">
                videocassette
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='d']">
                <img src="/opac-tmpl/prog/famfamfam/silk/dvd.png" alt="videodisc" title="videodisc"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='r']">
                videoreel
            </xsl:if>
<!--
            <xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q'][string-length(.)>1]">
                    <xsl:value-of select="."></xsl:value-of>
            </xsl:for-each>
            <xsl:for-each select="marc:datafield[@tag=300]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abce</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>
-->
        </xsl:variable>
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
            </xsl:if>
            <xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            <xsl:call-template name="part"/>
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
            <xsl:choose>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'"><img src="/opac-tmpl/prog/famfamfam/silk/book.png" alt="book" title="book"/> Book</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'"><img src="/opac-tmpl/prog/famfamfam/silk/newspaper.png" alt="serial" title="serial"/> Continuing Resource</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'"><img src="/opac-tmpl/prog/famfamfam/silk/book.png" alt="book" title="book"/> Book</xsl:when>
                <xsl:when test="$leader6='p'"><img src="/opac-tmpl/prog/famfamfam/silk/report_disk.png" alt="mixed materials" title="mixed materials"/>Mixed Materials</xsl:when>
                <xsl:when test="$leader6='m'"><img src="/opac-tmpl/prog/famfamfam/silk/computer_link.png" alt="computer file" title="computer file"/> Computer File</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'"><img src="/opac-tmpl/prog/famfamfam/silk/map.png" alt="map" title="map"/> Map</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'"><img src="/opac-tmpl/prog/famfamfam/silk/film.png" alt="visual material" title="visual material"/> Visual Material</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'"><img src="/opac-tmpl/prog/famfamfam/silk/sound.png" alt="sound" title="sound"/> Sound</xsl:when>
            </xsl:choose>
    </xsl:if>
    <xsl:if test="string-length(normalize-space($physicalDescription))">
        <span class="label">; Format: </span><xsl:copy-of select="$physicalDescription"></xsl:copy-of>
    </xsl:if>

        <xsl:if test="$controlField008-21 or $controlField008-22 or $controlField008-24 or $controlField008-26 or $controlField008-29 or $controlField008-34 or $controlField008-33 or $controlField008-30-31 or $controlField008-33">

        <xsl:if test="$typeOf008='CR'">
        <xsl:if test="$controlField008-21 and $controlField008-21 !='|' and $controlField008-21 !=' '">
        <span class="label">; Type of continuing resource: <xsl:value-of select="$controlField008-21"/></span>
        </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-21='d'">
                     <img src="/opac-tmpl/prog/famfamfam/silk/database.png" alt="database" title="database"/>
                </xsl:when>
                <xsl:when test="$controlField008-21='l'">
                    loose-leaf
                </xsl:when>
                <xsl:when test="$controlField008-21='m'">
                    series
                </xsl:when>
                <xsl:when test="$controlField008-21='n'">
                    newspaper
                </xsl:when>
                <xsl:when test="$controlField008-21='p'">
                    periodical
                </xsl:when>
                <xsl:when test="$controlField008-21='w'">
                     <img src="/opac-tmpl/prog/famfamfam/silk/world_link.png" alt="web site" title="web site"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='BK' or $typeOf008='CR'">
        <xsl:if test="contains($controlField008-24,'abcdefghijklmnopqrstvwxyz')">
        <span class="label">; Nature of contents: </span>
        </xsl:if>
            <xsl:choose>
                <xsl:when test="contains($controlField008-24,'a')">
                    abstract or summary
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'b')">
                     <img src="/opac-tmpl/prog/famfamfam/silk/text_list_bullets.png" alt="bibliography" title="bibliography"/>
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'c')">
                    catalog
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'d')">
                    dictionary
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'e')">
                    encyclopedia
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'f')">
                    handbook
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'g')">
                    legal article
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'i')">
                    index
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'k')">
                    discography
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'l')">
                    legislation
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'m')">
                    theses
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'n')">
                    survey of literature
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'o')">
                    review
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'p')">
                    programmed text
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'q')">
                    filmography
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'r')">
                    directory
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'s')">
                    statistics
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'t')">
                     <img src="/opac-tmpl/prog/famfamfam/silk/report.png" alt="technical report" title="technical report"/>
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'v')">
                    legal case and case notes
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'w')">
                    law report or digest
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'z')">
                    treaty
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$controlField008-29='1'">
                    conference publication
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='CF'">
            <xsl:if test="$controlField008-26='a' or $controlField008-26='e' or $controlField008-26='f' or $controlField008-26='g'">
            <span class="label">; Type of computer file: </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-26='a'">
                    numeric data
                </xsl:when>
                <xsl:when test="$controlField008-26='e'">
                     <img src="/opac-tmpl/prog/famfamfam/silk/database.png" alt="database" title="database"/>
                </xsl:when>
                <xsl:when test="$controlField008-26='f'">
                     <img src="/opac-tmpl/prog/famfamfam/silk/font.png" alt="font" title="font"/> 
                </xsl:when>
                <xsl:when test="$controlField008-26='g'">
                     <img src="/opac-tmpl/prog/famfamfam/silk/controller.png" alt="game" title="game"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="$typeOf008='BK'">
            <xsl:if test="(substring($controlField008,25,1)='j') or (substring($controlField008,25,1)='1') or ($controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d')">
            <span class="label">; Nature of contents: </span>
            </xsl:if>
            <xsl:if test="substring($controlField008,25,1)='j'">
                patent
            </xsl:if>
            <xsl:if test="substring($controlField008,31,1)='1'">
                festschrift
            </xsl:if>
            <xsl:if test="$controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d'">
                 <img src="/opac-tmpl/prog/famfamfam/silk/user.png" alt="biography" title="biography"/>
            </xsl:if>

            <xsl:if test="$controlField008-33 and $controlField008-33!='|' and $controlField008-33!='u' and $controlField008-33!=' '">
            <span class="label">; Literary form: </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-33='0'">
                    not fiction
                </xsl:when>
                <xsl:when test="$controlField008-33='1'">
                    fiction
                </xsl:when> 
                <xsl:when test="$controlField008-33='e'">
                    essay
                </xsl:when>
                <xsl:when test="$controlField008-33='d'">
                    drama
                </xsl:when>
                <xsl:when test="$controlField008-33='c'">
                    comic strip
                </xsl:when>
                <xsl:when test="$controlField008-33='l'">
                    fiction
                </xsl:when>
                <xsl:when test="$controlField008-33='h'">
                    humor, satire
                </xsl:when>
                <xsl:when test="$controlField008-33='i'">
                    letter
                </xsl:when>
                <xsl:when test="$controlField008-33='f'">
                    novel
                </xsl:when>
                <xsl:when test="$controlField008-33='j'">
                    short story
                </xsl:when>
                <xsl:when test="$controlField008-33='s'">
                    speech
                </xsl:when>
            </xsl:choose>
        </xsl:if> 
        <xsl:if test="$typeOf008='MU' and $controlField008-30-31 and $controlField008-30-31!='||' and $controlField008-30-31!='  '">
            <span class="label">; Literary form: <xsl:value-of select="$controlField008-30-31"/> </span> <!-- Literary text for sound recordings -->
            <xsl:if test="contains($controlField008-30-31,'b')">
                biography
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'c')">
                conference publication
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'d')">
                drama
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'e')">
                essay
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'f')">
                fiction
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'o')">
                folktale
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'h')">
                history
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'k')">
                humor, satire
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'m')">
                memoir
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'p')">
                poetry
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'r')">
                rehearsal
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'g')">
                reporting
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'s')">
                sound
            </xsl:if>
            <xsl:if test="contains($controlField008-30-31,'l')">
                speech
            </xsl:if>
        </xsl:if>
        <xsl:if test="$typeOf008='VM'">
            <span class="label">; Type of visual material: </span>
            <xsl:choose>
                <xsl:when test="$controlField008-33='a'">
                    art original
                </xsl:when>
                <xsl:when test="$controlField008-33='b'">
                    kit
                </xsl:when>
                <xsl:when test="$controlField008-33='c'">
                    art reproduction
                </xsl:when>
                <xsl:when test="$controlField008-33='d'">
                    diorama
                </xsl:when>
                <xsl:when test="$controlField008-33='f'">
                    filmstrip
                </xsl:when>
                <xsl:when test="$controlField008-33='g'">
                    legal article
                </xsl:when>
                <xsl:when test="$controlField008-33='i'">
                    picture
                </xsl:when>
                <xsl:when test="$controlField008-33='k'">
                    graphic
                </xsl:when>
                <xsl:when test="$controlField008-33='l'">
                    technical drawing
                </xsl:when>
                <xsl:when test="$controlField008-33='m'">
                    motion picture
                </xsl:when>
                <xsl:when test="$controlField008-33='n'">
                    chart
                </xsl:when>
                <xsl:when test="$controlField008-33='o'">
                    flash card
                </xsl:when>
                <xsl:when test="$controlField008-33='p'">
                    microscope slide
                </xsl:when>
                <xsl:when test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2
,1)='q']">
                    model
                </xsl:when>
                <xsl:when test="$controlField008-33='r'">
                    realia
                </xsl:when>
                <xsl:when test="$controlField008-33='s'">
                    slide
                </xsl:when>
                <xsl:when test="$controlField008-33='t'">
                    transparency
                </xsl:when>
                <xsl:when test="$controlField008-33='v'">
                    videorecording
                </xsl:when>
                <xsl:when test="$controlField008-33='w'">
                    toy
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        </xsl:if> 

    <xsl:if test="($typeOf008='BK' or $typeOf008='CF' or $typeOf008='MU' or $typeOf008='VM') and ($controlField008-22='a' or $controlField008-22='b' or $controlField008-22='c' or $controlField008-22='d' or $controlField008-22='e' or $controlField008-22='g' or $controlField008-22='j' or $controlField008-22='f')">
        <span class="label">; Audience: </span>
        <xsl:choose>
            <xsl:when test="$controlField008-22='a'">
             Preschool;
            </xsl:when>
            <xsl:when test="$controlField008-22='b'">
             Primary;
            </xsl:when>
            <xsl:when test="$controlField008-22='c'">
             Pre-adolescent;
            </xsl:when>
            <xsl:when test="$controlField008-22='d'">
             Adolescent;
            </xsl:when>
            <xsl:when test="$controlField008-22='e'">
             Adult;
            </xsl:when>
            <xsl:when test="$controlField008-22='g'">
             General;
            </xsl:when>
            <xsl:when test="$controlField008-22='j'">
             Juvenile;
            </xsl:when>
            <xsl:when test="$controlField008-22='f'">
             Specialized;
            </xsl:when>
            </xsl:choose>
    </xsl:if>
	</span>

    <xsl:if test="marc:datafield[@tag=260]">
	<span class="results_summary">
    <span class="label">Publisher: </span> 
            <xsl:for-each select="marc:datafield[@tag=260]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">bcg</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>
	</span>
    </xsl:if>

    <span class="results_summary">
			   <span class="label">Availability: </span>
			        <xsl:choose>
                        <xsl:when test="marc:datafield[@tag=856]">
                            <xsl:for-each select="marc:datafield[@tag=856]">
                                <xsl:choose>
                                    <xsl:when test="@ind2=0">
                                    <a><xsl:attribute name="href"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute>
                                    <xsl:choose>
                                    <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
                                        <xsl:call-template name="subfieldSelect">                        
                                        <xsl:with-param name="codes">y3z</xsl:with-param>                    
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
                                    Click here to access online
                                    </xsl:when>
                                    </xsl:choose>
                                    </a>
                                    <xsl:choose>
                                    <xsl:when test="position()=last()"></xsl:when>
                                    <xsl:otherwise> | </xsl:otherwise>
                                    </xsl:choose>
                                    </xsl:when> 
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>

				   <xsl:when test="count(key('item-by-status', 'available'))=0">No copies available
				   </xsl:when>
                   <xsl:when test="count(key('item-by-status', 'available'))>0">
                   <span class="available">
                       <b><xsl:text>Copies available at: </xsl:text></b>
                       <xsl:variable name="available_items"
                           select="key('item-by-status', 'available')"/>
                       <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch))[1])]">
                           <xsl:value-of select="items:homebranch"/>
                           <xsl:text> (</xsl:text>
                           <xsl:value-of select="count(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch)))"/>
                           <xsl:text>)</xsl:text>
<xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise></xsl:choose>
                       </xsl:for-each>
                   </span>
                   </xsl:when>
				   </xsl:choose>
                   <xsl:if test="count(key('item-by-status', 'Checked out'))>0">
                   <span class="unavailable">
                       <xsl:text>Checked out (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Checked out'))"/>
                       <xsl:text>) </xsl:text>
                   </span>
                   </xsl:if>
                   <xsl:if test="count(key('item-by-status', 'Withdrawn'))>0">
                   <span class="unavailable">
                       <xsl:text>Withdrawn (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Withdrawn'))"/>
                       <xsl:text>) </xsl:text>                   </span>
                   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'Lost'))>0">
                   <span class="unavailable">
                       <xsl:text>Lost (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Lost'))"/>
                       <xsl:text>) </xsl:text>                   </span>
                   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'Damaged'))>0">
                   <span class="unavailable">
                       <xsl:text>Damaged (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Damaged'))"/>
                       <xsl:text>) </xsl:text>                   </span>
                   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'On order'))>0">
                   <span class="unavailable">
                       <xsl:text>On order (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'On order'))"/>
                       <xsl:text>) </xsl:text>                   </span>
                   </xsl:if>
               </span>
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
