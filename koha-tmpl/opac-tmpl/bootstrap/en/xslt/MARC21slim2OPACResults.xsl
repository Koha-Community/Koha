<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha-community.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="marc items">
    <xsl:import href="MARC21slimUtils.xsl"/>
    <xsl:output method = "html" indent="yes" omit-xml-declaration = "yes" encoding="UTF-8"/>
    <xsl:key name="item-by-status" match="items:item" use="items:status"/>
    <xsl:key name="item-by-status-and-branch-home" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>
    <xsl:key name="item-by-status-and-branch-holding" match="items:item" use="concat(items:status, ' ', items:holdingbranch)"/>

    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="marc:record">

        <!-- Option: Display Alternate Graphic Representation (MARC 880)  -->
        <xsl:variable name="display880" select="boolean(marc:datafield[@tag=880])"/>

    <xsl:variable name="OPACResultsLibrary" select="marc:sysprefs/marc:syspref[@name='OPACResultsLibrary']"/>
    <xsl:variable name="hidelostitems" select="marc:sysprefs/marc:syspref[@name='hidelostitems']"/>
    <xsl:variable name="DisplayOPACiconsXSLT" select="marc:sysprefs/marc:syspref[@name='DisplayOPACiconsXSLT']"/>
    <xsl:variable name="OPACURLOpenInNewWindow" select="marc:sysprefs/marc:syspref[@name='OPACURLOpenInNewWindow']"/>
    <xsl:variable name="URLLinkText" select="marc:sysprefs/marc:syspref[@name='URLLinkText']"/>
    <xsl:variable name="Show856uAsImage" select="marc:sysprefs/marc:syspref[@name='OPACDisplay856uAsImage']"/>
    <xsl:variable name="AlternateHoldingsField" select="substring(marc:sysprefs/marc:syspref[@name='AlternateHoldingsField'], 1, 3)"/>
    <xsl:variable name="AlternateHoldingsSubfields" select="substring(marc:sysprefs/marc:syspref[@name='AlternateHoldingsField'], 4)"/>
    <xsl:variable name="AlternateHoldingsSeparator" select="marc:sysprefs/marc:syspref[@name='AlternateHoldingsSeparator']"/>
    <xsl:variable name="OPACItemLocation" select="marc:sysprefs/marc:syspref[@name='OPACItemLocation']"/>
    <xsl:variable name="singleBranchMode" select="marc:sysprefs/marc:syspref[@name='singleBranchMode']"/>
    <xsl:variable name="OPACTrackClicks" select="marc:sysprefs/marc:syspref[@name='TrackClicks']"/>
    <xsl:variable name="BiblioDefaultView" select="marc:sysprefs/marc:syspref[@name='BiblioDefaultView']"/>
        <xsl:variable name="leader" select="marc:leader"/>
        <xsl:variable name="leader6" select="substring($leader,7,1)"/>
        <xsl:variable name="leader7" select="substring($leader,8,1)"/>
        <xsl:variable name="leader19" select="substring($leader,20,1)"/>
        <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='c']"/>
        <xsl:variable name="isbn" select="marc:datafield[@tag=020]/marc:subfield[@code='a']"/>
        <xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
        <xsl:variable name="typeOf008">
            <xsl:choose>
                <xsl:when test="$leader19='a'">ST</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
                        <xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">CR</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'">BK</xsl:when>
                <xsl:when test="$leader6='o' or $leader6='p'">MX</xsl:when>
                <xsl:when test="$leader6='m'">CF</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='r'">VM</xsl:when>
                <xsl:when test="$leader6='i' or $leader6='j'">MU</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'">PR</xsl:when>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/cd.png" alt="computer optical disc cartridge" title="computer optical disc cartridge" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='j']">
                magnetic disc
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='m']">
                magneto-optical disc
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='o']">
                <img src="/opac-tmpl/lib/famfamfam/silk/cd.png" alt="optical disc" title="optical disc" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='r']">
		available online
                <img src="/opac-tmpl/lib/famfamfam/silk/drive_web.png" alt="remote" title="remote" class="format"/>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="celestial globe" title="celestial globe" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='e']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="earth moon globe" title="earth moon globe" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='b']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="planetary or lunar globe" title="planetary or lunar globe" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='c']">
                <img src="/opac-tmpl/lib/famfamfam/silk/world.png" alt="terrestrial globe" title="terrestrial globe" class="format"/>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/chart_curve.png" alt="chart" title="chart" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='c']">
                collage
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='d']">
                 <img src="/opac-tmpl/lib/famfamfam/silk/pencil.png" alt="drawing" title="drawing" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='o']">
                <img src="/opac-tmpl/lib/famfamfam/silk/note.png" alt="flash card" title="flash card" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='e']">
                <img src="/opac-tmpl/lib/famfamfam/silk/paintbrush.png" alt="painting" title="painting" class="format"/>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/picture.png" alt="picture" title="picture" class="format"/>
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='j']">
                print
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='l']">
                technical drawing
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='q'][substring(text(),2,1)='q']">
                <img src="/opac-tmpl/lib/famfamfam/silk/script.png" alt="notated music" title="notated music" class="format"/>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/pictures.png" alt="slide" title="slide" class="format"/>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/cd.png" alt="sound disc" title="sound disc" class="format"/>
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
                combination
            </xsl:if>
            <xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='b']">
                braille
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
                <img src="/opac-tmpl/lib/famfamfam/silk/magnifier.png" alt="large print" title="large print" class="format"/>
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
                <img src="/opac-tmpl/lib/famfamfam/silk/dvd.png" alt="videodisc" title="videodisc" class="format"/>
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

        <!-- Title Statement: Alternate Graphic Representation (MARC 880) -->
        <xsl:if test="$display880">
           <xsl:call-template name="m880Select">
              <xsl:with-param name="basetags">245</xsl:with-param>
              <xsl:with-param name="codes">abhfgknps</xsl:with-param>
              <xsl:with-param name="bibno"><xsl:value-of  select="$biblionumber"/></xsl:with-param>
           </xsl:call-template>
        </xsl:if>

    <a>
        <xsl:attribute name="href">
            <xsl:call-template name="buildBiblioDefaultViewURL">
                <xsl:with-param name="BiblioDefaultView">
                    <xsl:value-of select="$BiblioDefaultView"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="$biblionumber"/>
        </xsl:attribute>
        <xsl:attribute name="class">title</xsl:attribute>

        <xsl:if test="marc:datafield[@tag=245]">
            <xsl:for-each select="marc:datafield[@tag=245]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <!-- 13381 add additional subfields-->
                <!-- bz 17625 adding subfields f and g -->
                <xsl:for-each select="marc:subfield[contains('bcfghknps', @code)]">
                    <xsl:choose>
                        <xsl:when test="@code='h'">
                            <!--  13381 Span class around subfield h so it can be suppressed via css -->
                            <span class="title_medium"><xsl:apply-templates/> <xsl:text> </xsl:text> </span>
                        </xsl:when>
                        <xsl:when test="@code='c'">
                            <!--  13381 Span class around subfield c so it can be suppressed via css -->
                            <span class="title_resp_stmt"><xsl:apply-templates/> <xsl:text> </xsl:text> </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                            <xsl:text> </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </a>
    <p>

    <!-- Author Statement: Alternate Graphic Representation (MARC 880) -->
    <xsl:if test="$display880">
      <xsl:call-template name="m880Select">
      <xsl:with-param name="basetags">100,110,111,700,710,711</xsl:with-param>
      <xsl:with-param name="codes">abc</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:choose>
    <xsl:when test="marc:datafield[@tag=100] or marc:datafield[@tag=110] or marc:datafield[@tag=111] or marc:datafield[@tag=700] or marc:datafield[@tag=710] or marc:datafield[@tag=711]">

    by <span class="author">
        <!-- #13383 -->
        <xsl:for-each select="marc:datafield[(@tag=100 or @tag=700 or @tag=110 or @tag=710 or @tag=111 or @tag=711) and @ind1!='z']">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">
                            <xsl:choose>
                                <!-- #13383 include subfield e for field 111  -->
                                <xsl:when test="@tag=111 or @tag=711">aeq</xsl:when>
                                <xsl:when test="@tag=110 or @tag=710">ab</xsl:when>
                                <xsl:otherwise>abcjq</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <!-- Display title portion for 110 and 710 fields -->
            <xsl:if test="(@tag=110 or @tag=710) and boolean(marc:subfield[@code='c' or @code='d' or @code='n' or @code='t'])">
                <span class="titleportion">
                <xsl:choose>
                    <xsl:when test="marc:subfield[@code='c' or @code='d' or @code='n'][not(marc:subfield[@code='t'])]"><xsl:text> </xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">cdnt</xsl:with-param>
                    </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                </span>
            </xsl:if>
            <!-- Display title portion for 111 and 711 fields -->
            <xsl:if test="(@tag=111 or @tag=711) and boolean(marc:subfield[@code='c' or @code='d' or @code='g' or @code='n' or @code='t'])">
                    <span class="titleportion">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code='c' or @code='d' or @code='g' or @code='n'][not(marc:subfield[@code='t'])]"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
                    </xsl:choose>

                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">cdgnt</xsl:with-param>
                        </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                    </span>
            </xsl:if>
            <!-- Display dates for 100 and 700 fields -->
            <xsl:if test="(@tag=100 or @tag=700) and marc:subfield[@code='d']">
                <span class="authordates">
                <xsl:text>, </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                           <xsl:with-param name="codes">d</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                </span>
            </xsl:if>
            <!-- Display title portion for 100 and 700 fields -->
            <xsl:if test="@tag=700 and marc:subfield[@code='t']">
                <span class="titleportion">
                <xsl:text>. </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">t</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                </span>
            </xsl:if>
            <!-- Display relators for 1XX and 7XX fields -->
            <xsl:if test="marc:subfield[@code='4' or @code='e'][not(parent::*[@tag=111])] or (self::*[@tag=111] and marc:subfield[@code='4' or @code='j'][. != ''])">
                <span class="relatorcode">
                    <xsl:text> [</xsl:text>
                    <xsl:choose>
                        <xsl:when test="@tag=111 or @tag=711">
                            <xsl:choose>
                                <!-- Prefer j over 4 for 111 and 711 -->
                                <xsl:when test="marc:subfield[@code='j']">
                                    <xsl:for-each select="marc:subfield[@code='j']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="marc:subfield[@code=4]">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <!-- Prefer e over 4 on 100 and 110 -->
                        <xsl:when test="marc:subfield[@code='e']">
                            <xsl:for-each select="marc:subfield[@code='e'][not(@tag=111) or not(@tag=711)]">
                                <xsl:value-of select="."/>
                                <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="marc:subfield[@code=4]">
                                <xsl:value-of select="."/>
                                <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>]</xsl:text>
                </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </span>
    </xsl:when>
    </xsl:choose>
    </p>

    <xsl:if test="marc:datafield[@tag=250]">
    <span class="results_summary edition">
    <span class="label">Edition: </span>
            <xsl:for-each select="marc:datafield[@tag=250]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
            </xsl:for-each>
	</span>
    </xsl:if>

    <xsl:if test="marc:datafield[@tag=773]">
        <xsl:for-each select="marc:datafield[@tag=773]">
            <xsl:if test="marc:subfield[@code='t']">
    <span class="results_summary source">
    <span class="label">Source: </span>
            <xsl:value-of select="marc:subfield[@code='t']"/>
    </span>
            </xsl:if>
        </xsl:for-each>
    </xsl:if>

<xsl:if test="$DisplayOPACiconsXSLT!='0'">
    <span class="results_summary type">
    <xsl:if test="$typeOf008!=''">
    <span class="results_material_type">
        <span class="label">Material type: </span>
            <xsl:choose>
                <xsl:when test="$leader19='a'"><img src="/opac-tmpl/lib/famfamfam/silk/book_link.png" alt="book" title="book" class="materialtype"/> Set</xsl:when>
                <xsl:when test="$leader6='a'">
                    <xsl:choose>
                        <xsl:when test="$leader7='c' or $leader7='d' or $leader7='m'"><img src="/opac-tmpl/lib/famfamfam/silk/book.png" alt="book" title="book" class="materialtype"/> Book</xsl:when>
                        <xsl:when test="$leader7='i' or $leader7='s'"><img src="/opac-tmpl/lib/famfamfam/silk/newspaper.png" alt="serial" title="serial" class="materialtype"/> Continuing resource</xsl:when>
                        <xsl:when test="$leader7='a' or $leader7='b'"><img src="/opac-tmpl/lib/famfamfam/silk/book_open.png" alt="article" title="article" class="materialtype"/> Article</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$leader6='t'"><img src="/opac-tmpl/lib/famfamfam/silk/book.png" alt="book" title="book" class="materialtype"/> Book</xsl:when>
                <xsl:when test="$leader6='o'"><img src="/opac-tmpl/lib/famfamfam/silk/report_disk.png" alt="kit" title="kit" class="materialtype"/> Kit</xsl:when>
                <xsl:when test="$leader6='p'"><img src="/opac-tmpl/lib/famfamfam/silk/report_disk.png" alt="mixed materials" title="mixed materials" class="materialtype"/>Mixed materials</xsl:when>
                <xsl:when test="$leader6='m'"><img src="/opac-tmpl/lib/famfamfam/silk/computer_link.png" alt="computer file" title="computer file" class="materialtype"/> Computer file</xsl:when>
                <xsl:when test="$leader6='e' or $leader6='f'"><img src="/opac-tmpl/lib/famfamfam/silk/map.png" alt="map" title="map" class="materialtype"/> Map</xsl:when>
                <xsl:when test="$leader6='g' or $leader6='k' or $leader6='r'"><img src="/opac-tmpl/lib/famfamfam/silk/film.png" alt="visual material" title="visual material" class="materialtype"/> Visual material</xsl:when>
                <xsl:when test="$leader6='c' or $leader6='d'"><img src="/opac-tmpl/lib/famfamfam/silk/music.png" alt="score" title="score" class="materialtype"/> Score</xsl:when>
                <xsl:when test="$leader6='i'"><img src="/opac-tmpl/lib/famfamfam/silk/sound.png" alt="sound" title="sound" class="materialtype"/> Sound</xsl:when>
                <xsl:when test="$leader6='j'"><img src="/opac-tmpl/lib/famfamfam/silk/sound.png" alt="music" title="music" class="materialtype"/> Music</xsl:when>
            </xsl:choose>
    </span>
    </xsl:if>
    <xsl:if test="string-length(normalize-space($physicalDescription))">
        <span class="results_format">
            <span class="label">; Format: </span><xsl:copy-of select="$physicalDescription"></xsl:copy-of>
        </span>
    </xsl:if>

        <xsl:if test="$controlField008-21 or $controlField008-22 or $controlField008-24 or $controlField008-26 or $controlField008-29 or $controlField008-34 or $controlField008-33 or $controlField008-30-31 or $controlField008-33">

        <xsl:if test="$typeOf008='CR'">
        <span class="results_typeofcontinuing">
        <xsl:if test="$controlField008-21 and $controlField008-21 !='|' and $controlField008-21 !=' '">
        <span class="label">; Type of continuing resource: </span>
        </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-21='d'">
                     <img src="/opac-tmpl/lib/famfamfam/silk/database.png" alt="database" title="database" class="format"/>
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
                     <img src="/opac-tmpl/lib/famfamfam/silk/world_link.png" alt="web site" title="web site" class="format"/>
                </xsl:when>
            </xsl:choose>
        </span>
        </xsl:if>
        <xsl:if test="$typeOf008='BK' or $typeOf008='CR'">
        <xsl:if test="contains($controlField008-24,'abcdefghijklmnopqrstvwxyz')">
        <span class="results_natureofcontents">
        <span class="label">; Nature of contents: </span>
            <xsl:choose>
                <xsl:when test="contains($controlField008-24,'a')">
                    abstract or summary
                </xsl:when>
                <xsl:when test="contains($controlField008-24,'b')">
			bibliography
                     <img src="/opac-tmpl/lib/famfamfam/silk/text_list_bullets.png" alt="bibliography" title="bibliography" class="natureofcontents"/>
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
                     <img src="/opac-tmpl/lib/famfamfam/silk/report.png" alt="technical report" title="technical report" class="natureofcontents"/>
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
        </span>
        </xsl:if>
        </xsl:if>
        <xsl:if test="$typeOf008='CF'">
        <span class="results_typeofcomp">
            <xsl:if test="$controlField008-26='a' or $controlField008-26='e' or $controlField008-26='f' or $controlField008-26='g'">
            <span class="label">; Type of computer file: </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-26='a'">
                    numeric data
                </xsl:when>
                <xsl:when test="$controlField008-26='e'">
                     <img src="/opac-tmpl/lib/famfamfam/silk/database.png" alt="database" title="database" class="format"/>
                </xsl:when>
                <xsl:when test="$controlField008-26='f'">
                     <img src="/opac-tmpl/lib/famfamfam/silk/font.png" alt="font" title="font" class="format"/>
                </xsl:when>
                <xsl:when test="$controlField008-26='g'">
                     <img src="/opac-tmpl/lib/famfamfam/silk/controller.png" alt="game" title="game" class="format"/>
                </xsl:when>
            </xsl:choose>
        </span>
        </xsl:if>
        <xsl:if test="$typeOf008='BK'">
        <span class="results_contents_literary">
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
                 <img src="/opac-tmpl/lib/famfamfam/silk/user.png" alt="biography" title="biography" class="natureofcontents"/>
            </xsl:if>

            <xsl:if test="$controlField008-33 and $controlField008-33!='|' and $controlField008-33!='u' and $controlField008-33!=' '">
            <span class="label">; Literary form: </span>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$controlField008-33='0'">
                    Not fiction
                </xsl:when>
                <xsl:when test="$controlField008-33='1'">
                    Fiction
                </xsl:when>
                <xsl:when test="$controlField008-33='d'">
                    Dramas
                </xsl:when>
                <xsl:when test="$controlField008-33='e'">
                    Essays
                </xsl:when>
                <xsl:when test="$controlField008-33='f'">
                    Novels
                </xsl:when>
                <xsl:when test="$controlField008-33='h'">
                    Humor, satires, etc.
                </xsl:when>
                <xsl:when test="$controlField008-33='i'">
                    Letters
                </xsl:when>
                <xsl:when test="$controlField008-33='j'">
                    Short stories
                </xsl:when>
                <xsl:when test="$controlField008-33='m'">
                    Mixed forms
                </xsl:when>
                <xsl:when test="$controlField008-33='p'">
                    Poetry
                </xsl:when>
                <xsl:when test="$controlField008-33='s'">
                    Speeches
                </xsl:when>
            </xsl:choose>
        </span>
        </xsl:if>
        <xsl:if test="$typeOf008='MU' and $controlField008-30-31 and $controlField008-30-31!='||' and $controlField008-30-31!='  '">
        <span class="results_literaryform">
            <span class="label">; Literary form: </span> <!-- Literary text for sound recordings -->
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
        </span>
        </xsl:if>
        <xsl:if test="$typeOf008='VM'">
        <span class="results_typeofvisual">
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
                <xsl:when test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
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
            </span>
        </xsl:if>
        </xsl:if>

    <xsl:if test="($typeOf008='BK' or $typeOf008='CF' or $typeOf008='MU' or $typeOf008='VM') and ($controlField008-22='a' or $controlField008-22='b' or $controlField008-22='c' or $controlField008-22='d' or $controlField008-22='e' or $controlField008-22='g' or $controlField008-22='j' or $controlField008-22='f')">
        <span class="results_audience">
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
        </span>
    </xsl:if>
<xsl:text> </xsl:text> <!-- added blank space to fix font display problem, see Bug 3671 -->
	</span>
</xsl:if>

    <!-- Publisher Statement: Alternate Graphic Representation (MARC 880) -->
    <xsl:if test="$display880">
      <xsl:call-template name="m880Select">
        <xsl:with-param name="basetags">260</xsl:with-param>
        <xsl:with-param name="codes">abcg</xsl:with-param>
        <xsl:with-param name="class">results_summary publisher</xsl:with-param>
        <xsl:with-param name="label">Publisher: </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Publisher info and RDA related info from tags 260, 264 -->
    <xsl:choose>
        <xsl:when test="marc:datafield[@tag=264]">
            <xsl:call-template name="showRDAtag264"/>
        </xsl:when>
        <xsl:when test="marc:datafield[@tag=260]">
            <span class="results_summary publisher"><span class="label">Publisher: </span>
                <xsl:for-each select="marc:datafield[@tag=260]">
                    <xsl:if test="marc:subfield[@code='a']">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">a</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                    <xsl:if test="marc:subfield[@code='b']">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">b</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">cg</xsl:with-param>
                        </xsl:call-template>
                       </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
                </xsl:for-each>
                <xsl:if test="marc:datafield[@tag=264]">
                    <xsl:text>; </xsl:text>
                    <xsl:call-template name="showRDAtag264"/>
                </xsl:if>
            </span>
        </xsl:when>
    </xsl:choose>

    <!-- Dissertation note -->
    <xsl:if test="marc:datafield[@tag=502]">
        <span class="results_summary diss_note">
            <span class="label">Dissertation note: </span>
            <xsl:for-each select="marc:datafield[@tag=502]">
                <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">abcdgo</xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:choose><xsl:when test="position()=last()"><xsl:text></xsl:text></xsl:when><xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise></xsl:choose>
        </span>
    </xsl:if>

    <!-- Other Title  Statement: Alternate Graphic Representation (MARC 880) -->
    <xsl:if test="$display880">
       <xsl:call-template name="m880Select">
         <xsl:with-param name="basetags">246</xsl:with-param>
         <xsl:with-param name="codes">ab</xsl:with-param>
         <xsl:with-param name="class">results_summary other_title</xsl:with-param>
         <xsl:with-param name="label">Other title: </xsl:with-param>
       </xsl:call-template>
    </xsl:if>

    <xsl:if test="marc:datafield[@tag=246]">
    <span class="results_summary other_title">
    <span class="label">Other title: </span>
            <xsl:for-each select="marc:datafield[@tag=246]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">ab</xsl:with-param>
                    </xsl:call-template>
                <!-- #13386 added separator | -->
                <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><span class="separator"><xsl:text> | </xsl:text></span></xsl:otherwise></xsl:choose>
            </xsl:for-each>
	</span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=242]">
    <span class="results_summary translated_title">
    <span class="label">Title translated: </span>
            <xsl:for-each select="marc:datafield[@tag=242]">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abh</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
            </xsl:for-each>
	</span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=856]">
         <span class="results_summary online_resources">
			   <span class="label">Online access: </span>
                            <xsl:for-each select="marc:datafield[@tag=856]">
                            <xsl:variable name="SubqText"><xsl:value-of select="marc:subfield[@code='q']"/></xsl:variable>
                            <xsl:if test="$OPACURLOpenInNewWindow='0'">
			      <a>
			      <xsl:choose>
			        <xsl:when test="$OPACTrackClicks='track'">
                      <xsl:attribute name="href">/cgi-bin/koha/tracklinks.pl?uri=<xsl:value-of select="str:encode-uri(marc:subfield[@code='u'], true())"/>&amp;biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>
				</xsl:when>
	                        <xsl:when test="$OPACTrackClicks='anonymous'">
                      <xsl:attribute name="href">/cgi-bin/koha/tracklinks.pl?uri=<xsl:value-of select="str:encode-uri(marc:subfield[@code='u'], true())"/>&amp;biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:attribute name="href"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute>
				</xsl:otherwise>
			      </xsl:choose>
                                    <xsl:choose>
                                     <xsl:when test="($Show856uAsImage='Results' or $Show856uAsImage='Both') and (substring($SubqText,1,6)='image/' or $SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
                                        <xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="marc:subfield[@code='y']"/></xsl:attribute><xsl:attribute name="style">height:100px;</xsl:attribute></xsl:element><xsl:text></xsl:text>
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
						<xsl:text>Click here to access online</xsl:text>
					</xsl:otherwise>
					</xsl:choose>
                                    </xsl:when>
                                    </xsl:choose>
                                    </a>
                              </xsl:if>
                            <xsl:if test="$OPACURLOpenInNewWindow='1'">
                                   <a target='_blank'>
				   <xsl:choose>
				     <xsl:when test="$OPACTrackClicks='track'">
                      <xsl:attribute name="href">/cgi-bin/koha/tracklinks.pl?uri=<xsl:value-of select="str:encode-uri(marc:subfield[@code='u'], true())"/>&amp;biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>
				     </xsl:when>
				     <xsl:when test="$OPACTrackClicks='anonymous'">
                      <xsl:attribute name="href">/cgi-bin/koha/tracklinks.pl?uri=<xsl:value-of select="str:encode-uri(marc:subfield[@code='u'], true())"/>&amp;biblionumber=<xsl:value-of select="$biblionumber"/></xsl:attribute>
				     </xsl:when>
				     <xsl:otherwise>
		                       <xsl:attribute name="href"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute>
				     </xsl:otherwise>
				   </xsl:choose>
                                    <xsl:choose>
                                    <xsl:when test="($Show856uAsImage='Results' or $Show856uAsImage='Both') and ($SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
                                        <xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="marc:subfield[@code='y']"/></xsl:attribute><xsl:attribute name="style">height:100px</xsl:attribute></xsl:element><xsl:text></xsl:text>
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
						<xsl:text>Click here to access online</xsl:text>
					</xsl:otherwise>
					</xsl:choose>
                                    </xsl:when>
                                    </xsl:choose>
                                    </a>
                              </xsl:if>
                                    <xsl:choose>
                                    <xsl:when test="position()=last()"><xsl:text> </xsl:text></xsl:when>
                                    <xsl:otherwise> | </xsl:otherwise>
                                    </xsl:choose>
                            </xsl:for-each>
                            </span>
                        </xsl:if>
                        <span class="results_summary availability">
                        <span class="label">Availability: </span>
                        <xsl:choose>
				   <xsl:when test="count(key('item-by-status', 'available'))=0 and count(key('item-by-status', 'reference'))=0">
                        <xsl:choose>
                            <xsl:when test="string-length($AlternateHoldingsField)=3 and marc:datafield[@tag=$AlternateHoldingsField]">
                            <xsl:variable name="AlternateHoldingsCount" select="count(marc:datafield[@tag=$AlternateHoldingsField])"/>
                            <xsl:for-each select="marc:datafield[@tag=$AlternateHoldingsField][1]">
                                <xsl:call-template name="subfieldSelect">
                                    <xsl:with-param name="codes"><xsl:value-of select="$AlternateHoldingsSubfields"/></xsl:with-param>
                                    <xsl:with-param name="delimeter"><xsl:value-of select="$AlternateHoldingsSeparator"/></xsl:with-param>
                                </xsl:call-template>
                            </xsl:for-each>
                            (<xsl:value-of select="$AlternateHoldingsCount"/>)
                            </xsl:when>
                            <xsl:otherwise>No items available </xsl:otherwise>
                        </xsl:choose>
				   </xsl:when>
                   <xsl:when test="count(key('item-by-status', 'available'))>0">
                   <span class="available">
                       <b><xsl:text>Items available for loan: </xsl:text></b>
                       <xsl:variable name="available_items"
                           select="key('item-by-status', 'available')"/>
               <xsl:choose>
                   <xsl:when test="$singleBranchMode=1">
                       <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch))[1])]">
                           <span class="ItemSummary">
                               <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber"> [<span class="LabelCallNumber">Call number: </span><xsl:value-of select="items:itemcallnumber"/>]</xsl:if>
                               <xsl:text> (</xsl:text>
                                   <xsl:value-of select="count(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch)))"/>
                               <xsl:text>)</xsl:text>
                               <xsl:choose>
                                   <xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when>
                                   <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                               </xsl:choose>
                            </span>
                       </xsl:for-each>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:choose>
                            <xsl:when test="$OPACResultsLibrary='homebranch'">
                               <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch))[1])]">
                                   <span class="ItemSummary">
                                       <xsl:value-of select="items:homebranch"/>
                                       <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber and $OPACItemLocation='callnum'"> [<span class="LabelCallNumber">Call number: </span><xsl:value-of select="items:itemcallnumber"/>]</xsl:if>
                                       <xsl:text> (</xsl:text>
                                           <xsl:value-of select="count(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch)))"/>
                                       <xsl:text>)</xsl:text>
                                       <xsl:choose>
                                           <xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when>
                                           <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                                       </xsl:choose>
                                   </span>
                               </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                               <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch-holding', concat(items:status, ' ', items:holdingbranch))[1])]">
                                   <span class="ItemSummary">
                                       <xsl:value-of select="items:holdingbranch"/>
                                       <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber and $OPACItemLocation='callnum'"> [<span class="LabelCallNumber">Call number: </span><xsl:value-of select="items:itemcallnumber"/>]</xsl:if>
                                       <xsl:text> (</xsl:text>
                                           <xsl:value-of select="count(key('item-by-status-and-branch-holding', concat(items:status, ' ', items:holdingbranch)))"/>
                                       <xsl:text>)</xsl:text>
                                       <xsl:choose>
                                           <xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when>
                                           <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                                       </xsl:choose>
                                   </span>
                               </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                   </xsl:otherwise>
               </xsl:choose>

           </span>
                   </xsl:when>
				   </xsl:choose>

            <xsl:choose>
                <xsl:when test="count(key('item-by-status', 'reference'))>0">
                    <span class="available">
                        <b><xsl:text>Items available for reference: </xsl:text></b>
                        <xsl:variable name="reference_items" select="key('item-by-status', 'reference')"/>
                        <xsl:for-each select="$reference_items[generate-id() = generate-id(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch))[1])]">
                            <span class="ItemSummary">
                                <xsl:if test="$singleBranchMode=0">
                                    <xsl:value-of select="items:homebranch"/>
                                </xsl:if>
                                <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber"> [<span class="LabelCallNumber">Call number: </span><xsl:value-of select="items:itemcallnumber"/>]</xsl:if>
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="count(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch)))"/>
                                <xsl:text>)</xsl:text>
                                <xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise></xsl:choose>
                            </span>
                        </xsl:for-each>
                    </span>
                </xsl:when>
            </xsl:choose>

                   <xsl:choose> <xsl:when test="count(key('item-by-status', 'available'))>0">
                       <xsl:choose><xsl:when test="count(key('item-by-status', 'reference'))>0">
                            <br/>
                       </xsl:when></xsl:choose>
                   </xsl:when> </xsl:choose>

                   <xsl:if test="count(key('item-by-status', 'Checked out'))>0">
                   <span class="unavailable">
                       <xsl:text>Checked out (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Checked out'))"/>
                       <xsl:text>). </xsl:text>
				   </span>
                   </xsl:if>
                   <xsl:if test="count(key('item-by-status', 'Withdrawn'))>0">
                   <span class="unavailable">
                       <xsl:text>Withdrawn (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Withdrawn'))"/>
                       <xsl:text>). </xsl:text>                   </span>
				   </xsl:if>
                    <xsl:if test="$hidelostitems='0' and count(key('item-by-status', 'Lost'))>0">
                   <span class="unavailable">
                       <xsl:text>Lost (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Lost'))"/>
                       <xsl:text>). </xsl:text>                   </span>
				   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'Damaged'))>0">
                   <span class="unavailable">
                       <xsl:text>Damaged (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Damaged'))"/>
                       <xsl:text>). </xsl:text>                   </span>
                   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'On order'))>0">
                   <span class="unavailable">
                       <xsl:text>On order (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'On order'))"/>
                       <xsl:text>). </xsl:text>                   </span>
                   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'In transit'))>0">
                   <span class="unavailable">
                       <xsl:text>In transit (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'In transit'))"/>
                       <xsl:text>). </xsl:text>                   </span>
                   </xsl:if>
                    <xsl:if test="count(key('item-by-status', 'Waiting'))>0">
                   <span class="unavailable">
                       <xsl:text>On hold (</xsl:text>
                       <xsl:value-of select="count(key('item-by-status', 'Waiting'))"/>
                       <xsl:text>). </xsl:text>                   </span>
                   </xsl:if>
               </span>
    <xsl:choose>
        <xsl:when test="($OPACItemLocation='location' or $OPACItemLocation='ccode') and (count(key('item-by-status', 'available'))!=0 or count(key('item-by-status', 'reference'))!=0)">
            <span class="results_summary location">
                <span class="label">Location(s): </span>
                <xsl:choose>
                <xsl:when test="count(key('item-by-status', 'available'))>0">
                    <span class="available">
                        <xsl:variable name="available_items" select="key('item-by-status', 'available')"/>
                        <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch))[1])]">
                            <xsl:choose>
                                <xsl:when test="$OPACItemLocation='location'"><b><xsl:value-of select="concat(items:location,' ')"/></b></xsl:when>
                                <xsl:when test="$OPACItemLocation='ccode'"><b><xsl:value-of select="concat(items:ccode,' ')"/></b></xsl:when>
                            </xsl:choose>
                            <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber"> <xsl:value-of select="items:itemcallnumber"/></xsl:if>
                            <xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise></xsl:choose>
                        </xsl:for-each>
                    </span>
                </xsl:when>
                <xsl:when test="count(key('item-by-status', 'reference'))>0">
                    <span class="available">
                        <xsl:variable name="reference_items" select="key('item-by-status', 'reference')"/>
                        <xsl:for-each select="$reference_items[generate-id() = generate-id(key('item-by-status-and-branch-home', concat(items:status, ' ', items:homebranch))[1])]">
                            <xsl:choose>
                                <xsl:when test="$OPACItemLocation='location'"><b><xsl:value-of select="concat(items:location,' ')"/></b></xsl:when>
                                <xsl:when test="$OPACItemLocation='ccode'"><b><xsl:value-of select="concat(items:ccode,' ')"/></b></xsl:when>
                            </xsl:choose>
                            <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber"> <xsl:value-of select="items:itemcallnumber"/></xsl:if>
                            <xsl:choose><xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when><xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise></xsl:choose>
                        </xsl:for-each>
                    </span>
                </xsl:when>
                </xsl:choose>
            </span>
        </xsl:when>
       </xsl:choose>
    </xsl:template>

    <xsl:template name="nameABCQ">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcq</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameABCDN">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">abcdn</xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                    <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
            </xsl:call-template>
    </xsl:template>

    <xsl:template name="nameACDEQ">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">acdeq</xsl:with-param>
            </xsl:call-template>
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
