[% USE Branches %]
[% USE Registers %]
<div id="pos-menu" class="sidebar_menu icon-collapse">
    [% IF ( CAN_user_cash_management_cashup || CAN_user_cash_management_anonymous_refund ) %]
        <h5>Cash management</h5>
        <ul>
            <li
                ><a href="/cgi-bin/koha/pos/pay.pl" title="Point of sale"><i class="fa-solid fa-cash-register fa-fw" aria-hidden="true"></i><span class="menu-label">Point of sale</span></a></li
            >
            [% IF !(Registers.session_register_name == '') %]
                <li
                    ><a href="/cgi-bin/koha/pos/register.pl" title="Transaction history"
                        ><i class="fa-solid fa-receipt fa-fw" aria-hidden="true"></i><span class="menu-label">Transaction history for [% Registers.session_register_name | html %]</span></a
                    ></li
                >
            [% END %]
            <li
                ><a href="/cgi-bin/koha/pos/registers.pl" title="Cash summary"><i class="fa-solid fa-coins fa-fw" aria-hidden="true"></i><span class="menu-label">Cash summary for [% Branches.GetLoggedInBranchname | html %]</span></a></li
            >
        </ul>
    [% END %]
    [% IF ( CAN_user_parameters_manage_cash_registers || CAN_user_parameters_manage_accounts) %]
        <h5>Administration</h5>
        <ul>
            [% IF ( CAN_user_parameters_manage_cash_registers ) %]
                <li
                    ><a href="/cgi-bin/koha/admin/cash_registers.pl" title="Configure cash registers"><i class="fa-solid fa-gear fa-fw" aria-hidden="true"></i><span class="menu-label">Configure cash registers</span></a></li
                >
            [% END %]

            [% IF ( CAN_user_parameters_manage_accounts ) %]
                <li
                    ><a href="/cgi-bin/koha/admin/debit_types.pl" title="Configure items for purchase"><i class="fa-solid fa-tags fa-fw" aria-hidden="true"></i><span class="menu-label">Configure items for purchase</span></a></li
                >
            [% END %]
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
