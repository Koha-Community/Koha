<!-- Begin Circulation Resident Search Box -->



<script type="text/javascript" src="http://yui.yahooapis.com/2.3.1/build/utilities/utilities.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.3.1/build/autocomplete/autocomplete-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.3.1/build/yahoo-dom-event/yahoo-dom-event-min.js"></script>
<script type="text/javascript" src="http://yui.yahooapis.com/2.3.1/build/element/element-beta-min.js"></script>



<style type="text/css">
.yui-skin-sam .yui-ac {
    position:relative;
    font-size:100%;
}
.yui-skin-sam .yui-ac-input { 
    position:absolute;
    width:100%;}
.yui-skin-sam .yui-ac-container { 
    position:absolute;
    top:1.6em;
    width:100%;
}
.yui-skin-sam .yui-ac-content {
    position:absolute;
    width:100%;
    border:1px solid #808080;
    background:#fff;
    overflow:hidden;
    z-index:9050;
}
.yui-skin-sam .yui-ac-shadow {
    position:absolute;
    margin:.3em;
    width:100%;
    background:#000;
    -moz-opacity:0.10;
    opacity:.10;
    filter:alpha(opacity=10);
    z-index:9049;
}
.yui-skin-sam .yui-ac-content ul {
    margin:0;
    padding:0;
    width:100%;
}
.yui-skin-sam .yui-ac-content li {
    margin:0;
    padding:2px 5px;
    cursor:default;
    white-space:nowrap;
}
.yui-skin-sam .yui-ac-content li.yui-ac-prehighlight {
    background:#B3D4FF;
}
.yui-skin-sam .yui-ac-content li.yui-ac-highlight {
    background:#426FD9;
    color:#FFF;
}



#borrowerautocomplete { width: 405px; text-align:left;} /* z-index needed on top instances for ie & sf absolute inside relative issue */
.autocomplete { width:130px; }/* set width of widget here*/
.autocomplete .yui-ac-highlight ,
.autocomplete .yui-ac-highlight .sample-result,
.autocomplete .yui-ac-highlight .sample-query { color:#FFF; }
.autocomplete .sample-result { color: black; }
.autocomplete .sample-query { color:#000; }
#findborrower { position:static; width:335px; }  */
#yborrowercontainer { text-align:left;width:300px; }
</style>


<div id="header_search">

<div id="circ_search" class="residentsearch">
    <p class="tip">Entrer le n° de carte d'adhérent ou une partie du nom : </p>
    <form action="/cgi-bin/koha/circ/circulation.pl" method="post">
        <div class="yui-skin-sam">
            <div id="borrowerautocomplete" class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" class="focus" type="text" />
                <div id="yborrowercontainer"></div>
                <input id="ysearchsubmit" type="submit" value="Valider">
                <input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
                <input name="printer" value="" type="hidden" />
            </div>
        </div>
    </form>
</div>	

<div id="checkin_search" class="residentsearch">
    <p class="tip">Scanner un code à barre pour le retour</p>
    <form method="post" action="/cgi-bin/koha/circ/returns.pl">
        <input name="barcode" id="ret_barcode" size="40" maxlength="14" />
        <input value="Valider" type="submit">
    </form>
</div>

<div id="catalog_search" class="residentsearch">
    <p class="tip">Entrer les termes de recherche :</p>
    <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
        <input type="text" name="q" id="search-form" size="40" />
=======
>>>>>>> french translation updated (again...):koha-tmpl/intranet-tmpl/prog/fr/includes/circ-search-autocompl.inc
    </form>
</div>

<ul>
    <li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Prêt</a></li>
    <li><a href="/cgi-bin/koha/circ/returns.pl#checkin_search">Retours</a></li>
    <li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Recherche catalogue</a></li>
</ul>   

</div>


<script type="text/javascript">
YAHOO.bsearch.ACFlatData = new function() {
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



</script>

<!-- End Circulation Resident Search Box -->
