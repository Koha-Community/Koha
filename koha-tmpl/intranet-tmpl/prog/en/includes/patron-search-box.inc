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
</script>[% END %]
	<div id="circ_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/circ/circulation.pl" method="post">
    [% IF ( CircAutocompl ) %]
    <div class="autocomplete">
            <div id="borrowerautocomplete" class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" size="40" class="focus" type="text" /> <input id="ysearchsubmit" type="submit" class="submit" value="Submit" />
                <div id="yborrowercontainer"></div>
                <input name="branch" value="[% branch %]" type="hidden" />
                <input name="printer" value="" type="hidden" />
            [% IF ( stickyduedate ) %]
                <input type="hidden" name="duedatespec" value="[% duedatespec %]" />
                <input type="hidden" name="stickyduedate" value="[% stickyduedate %]" />
            [% END %]
            </div>
        </div>
	[% ELSE %]
            <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
            <input name="branch" value="[% branch %]" type="hidden" />
            <input name="printer" value="" type="hidden" />
            [% IF ( stickyduedate ) %]
            <input type="hidden" name="duedatespec" value="[% duedatespec %]" />
            <input type="hidden" name="stickyduedate" value="[% stickyduedate %]" />
            [% END %]
            <input value="Submit" class="submit" type="submit" />
	[% END %]
    </form>
	</div>
	[% END %]
