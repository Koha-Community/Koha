<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1>
<!-- Begin Authorities Resident Search Box -->
<div id="header_search" class="residentsearch">
    <div id="mainmain_heading" class="residentsearch">
    <p class="tip">Enter main heading ($a only):</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select name="authtypecode">
        [% IF (marcflavour == 'UNIMARC' ) %]<option value="">All authority types</option>[% END %]
        [% FOREACH authority_type IN authority_types %]
            [% IF authority_type.authtypecode == authtypecode %]
            <option value="[% authority_type.authtypecode%]" selected="selected">[% authority_type.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authority_type.authtypecode %]">[% authority_type.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="mainmainentry" />
        <input type="hidden" name="and_or" value="and" />
        <input type="hidden" name="excluding" value="" />
        <select name="operator">
            [% IF ( operator == 'contains' ) %]
            <option value="contains" selected="selected">contains</option>
            [% ELSE %]
            <option value="contains">contains</option>
            [% END %]
            [% IF ( operator == 'start' ) %]
            <option value="start" selected="selected">starts with</option>
            [% ELSE %]
            <option value="start">starts with</option>
            [% END %]
            [% IF ( operator == 'is' ) %]
            <option value="is" selected="selected">is exactly</option>
            [% ELSE %]
            <option value="is">is exactly</option>
            [% END %]
        </select>
        <input id="value_mainentry" type="text" name="value" value="[% value | html%]" class="head-searchbox" />
        <select name="orderby">
            [% IF ( orderby == 'HeadingAsc' ) %]
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            [% ELSE %]
            <option value="HeadingAsc">Heading A-Z</option>
            [% END %]
            [% IF ( orderby == 'HeadingDsc' ) %]
            <option value="HeadingDsc" selected="selected">Heading Z-A</option>
            [% ELSE %]
            <option value="HeadingDsc">Heading Z-A</option>
            [% END %]
            [% IF ( orderby == '' && op ) %]
            <option value="" selected="selected">None</option>
            [% ELSE %]
            <option value="">None</option>
            [% END %]
        </select>
        <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <div id="main_heading" class="residentsearch">
    <p class="tip">Enter main heading:</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select name="authtypecode">
        [% IF (marcflavour == 'UNIMARC' ) %]<option value="">All authority types</option>[% END %]
        [% FOREACH authority_type IN authority_types %]
            [% IF authority_type.authtypecode == authtypecode %]
            <option value="[% authority_type.authtypecode %]" selected="selected">[% authority_type.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authority_type.authtypecode %]">[% authority_type.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="mainentry" />
        <input type="hidden" name="and_or" value="and" />
        <input type="hidden" name="excluding" value="" />
        <select name="operator">
            [% IF ( operator == 'contains' ) %]
            <option value="contains" selected="selected">contains</option>
            [% ELSE %]
            <option value="contains">contains</option>
            [% END %]
            [% IF ( operator == 'start' ) %]
            <option value="start" selected="selected">starts with</option>
            [% ELSE %]
            <option value="start">starts with</option>
            [% END %]
            [% IF ( operator == 'is' ) %]
            <option value="is" selected="selected">is exactly</option>
            [% ELSE %]
            <option value="is">is exactly</option>
            [% END %]
        </select>
        <input id="value_mainentry" type="text" name="value" value="[% value | html%]" class="head-searchbox" />
        <select name="orderby">
            [% IF ( orderby == 'HeadingAsc' ) %]
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            [% ELSE %]
            <option value="HeadingAsc">Heading A-Z</option>
            [% END %]
            [% IF ( orderby == 'HeadingDsc' ) %]
            <option value="HeadingDsc" selected="selected">Heading Z-A</option>
            [% ELSE %]
            <option value="HeadingDsc">Heading Z-A</option>
            [% END %]
            [% IF ( orderby == '' && op ) %]
            <option value="" selected="selected">None</option>
            [% ELSE %]
            <option value="">None</option>
            [% END %]
        </select>
        <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <div id="matchheading_search" class="residentsearch">
    <p class="tip">Enter any heading:</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select name="authtypecode">
        [% IF (marcflavour == 'UNIMARC' ) %]<option value="">All authority types</option>[% END %]
        [% FOREACH authority_type IN authority_types %]
            [% IF authority_type.authtypecode == authtypecode %]
            <option value="[% authority_type.authtypecode %]" selected="selected">[% authority_type.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authority_type.authtypecode %]">[% authority_type.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="match" />
        <select name="operator">
            [% IF ( operator == 'contains' ) %]
            <option value="contains" selected="selected">contains</option>
            [% ELSE %]
            <option value="contains">contains</option>
            [% END %]
            [% IF ( operator == 'start' ) %]
            <option value="start" selected="selected">starts with</option>
            [% ELSE %]
            <option value="start">starts with</option>
            [% END %]
            [% IF ( operator == 'is' ) %]
            <option value="is" selected="selected">is exactly</option>
            [% ELSE %]
            <option value="is">is exactly</option>
            [% END %]
        </select>
        <input id="value_matchheading" type="text" name="value" value="[% value | html %]" class="head-searchbox" />
        <select name="orderby">
            [% IF ( orderby == 'HeadingAsc' ) %]
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            [% ELSE %]
            <option value="HeadingAsc">Heading A-Z</option>
            [% END %]
            [% IF ( orderby == 'HeadingDsc' ) %]
            <option value="HeadingDsc" selected="selected">Heading Z-A</option>
            [% ELSE %]
            <option value="HeadingDsc">Heading Z-A</option>
            [% END %]
            [% IF ( orderby == '' && op ) %]
            <option value="" selected="selected">None</option>
            [% ELSE %]
            <option value="">None</option>
            [% END %]
         </select>
         <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <div id="entire_record" class="residentsearch">
    <p class="tip">Enter any authority field:</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select name="authtypecode">
        [% IF (marcflavour == 'UNIMARC' ) %]<option value="">All authority types</option>[% END %]
        [% FOREACH authority_type IN authority_types %]
            [% IF authority_type.authtypecode == authtypecode %]
            <option value="[% authority_type.authtypecode %]" selected="selected">[% authority_type.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authority_type.authtypecode %]">[% authority_type.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="all" />
        <input type="hidden" name="and_or" value="and" />
        <input type="hidden" name="excluding" value="" />
        <select name="operator">
            [% IF ( operator == 'contains' ) %]
            <option value="contains" selected="selected">contains</option>
            [% ELSE %]
            <option value="contains">contains</option>
            [% END %]
            [% IF ( operator == 'start' ) %]
            <option value="start" selected="selected">starts with</option>
            [% ELSE %]
            <option value="start">starts with</option>
            [% END %]
            [% IF ( operator == 'is' ) %]
            <option value="is" selected="selected">is exactly</option>
            [% ELSE %]
            <option value="is">is exactly</option>
            [% END %]
        </select>
        <input id="value_anywhere" type="text" name="value" value="[% value | html %]" class="head-searchbox" />
        <select name="orderby">
            [% IF ( orderby == 'HeadingAsc' ) %]
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            [% ELSE %]
            <option value="HeadingAsc">Heading A-Z</option>
            [% END %]
            [% IF ( orderby == 'HeadingDsc' ) %]
            <option value="HeadingDsc" selected="selected">Heading Z-A</option>
            [% ELSE %]
            <option value="HeadingDsc">Heading Z-A</option>
            [% END %]
            [% IF ( orderby == '' && op ) %]
            <option value="" selected="selected">None</option>
            [% ELSE %]
            <option value="">None</option>
            [% END %]
        </select>
        <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <ul>
        <li><a class="keep_text" href="#mainmain_heading">Search main heading ($a only)</a></li>
        <li><a class="keep_text" href="#main_heading">Search main heading</a></li>
        <li><a class="keep_text" href="#matchheading_search">Search all headings</a></li>
        <li><a class="keep_text" href="#entire_record">Search entire record</a></li>
    </ul>
</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Authorities Resident Search Box -->
