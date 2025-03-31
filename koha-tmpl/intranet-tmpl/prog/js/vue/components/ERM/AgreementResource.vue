<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
        embedded: { type: Boolean, default: false },
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const {
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            av_agreement_relationships,
        } = storeToRefs(AVStore);

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        return {
            ...BaseResource.setup({
                resourceName: "agreement",
                nameAttr: "name",
                idAttr: "agreement_id",
                showComponent: "AgreementsShow",
                listComponent: "AgreementsList",
                addComponent: "AgreementsFormAdd",
                editComponent: "AgreementsFormAddEdit",
                apiClient: APIClient.erm.agreements,
                resourceTableUrl: APIClient.erm._baseURL + "agreements",
                i18n: {
                    displayName: __("Agreement"),
                    displayNameLowerCase: __("agreement"),
                    displayNamePlural: __("agreements"),
                },
                embedded: props.embedded,
                extendedAttributesResourceType: "agreement",
                resourceListFiltersRequired: true,
                av_agreement_statuses,
                av_agreement_closure_reasons,
                av_agreement_renewal_priorities,
                av_user_roles,
                av_agreement_license_statuses,
                av_agreement_license_location,
                av_agreement_relationships,
                agreement_table_settings,
                vendors,
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilters();
        const defaults = this.getFilters(this.$route.query, tableFilters);

        return {
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Agreement name"),
                    showInTable: true,
                },
                {
                    name: "vendor_id",
                    type: "vendor",
                    label: __("Vendor"),
                    showInTable: true,
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
                    textAreaRows: 10,
                    textAreaCols: 50,
                    label: __("Description"),
                    showInTable: true,
                },
                {
                    name: "status",
                    required: true,
                    type: "select",
                    label: __("Status"),
                    showInTable: true,
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
                    label: __("Closure reason"),
                    showInTable: true,
                    avCat: "av_agreement_closure_reasons",
                    disabled: agreement => agreement.status !== "closed",
                },
                {
                    name: "is_perpetual",
                    type: "boolean",
                    label: __("Is perpetual"),
                    showInTable: true,
                },
                {
                    name: "renewal_priority",
                    type: "select",
                    label: __("Renewal priority"),
                    showInTable: true,
                    avCat: "av_agreement_renewal_priorities",
                },
                {
                    name: "license_info",
                    type: "textarea",
                    textAreaRows: 2,
                    textAreaCols: 50,
                    label: __("License info"),
                },
                {
                    name: "additional_fields",
                    extended_attributes_resource_type:
                        this.extendedAttributesResourceType,
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
                                name: __("Period start"),
                                value: "started_on",
                                format: this.format_date,
                            },
                            {
                                name: __("Period end"),
                                value: "ended_on",
                                format: this.format_date,
                            },
                            {
                                name: __("Cancellation deadline"),
                                value: "cancellation_deadline",
                                format: this.format_date,
                            },
                            {
                                name: __("Notes"),
                                value: "notes",
                            },
                        ],
                    },
                    group: __("Periods"),
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "periods",
                        },
                        relationshipStrings: {
                            nameLowerCase: __("period"),
                            nameUpperCase: __("Period"),
                            namePlural: __("periods"),
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
                            label: __("Start date"),
                            required: true,
                            indexRequired: true,
                            componentProps: {
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                                date_to: {
                                    type: "string",
                                    value: "ended_on",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "ended_on",
                            type: "date",
                            label: __("End date"),
                            required: false,
                            indexRequired: true,
                        },
                        {
                            name: "cancellation_deadline",
                            type: "date",
                            label: __("Cancellation deadline"),
                            required: false,
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                            indexRequired: true,
                        },
                    ],
                },
                {
                    name: "user_roles",
                    type: "relationshipWidget",
                    group: __("Users"),
                    showElement: {
                        type: "table",
                        columnData: "user_roles",
                        hidden: agreement => !!agreement.user_roles?.length,
                        columns: [
                            {
                                name: __("Name"),
                                value: "patron",
                                format: this.patron_to_html,
                            },
                            {
                                name: __("Role"),
                                value: "role",
                                av: "av_user_roles",
                            },
                        ],
                    },
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "user_roles",
                        },
                        relationshipStrings: {
                            nameLowerCase: __("user"),
                            nameUpperCase: __("Agreement user"),
                            namePlural: __("users"),
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
                            label: __("User"),
                            componentPath: "./PatronSearch.vue",
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
                                    value: __("User"),
                                },
                            },
                        },
                        {
                            name: "role",
                            type: "select",
                            label: __("Role"),
                            avCat: "av_user_roles",
                            required: true,
                            indexRequired: true,
                        },
                    ],
                },
                {
                    name: "agreement_licenses",
                    type: "relationshipWidget",
                    group: __("Licenses"),
                    showElement: {
                        type: "table",
                        columnData: "agreement_licenses",
                        hidden: agreement =>
                            !!agreement.agreement_licenses?.length,
                        columns: [
                            {
                                name: __("Name"),
                                value: "license.name",
                                link: {
                                    name: "LicensesShow",
                                    params: {
                                        license_id: "license_id",
                                    },
                                },
                            },
                            {
                                name: __("Status"),
                                value: "status",
                                av: "av_agreement_license_statuses",
                            },
                            {
                                name: __("Physical location"),
                                value: "physical_location",
                                av: "av_agreement_license_location",
                            },
                            {
                                name: __("Notes"),
                                value: "notes",
                            },
                            {
                                name: __("URI"),
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
                        relationshipStrings: {
                            nameLowerCase: __("license"),
                            nameUpperCase: __("License"),
                            namePlural: __("licenses"),
                        },
                    },
                    relationshipFields: [
                        {
                            name: "license_id",
                            type: "component",
                            label: __("License"),
                            componentPath: "./InfiniteScrollSelect.vue",
                            required: true,
                            indexRequired: true,
                            componentProps: {
                                id: {
                                    type: "string",
                                    value: "license_id_",
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
                            label: __("Status"),
                            avCat: "av_agreement_license_statuses",
                            indexRequired: true,
                        },
                        {
                            name: "physical_location",
                            type: "select",
                            label: __("Physical location"),
                            avCat: "av_agreement_license_location",
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                            indexRequired: true,
                        },
                        {
                            name: "uri",
                            required: false,
                            type: "text",
                            label: __("URI"),
                            indexRequired: true,
                        },
                    ],
                },
                {
                    name: "agreement_relationships",
                    type: "relationshipWidget",
                    group: __("Related agreements"),
                    showElement: {
                        type: "component",
                        hidden: agreement =>
                            !!agreement.agreement_relationships?.length,
                        componentPath:
                            "./ERM/AgreementRelationshipsDisplay.vue",
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
                        relationshipStrings: {
                            nameLowerCase: __("related agreement"),
                            nameUpperCase: __("Related agreement"),
                            namePlural: __("related agreements"),
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
                            label: __("Related agreement"),
                            requiredKey: "agreement_id",
                            selectLabel: "name",
                            required: true,
                            indexRequired: true,
                        },
                        {
                            name: "relationship",
                            type: "select",
                            label: __("Relationship"),
                            avCat: "av_agreement_relationships",
                            required: true,
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                            indexRequired: true,
                        },
                    ],
                },
                {
                    name: "agreement_packages",
                    type: "component",
                    componentPath: null,
                    showElement: {
                        type: "component",
                        hidden: agreement =>
                            !!agreement.agreement_packages?.length,
                        componentPath: "./ERM/AgreementPackagesDisplay.vue",
                        componentProps: {
                            agreement: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                },
                {
                    name: "documents",
                    type: "relationshipWidget",
                    group: __("Documents"),
                    showElement: {
                        type: "component",
                        label: __("Agreement users"),
                        hidden: agreement => !!agreement.documents?.length,
                        componentPath: "./DocumentDisplay.vue",
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
                        relationshipStrings: {
                            nameLowerCase: __("document"),
                            nameUpperCase: __("Document"),
                            namePlural: __("documents"),
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
                            componentPath: "./DocumentSelect.vue",
                            label: __("File"),
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
                            label: __("Physical location"),
                            indexRequired: true,
                        },
                        {
                            name: "uri",
                            required: false,
                            type: "text",
                            label: __("URI"),
                            indexRequired: true,
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                            indexRequired: true,
                        },
                    ],
                },
            ],
            tableOptions: {
                options: {
                    embed: "user_roles,vendor,extended_attributes,+strings",
                },
                url: () => this.tableUrl(defaults),
                table_settings: this.agreement_table_settings,
                add_filters: true,
                filters_options: {
                    2: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"];
                            e["_str"] = e["name"];
                            return e;
                        }),
                    4: () => this.map_av_dt_filter("av_agreement_statuses"),
                    5: () =>
                        this.map_av_dt_filter("av_agreement_closure_reasons"),
                    6: [
                        { _id: 0, _str: this.$__("No") },
                        { _id: 1, _str: this.$__("Yes") },
                    ],
                    7: () =>
                        this.map_av_dt_filter(
                            "av_agreement_renewal_priorities"
                        ),
                },
                actions: {
                    0: ["show"],
                    1: ["show"],
                    "-1": this.embedded
                        ? [
                              {
                                  select: {
                                      text: this.$__("Select"),
                                      icon: "fa fa-check",
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
            },
            tableFilters,
        };
    },
    methods: {
        checkForm(agreement) {
            let errors = [];

            let agreement_licenses = agreement.agreement_licenses;
            // Do not use al.license.name here! Its name is not the one linked with al.license_id
            // At this point al.license is meaningless, form/template only modified al.license_id
            const license_ids = agreement_licenses.map(al => al.license_id);
            const duplicate_license_ids = license_ids.filter(
                (id, i) => license_ids.indexOf(id) !== i
            );

            if (duplicate_license_ids.length) {
                errors.push(this.$__("A license is used several times"));
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
                    this.$__(
                        "An agreement is used as relationship several times"
                    )
                );
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push(
                    this.$__("Only one controlling license is allowed")
                );
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
                    this.$__("File size exceeds maximum allowed: %s MB").format(
                        (max_allowed_packet / (1024 * 1024)).toFixed(2)
                    )
                );
            }
            agreement.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        this.$__("Agreement user %s is missing a user").format(
                            i + 1
                        )
                    );
                }
            });
            this.setWarning(errors.join("<br>"));
            return !errors.length;
        },
        onSubmit(e, agreementToSave) {
            e.preventDefault();

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(agreementToSave)); // copy
            let agreement_id = agreement.agreement_id;

            if (!this.checkForm(agreement)) {
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
                this.apiClient.update(agreement, agreement_id).then(
                    success => {
                        this.setMessage(this.$__("Agreement updated"));
                        this.$router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            } else {
                this.apiClient.create(agreement).then(
                    success => {
                        this.setMessage(this.$__("Agreement created"));
                        this.$router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            }
        },
        getTableFilters() {
            return [
                {
                    name: "by_expired",
                    type: "checkbox",
                    label: __("Filter by expired"),
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
                    label: __("on"),
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
                    label: __("Show mine only"),
                    value: false,
                },
            ];
        },
        tableUrl(filters) {
            let url = this.getResourceTableUrl();
            if (filters?.by_expired)
                url += "?max_expiration_date=" + filters.max_expiration_date;
            return url;
        },
        async filterTable(filters, table, embedded = false) {
            if (!embedded) {
                if (filters.by_expired && !filters.max_expiration_date) {
                    filters.max_expiration_date = new Date()
                        .toISOString()
                        .substring(0, 10);
                }
                if (!filters.by_expired) {
                    filters.max_expiration_date = "";
                }
                let { href } = this.$router.resolve({ name: "AgreementsList" });
                let new_route = this.build_url(href, filters);
                this.$router.push(new_route);
            }
            table.redraw(this.tableUrl(filters));
        },
    },
    emits: ["select-resource"],
    name: "AgreementResource",
};
</script>
