<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
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

        return {
            ...BaseResource.setup({
                resource_name: "agreement",
                name_attr: "name",
                id_attr: "agreement_id",
                show_component: "AgreementsShow",
                list_component: "AgreementsList",
                add_component: "AgreementsFormAdd",
                edit_component: "AgreementsFormAddEdit",
                api_client: APIClient.erm.agreements,
                resource_table_url: APIClient.erm._baseURL + "agreements",
                i18n: {
                    display_name: __("Agreement"),
                },
                av_agreement_statuses,
                av_agreement_closure_reasons,
                av_agreement_renewal_priorities,
                av_user_roles,
                av_agreement_license_statuses,
                av_agreement_license_location,
                av_agreement_relationships,
            }),
        };
    },
    data() {
        return {
            resource_attrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Agreement name"),
                    show_in_table: true,
                },
                {
                    name: "vendor_id",
                    type: "component",
                    component: "FormSelectVendors",
                    label: __("Vendor"),
                    show_in_table: true,
                },
                {
                    name: "description",
                    type: "textarea",
                    text_area_rows: 10,
                    text_area_cols: 50,
                    label: __("Description"),
                    show_in_table: true,
                },
                {
                    name: "status",
                    required: true,
                    type: "av",
                    label: __("Status"),
                    av_cat: "av_agreement_statuses",
                    show_in_table: true,
                },
                {
                    name: "closure_reason",
                    type: "av",
                    label: __("Closure reason"),
                    av_cat: "av_agreement_closure_reasons",
                    show_in_table: true,
                },
                {
                    name: "is_perpetual",
                    type: "boolean",
                    label: __("Is perpetual"),
                    show_in_table: true,
                },
                {
                    name: "renewal_priority",
                    type: "av",
                    label: __("Renewal priority"),
                    av_cat: "av_agreement_renewal_priorities",
                    show_in_table: true,
                },
                {
                    name: "license_info",
                    type: "textarea",
                    text_area_rows: 2,
                    text_area_cols: 50,
                    label: __("License info"),
                },
                // {
                //     name: "periods",
                //     type: "relationship",
                // },
                // {
                //     name: "user_roles",
                //     type: "relationship",
                // },
                // {
                //     name: "licenses",
                //     type: "relationship",
                // },
                // {
                //     name: "agreements",
                //     type: "relationship",
                // },
                // {
                //     name: "documents",
                //     type: "relationship",
                // },
            ],
        };
    },
    created() {
        //IMPROVEME: We need this for now to assign the correct av array from setup to the attr options in data
        this.resource_attrs.forEach(attr => {
            if (typeof attr.av_cat === "string") {
                const av_key = attr.av_cat;
                attr.options = this[av_key];
            }
        });
        this.getResourceTableColumns();
    },
    methods: {},
    name: "AgreementResource",
};
</script>
