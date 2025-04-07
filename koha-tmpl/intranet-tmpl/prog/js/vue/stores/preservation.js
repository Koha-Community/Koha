import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";
import { withAuthorisedValueActions } from "../composables/authorisedValues";

export const usePreservationStore = defineStore("preservation", () => {
    const store = reactive({
        config: {
            settings: {
                enabled: 0,
                not_for_loan_waiting_list_in: null,
                not_for_loan_default_train_in: 0,
            },
        },
        authorisedValues: {
            av_notforloan: "NOT_LOAN",
        },
    });

    const sharedActions = withAuthorisedValueActions(store);

    return {
        ...toRefs(store),
        ...sharedActions,
    };
});
