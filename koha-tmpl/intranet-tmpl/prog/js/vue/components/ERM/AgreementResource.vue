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
        embedded: { type: Boolean, default: false },
        embedEvent: Function,
    },

    setup(props) {
        const format_date = $date;
        const patron_to_html = $patron_to_html;

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        const extendedAttributesResourceType = "agreement";
        const additionalFilters = [
            {
                name: "by_expired",
                type: "checkbox",
                label: $__("Filter by expired"),
                value: false,
                onChange: function (filters) {
                    if (filters.by_expired) {
                        filters.max_expiration_date = new Date()
                            .toISOString()
                            .substring(0, 10);
                    } else {
                        filters.max_expiration_date = "";
                    }
                    return filters;
                },
            },
            {
                name: "max_expiration_date",
                type: "date",
                label: $__("on"),
                componentProps: {
                    disabled: {
                        resourceProperty: "by_expired",
                        qualifier: "!",
                    },
                },
                value: "",
            },
            {
                name: "by_mine",
                type: "checkbox",
                label: $__("Show mine only"),
                value: false,
            },
        ];

        const baseResource = useBaseResource({
            resourceName: "agreement",
            nameAttr: "name",
            idAttr: "agreement_id",
            components: {
                show: "AgreementsShow",
                list: "AgreementsList",
                add: "AgreementsFormAdd",
                edit: "AgreementsFormAddEdit",
            },
            apiClient: APIClient.erm.agreements,
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this agreement?"
                ),
                deleteSuccessMessage: $__("Agreement %s deleted"),
                displayName: $__("Agreement"),
                editLabel: $__("Edit agreement #%s"),
                emptyListMessage: $__("There are no agreements defined"),
                newLabel: $__("New agreement"),
            },
            table: {
                addAdditionalFilters: true,
                resourceTableUrl:
                    APIClient.erm.httpClient._baseURL + "agreements",
                additionalFilters,
            },
            embedded: props.embedded,
            extendedAttributesResourceType,
            resourceAttrs: [
                {
                    name: "agreement_id",
                    label: $__("ID"),
                    type: "text",
                    hideIn: ["Form", "Show"],
                },
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: $__("Agreement name"),
                },
                {
                    name: "vendor_id",
                    type: "vendor",
                    label: $__("Vendor"),
                    showElement: {
                        type: "text",
                        value: "vendor.name",
                        link: {
                            href: "/cgi-bin/koha/acquisition/vendors",
                            slug: "vendor_id",
                        },
                    },
                },
                {
                    name: "description",
                    type: "textarea",
                    label: $__("Description"),
                },
                {
                    name: "status",
                    required: true,
                    type: "select",
                    label: $__("Status"),
                    avCat: "av_agreement_statuses",
                    onSelected: resource => {
                        if (resource.status !== "closed") {
                            resource.closure_reason = null;
                        }
                        return resource;
                    },
                },
                {
                    name: "closure_reason",
                    type: "select",
                    label: $__("Closure reason"),
                    avCat: "av_agreement_closure_reasons",
                    disabled: agreement => agreement.status !== "closed",
                },
                {
                    name: "is_perpetual",
                    type: "boolean",
                    label: $__("Is perpetual"),
                },
                {
                    name: "renewal_priority",
                    type: "select",
                    label: $__("Renewal priority"),
                    avCat: "av_agreement_renewal_priorities",
                },
                {
                    name: "license_info",
                    type: "textarea",
                    textAreaRows: 2,
                    label: $__("License info"),
                    hideIn: ["List"],
                },
                {
                    name: "periods",
                    type: "relationshipWidget",
                    showElement: {
                        type: "table",
                        columnData: "periods",
                        hidden: agreement => !!agreement.periods?.length,
                        columns: [
                            {
                                name: $__("Period start"),
                                value: "started_on",
                                format: format_date,
                            },
                            {
                                name: $__("Period end"),
                                value: "ended_on",
                                format: format_date,
                            },
                            {
                                name: $__("Cancellation deadline"),
                                value: "cancellation_deadline",
                                format: format_date,
                            },
                            {
                                name: $__("Notes"),
                                value: "notes",
                            },
                        ],
                    },
                    group: $__("Periods"),
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "periods",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Period"),
                            removeThisMessage: $__("Remove this period"),
                            addNewMessage: $__("Add new period"),
                            noneCreatedYetMessage: $__(
                                "There are no periods created yet"
                            ),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                started_on: null,
                                ended_on: null,
                                cancellation_deadline: null,
                                notes: null,
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "started_on",
                            type: "date",
                            label: $__("Start date"),
                            required: true,
                            indexRequired: true,
                            componentProps: {
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                                date_to: {
                                    type: "string",
                                    value: "periods_ended_on",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "ended_on",
                            type: "date",
                            label: $__("End date"),
                            required: false,
                            indexRequired: true,
                        },
                        {
                            name: "cancellation_deadline",
                            type: "date",
                            label: $__("Cancellation deadline"),
                            required: false,
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: $__("Notes"),
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
                {
                    name: "user_roles",
                    type: "relationshipWidget",
                    group: $__("Users"),
                    showElement: {
                        type: "table",
                        columnData: "user_roles",
                        hidden: agreement => !!agreement.user_roles?.length,
                        columns: [
                            {
                                name: $__("Name"),
                                value: "patron",
                                format: patron_to_html,
                            },
                            {
                                name: $__("Role"),
                                value: "role",
                                av: "av_user_roles",
                            },
                        ],
                    },
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "user_roles",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Agreement user"),
                            removeThisMessage: $__("Remove this user"),
                            addNewMessage: $__("Add new user"),
                            noneCreatedYetMessage: $__(
                                "There are no users created yet"
                            ),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                user_id: null,
                                role: null,
                                patron_str: "",
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "user_id",
                            type: "component",
                            label: $__("User"),
                            componentPath:
                                "@koha-vue/components/PatronSearch.vue",
                            required: true,
                            indexRequired: true,
                            componentProps: {
                                name: {
                                    type: "string",
                                    value: "user_id",
                                },
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                                resource: {
                                    type: "resource",
                                    value: null,
                                },
                                label: {
                                    type: "string",
                                    value: $__("User"),
                                },
                            },
                        },
                        {
                            name: "role",
                            type: "select",
                            label: $__("Role"),
                            avCat: "av_user_roles",
                            required: true,
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
                {
                    name: "agreement_licenses",
                    type: "relationshipWidget",
                    group: $__("Licenses"),
                    showElement: {
                        type: "table",
                        columnData: "agreement_licenses",
                        hidden: agreement =>
                            !!agreement.agreement_licenses?.length,
                        columns: [
                            {
                                name: $__("Name"),
                                value: "license.name",
                                link: {
                                    name: "LicensesShow",
                                    params: {
                                        license_id: "license_id",
                                    },
                                },
                            },
                            {
                                name: $__("Status"),
                                value: "status",
                                av: "av_agreement_license_statuses",
                            },
                            {
                                name: $__("Physical location"),
                                value: "physical_location",
                                av: "av_agreement_license_location",
                            },
                            {
                                name: $__("Notes"),
                                value: "notes",
                            },
                            {
                                name: $__("URI"),
                                value: "uri",
                            },
                        ],
                    },
                    apiClient: APIClient.erm.licenses,
                    componentProps: {
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                license_id: null,
                                status: null,
                                physical_location: null,
                                notes: "",
                                uri: "",
                                license: { name: "" },
                            },
                        },
                        resourceRelationships: {
                            resourceProperty: "agreement_licenses",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("License"),
                            removeThisMessage: $__("Remove this license"),
                            addNewMessage: $__("Add new license"),
                            noneCreatedYetMessage: $__(
                                "There are no licenses created yet"
                            ),
                        },
                    },
                    relationshipFields: [
                        {
                            name: "license_id",
                            type: "component",
                            label: $__("License"),
                            componentPath:
                                "@koha-vue/components/InfiniteScrollSelect.vue",
                            required: true,
                            indexRequired: true,
                            componentProps: {
                                id: {
                                    type: "string",
                                    value: "agreement_licenses_license_id",
                                    indexRequired: true,
                                },
                                selectedData: {
                                    resourceProperty: "license",
                                },
                                dataType: {
                                    type: "string",
                                    value: "licenses",
                                },
                                dataIdentifier: {
                                    type: "string",
                                    value: "license_id",
                                },
                                label: {
                                    type: "string",
                                    value: "name",
                                },
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                            },
                        },
                        {
                            name: "status",
                            type: "select",
                            label: $__("Status"),
                            avCat: "av_agreement_license_statuses",
                            indexRequired: true,
                        },
                        {
                            name: "physical_location",
                            type: "select",
                            label: $__("Physical location"),
                            avCat: "av_agreement_license_location",
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: $__("Notes"),
                            indexRequired: true,
                        },
                        {
                            name: "uri",
                            required: false,
                            type: "text",
                            label: $__("URI"),
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
                {
                    name: "agreement_relationships",
                    type: "relationshipWidget",
                    group: $__("Related agreements"),
                    showElement: {
                        type: "component",
                        hidden: agreement =>
                            !!agreement.agreement_relationships?.length,
                        componentPath:
                            "@koha-vue/components/ERM/AgreementRelationshipsDisplay.vue",
                        componentProps: {
                            agreement: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    apiClient: APIClient.erm.agreements,
                    componentProps: {
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                related_agreement_id: null,
                                relationship: null,
                                notes: "",
                            },
                        },
                        resourceRelationships: {
                            resourceProperty: "agreement_relationships",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Related agreement"),
                            removeThisMessage: $__(
                                "Remove this related agreement"
                            ),
                            addNewMessage: $__("Add new related agreement"),
                            noneCreatedYetMessage: $__(
                                "There are no related agreements created yet"
                            ),
                        },
                        filters: {
                            type: "filter",
                            keys: {
                                "me.agreement_id": {
                                    property: "agreement_id",
                                    filterType: "!=",
                                },
                            },
                        },
                        fetchOptions: {
                            type: "boolean",
                            value: true,
                        },
                    },
                    relationshipFields: [
                        {
                            name: "related_agreement_id",
                            type: "select",
                            label: $__("Related agreement"),
                            requiredKey: "agreement_id",
                            selectLabel: "name",
                            required: true,
                            indexRequired: true,
                        },
                        {
                            name: "relationship",
                            type: "select",
                            label: $__("Relationship"),
                            avCat: "av_agreement_relationships",
                            required: true,
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: $__("Notes"),
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
                {
                    name: "agreement_packages",
                    type: "component",
                    componentPath: null,
                    showElement: {
                        type: "component",
                        hidden: agreement =>
                            !!agreement.agreement_packages?.length,
                        componentPath:
                            "@koha-vue/components/ERM/AgreementPackagesDisplay.vue",
                        componentProps: {
                            agreement: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    hideIn: ["List", "Form"],
                },
                {
                    name: "documents",
                    type: "relationshipWidget",
                    group: $__("Documents"),
                    showElement: {
                        type: "component",
                        label: $__("Agreement users"),
                        hidden: agreement => !!agreement.documents?.length,
                        componentPath:
                            "@koha-vue/components/DocumentDisplay.vue",
                        componentProps: {
                            resource: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "documents",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Document"),
                            removeThisMessage: $__("Remove this document"),
                            addNewMessage: $__("Add new document"),
                            noneCreatedYetMessage: $__(
                                "There are no documents created yet"
                            ),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                file_name: null,
                                file_type: null,
                                file_description: null,
                                file_content: null,
                                physical_location: null,
                                uri: null,
                                notes: null,
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "document",
                            type: "component",
                            componentPath:
                                "@koha-vue/components/DocumentSelect.vue",
                            label: $__("File"),
                            componentProps: {
                                counter: {
                                    type: "string",
                                    value: "",
                                    indexRequired: true,
                                },
                                document: {
                                    type: "resource",
                                    value: null,
                                },
                            },
                        },
                        {
                            name: "physical_location",
                            required: false,
                            type: "text",
                            label: $__("Physical location"),
                            indexRequired: true,
                        },
                        {
                            name: "uri",
                            required: false,
                            type: "text",
                            label: $__("URI"),
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: $__("Notes"),
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
            ],
            moduleStore: "ERMStore",
            vendors,
            props: props,
        });

        const defaults = baseResource.getFilterValues(
            baseResource.route.query,
            additionalFilters
        );

        const tableOptions = {
            options: {
                embed: "user_roles,vendor,extended_attributes,+strings",
            },
            url: () => tableUrl(defaults),
            table_settings: agreement_table_settings,
            add_filters: true,
            filters_options: {
                2: [
                    ...vendors.value.map(e => {
                        e["_id"] = e["id"];
                        e["_str"] = e["name"];
                        return e;
                    }),
                ],
                4: () => baseResource.map_av_dt_filter("av_agreement_statuses"),
                5: () =>
                    baseResource.map_av_dt_filter(
                        "av_agreement_closure_reasons"
                    ),
                6: [
                    { _id: 0, _str: $__("No") },
                    { _id: 1, _str: $__("Yes") },
                ],
                7: () =>
                    baseResource.map_av_dt_filter(
                        "av_agreement_renewal_priorities"
                    ),
            },
            actions: {
                "-1": baseResource.embedded
                    ? [
                          {
                              select: {
                                  text: $__("Select"),
                                  icon: "fa fa-check",
                                  callback: props.embedEvent,
                              },
                          },
                      ]
                    : ["edit", "delete"],
            },
            default_filters: {
                "user_roles.user_id": function () {
                    return defaults.by_mine
                        ? logged_in_user.borrowernumber
                        : "";
                },
            },
        };

        const checkForm = agreement => {
            let errors = [];

            let agreement_licenses = agreement.agreement_licenses;
            // Do not use al.license.name here! Its name is not the one linked with al.license_id
            // At this point al.license is meaningless, form/template only modified al.license_id
            const license_ids = agreement_licenses.map(al => al.license_id);
            const duplicate_license_ids = license_ids.filter(
                (id, i) => license_ids.indexOf(id) !== i
            );

            if (duplicate_license_ids.length) {
                errors.push($__("A license is used several times"));
            }

            const related_agreement_ids = agreement.agreement_relationships.map(
                rs => rs.related_agreement_id
            );
            const duplicate_related_agreement_ids =
                related_agreement_ids.filter(
                    (id, i) => related_agreement_ids.indexOf(id) !== i
                );

            if (duplicate_related_agreement_ids.length) {
                errors.push(
                    $__("An agreement is used as relationship several times")
                );
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push($__("Only one controlling license is allowed"));
            }

            let documents_with_uploaded_files = agreement.documents.filter(
                doc => typeof doc.file_content !== "undefined"
            );
            if (
                documents_with_uploaded_files.filter(
                    doc => atob(doc.file_content).length >= max_allowed_packet
                ).length >= 1
            ) {
                errors.push(
                    $__("File size exceeds maximum allowed: %s MB").format(
                        (max_allowed_packet / (1024 * 1024)).toFixed(2)
                    )
                );
            }
            agreement.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        $__("Agreement user %s is missing a user").format(i + 1)
                    );
                }
            });
            baseResource.setWarning(errors.join("<br>"));
            return !errors.length;
        };
        const onFormSave = (e, agreementToSave) => {
            e.preventDefault();

            let agreement = JSON.parse(JSON.stringify(agreementToSave)); // copy
            let agreement_id = agreement.agreement_id;

            if (!checkForm(agreement)) {
                return false;
            }

            delete agreement.agreement_id;
            delete agreement.vendor;
            delete agreement._strings;
            agreement.is_perpetual = agreement.is_perpetual ? true : false;

            if (agreement.vendor_id == "") {
                agreement.vendor_id = null;
            }

            agreement.periods = agreement.periods.map(
                ({ agreement_id, agreement_period_id, ...keepAttrs }) =>
                    keepAttrs
            );

            agreement.user_roles = agreement.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            );

            agreement.agreement_licenses = agreement.agreement_licenses.map(
                ({
                    license,
                    agreement_id,
                    agreement_license_id,
                    ...keepAttrs
                }) => keepAttrs
            );

            agreement.agreement_relationships =
                agreement.agreement_relationships.map(
                    ({ related_agreement, ...keepAttrs }) => keepAttrs
                );

            agreement.documents = agreement.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            );

            delete agreement.agreement_packages;

            if (agreement_id) {
                baseResource.apiClient.update(agreement, agreement_id).then(
                    success => {
                        baseResource.setMessage($__("Agreement updated"));
                        baseResource.router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            } else {
                baseResource.apiClient.create(agreement).then(
                    success => {
                        baseResource.setMessage($__("Agreement created"));
                        baseResource.router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            }
        };
        const tableUrl = filters => {
            let url = baseResource.getResourceTableUrl();
            if (filters?.by_expired)
                url += "?max_expiration_date=" + filters.max_expiration_date;
            const vendorId = baseResource.route.query.vendor_id;
            if (vendorId) {
                url = filters?.by_expired
                    ? url + "&vendor_id=" + vendorId
                    : url + "?vendor_id=" + vendorId;
            }
            return url;
        };
        const filterTable = async (filters, table, embedded = false) => {
            if (!embedded) {
                if (filters.by_expired && !filters.max_expiration_date) {
                    filters.max_expiration_date = new Date()
                        .toISOString()
                        .substring(0, 10);
                }
                if (!filters.by_expired) {
                    filters.max_expiration_date = "";
                }
                let { href } = baseResource.router.resolve({
                    name: "AgreementsList",
                });
                let new_route = baseResource.build_url(href, filters);
                window.history.pushState({}, "", new_route);
            }
            table.redraw(tableUrl(filters));
        };

        return {
            ...baseResource,
            tableOptions,
            checkForm,
            onFormSave,
            tableUrl,
            filterTable,
        };
    },
    emits: ["select-resource"],
    name: "AgreementResource",
    components: {
        BaseResource,
    },
};
</script>
