[% PROCESS 'form-blocks.inc' %]
<script type="text/javascript">
//<![CDATA[

$(document).ready(function(){

    var searchButton = new YAHOO.widget.Button("search");
    var cancelButton = new YAHOO.widget.Button("cancel");
    var clearButton = new YAHOO.widget.Button("clear");
    var newButton = new YAHOO.widget.Button("createnew");
    // marclist
    $( "#value_any" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "contains",
                    orderby: "HeadingAsc",
                    querytype: "marclist"
                },
                success: function(data) {
                    response( $.map( data, function( item ) {
                            return {
                                label: item.summary,
                                value: item.summary
                            }
                        }));
                }
            });
        },
        minLength: 3,
    });
    // mainentry
    $( "#value_main" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "contains",
                    orderby: "HeadingAsc",
                    querytype: "mainentry"
                },
                success: function(data) {
                    response( $.map( data, function( item ) {
                            return {
                                label: item.summary,
                                value: item.summary
                            }
                        }));
                }
            });
        },
        minLength: 3,
    });
    // mainmainentry
    $( "#value_mainstr" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "contains",
                    orderby: "HeadingAsc",
                    querytype: "mainmainentry"
                },
                success: function(data) {
                    response( $.map( data, function( item ) {
                            return {
                                label: item.summary,
                                value: item.summary
                            }
                        }));
                }
            });
        },
        minLength: 3,
    });
});

function finderjumpfull(page)
{
    window.open(page,'','fullscreen,scrollbars');
}

//]]>
</script>


<form name="f" method="get" action="auth_finder.pl">
            <input type="hidden" name="source" value="[% source %]" />
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="index" value="[% index %]" />
                <fieldset class="rows"><legend>Search options</legend>
                <ol><li>
                    <span class="label">Authority type</span>
                    [% authtypecode %]
                    <input type="hidden" name="authtypecode" value="[% authtypecode %]" />
                </li>
                <li>
                    <label for="mainmainentry">Main entry ($a only)</label>
                    <input type="hidden" name="marclist" value="mainmainentry" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="mainmainentry">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input id="value_mainstr" style="width:400px;" type="text" name="value_mainstr" value="[% value_mainstr |html %]" />
                    <div id="yvaluecontainermainmainentry"></div>
                </li>

                <li>
                    <label for="mainentry">Main entry</label>
                    <input type="hidden" name="marclist" value="mainentry" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="mainentry">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input id="value_main" style="width:400px;" type="text" name="value_main" value="[% value_main |html %]" />
                    <div id="yvaluecontainermainentry"></div>
                </li>

                <li>
                    <label for="marclistanywhere">Anywhere</label>
                    <input type="hidden" name="marclist" value="any" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="marclistanywhere">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input id="value_any" style="width:400px;" type="text" name="value_any" value="[% value_any |html %]" />
                    <div id="yvaluecontainermarclist"></div>
                </li>
                <li>
                    <label for="marclistheading">Heading match</label>
                    <input type="hidden" name="marclist" value="match" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="marclistheading">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input type="text" name="value_match" value="[% value_match |html %]" />
                </li>
        <li>
        <label for="orderby">Sort by </label>
        <select name="orderby" id="orderby">
            <option value="">No order</option>
            <option value="HeadingAsc" selected="selected">Heading ascendant</option>
            <option value="HeadingDsc">Heading descendant</option>
        </select>
        </li></ol></fieldset>
        [% IF source == 'auth' %]
        <fieldset class="rows"><legend>Relationship information</legend>
            <ol>
            <li>
                <label for="relationship">Special relationship: </label>
                <select name="relationship" id="relationship">
                    [% selected=relationship %]
                    [% PROCESS selectoptionopen value='' %]None specified</option>
                    [% PROCESS selectoptionopen value='a' %]a - Earlier heading</option>
                    [% PROCESS selectoptionopen value='b' %]b - Later heading</option>
                    [% PROCESS selectoptionopen value='d' %]d - Acronym</option>
                    [% PROCESS selectoptionopen value='f' %]f - Musical composition</option>
                    [% PROCESS selectoptionopen value='g' %]g - Broader term</option>
                    [% PROCESS selectoptionopen value='h' %]h - Narrower term</option>
                    [% PROCESS selectoptionopen value='i' %]i - Reference instruction phrase in subfield $i</option>
                    [% PROCESS selectoptionopen value='n' %]n - Not applicable</option>
                    [% PROCESS selectoptionopen value='r' %]r - Relationship designation in $i or $4</option>
                    [% PROCESS selectoptionopen value='t' %]t - Immediate parent body</option>
                </select>
            </li>
            </ol>
        </fieldset>
        [% END %]
        <fieldset class="action"> <input type="submit" value="Start search" class="submit" id="search" /> <a id="cancel" class="cancel close" href="#">Cancel</a>
        <span id="authfinderops">
        <a href="javascript:finderjumpfull('blinddetail-biblio-search.pl?authid=0&amp;index=[% index %]')" id="clear" class="button">Clear field</a>
        <a href="javascript:finderjumpfull('authorities.pl?index=[% index %]&authtypecode=[% authtypecode %]')" id="createnew" class="button">Create new</a>
        </span>
        </fieldset>
</form>
