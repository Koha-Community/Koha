import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";

export const useVendorStore = defineStore("vendors", () => {
    const store = reactive({
        vendors: [],
    });

    return {
        ...toRefs(store),
    };
});
