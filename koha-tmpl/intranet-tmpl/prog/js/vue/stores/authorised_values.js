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
            { authorised_value: "supersedes", lib: __("supersedes") },
            { authorised_value: "is-superseded-by", lib: __("is superseded by") },
            {
                authorised_value: "provides_post-cancellation_access_for",
                lib: __("provides post-cancellation access for"),
            },
            {
                authorised_value: "has-post-cancellation-access-in",
                lib: __("has post-cancellation access in"),
            },
            {
                authorised_value: "tracks_demand-driven_acquisitions_for",
                lib: __("tracks demand-driven acquisitions for"),
            },
            {
                authorised_value: "has-demand-driven-acquisitions-in",
                lib: __("has demand-driven acquisitions in"),
            },
            { authorised_value: "has_backfile_in", lib: __("has backfile in") },
            { authorised_value: "has_frontfile_in", lib: __("has frontfile in") },
            { authorised_value: "related_to", lib: __("related to") },
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
            let o = this[arr_name].find((e) => e.authorised_value == av);
            return o ? o.lib : av;
        },
        map_av_dt_filter(arr_name) {
            return this[arr_name].map((e) => {
                e["_id"] = e["authorised_value"];
                e["_str"] = e["lib"];
                return e;
            });
        },
    },
});
