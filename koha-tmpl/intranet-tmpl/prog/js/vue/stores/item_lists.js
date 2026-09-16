import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";
import { withAuthorisedValueActions } from "../composables/authorisedValues";

export const useItemListsStore = defineStore("item_lists", () => {
    const store = reactive({
        config: {},
        authorisedValues: {
            av_collection_codes: "CCODE",
            av_locations: "LOC",
        },
        itemTypes: [],
    });
    const sharedActions = withAuthorisedValueActions(store);

    return {
        ...toRefs(store),
        ...sharedActions,
    };
});
