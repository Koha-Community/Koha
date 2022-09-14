[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <div id="renew_search" class="residentsearch">
        <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
            <span class="form-title">
                <label class="control-label">Renew</label>
            </span>

            <span class="form-content">
                <input name="barcode" id="ren_barcode" class="head-searchbox form-control" accesskey="r" type="text" placeholder="Scan a barcode to renew" size="40"/>
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>
[% END %]
