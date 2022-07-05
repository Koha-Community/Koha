[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin ERM Resident Search Box -->
<div id="header_search">
    <div id="agreement_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/agreements" method="get">
            <label class="tip" for="agreement_name_filter">Agreement search:</label>
            <input class="head-searchbox" type="text" name="q" id="agreement_filter" size="40" />
            <input type="submit" value="OK" class="submit" />
        </form>
    </div>

    <div id="package_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/eholdings/local/packages" method="get">
            <label class="tip" for="package_name_filter">Package search:</label>
            <input class="head-searchbox" type="text" name="package_name" id="package_name_filter" size="40" />
            <input type="submit" value="OK" class="submit" />
        </form>
    </div>

    <div id="title_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/eholdings/local/titles" method="get">
            <label class="tip" for="title_filter">Title search:</label>
            <input class="head-searchbox" type="text" name="publication_title" id="title_filter" size="40" />
            <input type="submit" value="OK" class="submit" />
        </form>
    </div>

    <ul>
        <li><a class="keep_text" href="#agreement_search">Search agreements</a></li>
        <li><a class="keep_text" href="#package_search">Search packages</a></li>
        <li><a class="keep_text" href="#title_search">Search Titles</a></li>
    </ul>
</div>
</div>
<!-- End ERM Resident Search Box -->
