import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";
import { withAuthorisedValueActions } from "../composables/authorisedValues";

export const useERMStore = defineStore("erm", () => {
    const store = reactive({
        config: {
            settings: {
                ERMModule: false,
                ERMProviders: [],
            },
        },
        authorisedValues: {
            av_agreement_statuses: "ERM_AGREEMENT_STATUS",
            av_agreement_closure_reasons: "ERM_AGREEMENT_CLOSURE_REASON",
            av_agreement_renewal_priorities: "ERM_AGREEMENT_RENEWAL_PRIORITY",
            av_user_roles: "ERM_USER_ROLES",
            av_license_types: "ERM_LICENSE_TYPE",
            av_license_statuses: "ERM_LICENSE_STATUS",
            av_agreement_license_statuses: "ERM_AGREEMENT_LICENSE_STATUS",
            av_agreement_license_location: "ERM_AGREEMENT_LICENSE_LOCATION",
            av_package_types: "ERM_PACKAGE_TYPE",
            av_package_content_types: "ERM_PACKAGE_CONTENT_TYPE",
            av_title_publication_types: "ERM_TITLE_PUBLICATION_TYPE",
            av_report_types: "ERM_REPORT_TYPES",
            av_platform_reports_metrics: "ERM_PLATFORM_REPORTS_METRICS",
            av_database_reports_metrics: "ERM_DATABASE_REPORTS_METRICS",
            av_title_reports_metrics: "ERM_TITLE_REPORTS_METRICS",
            av_item_reports_metrics: "ERM_ITEM_REPORTS_METRICS",
            av_agreement_relationships: [
                { value: "supersedes", description: __("supersedes") },
                {
                    value: "is-superseded-by",
                    description: __("is superseded by"),
                },
                {
                    value: "provides_post-cancellation_access_for",
                    description: __("provides post-cancellation access for"),
                },
                {
                    value: "has-post-cancellation-access-in",
                    description: __("has post-cancellation access in"),
                },
                {
                    value: "tracks_demand-driven_acquisitions_for",
                    description: __("tracks demand-driven acquisitions for"),
                },
                {
                    value: "has-demand-driven-acquisitions-in",
                    description: __("has demand-driven acquisitions in"),
                },
                {
                    value: "has_backfile_in",
                    description: __("has backfile in"),
                },
                {
                    value: "has_frontfile_in",
                    description: __("has frontfile in"),
                },
                { value: "related_to", description: __("related to") },
            ],
        },
    });
    const sharedActions = withAuthorisedValueActions(store);

    return {
        ...toRefs(store),
        ...sharedActions,
    };
});
