[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <div id="checkin_search" class="residentsearch">
        <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
            <span class="form-title">
                <label class="control-label">Check in</label>
            </span>
            <span class="form-content">
                <input name="barcode" id="ret_barcode" class="head-searchbox form-control" accesskey="r" type="text" placeholder="Scan a barcode to check in" size="40"/>
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>
[% END %]
