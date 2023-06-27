[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <!-- renew-search-box.inc -->
    [% IF( bs_tab_active ) %]
        <div id="renew_search" role="tabpanel" class="tab-pane active">
    [% ELSE %]
        <div id="renew_search" role="tabpanel" class="tab-pane">
    [% END %]
        <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
            <div class="form-title">
                <label class="control-label"><span class="control-text">Renew</span> <i class="fa fa-fw fa-retweet" aria-hidden="true"></i></label>
            </div>

            <div class="form-content">
                <input name="barcode" id="ren_barcode" class="head-searchbox form-control" accesskey="r" type="text" placeholder="Scan a barcode to renew" size="40"/>
            </div>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>
    <!-- /renew-search-box.inc -->
[% END %]
