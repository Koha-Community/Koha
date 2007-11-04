<!-- Begin Suggestions Resident Search Box -->
<!-- TMPL_IF NAME="CircAutocompl" --><script type="text/javascript">
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
                "<div class='sample-result'>",
                name,
                " (",
                cardnumber,
                ")<small> -- ",
                address,
                ", ",
                city,
                "</small>",
                "</div>"];
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
</script><!-- /TMPL_IF -->
<div id="header_search">
	<div id="suggestions_search" class="residentsearch">
	<p class="tip">Suggestions Search:</p>
	<form action="/cgi-bin/koha/acqui/newordersuggestion.pl" method="get">
	<label for="searchtitle">Title:</label> <input type="text" id="searchtitle" name="title" value="<!-- TMPL_VAR NAME="title"-->" />
    <label for="searchauthor">Author:</label> <input type="text" id="searchauthor" name="author" value="<!-- TMPL_VAR NAME="author" -->" />
    <label for="searchpublishercode">Publisher:</label> <input type="text" id="searchpublishercode" name="publishercode" value="<!-- TMPL_VAR NAME="publishercode"-->" />
    <input type="submit" class="button" value="Search Suggestions" />
        </form>
	</div>
	<div id="circ_search" class="residentsearch">
	<p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/circ/circulation.pl" method="post">
    <!-- TMPL_IF NAME="CircAutocompl" -->
    <div class="autocomplete">
            <div id="borrowerautocomplete" class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" class="focus" type="text" />
                <div id="yborrowercontainer"></div>
                <input id="ysearchsubmit" type="submit" value="Submit">
                <input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
                <input name="printer" value="" type="hidden" />
            </div>
        </div>
	<!-- TMPL_ELSE -->
            <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
            <input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
            <input name="printer" value="" type="hidden" />
            <input value="Submit" type="submit" />
	<!-- /TMPL_IF -->
    </form>
	</div>	
	<div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit"  class="form-submit" />
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/acqui/newordersuggestion.pl?booksellerid=<!-- TMPL_VAR NAME="supplierid" -->&amp;basketno=<!-- TMPL_VAR NAME="basketno" -->#suggestions_search">Search Printers</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>
			<li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Suggestions Resident Search Box -->
