<script type="text/javascript">
//<![CDATA[

$(document).ready(function(){
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

//]]>
</script>


<span id="header_search">
<form name="f" method="get" action="auth_finder.pl">
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="index" value="[% index %]" />
                <fieldset class="rows"><ol><li>
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
                    <label for="marclist">Anywhere</label>
                    <input type="hidden" name="marclist" value="any" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="marclist">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input id="value_any" style="width:400px;" type="text" name="value_any" value="[% value_any |html %]" />
                    <div id="yvaluecontainermarclist"></div>
                </li>
                <li>
                    <label for="marclist">Heading match</label>
                    <input type="hidden" name="marclist" value="match" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="marclist">
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
            <fieldset class="action"> <input type="submit" value="Start search" class="submit" /> <a class="cancel close" href="#">Cancel</a></fieldset>
</form>
</span>
