[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <div id="circ_search" class="residentsearch">
        <form action="/cgi-bin/koha/circ/circulation.pl" id="patronsearch" method="post">
            <span class="form-content">
                <input autocomplete="off" id="findborrower" name="findborrower" class="head-searchbox form-control" type="text" placeholder="Enter patron card number or partial name" size="40"/>

                [% IF ( stickyduedate ) %]
                    <input type="hidden" name="duedatespec" value="[% duedatespec | html %]" />
                    <input type="hidden" name="stickyduedate" value="[% stickyduedate | html %]" />
                [% END %]
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>
[% END %]
