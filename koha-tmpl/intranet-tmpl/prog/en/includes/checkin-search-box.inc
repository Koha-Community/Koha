[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <!-- checkin-search-box.inc -->
    [% IF( bs_tab_active ) %]
        <div id="checkin_search" role="tabpanel" class="tab-pane active">
    [% ELSE %]
        <div id="checkin_search" role="tabpanel" class="tab-pane">
    [% END %]
        <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
            <div class="form-title">
                <label class="control-label"><span class="control-text">Check in</span> <i class="fa fa-fw fa-download" aria-hidden="true"></i></label>
            </div>

            <div class="form-content">
                <input name="barcode" id="ret_barcode" class="head-searchbox form-control" accesskey="r" type="text" placeholder="Scan a barcode to check in" size="40"/>
            </div>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>
    <!-- /checkin-search-box.inc -->
[% END %]
