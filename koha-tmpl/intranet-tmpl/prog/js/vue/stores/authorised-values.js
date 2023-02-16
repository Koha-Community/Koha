import { defineStore } from "pinia";

export const useAVStore = defineStore("authorised_values", {
    state: () => ({
        av_agreement_statuses: [],
        av_agreement_closure_reasons: [],
        av_agreement_renewal_priorities: [],
        av_user_roles: [],
        av_license_types: [],
        av_license_statuses: [],
        av_agreement_license_statuses: [],
        av_agreement_license_location: [],
        av_agreement_relationships: [
            { value: "supersedes", description: __("supersedes") },
            { value: "is-superseded-by", description: __("is superseded by") },
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
            { value: "has_backfile_in", description: __("has backfile in") },
            { value: "has_frontfile_in", description: __("has frontfile in") },
            { value: "related_to", description: __("related to") },
        ],
        av_package_types: [],
        av_package_content_types: [],
        av_title_publication_types: [],
    }),
    actions: {
        get_lib_from_av(arr_name, av) {
            if (this[arr_name] === undefined) {
                console.warn(
                    "The authorised value category for '%s' is not defined.".format(
                        arr_name
                    )
                );
                return;
            }
            let o = this[arr_name].find((e) => e.value == av);
            return o ? o.description : av;
        },
        map_av_dt_filter(arr_name) {
            return this[arr_name].map((e) => {
                e["_id"] = e["value"];
                e["_str"] = e["description"];
                return e;
            });
        },
    },
});
