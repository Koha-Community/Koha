<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1>
<!-- Begin Authorities Resident Search Box -->
<div id="header_search" class="residentsearch">
    <div id="authority_search" class="residentsearch">
    <p class="tip">Enter authority heading ($a):</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select name="authtypecode">
        <option value="">All Authority Types</option>
        [% FOREACH authtypesloo IN authtypesloop %]
            [% IF ( authtypesloo.selected ) %]
            <option value="[% authtypesloo.value %]" selected="selected">[% authtypesloo.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authtypesloo.value %]">[% authtypesloo.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="mainmainentry" />
        <select name="operator">
            <option value="contains">contains</option>
            <option value="start">starts with</option>
            <option value="is">is exactly</option>
        </select>
        <input id="value_anywhere" type="text" name="value" value="[% value %]" />
        <select name="orderby">
            <option value="">None</option>
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            <option value="HeadingDsc">Heading Z-A</option>
         </select>
         <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <div id="main_heading" class="residentsearch">
    <p class="tip">Enter authority heading:</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select  name="authtypecode">
        <option value="">All Authority Types</option>
        [% FOREACH authtypesloo IN authtypesloop %]
            [% IF ( authtypesloo.selected ) %]
            <option value="[% authtypesloo.value %]" selected="selected">[% authtypesloo.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authtypesloo.value %]">[% authtypesloo.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="mainentry" />
        <input type="hidden" name="and_or" value="and" />
        <input type="hidden" name="excluding" value="" />
        <select name="operator">
            <option value="contains">contains</option>
            <option value="start">starts with</option>
            <option value="is">is exactly</option>
        </select>
        <input id="value_mainentry" type="text" name="value" value="[% value %]" />
        <select name="orderby">
            <option value="">None</option>
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            <option value="HeadingDsc">Heading Z-A</option>
        </select>
        <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <div id="all_headings" class="residentsearch">
    <p class="tip">Enter any authority field:</p>
    <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
        <input type="hidden" name="op" value="do_search" />
        <input type="hidden" name="type" value="intranet" />
        <select name="authtypecode">
        <option value="">All Authority Types</option>
        [% FOREACH authtypesloo IN authtypesloop %]
            [% IF ( authtypesloo.selected ) %]
            <option value="[% authtypesloo.value %]" selected="selected">[% authtypesloo.authtypetext %]</option>
            [% ELSE %]
            <option value="[% authtypesloo.value %]">[% authtypesloo.authtypetext %]</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="marclist" value="all" />
        <input type="hidden" name="and_or" value="and" />
        <input type="hidden" name="excluding" value="" />
        <select name="operator">
            <option value="contains">contains</option>
            <option value="start">starts with</option>
            <option value="is">is exactly</option>
        </select>
        <input id="value_mainmainentry" type="text" name="value" value="[% value %]" />
        <select name="orderby">
            <option value="">None</option>
            <option value="HeadingAsc" selected="selected">Heading A-Z</option>
            <option value="HeadingDsc">Heading Z-A</option>
        </select>
        <input type="submit" class="submit" value="Submit" />
    </form>
    </div>
    <ul>
        <li><a href="#authority_search">Search authorities</a></li>
        <li><a href="#main_heading">Search main heading</a></li>
        <li><a href="#all_headings">Search all headings</a></li>
    </ul>
</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Authorities Resident Search Box -->
