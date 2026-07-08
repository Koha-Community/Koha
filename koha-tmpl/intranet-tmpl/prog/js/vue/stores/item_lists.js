import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";

export const useItemListsStore = defineStore("item_lists", () => {
    const store = reactive({
        config: {},
    });

    return {
        ...toRefs(store),
    };
});
