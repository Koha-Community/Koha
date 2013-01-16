<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Patrons Resident Search Box -->
[% IF ( CAN_user_circulate ) %][% IF ( CircAutocompl ) %]<script type="text/javascript">
//<![CDATA[
YAHOO.util.Event.onContentReady("header_search", function() {
    new function() {
        // Define a custom formatter function
        this.fnCustomFormatter = function(oResultItem, sQuery) {
            var name        = oResultItem[0];
            var cardnumber  = oResultItem[1];
            var address     = oResultItem[2];
            var city        = oResultItem[3];
            var zip         = oResultItem[4];
            var aMarkup = [
                "<div class=\"sample-result\">",
                name,
                " (",
                cardnumber,
                ")<small> -- ",
                address,
                ", ",
                city,
                "<\/small>",
                "<\/div>"];
            return (aMarkup.join(""));
        };

        // Instantiate one XHR DataSource and define schema as an array:
        //     ["Record Delimiter",
        //     "Field Delimiter"]
        this.oACDS = new YAHOO.widget.DS_XHR("/cgi-bin/koha/circ/ysearch.pl", ["\n", "\t"]);
        this.oACDS.responseType = YAHOO.widget.DS_XHR.TYPE_FLAT;
        this.oACDS.maxCacheEntries = 60;
        this.oACDS.queryMatchSubset = true;

        // Instantiate first AutoComplete
        var myInput = document.getElementById('findborrower');
        var myContainer = document.getElementById('yborrowercontainer');
        this.oAutoComp = new YAHOO.widget.AutoComplete(myInput,myContainer,this.oACDS);
        //this.oAutoComp.delimChar = ";";
        //this.oAutoComp.queryDelay = 1;
        this.oAutoComp.formatResult = this.fnCustomFormatter;
}
});
//]]>
</script>[% END %][% END %]
<div id="header_search">
	<div id="patron_search" class="residentsearch">
	<p class="tip">Enter patron card number or partial name:</p>
	<form action="/cgi-bin/koha/members/member.pl" method="post">
    <input id="searchmember" size="25" class="focus" name="member" type="text" value="[% member %]"/>
	[% IF ( branchloop ) %]
	<span class="filteraction" id="filteraction_off"> <a href="#" onclick="$('#filters').toggle();$('.filteraction').toggle();">[-]</a></span>
	<span class="filteraction" id="filteraction_on"> <a href="#" onclick="$('#filters').toggle();$('.filteraction').toggle();">[+]</a></span>
	[% END %]

      <label for="searchfields">Search fields:</label>
      <select name="searchfields" id="searchfields">
          <option selected="selected" value=''>Standard</option>
          <option value='email,emailpro,B_email,'>Email</option>
          <option value='borrowernumber'>Borrower number</option>
          <option value='phone,phonepro,B_phone,altcontactphone,mobile'>Phone number</option>
      </select>

      <label for="searchtype">Search type:</label>
      <select name="searchtype" id="searchtype">
          <option selected="selected" value=''>Starts with</option>
          <option value='contain'>Contains</option>
      </select>

    <label for="orderby">Order by:</label>
    <select name="orderby" id="searchorderby">
    <option value="surname,0">Surname</option>
    <option value="cardnumber,0">Cardnumber</option>
    </select>
    <input value="Search" class="submit" type="submit" />
	[% IF ( branchloop ) %]
	<p id="filters"> <label for="branchcode">Library: </label><select name="branchcode" id="branchcode">
        <option value="">Any</option>[% FOREACH branchloo IN branchloop %]
        [% IF ( branchloo.selected ) %]
        <option value="[% branchloo.value %]" selected="selected">[% branchloo.branchname %]</option>[% ELSE %]
        <option value="[% branchloo.value %]">[% branchloo.branchname %]</option>[% END %]
      [% END %]</select>
                 <label for="categorycode">Category: </label><select name="categorycode" id="categorycode">
        <option value="">Any</option>[% FOREACH categorie IN categories %]
        [% IF ( categorie.selected ) %]
        <option value="[% categorie.categorycode %]" selected="selected">[% categorie.description %]</option>[% ELSE %]
        <option value="[% categorie.categorycode %]">[% categorie.description %]</option>[% END %]
      [% END %]</select>
	</p>
	[% END %]
</form>
	</div>
	[% IF ( CAN_user_circulate ) %]
	<div id="circ_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/circ/circulation.pl" method="post" autocomplete="off">
    [% IF ( CircAutocompl ) %]
    <div class="autocomplete">
            <div id="borrowerautocomplete" class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" type="text" />
                <div id="yborrowercontainer"></div>
                <input id="ysearchsubmit" type="submit" class="submit" value="Submit" />
                <input name="branch" value="[% branch %]" type="hidden" />
                <input name="printer" value="" type="hidden" />
            </div>
        </div>
	[% ELSE %]
            <input id="findborrower" name="findborrower" size="40" type="text" />
            <input name="branch" value="[% branch %]" type="hidden" />
            <input name="printer" value="" type="hidden" />
            <input value="Submit" class="submit" type="submit" />
	[% END %]
    </form>
	</div>[% END %]
	[% IF ( CAN_user_catalogue ) %]
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" name="op" id="opac-submit" value="Submit" class="submit" />
		</form>
	</div>[% END %]
    [% IF ( CAN_user_circulate ) %]
    <div id="checkin_search" class="residentsearch" style="display:none;">
    <p class="tip">Scan a barcode to check in:</p>
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
    <input name="barcode" id="ret_barcode" size="40" accesskey="r" />
    <input value="Submit" class="submit" type="submit" />
    </form>
    </div>
    [% END %]
			<ul>
            <li><a href="/cgi-bin/koha/members/members-home.pl#patron_search">Search patrons</a></li>
            [% IF ( CAN_user_circulate ) %]<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate ) %]<li><a href="/cgi-bin/koha/circ/returns.pl#checkin_search">Check in</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the catalog</a></li>[% END %]
			</ul>
</div><!-- /header_search -->
</div><!-- /gradient -->
<script type="text/javascript">//<![CDATA[
$(document).ready(function() {
    [% IF ( advsearch ) %]$("#filteraction_on").toggle();
    [% ELSE %]$("#filters").toggle();
    $("#filteraction_off").toggle();[% END %]
});
//]]>
</script>
<!-- End Patrons Resident Search Box -->
