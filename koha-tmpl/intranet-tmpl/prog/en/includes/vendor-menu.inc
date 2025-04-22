[% USE Koha %]
[% USE Asset %]
[% USE raw %]
[% USE To %]

<vendor-menu
    vendorid="[% booksellerid | uri %]"
    basketno="[% basketno | html %]"
    ordermanage="[% CAN_user_acquisition_order_manage | html %]"
    groupmanage="[% CAN_user_acquisition_group_manage | html %]"
    contractsmanage="[% CAN_user_acquisition_contracts_manage | html %]"
    issuemanage="[% CAN_user_acquisition_issue_manage | html %]"
></vendor-menu>
