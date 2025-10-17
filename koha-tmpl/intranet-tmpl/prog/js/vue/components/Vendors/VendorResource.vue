<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
    },
    setup(props, { emit }) {
        const format_date = $date;

        const vendorStore = inject("vendorStore");
        const { currencies, gstValues } = storeToRefs(vendorStore);

        const handleContactOptions = value => {
            return value ? "Yes" : "No";
        };

        const verifyDiscountValue = discount => {
            return /^[\-]?\d{0,2}(\.\d{0,3})*$/.test(discount);
        };

        const additionalToolbarButtons = (resource, componentData) => {
            const { instancedResource } = componentData;
            const buttons = {
                form: [
                    {
                        title: $__("Save"),
                        icon: "save",
                        callback: () => {
                            componentData.resourceForm.value.requestSubmit()
                        },
                        cssClass: "btn btn-primary"
                    },
                    {
                        to: {
                            name: "VendorList",
                        },
                        title: $__("Cancel"),
                        icon: "times",
                        cssClass: "btn btn-link",
                    },
                ],
                show: [
                    {
                        dropdownButtons: [
                            {
                                to: {
                                    path: "/cgi-bin/koha/acqui/basketheader.pl",
                                    query: {
                                        booksellerid: resource.id,
                                        op: "add_form",
                                    },
                                },
                                title: "Basket",
                                callback: toolbarComponent => {
                                    const url = toolbarComponent.handleQuery(
                                        toolbarComponent.to
                                    );
                                    toolbarComponent.redirect(url);
                                },
                            },
                            {
                                to: {
                                    path: "/cgi-bin/koha/admin/aqcontract.pl",
                                    query: {
                                        booksellerid: resource.id,
                                        op: "add_form",
                                    },
                                },
                                title: "Contract",
                                callback: toolbarComponent => {
                                    const url = toolbarComponent.handleQuery(
                                        toolbarComponent.to
                                    );
                                    toolbarComponent.redirect(url);
                                },
                            },
                            {
                                to: { name: "VendorFormAdd" },
                                title: "Vendor",
                            },
                        ],
                        title: $__("New"),
                        index: -1,
                    },
                ],
            };
            if (
                resource.active &&
                resource.baskets_count > 0 &&
                instancedResource.isUserPermitted(
                    "CAN_user_acquisition_order_receive"
                )
            ) {
                buttons.show.push({
                    to: {
                        path: "/cgi-bin/koha/acqui/parcels.pl",
                        query: { booksellerid: resource.id },
                    },
                    title: $__("Receive shipments"),
                    callback: toolbarComponent => {
                        const url = toolbarComponent.handleQuery(
                            toolbarComponent.to
                        );
                        toolbarComponent.redirect(url);
                    },
                    icon: "inbox",
                });
            }
            return buttons;
        };
        const defaultToolbarButtons = (defaultButtons, resource) => {
            return {
                list: defaultButtons.list,
                show: defaultButtons.show.filter(
                    button =>
                        button.action === "edit" ||
                        (resource.baskets_count === 0 &&
                            resource.subscriptions_count === 0 &&
                            resource.invoices_count === 0 &&
                            button.action === "delete")
                ),
            };
        };

        const baseResource = useBaseResource({
            resourceName: "vendor",
            nameAttr: "name",
            idAttr: "id",
            components: {
                show: "VendorShow",
                list: "VendorList",
                add: "VendorFormAdd",
                edit: "VendorFormAddEdit",
            },
            apiClient: APIClient.acquisition.vendors,
            table: {
                resourceTableUrl:
                    APIClient.acquisition.httpClient._baseURL + "vendors",
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this vendor?"
                ),
                deleteSuccessMessage: $__("Vendor %s deleted"),
                displayName: $__("Vendor"),
                editLabel: $__("Edit vendor #%s"),
                emptyListMessage: $__("There are no vendors defined"),
                newLabel: $__("New vendor"),
            },
            props,
            moduleStore: "vendorStore",
            formGroupsDisplayMode: "accordion",
            showGroupsDisplayMode: "splitScreen",
            splitScreenGroupings: [
                { name: "Details", pane: 1 },
                { name: "Aliases", pane: 1 },
                { name: "Ordering information", pane: 2 },
                { name: "Interfaces", pane: 2 },
            ],
            additionalToolbarButtons,
            defaultToolbarButtons,
            stickyToolbar: ["Form"],
            extendedAttributesResourceType: "vendor",
            extendedAttributesFieldGroup: "Details",
            resourceAttrs: [
                {
                    name: "id",
                    group: $__("Details"),
                    label: $__("ID"),
                    type: "text",
                    hideIn: ["Form", "Show"],
                },
                {
                    name: "name",
                    tableDataSearchFields: "me.name:aliases.alias:me.id",
                    group: $__("Details"),
                    required: true,
                    type: "text",
                    label: $__("Vendor name"),
                },
                {
                    name: "postal",
                    group: $__("Details"),
                    type: "textarea",
                    label: $__("Postal address"),
                    textAreaRows: 3,
                    hideIn: ["List"],
                },
                {
                    name: "physical",
                    group: $__("Details"),
                    type: "textarea",
                    label: $__("Physical address"),
                    textAreaRows: 3,
                    hideIn: ["List"],
                },
                {
                    name: "phone",
                    group: $__("Details"),
                    type: "text",
                    label: $__("Phone"),
                    hideIn: ["List"],
                },
                {
                    name: "fax",
                    group: $__("Details"),
                    type: "text",
                    label: $__("Fax"),
                    hideIn: ["List"],
                },
                {
                    name: "url",
                    group: $__("Details"),
                    type: "text",
                    label: $__("Website"),
                    hideIn: ["List"],
                },
                {
                    name: "accountnumber",
                    group: $__("Details"),
                    type: "text",
                    label: $__("Account number"),
                    hideIn: ["List"],
                },
                {
                    name: "type",
                    group: $__("Details"),
                    type: "select",
                    label: $__("Vendor type"),
                    avCat: "av_vendor_types",
                    fallbackType: "text",
                },
                {
                    name: "aliases",
                    type: "relationshipWidget",
                    group: $__("Aliases"),
                    showElement: {
                        type: "table",
                        columnData: "aliases",
                        hidden: vendor => !!vendor.aliases?.length,
                        columns: [
                            {
                                name: $__("Alias"),
                                value: "alias",
                            },
                        ],
                    },
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "aliases",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Alias"),
                            removeThisMessage: $__("Remove this alias"),
                            addNewMessage: $__("Add new alias"),
                            noneCreatedYetMessage: $__(
                                "There are no aliases created yet"
                            ),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                alias: "",
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "alias",
                            type: "text",
                            label: $__("Alias"),
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
                {
                    name: "contacts",
                    type: "relationshipWidget",
                    group: $__("Contacts"),
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "contacts",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Contact"),
                            removeThisMessage: $__("Remove this contact"),
                            addNewMessage: $__("Add new contact"),
                            noneCreatedYetMessage: $__(
                                "There are no contacts created yet"
                            ),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                name: "",
                                position: "",
                                email: "",
                                phone: "",
                                notes: "",
                                altphone: "",
                                fax: "",
                                acqprimary: false,
                                orderacquisition: false,
                                claimacquisition: false,
                                serialsprimary: false,
                                claimissues: false,
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "name",
                            type: "text",
                            label: $__("Name"),
                            indexRequired: true,
                        },
                        {
                            name: "position",
                            type: "text",
                            label: $__("Position"),
                            indexRequired: true,
                        },
                        {
                            name: "phone",
                            type: "text",
                            label: $__("Phone"),
                            indexRequired: true,
                        },
                        {
                            name: "altphone",
                            type: "text",
                            label: $__("Alternative phone"),
                            indexRequired: true,
                        },
                        {
                            name: "fax",
                            type: "text",
                            label: $__("Fax"),
                            indexRequired: true,
                        },
                        {
                            name: "email",
                            type: "text",
                            label: $__("Email"),
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            type: "text",
                            label: $__("Notes"),
                            indexRequired: true,
                        },
                        {
                            type: "component",
                            componentPath:
                                "@koha-vue/components/Vendors/VendorContacts.vue",
                            indexRequired: true,
                            componentProps: {
                                contact: {
                                    type: "resource",
                                    value: null,
                                },
                            },
                            hideIn: ["List", "Show"],
                        },
                    ],
                    hideIn: ["List", "Show"],
                },
                {
                    name: "interfaces",
                    type: "relationshipWidget",
                    group: $__("Interfaces"),
                    showElement: {
                        type: "component",
                        hidden: vendor => !!vendor.interfaces?.length,
                        componentPath:
                            "@koha-vue/components/Vendors/VendorInterfaces.vue",
                        componentProps: {
                            vendor: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "interfaces",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Interface"),
                            removeThisMessage: $__("Remove this interface"),
                            addNewMessage: $__("Add new interface"),
                            noneCreatedYetMessage: $__(
                                "There are no interfaces created yet"
                            ),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                type: "",
                                name: "",
                                uri: "",
                                login: "",
                                password: "",
                                account_email: "",
                                notes: "",
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "name",
                            type: "text",
                            label: $__("Name"),
                            indexRequired: true,
                        },
                        {
                            name: "type",
                            type: "select",
                            label: $__("Type"),
                            avCat: "av_vendor_interface_types",
                            indexRequired: true,
                        },
                        {
                            name: "uri",
                            type: "text",
                            label: $__("URI"),
                            indexRequired: true,
                        },
                        {
                            name: "login",
                            type: "text",
                            label: $__("Login"),
                            indexRequired: true,
                        },
                        {
                            name: "password",
                            type: "text",
                            label: $__("Password"),
                            indexRequired: true,
                        },
                        {
                            name: "account_email",
                            type: "text",
                            label: $__("Account email"),
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            type: "text",
                            label: $__("Notes"),
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
                {
                    name: "active",
                    group: $__("Ordering information"),
                    label: $__("Vendor is"),
                    type: "radio",
                    options: [
                        { value: true, description: $__("Active") },
                        { value: false, description: $__("Inactive") },
                    ],
                    value: true,
                },
                {
                    name: "list_currency",
                    group: $__("Ordering information"),
                    type: "select",
                    label: $__("List prices are"),
                    selectLabel: "currency",
                    requiredKey: "currency",
                    options: currencies.value,
                    defaultValue: null,
                    hideIn: ["List"],
                },
                {
                    name: "invoice_currency",
                    group: $__("Ordering information"),
                    type: "select",
                    selectLabel: "currency",
                    requiredKey: "currency",
                    label: $__("Invoice prices are"),
                    options: currencies.value,
                    defaultValue: null,
                },
                {
                    name: "gst",
                    group: $__("Ordering information"),
                    label: $__("Tax number registered"),
                    type: "radio",
                    options: [
                        { value: true, description: $__("Yes") },
                        { value: false, description: $__("No") },
                    ],
                    value: true,
                    hideIn: ["List"],
                },
                {
                    name: "invoice_includes_gst",
                    group: $__("Ordering information"),
                    label: $__("Invoice prices"),
                    type: "radio",
                    options: [
                        { value: true, description: $__("Include tax") },
                        { value: false, description: $__("Don't include tax") },
                    ],
                    value: true,
                    hideIn: ["List"],
                },
                {
                    name: "list_includes_gst",
                    group: $__("Ordering information"),
                    label: $__("List prices"),
                    type: "radio",
                    options: [
                        { value: true, description: $__("Include tax") },
                        { value: false, description: $__("Don't include tax") },
                    ],
                    value: true,
                    hideIn: ["List"],
                },
                {
                    name: "tax_rate",
                    group: $__("Ordering information"),
                    type: "select",
                    label: $__("Tax rate"),
                    options: gstValues.value,
                    defaultValue: null,
                    requiredKey: "value",
                    selectLabel: "label",
                    hideIn: ["List"],
                },
                {
                    name: "discount",
                    group: $__("Ordering information"),
                    type: "number",
                    label: $__("Discount (%)"),
                    defaultValue: null,
                    size: 6,
                    formErrorHandler: verifyDiscountValue,
                    formErrorMessage: $__(
                        "Please enter a decimal number in the format: 0.0"
                    ),
                    hideIn: ["List"],
                },
                {
                    name: "deliverytime",
                    group: $__("Ordering information"),
                    type: "number",
                    label: $__("Delivery time (days)"),
                    hideIn: ["List"],
                },
                {
                    name: "notes",
                    group: $__("Ordering information"),
                    type: "textarea",
                    label: $__("Notes"),
                    hideIn: ["List"],
                },
                {
                    name: "baskets",
                    tableColumnDefinition: {
                        title: $__("Baskets"),
                        data: "baskets_count",
                        searchable: false,
                        orderable: false,
                        render(data, type, row, meta) {
                            return row.baskets_count
                                ? '<a href="/cgi-bin/koha/acqui/booksellers.pl?booksellerid=' +
                                      row.id +
                                      '" class="show">' +
                                      escape_str(
                                          $__("%s basket(s)").format(
                                              row.baskets_count
                                          )
                                      ) +
                                      "</a>"
                                : escape_str($__("No baskets"));
                        },
                    },
                    hideIn: ["Show", "Form"],
                },
                {
                    name: "subscriptions",
                    tableColumnDefinition: {
                        title: $__("Subscriptions"),
                        data: "subscriptions_count",
                        searchable: false,
                        orderable: false,
                        render(data, type, row, meta) {
                            return row.subscriptions_count
                                ? '<a href="/cgi-bin/koha/serials/serials-search.pl?bookseller_filter=' +
                                      escape_str(row.name) +
                                      "&searched=1" +
                                      '" class="show">' +
                                      escape_str(
                                          $__("%s subscription(s)").format(
                                              row.subscriptions_count
                                          )
                                      ) +
                                      "</a>"
                                : escape_str($__("No subscriptions"));
                        },
                    },
                    hideIn: ["Show", "Form"],
                },
            ],
        });

        const tableOptions = {
            options: {
                embed: "aliases,baskets+count,subscriptions+count,invoices+count,extended_attributes,+strings",
            },
            url: baseResource.getResourceTableUrl(),
            table_settings: baseResource.vendorTableSettings,
            add_filters: true,
            filters_options: {
                ...(baseResource.map_av_dt_filter("av_vendor_types").length && {
                    type: () =>
                        baseResource.map_av_dt_filter("av_vendor_types"),
                }),
                active: [
                    { _id: 0, _str: $__("Inactive") },
                    { _id: 1, _str: $__("Active") },
                ],
            },
            actions: {
                "-1": [
                    "edit",
                    {
                        delete: {
                            text: $__("Delete"),
                            icon: "fa fa-trash",
                            should_display: row =>
                                row.baskets_count === 0 &&
                                row.subscriptions_count === 0 &&
                                row.invoices_count === 0,
                        },
                    },
                    {
                        receive: {
                            text: $__("Receive shipments"),
                            icon: "fa fa-inbox",
                            should_display: row =>
                                row.active &&
                                row.baskets_count > 0 &&
                                baseResource.isUserPermitted(
                                    "CAN_user_acquisition_order_receive"
                                ),
                            callback: ({ id }, dt, event) => {
                                event.preventDefault();
                                window.location.href = `/cgi-bin/koha/acqui/parcels.pl?booksellerid=${id}`;
                            },
                        },
                    },
                ],
            },
            default_filters: {
                ...(baseResource.route.query.supplier && {
                    "-and": [
                        {
                            "me.name": {
                                like: `%${baseResource.route.query.supplier}%`,
                            },
                        },
                        {
                            "aliases.alias": {
                                like: `%${baseResource.route.query.supplier}%`,
                            },
                        },
                    ],
                }),
            },
        };

        const checkContactOrInterface = array => {
            return array.reduce((acc, curr) => {
                const atLeastOneFieldFilled = Object.keys(curr).some(
                    key => curr[key]
                );
                if (atLeastOneFieldFilled) {
                    acc.push(curr);
                }
                return acc;
            }, []);
        };

        const onFormSave = (e, vendorToSave) => {
            e.preventDefault();
            const errors = [];
            const vendor = JSON.parse(JSON.stringify(vendorToSave));

            const vendorId = vendor.id;
            delete vendor.id;

            if (vendor.physical) {
                const addressLines = vendor.physical.split("\n");
                if (addressLines.length > 4) {
                    addressLines.length = 4;
                }
                addressLines.forEach((line, i) => {
                    vendor[`address${i + 1}`] = line;
                });
            }
            delete vendor.physical;
            delete vendor.subscriptions_count;
            delete vendor.baskets;
            delete vendor.baskets_count;
            delete vendor.subscriptions;
            delete vendor.contracts;
            delete vendor.invoices_count;
            delete vendor._strings;

            if (vendor.discount && !verifyDiscountValue(vendor.discount))
                errors.push($__("Invalid discount value"));

            vendor.contacts = checkContactOrInterface(
                vendor.contacts.map(
                    ({ id, booksellerid, ...requiredProperties }) =>
                        requiredProperties
                )
            );
            vendor.interfaces = checkContactOrInterface(
                vendor.interfaces.map(
                    ({
                        vendor_interface_id,
                        vendor_id,
                        ...requiredProperties
                    }) => requiredProperties
                )
            );

            baseResource.setWarning(errors.join("<br>"));
            if (errors.length) return false;

            if (vendorId) {
                return baseResource.apiClient.update(vendor, vendorId).then(
                    vendor => {
                        baseResource.setMessage($__("Vendor updated"));
                        return vendor
                    },
                    error => {}
                );
            } else {
                return baseResource.apiClient.create(vendor).then(
                    vendor => {
                        baseResource.setMessage($__("Vendor created"));
                        return vendor
                    },
                    error => {}
                );
            }
        };

        const afterResourceFetch = (componentData, resource, caller) => {
            if (caller === "form") {
                let physical = "";
                resource.address1 && (physical += resource.address1 + "\n");
                resource.address2 && (physical += resource.address2 + "\n");
                resource.address3 && (physical += resource.address3 + "\n");
                resource.address4 && (physical += resource.address4 + "\n");
                componentData.resource.value.physical = physical;

                if (!componentData.resource.value.discount)
                    componentData.resource.value.discount = 0.0;
                const decimalPlaces =
                    componentData.resource.value.discount
                        .toString()
                        .split(".")[1]?.length || 0;
                if (!decimalPlaces) {
                    componentData.resource.value.discount =
                        componentData.resource.value.discount.toFixed(1);
                }
            }
            if (caller === "show") {
                let physicalAddress = "";
                [1, 2, 3, 4].forEach(i => {
                    if (resource[`address${i}`]) {
                        physicalAddress += `${resource[`address${i}`]}`;
                    }
                });
                resource.physical = physicalAddress;
            }
        };

        const appendToShow = componentData => {
            let formatDate = format_date;
            return [
                {
                    name: $__("Contacts"),
                    hidden: vendor => !!vendor.contacts?.length,
                    showElement: {
                        type: "table",
                        columnData: "contacts",
                        hidden: vendor => !!vendor.contacts?.length,
                        columns: [
                            {
                                name: $__("Name"),
                                value: "name",
                            },
                            {
                                name: $__("Position"),
                                value: "position",
                            },
                            {
                                name: $__("Phone"),
                                value: "phone",
                            },
                            {
                                name: $__("Alternative phone"),
                                value: "altphone",
                            },
                            {
                                name: $__("Fax"),
                                value: "fax",
                            },
                            {
                                name: $__("Email"),
                                value: "email",
                            },
                            {
                                name: $__("Notes"),
                                value: "notes",
                            },
                            {
                                name: $__("Primary acquisitions contact"),
                                value: "acqprimary",
                                format: handleContactOptions,
                            },
                            {
                                name: $__("Contact when ordering"),
                                value: "orderacquisition",
                                format: handleContactOptions,
                            },
                            {
                                name: $__("Contact about late orders"),
                                value: "claimacquisition",
                                format: handleContactOptions,
                            },
                            {
                                name: $__("Primary serials contact"),
                                value: "serialsprimary",
                                format: handleContactOptions,
                            },
                            {
                                name: $__("Contact about late issues"),
                                value: "claimissues",
                                format: handleContactOptions,
                            },
                        ],
                    },
                },
                {
                    type: "component",
                    name: $__("Contracts"),
                    hidden: vendor => vendor.contracts.length,
                    componentPath:
                        "@koha-vue/components/RelationshipTableDisplay.vue",
                    componentProps: {
                        tableOptions: {
                            type: "object",
                            value: {
                                columns: [
                                    {
                                        title: $__("Name"),
                                        data: "contractname",
                                        render: function (
                                            data,
                                            type,
                                            row,
                                            meta
                                        ) {
                                            return (
                                                `<a href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&booksellerid=${row.booksellerid}&contractnumber=${row.contractnumber}">` +
                                                escape_str(row.contractname) +
                                                "</a>"
                                            );
                                        },
                                    },
                                    {
                                        title: $__("Description"),
                                        data: "contractdescription",
                                    },
                                    {
                                        title: $__("Start date"),
                                        data: "contractstartdate",
                                        render: function (
                                            data,
                                            type,
                                            row,
                                            meta
                                        ) {
                                            return type == "sort"
                                                ? row.contractstartdate
                                                : formatDate(
                                                      row.contractstartdate
                                                  );
                                        },
                                    },
                                    {
                                        title: $__("End date"),
                                        data: "contractenddate",
                                        render: function (
                                            data,
                                            type,
                                            row,
                                            meta
                                        ) {
                                            return type == "sort"
                                                ? row.contractenddate
                                                : formatDate(
                                                      row.contractenddate
                                                  );
                                        },
                                    },
                                    ...(componentData.instancedResource.isUserPermitted(
                                        "CAN_user_acquisition_contracts_manage"
                                    )
                                        ? [
                                              {
                                                  title: $__("Actions"),
                                                  data: "contractnumber",
                                                  searchable: false,
                                                  orderable: false,
                                                  render: function (
                                                      data,
                                                      type,
                                                      row,
                                                      meta
                                                  ) {
                                                      return (
                                                          `<a class="btn btn-default btn-xs" href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&contractnumber=${row.contractnumber}&booksellerid=${row.booksellerid}"><i class="fa-solid fa-pencil" aria-hidden="true"></i>` +
                                                          " " +
                                                          $__("Edit") +
                                                          "</a>" +
                                                          `<a style="margin-left: 5px;" class="btn btn-default btn-xs" href="/cgi-bin/koha/admin/aqcontract.pl?op=delete_confirm&contractnumber=${row.contractnumber}&booksellerid=${row.booksellerid}"><i class="fa-solid fa-trash-can" aria-hidden="true"></i>` +
                                                          " " +
                                                          $__("Delete") +
                                                          "</a>"
                                                      );
                                                  },
                                              },
                                          ]
                                        : []),
                                ],
                                dom: '<<"table_entries">>',
                                data: componentData.resource.contracts,
                            },
                        },
                        resource: {
                            type: "resource",
                        },
                        resourceName: {
                            type: "string",
                            value: $__("contract"),
                        },
                        resourceNamePlural: {
                            type: "string",
                            value: $__("contracts"),
                        },
                    },
                    splitPane: null,
                },
                {
                    type: "component",
                    name: $__("Subscription details"),
                    componentPath:
                        "@koha-vue/components/Vendors/VendorSubscriptions.vue",
                    componentProps: {
                        vendor: {
                            type: "resource",
                        },
                    },
                    splitPane: "right",
                },
            ];
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
            afterResourceFetch,
            currencies,
            appendToShow,
        };
    },
    name: "VendorResource",
    emits: ["select-resource"],
    components: {
        BaseResource,
    },
};
</script>
