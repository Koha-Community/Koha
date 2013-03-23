<fieldset id="acqui_basket_add">
    <legend>Add order to basket</legend>
    [% IF has_budgets %]
      <ul>
        <li>
          <label for="q">From an existing record: </label>
          <form action="/cgi-bin/koha/acqui/neworderbiblio.pl" method="post">
            <input type="hidden" name="booksellerid" value="[% booksellerid %]" />
            <input type="hidden" name="basketno" value="[% basketno %]" />
            <input id="q" type="text"  size="25" name="q" />
            <input type="submit" class="submit" value="Search" />
          </form>
        </li>
        <li><a href="/cgi-bin/koha/acqui/newordersuggestion.pl?booksellerid=[% booksellerid %]&amp;basketno=[% basketno %]">From a suggestion</a></li>
        <li><a href="/cgi-bin/koha/acqui/newordersubscription.pl?booksellerid=[% booksellerid %]&amp;basketno=[% basketno %]">From a subscription</a></li>
        <li><a href="/cgi-bin/koha/acqui/neworderempty.pl?booksellerid=[% booksellerid %]&amp;basketno=[% basketno %]">From a new (empty) record</a></li>
        <li><a href="/cgi-bin/koha/acqui/z3950_search.pl?booksellerid=[% booksellerid %]&amp;basketno=[% basketno %]">From an external source</a></li>
        <li><a href="/cgi-bin/koha/acqui/addorderiso2709.pl?booksellerid=[% booksellerid %]&amp;basketno=[% basketno %]"> From a staged file</a></li>
      </ul>
    [% ELSE %]
        You can't create any orders unless you first <a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">define a budget and a fund</a>.
    [% END %]
</fieldset>
