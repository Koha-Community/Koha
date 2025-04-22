[% USE Koha %]
[% USE Asset %]
[% USE raw %]
[% USE To %]

<acquisitions-menu
    ordermanage="[% CAN_user_acquisition_order_manage | html %]"
    orderreceive="[% CAN_user_acquisition_order_receive | html %]"
    edifact="[% Koha.Preference('EDIFACT') | html %]"
    edimanage="[% CAN_user_acquisition_edi_manage | html %]"
    reports="[% CAN_user_reports | html %]"
    circulateremainingpermissions="[% CAN_user_circulate_circulate_remaining_permissions | html %]"
    periodmanage="[% CAN_user_acquisition_period_manage | html %]"
    budgetmanage="[% CAN_user_acquisition_budget_manage | html %]"
    currenciesmanage="[% CAN_user_acquisition_currencies_manage | html %]"
    manageadditionalfields="[% CAN_user_parameters_manage_additional_fields | html %]"
    invoiceedit="[% CAN_user_acquisition_edit_invoices | html %]"
    suggestionscreate="[% CAN_user_suggestions_suggestions_create | html %]"
    suggestionsmanage="[% CAN_user_suggestions_suggestions_manage | html %]"
    suggestionsdelete="[% CAN_user_suggestions_suggestions_delete | html %]"
    marcorderautomation="[% Koha.Preference('MarcOrderingAutomation') | html %]"
    marcordermanage="[% CAN_user_acquisition_marc_order_manage | html %]"
></acquisitions-menu>
