<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Checkin Resident Search Box -->
<div id="header_search">
[% INCLUDE 'patron-search-box.inc' %]
[% IF ( CAN_user_catalogue ) %]
<div id="catalog_search" class="residentsearch">
    <p class="tip">Enter search keywords:</p>
    <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
        <input type="text" name="q" id="search-form" size="40" />
        <input type="submit" class="submit" value="Submit"/>
    </form>
</div>
[% END %]
<ul>
    [% IF ( CAN_user_circulate ) %]<li><a href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li><a href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>   

</div>
</div><!-- /gradient -->
<!-- End Checkin Resident Search Box -->
