[% USE Koha %]
<div class="gradient">
  <div id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></div><!-- Begin Serials Resident Search Box -->
  <div id="header_search">
    <div id="subscription_search" class="residentsearch">
    <p class="tip">Search subscriptions:</p>
    <form action="/cgi-bin/koha/serials/serials-search.pl" method="get">
      [% IF ( routing ) %]
        <input type="hidden" name="routing" value="[% routing | html %]" />
      [% END %]
      <input type="hidden" name="searched" value="1" />
      <label for="ISSN_filter">ISSN:</label> <input type="text" size="10" maxlength="11" name="ISSN_filter" id="ISSN_filter" value="[% ISSN_filter | html %]" />

      [% IF (UNIMARC) %]
        <label for="EAN_filter">EAN:</label> <input type="text" size="20" maxlength="40" name="EAN_filter" id="EAN_filter" value="[% EAN_filter | html %]" />
      [% END %]
      <label for="title_filter">Title:</label> <input type="text" size="20" maxlength="40" name="title_filter" id="title_filter" value="[% title_filter | html %]" />
      <input value="Submit" class="submit" type="submit" /> <a href="/cgi-bin/koha/serials/serials-search.pl">Advanced search</a>
    </form>
    </div>
    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]
    <ul>
      <li><a href="#subscription_search">Search subscriptions</a></li>
      [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
      [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
    </ul>
  </div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Serials Resident Search Box -->
