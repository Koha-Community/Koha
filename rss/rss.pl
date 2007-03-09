<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE rss PUBLIC "-//Netscape Communications/DTD RSS 0.91/EN"
          "http://my.netscape.com/publish/formats/rss-0.91.dtd">

<rss version="0.91">

<channel>
 <title><!-- TMPL_VAR name="CHANNELTITLE" --></title>
 <link><!-- TMPL_VAR name="CHANNELLINK" --></link>
 <description><!-- TMPL_VAR name="CHANNELDESC" --></description>
 <language><!-- TMPL_VAR name="CHANNELLANG" --></language>
 <lastBuildDate><!-- TMPL_VAR name="CHANNELLASTBUILD" --></lastBuildDate>

 <image>
  <title><!-- TMPL_VAR name="IMAGETITLE" --></title>
  <url><!-- TMPL_VAR name="IMAGEURL" --></url>
  <link><!-- TMPL_VAR name="IMAGELINK" --></link>
 </image>

<!-- TMPL_LOOP NAME="ITEMS" -->
 <item>
  <title><!-- TMPL_VAR name="TITLE" --><!-- TMPL_IF NAME="SUBTITLE" --> <!-- TMPL_VAR name="SUBTITLE" --><!-- /TMPL_IF --><!-- TMPL_IF NAME="AUTHOR" -->, by <!-- TMPL_VAR name="AUTHOR" --><!-- /TMPL_IF --></title>
        <category><!-- TMPL_VAR NAME="itemtype" --></category>
        <description><![CDATA[Call Number: <!-- TMPL_VAR NAME="callno" --><br />
        <!-- TMPL_IF NAME="notes" -->Notes: <!-- TMPL_VAR NAME="notes" --><br /><!-- /TMPL_IF -->
<a href="https://libcat.nbbc.edu/cgi-bin/koha/opac-detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">View Details</a> <!-- TMPL_IF NAME="reservable" -->| <a href="https://libcat.nbbc.edu/cgi-bin/koha/opac-reserve.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Reserve this Item</a><!-- /TMPL_IF -->]]>
</description>
  <link>https://libcat.nbbc.edu/cgi-bin/koha/opac-detail.pl?biblionumber=<!-- TMPL_VAR name="biblionumber" --></link>

 </item>
<!-- /TMPL_LOOP -->

</channel>
</rss>
