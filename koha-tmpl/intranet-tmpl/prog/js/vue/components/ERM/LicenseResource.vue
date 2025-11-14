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
    setup(props) {
        const format_date = $date;
        const patron_to_html = $patron_to_html;

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        const extendedAttributesResourceType = "license";

        const baseResource = useBaseResource({
            resourceName: "license",
            nameAttr: "name",
            idAttr: "license_id",
            components: {
                show: "LicensesShow",
                list: "LicensesList",
                add: "LicensesFormAdd",
                edit: "LicensesFormAddEdit",
            },
            apiClient: APIClient.erm.licenses,
            table: {
                resourceTableUrl:
                    APIClient.erm.httpClient._baseURL + "licenses",
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this license?"
                ),
                deleteSuccessMessage: $__("License %s deleted"),
                displayName: $__("License"),
                editLabel: $__("Edit license #%s"),
                emptyListMessage: $__("There are no licenses defined"),
                newLabel: $__("New license"),
            },
            extendedAttributesResourceType,
            vendors,
            props,
            moduleStore: "ERMStore",
            resourceAttrs: [
                {
                    name: "license_id",
                    label: $__("ID"),
                    type: "text",
                    hideIn: ["Form", "Show"],
                },
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: $__("License name"),
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
                    required: true,
                },
                {
                    name: "type",
                    required: true,
                    type: "select",
                    label: $__("Type"),
                    avCat: "av_license_types",
                },
                {
                    name: "status",
                    required: true,
                    type: "select",
                    label: $__("Status"),
                    avCat: "av_license_statuses",
                },
                {
                    name: "started_on",
                    type: "date",
                    label: $__("Start date"),
                    showElement: {
                        type: "text",
                        value: "started_on",
                        format: format_date,
                    },
                    componentProps: {
                        date_to: {
                            type: "string",
                            value: "ended_on",
                        },
                    },
                },
                {
                    name: "ended_on",
                    type: "date",
                    label: $__("End date"),
                    showElement: {
                        type: "text",
                        value: "ended_on",
                        format: format_date,
                    },
                },
                {
                    name: "user_roles",
                    type: "relationshipWidget",
                    group: $__("Users"),
                    showElement: {
                        type: "table",
                        columnData: "user_roles",
                        hidden: license => !!license.user_roles?.length,
                        label: $__("License users"),
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
                            nameUpperCase: $__("License user"),
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
                    name: "documents",
                    type: "relationshipWidget",
                    group: $__("Documents"),
                    showElement: {
                        type: "component",
                        hidden: license => !!license.documents?.length,
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
        });
        const tableURL = () => {
            let url = baseResource.getResourceTableUrl();

            const vendorId = baseResource.route.query.vendor_id;
            if (vendorId) {
                url += "?vendor_id=" + vendorId;
            }
            return url;
        };

        const tableOptions = {
            url: tableURL(),
            options: { embed: "vendor,extended_attributes,+strings" },
            table_settings: license_table_settings,
            add_filters: true,
            filters_options: {
                2: [
                    ...vendors.value.map(e => {
                        e["_id"] = e["id"];
                        e["_str"] = e["name"];
                        return e;
                    }),
                ],
                4: () => baseResource.map_av_dt_filter("av_license_types"),
                5: () => baseResource.map_av_dt_filter("av_license_statuses"),
            },
            actions: {
                "-1": ["edit", "delete"],
            },
        };

        const checkForm = license => {
            let errors = [];

            let documents_with_uploaded_files = license.documents.filter(
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
            license.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        $__("License user %s is missing a user").format(i + 1)
                    );
                }
            });
            baseResource.setWarning(errors.join("<br>"));
            return !errors.length;
        };
        const onFormSave = (e, licenseToSave) => {
            e.preventDefault();

            let license = JSON.parse(JSON.stringify(licenseToSave)); // copy
            let license_id = license.license_id;

            if (!checkForm(license)) {
                return false;
            }

            delete license.license_id;
            delete license.vendor;
            delete license._strings;

            if (license.vendor_id == "") {
                license.vendor_id = null;
            }

            license.user_roles = license.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            );

            license.documents = license.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            );

            if (license_id) {
                baseResource.apiClient.update(license, license_id).then(
                    success => {
                        baseResource.setMessage($__("License updated"));
                        baseResource.router.push({ name: "LicensesList" });
                    },
                    error => {}
                );
            } else {
                baseResource.apiClient.create(license).then(
                    success => {
                        baseResource.setMessage($__("License created"));
                        baseResource.router.push({ name: "LicensesList" });
                    },
                    error => {}
                );
            }
        };

        return {
            ...baseResource,
            tableOptions,
            checkForm,
            onFormSave,
        };
    },
    name: "LicenseResource",
    emits: ["select-resource"],
    components: {
        BaseResource,
    },
};
</script>
