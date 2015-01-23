<fieldset class="acqui_basket_add">
    <legend>Add order to basket</legend>
    [% IF has_budgets %]
      <ul>
        <li>
          <form action="/cgi-bin/koha/acqui/neworderbiblio.pl" method="post">
            <label>From an existing record:
                <input type="text"  size="25" name="q" />
            </label>
            <input type="hidden" name="booksellerid" value="[% booksellerid | html %]" />
            <input type="hidden" name="basketno" value="[% basketno | html %]" />
            <input type="submit" class="submit" value="Search" />
          </form>
        </li>
        <li><a href="/cgi-bin/koha/acqui/newordersuggestion.pl?booksellerid=[% booksellerid | html %]&amp;basketno=[% basketno | html %]">From a suggestion</a></li>
        <li><a href="/cgi-bin/koha/acqui/newordersubscription.pl?booksellerid=[% booksellerid | html %]&amp;basketno=[% basketno | html %]">From a subscription</a></li>
        <li><a href="/cgi-bin/koha/acqui/neworderempty.pl?booksellerid=[% booksellerid | html %]&amp;basketno=[% basketno | html %]">From a new (empty) record</a></li>
        <li><a href="/cgi-bin/koha/acqui/z3950_search.pl?booksellerid=[% booksellerid | html %]&amp;basketno=[% basketno | html %]">From an external source</a></li>
        <li><a href="/cgi-bin/koha/acqui/addorderiso2709.pl?booksellerid=[% booksellerid | html %]&amp;basketno=[% basketno | html %]"> From a staged file</a></li>
        [% IF ( CAN_user_circulate ) %]<li><a href="/cgi-bin/koha/circ/reserveratios.pl?booksellerid=[% booksellerid | html %]&amp;basketno=[% basketno | html %]">From titles with highest hold ratios</a></li>[% END %]
      </ul>
    [% ELSE %]
        <div class="dialog alert">
          <p>You can't create any orders unless you first <a href="/cgi-bin/koha/admin/aqbudgetperiods.pl">define a budget and a fund</a>.</p>
        </div>
    [% END %]
</fieldset>
