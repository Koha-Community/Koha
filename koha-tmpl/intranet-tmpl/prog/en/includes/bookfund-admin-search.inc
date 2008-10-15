
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1><!-- Begin Fund Admin Resident Search Box -->
<!-- TMPL_IF NAME="CAN_user_circulate" --><!-- TMPL_IF NAME="CircAutocompl" --><script type="text/javascript">
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
 </script>  <!-- /TMPL_IF --><!-- /TMPL_IF -->
<div id="header_search">
	<div id="bookfund_search" class="residentsearch">
	<p class="tip">Search Funds:</p>

	<form action="/cgi-bin/koha/admin/aqbookfund.pl" method="post">
      <label for="filter_bookfundid_s">Code: </label><select name="filter_bookfundid" id="filter_bookfundid_s">
        <option value="">----</option>
    <!-- TMPL_LOOP name="filter_bookfundids" -->
      <!-- TMPL_IF NAME="selected" -->
        <option value="<!-- TMPL_VAR name="bookfundid" -->" selected="selected"><!-- TMPL_VAR name="bookfundid" --></option>
      <!-- TMPL_ELSE -->
        <option value="<!-- TMPL_VAR name="bookfundid" -->"><!-- TMPL_VAR name="bookfundid" --></option>
      <!-- /TMPL_IF -->
    <!-- /TMPL_LOOP -->
      </select>
      <label for="filter_bookfundname_s">Name: </label><input type="text" name="filter_bookfundname" id="filter_bookfundname_s" size="10" value="<!-- TMPL_VAR name="filter_bookfundname" -->" />
      <label for="filter_branchcode_s">Library: </label><select name="filter_branchcode" id="filter_branchcode_s" style="width:10em;">
        <option value="">----</option>
    <!-- TMPL_LOOP name="filter_branches" -->
      <!-- TMPL_IF NAME="selected" -->
        <option value="<!-- TMPL_VAR name="code" -->" selected="selected"><!-- TMPL_VAR name="name" --></option>
      <!-- TMPL_ELSE -->
        <option value="<!-- TMPL_VAR name="code" -->"><!-- TMPL_VAR name="name" --></option>
      <!-- /TMPL_IF -->
    <!-- /TMPL_LOOP -->
      </select>
      <input type="submit" name="filter" value="Submit" />
</form>

	</div>
	<!-- TMPL_IF NAME="CAN_user_circulate" -->
	<div id="circ_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/circ/circulation.pl" method="post">
    <!-- TMPL_IF NAME="CircAutocompl" -->
    <div class="autocomplete">
            <div id="borrowerautocomplete" class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" class="focus" type="text" />
                <div id="yborrowercontainer"></div>
                <input id="ysearchsubmit" type="submit" class="submit" value="Submit" />
                <input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
                <input name="printer" value="" type="hidden" />
            </div>
        </div>
	<!-- TMPL_ELSE -->
            <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
            <input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
            <input name="printer" value="" type="hidden" />
            <input value="Submit" class="submit" type="submit" />
	<!-- /TMPL_IF -->
    </form>
	</div>	
	<!-- /TMPL_IF -->
	
	<!-- TMPL_IF NAME="CAN_user_catalogue" -->
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit"  class="submit" />
		</form>
	</div><!-- /TMPL_IF -->
			<ul>
			<li><a href="/cgi-bin/koha/admin/aqbookfund.pl#bookfund_search">Search Funds</a></li>
			<!-- TMPL_IF NAME="CAN_user_circulate" --><li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li><!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_catalogue" --><li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li><!-- /TMPL_IF -->
			</ul>	
</div>
<!-- End Suggestions Resident Search Box -->
