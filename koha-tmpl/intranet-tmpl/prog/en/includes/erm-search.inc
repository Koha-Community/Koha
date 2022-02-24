[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Cities Resident Search Box -->
<div id="header_search">
    <div id="agreement_search" class="residentsearch">
        <form action="[% script_name | html %]" method="post">
            <label class="tip" for="agreement_name_filter">Agreement search:</label>
            <input class="head-searchbox" type="text" name="agreement_name_filter" id="agreement_name_filter" value="[% agreement_name_filter | html %]" size="40" />
            <input type="submit" name="submit" value="OK" class="submit" />
        </form>
    </div>

    <ul>
        <li><a class="keep_text" href="#agreement_search">Search agreements</a></li>
    </ul>
</div>
</div>
<!-- End Cities Resident Search Box -->
