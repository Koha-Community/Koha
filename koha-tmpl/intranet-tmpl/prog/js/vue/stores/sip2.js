import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";
import { withAuthorisedValueActions } from "../composables/authorisedValues";
import { $__ } from "@koha-vue/i18n";

export const useSIP2Store = defineStore("erm", () => {
    const store = reactive({
        config: {
            displayRestartSIPDialog: true,
        },
        authorisedValues: {
            av_lost: "LOST",
        },
    });
    const sharedActions = withAuthorisedValueActions(store);

    return {
        ...toRefs(store),
        ...sharedActions,
    };
});
