<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="vendors_show">
        <Toolbar>
            <ButtonLink
                :to="{ name: 'VendorFormAdd' }"
                icon="plus"
                :title="$__('New vendor')"
            />
            <ButtonLink
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
                icon="inbox"
                :title="$__('Receive shipments')"
                callback="redirect"
            />
        </Toolbar>
        <h1>
            {{ vendor.name }}
        </h1>
        <template v-if="!basketView">
            <div class="row">
                <div class="col-sm-6">
                    <VendorDetails :vendor="vendor" :display="true" />
                    <VendorOrderingInformation
                        :vendor="vendor"
                        :display="true"
                    />
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
        </template>
        <template v-if="basketView">
            <h2>{{ $__("Baskets") }}</h2>
            <VendorBaskets :basketCount="basketCount" :vendorId="vendor.id" />
        </template>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import ToolbarButton from "../ToolbarButton.vue";
import VendorDetails from "./VendorDetails.vue";
import VendorOrderingInformation from "./VendorOrderingInformation.vue";
import VendorInterfaces from "./VendorInterfaces.vue";
import VendorContacts from "./VendorContacts.vue";
import VendorSubscriptions from "./VendorSubscriptions.vue";
import VendorContracts from "./VendorContracts.vue";
import VendorBaskets from "./VendorBaskets.vue";

export default {
    setup() {
        const { setConfirmationDialog, setMessage } = inject("mainStore");

        return {
            setConfirmationDialog,
            setMessage,
        };
    },
    data() {
        return {
            vendor: null,
            initialized: false,
            basketView: false,
            basketCount: null,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.path.includes("basket")) {
                vm.basketView = true;
                vm.getVendor(to.params.vendor_id).then(() =>
                    vm.getBasketCount(to.params.vendor_id)
                );
            } else {
                vm.getVendor(to.params.vendor_id);
            }
        });
    },
    methods: {
        async getVendor(vendor_id) {
            const client = APIClient.acquisition;
            await client.vendors.get(vendor_id).then(
                vendor => {
                    this.vendor = vendor;
                    this.initialized = true;
                },
                error => {}
            );
        },
        async getBasketCount(booksellerid) {
            const client = APIClient.acquisition;
            await client.baskets.count({ booksellerid }).then(
                count => {
                    this.basketCount = count;
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
        VendorBaskets,
    },
    name: "VendorShow",
};
</script>

<style>
.vendor_info {
    display: grid;
}
</style>
