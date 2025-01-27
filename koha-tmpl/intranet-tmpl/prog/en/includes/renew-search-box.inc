[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <!-- renew-search-box.inc -->
    [% WRAPPER tab_panel tabname="renew_search" bt_active= bs_tab_active %]
        <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
            [% INCLUDE 'csrf-token.inc' %]

            <div class="form-title">
                <label class="control-label" for="ren_barcode"><span class="control-text">Renew</span> <i class="fa fa-fw fa-retweet" aria-hidden="true"></i></label>
            </div>

            <div class="form-content">
                <input name="barcode" id="ren_barcode" class="head-searchbox form-control" accesskey="r" type="text" placeholder="Scan a barcode to renew" size="40" />
            </div>
            <input type="hidden" name="op" value="cud-renew" />
            <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
        </form>
    [% END # /tab_panel %]
    <!-- /renew-search-box.inc -->
[% END %]
