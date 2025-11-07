import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";
import { withAuthorisedValueActions } from "../composables/authorisedValues";

export const useSIP2Store = defineStore("sip2", () => {
    const store = reactive({
        sysprefs: {
            UseCashRegisters: 0,
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
