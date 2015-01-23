[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <div id="circ_search" class="residentsearch">
    <p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/circ/circulation.pl" id="patronsearch" method="post">
    [% IF ( CircAutocompl ) %]
    <div class="autocomplete">
                <input autocomplete="off" id="findborrower" name="findborrower" size="40" class="head-searchbox focus" type="text" />
                <input id="autocsubmit" type="submit" class="submit" value="Submit" />
            [% IF ( stickyduedate ) %]
                <input type="hidden" name="duedatespec" value="[% duedatespec | html %]" />
                <input type="hidden" name="stickyduedate" value="[% stickyduedate | html %]" />
            [% END %]
        </div>
	[% ELSE %]
            <input id="findborrower" name="findborrower" size="40" class="head-searchbox focus" type="text" />
            [% IF ( stickyduedate ) %]
            <input type="hidden" name="duedatespec" value="[% duedatespec | html %]" />
            <input type="hidden" name="stickyduedate" value="[% stickyduedate | html %]" />
            [% END %]
            <input value="Submit" class="submit" type="submit" />
	[% END %]
    </form>
	</div>
	[% END %]
