import { defineStore } from "pinia";

export const useAVStore = defineStore("authorised_values", {
    state: () => ({
        av_agreement_statuses: [],
        av_agreement_closure_reasons: [],
        av_agreement_renewal_priorities: [],
        av_agreement_user_roles: [],
        av_license_types: [],
        av_license_statuses: [],
        av_agreement_license_statuses: [],
        av_agreement_license_location: [],
        av_agreement_relationships: [
            { authorised_value: "supersedes", lib: "supersedes" },
            { authorised_value: "is-superseded-by", lib: "is superseded by" },
            {
                authorised_value: "provides_post-cancellation_access_for",
                lib: "provides_post-cancellation_access_for",
            },
            {
                authorised_value: "has-post-cancellation-access-in",
                lib: "has-post-cancellation-access-in",
            },
            {
                authorised_value: "tracks_demand-driven_acquisitions_for",
                lib: "tracks_demand-driven_acquisitions_for",
            },
            {
                authorised_value: "has-demand-driven-acquisitions-in",
                lib: "has-demand-driven-acquisitions-in",
            },
            { authorised_value: "has_backfile_in", lib: "has_backfile_in" },
            { authorised_value: "has_frontfile_in", lib: "has_frontfile_in" },
            { authorised_value: "related_to", lib: "related_to" },
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
