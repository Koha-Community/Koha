[% USE Branches %]
[% USE Registers %]
<div id="pos-menu" class="sidebar_menu">
    [% IF ( CAN_user_cash_management_cashup || CAN_user_cash_management_anonymous_refund ) %]
        <h5>Cash management</h5>
        <ul>
            <li><a href="/cgi-bin/koha/pos/pay.pl">Point of sale</a></li>
            [% IF !(Registers.session_register_name == '') %]
                <li><a href="/cgi-bin/koha/pos/register.pl">Transaction history for [% Registers.session_register_name | html %]</a></li>
            [% END %]
            <li><a href="/cgi-bin/koha/pos/registers.pl">Cash summary for [% Branches.GetLoggedInBranchname | html %]</a></li>
        </ul>
    [% END %]
    [% IF ( CAN_user_parameters_manage_cash_registers || CAN_user_parameters_manage_accounts) %]
        <h5>Administration</h5>
        <ul>
            [% IF ( CAN_user_parameters_manage_cash_registers ) %]
                <li><a href="/cgi-bin/koha/admin/cash_registers.pl">Configure cash registers</a></li>
            [% END %]

            [% IF ( CAN_user_parameters_manage_accounts ) %]
                <li><a href="/cgi-bin/koha/admin/debit_types.pl">Configure items for purchase</a></li>
            [% END %]
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
