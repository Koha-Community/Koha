<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="vendors_show">
        <Toolbar>
            <ToolbarButton
                :to="{ name: 'VendorFormAdd' }"
                icon="plus"
                :title="$__('New vendor')"
            />
            <ToolbarButton
                :to="{
                    name: 'VendorFormAddEdit',
                    params: { vendor_id: vendor.id },
                }"
                icon="pencil"
                :title="$__('Edit vendor')"
            />
            <ToolbarButton
                :to="{
                    path: '/cgi-bin/koha/acqui/parcels.pl',
                    query: { booksellerid: vendor.id },
                }"
                icon="plus"
                :title="$__('Receive shipments')"
            />
        </Toolbar>
        <h1>
            {{ vendor.name }}
        </h1>
        <div class="row">
            <div class="col-sm-6">
                <VendorDetails :vendor="vendor" :display="true" />
                <VendorOrderingInformation :vendor="vendor" :display="true" />
                <VendorInterfaces
                    :vendor="vendor"
                    v-if="vendor.interfaces.length > 0"
                    :display="true"
                />
            </div>
            <div class="col-sm-6">
                <VendorContacts :vendor="vendor" :display="true" />
                <VendorSubscriptions :vendor="vendor" />
            </div>
        </div>
        <div
            class="page-section rows"
            v-if="vendor.contracts && vendor.contracts.length > 0"
        >
            <VendorContracts :vendor="vendor" />
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import ToolbarButton from "../ToolbarButton.vue";
import VendorDetails from "./VendorDetails.vue";
import VendorOrderingInformation from "./VendorOrderingInformation.vue";
import VendorInterfaces from "./VendorInterfaces.vue";
import VendorContacts from "./VendorContacts.vue";
import VendorSubscriptions from "./VendorSubscriptions.vue";
import VendorContracts from "./VendorContracts.vue";

export default {
    setup() {
        const format_date = $date;
        const patron_to_html = $patron_to_html;

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        return {
            format_date,
            patron_to_html,
            setConfirmationDialog,
            setMessage,
        };
    },
    data() {
        return {
            vendor: null,
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getVendor(to.params.vendor_id);
        });
    },
    methods: {
        async getVendor(vendor_id) {
            const client = APIClient.acquisition;
            client.vendors.get(vendor_id).then(
                vendor => {
                    this.vendor = vendor;
                    this.initialized = true;
                },
                error => {}
            );
        },
    },
    components: {
        Toolbar,
        ToolbarButton,
        ToolbarButton,
        VendorDetails,
        VendorOrderingInformation,
        VendorInterfaces,
        VendorContacts,
        VendorSubscriptions,
        VendorContracts,
    },
    name: "VendorShow",
};
</script>

<style>
.vendor_info {
    display: grid;
}
</style>
