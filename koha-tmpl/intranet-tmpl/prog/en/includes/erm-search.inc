[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1>
<div id="header_search">
    <div id="erm_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/agreements.pl">
            <label class="tip" for="searchfield">Agreement search:</label>
            <input type="hidden" name="op" value="search" />
            <input class="head-searchbox" type="text" size="40" name="searchfield" id="searchfield" value="">
            <input type="submit" class="submit" value="Search" />
        </form>
    </div>
    <ul>
        <li>
            <a class="keep_text" href="#agreement_search">Search agreements</a>
        </li>
    </ul>
</div>
</div>
