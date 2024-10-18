import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";
import { withAuthorisedValueActions } from "../composables/authorisedValues";
import { permissionsActions } from "../composables/permissions";

export const useVendorStore = defineStore("vendors", () => {
    const store = reactive({
        vendors: [],
        currencies: [],
        gstValues: [],
        config: {
            settings: {
                edifact: false,
                marcOrderAutomation: false,
            },
        },
        authorisedValues: {
            av_vendor_types: "VENDOR_TYPE",
            av_vendor_interface_types: "VENDOR_INTERFACE_TYPE",
            av_vendor_payment_methods: "VENDOR_PAYMENT_METHOD",
        },
        userPermissions: null,
    });
    const sharedActions = {
        ...withAuthorisedValueActions(store),
        ...permissionsActions(store),
    };

    return {
        ...toRefs(store),
        ...sharedActions,
    };
});
