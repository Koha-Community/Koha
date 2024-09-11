import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";

export const useVendorStore = defineStore("vendors", () => {
    const store = reactive({
        vendors: [],
        currencies: [],
        gstValues: [],
        config: {
            settings: {
                edifact: false,
            },
        },
    });

    return {
        ...toRefs(store),
    };
});
