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
    }),
    // FIXME We could move get_lib_from_av here
});
