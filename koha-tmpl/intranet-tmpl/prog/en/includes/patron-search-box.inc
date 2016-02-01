[% USE Branches %]
[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %][% IF ( CircAutocompl ) %]<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
    $( "#findborrower" ).autocomplete({
        source: "/cgi-bin/koha/circ/ysearch.pl",
        minLength: 3,
        select: function( event, ui ) {
            $( "#findborrower" ).val( ui.item.cardnumber );
            $("#patronsearch").submit();
            return false;
        }
    })
    .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
        .data( "ui-autocomplete-item", item )
        .append( "<a>" + item.surname + ", " + item.firstname + " (" + item.cardnumber + ") <small>" + item.dateofbirth + " " + item.address + " " + item.city + " " + item.zipcode + " " + item.country + "</small></a>" )
        .appendTo( ul );
    };

});
//]]>
</script>[% END %]
    <div id="circ_search" class="residentsearch">
    <p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/circ/circulation.pl" id="patronsearch" method="post">
    [% IF ( CircAutocompl ) %]
    <div class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" size="40" class="head-searchbox focus" type="text" />
                <input id="autocsubmit" type="submit" class="submit" value="Submit" />
                <input name="branch" value="[% Branches.GetLoggedInBranchcode() %]" type="hidden" />
                <input name="printer" value="" type="hidden" />
            [% IF ( stickyduedate ) %]
                <input type="hidden" name="duedatespec" value="[% duedatespec %]" />
                <input type="hidden" name="stickyduedate" value="[% stickyduedate %]" />
            [% END %]
        </div>
	[% ELSE %]
            <input id="findborrower" name="findborrower" size="40" class="head-searchbox focus" type="text" />
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
