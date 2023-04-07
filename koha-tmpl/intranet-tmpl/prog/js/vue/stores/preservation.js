import { defineStore } from "pinia";

export const usePreservationStore = defineStore("preservation", {
    state: () => ({
        settings: {
            not_for_loan_waiting_list_in: null,
            not_for_loan_default_train_in: 0,
        },
    }),
});
