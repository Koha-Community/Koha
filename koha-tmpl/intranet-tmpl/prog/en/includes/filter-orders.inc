[% USE Koha %]
[% USE KohaDates %]
<ol>
    <li><label for="title">Title: </label> <input type="text" name="title" id="title" value="[% filters.title | html %]" /></li>
    <li><label for="author">Author: </label> <input type="text" name="author" id="author" value="[% filters.author | html %]" /></li>
    <li><label for="isbn">ISBN: </label> <input type="text" name="isbn" id="isbn" value="[% filters.isbn | html %]" /></li>
            [% IF Koha.Preference('marcflavour') == 'UNIMARC' %]
    <li><label for="ean">EAN: </label> <input type="text" name="ean" id="ean" value="[% filters.ean | html %]" /></li>
            [% END %]
    <li><label for="name">Vendor: </label> <input type="text" name="name" id="name" value="[% filters.name | html %]" /></li>
    <li><label for="basket">Basket: </label> <input type="text" name="basket" id="basket" value="[% filters.basket | html %]" /></li>
    <li><label for="basket_creators">Basket created by: </label>
        <input autocomplete="off" id="find_patron" type="text" style="width:150px" class="noEnterSubmit" />
        <div>
            <div id="basket_creators" style="float:left;"></div>
        </div>
    </li>
    <li><label for="booksellerinvoicenumber ">Bookseller invoice no: </label> <input type="text" name="booksellerinvoicenumber" id="booksellerinvoicenumber" value="[% filters.booksellerinvoicenumber | html %]" /></li>
    <li>
        <label for="basketgroupname">Basket group:</label>
        <input type="text" name="basketgroupname" id="basketgroupname" value="[% filters.basketgroupname | html %]" />
    </li>
    <li>
      <label for="ordernumber">Order line:</label>
      <input type="text" name="ordernumber" id="ordernumber" value="[% filters.ordernumber | html %]" />
      [% IF filters.search_children_too %]
        <input type="checkbox" name="search_children_too" id="search_children_too" value="1" checked="checked" />
      [% ELSE %]
        <input type="checkbox" name="search_children_too" id="search_children_too" value="1" />
      [% END %]
      <label class="yesno" for="search_children_too">Display children too.</label>
    </li>

    <li>
        <label for="orderstatus">Order status: </label>
        <select name="orderstatus" id="orderstatus">
            [% IF filters.orderstatus == "" %]
              <option value="">Any status except cancelled</option>
            [% ELSE %]
              <option value="" selected="selected"></option>
            [% END %]
            [% IF filters.orderstatus == "new" %]
              <option value="new" selected="selected">New</option>
            [% ELSE %]
              <option value="new">New</option>
            [% END %]
            [% IF filters.orderstatus == "ordered" %]
              <option value="ordered" selected="selected">Ordered</option>
            [% ELSE %]
              <option value="ordered">Ordered</option>
            [% END %]
            [% IF filters.orderstatus == "partial" %]
              <option value="partial" selected="selected">Partially received</option>
            [% ELSE %]
              <option value="partial">Partially received</option>
            [% END %]
            [% IF filters.orderstatus == "complete" %]
              <option value="complete" selected="selected">Received</option>
            [% ELSE %]
              <option value="complete">Received</option>
            [% END %]
            [% IF filters.orderstatus == "cancelled" %]
              <option value="cancelled" selected="selected">Cancelled</option>
            [% ELSE %]
              <option value="cancelled">Cancelled</option>
            [% END %]
        </select>
    </li>
    <li>
        <label for="fund">Fund: </label>
        <select name="budget" id="fund">
            <option value="">All funds</option>
            [% FOREACH bp_loo IN bp_loop %]
                <optgroup label="[% bp_loo.budget_period_description | html %]">
                [% FOREACH h_loo IN bp_loo.hierarchy %]
                  [% IF h_loo.budget_id == filters.budget %]
                    <option type="text" value="[% h_loo.budget_id | html %]" branchcode="[% h_loo.budget_branchcode | html %]" selected="selected">
                  [% ELSE %]
                    <option type="text" value="[% h_loo.budget_id | html %]" branchcode="[% h_loo.budget_branchcode | html %]">
                  [% END %]
                        [% h_loo.budget_display_name | html %]
                    </option>
                [% END %]
                </optgroup>
            [% END %]
        </select>
    </li>

    <li><label for="from">From: </label>
    <input type="text" size="10" id="from" name="from" value="[% filters.from_placed_on | $KohaDates %]" class="datepickerfrom" />
            <div class="hint">[% INCLUDE 'date-format.inc' %]</div>
    </li>
    <li><label for="to">To: </label>
    <input type="text" size="10" id="to" name="to" value="[% filters.to_placed_on | $KohaDates %]" class="datepickerto" />
            <div class="hint">[% INCLUDE 'date-format.inc' %]</div>
    </li>
</ol>
