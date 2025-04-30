<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="vendors_show">
        <Toolbar>
            <DropdownButtons
                :items="[
                    {
                        to: {
                            path: '/cgi-bin/koha/acqui/basketheader.pl',
                            query: { booksellerid: vendor.id, op: 'add_form' },
                        },
                        title: 'Basket',
                        callback: toolbarComponent => {
                            const url = toolbarComponent.handleQuery(
                                toolbarComponent.to
                            );
                            toolbarComponent.redirect(url);
                        },
                    },
                    {
                        to: {
                            path: '/cgi-bin/koha/admin/aqcontract.pl',
                            query: { booksellerid: vendor.id, op: 'add_form' },
                        },
                        title: 'Contract',
                        callback: toolbarComponent => {
                            const url = toolbarComponent.handleQuery(
                                toolbarComponent.to
                            );
                            toolbarComponent.redirect(url);
                        },
                    },
                    {
                        to: { name: 'VendorFormAdd' },
                        title: 'Vendor',
                    },
                ]"
                :title="$__('New')"
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
                v-if="
                    vendor.active &&
                    vendor.baskets_count > 0 &&
                    isUserPermitted('CAN_user_acquisition_order_receive')
                "
                :to="{
                    path: '/cgi-bin/koha/acqui/parcels.pl',
                    query: { booksellerid: vendor.id },
                }"
                icon="inbox"
                :title="$__('Receive shipments')"
                callback="redirect"
            />
            <a
                v-if="
                    vendor.baskets_count === 0 &&
                    vendor.subscriptions_count === 0 &&
                    vendor.invoices_count === 0
                "
                @click="doDelete(vendor.id, vendor.name)"
                class="btn btn-default"
                ><font-awesome-icon icon="trash" /> {{ $__("Delete") }}</a
            >
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
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import ToolbarButton from "../ToolbarButton.vue";
import VendorDetails from "./VendorDetails.vue";
import VendorOrderingInformation from "./VendorOrderingInformation.vue";
import VendorInterfaces from "./VendorInterfaces.vue";
import VendorContacts from "./VendorContacts.vue";
import VendorSubscriptions from "./VendorSubscriptions.vue";
import VendorContracts from "./VendorContracts.vue";
import DropdownButtons from "../DropdownButtons.vue";

export default {
    setup() {
        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const permissionsStore = inject("permissionsStore");
        const { isUserPermitted } = permissionsStore;

        return {
            setConfirmationDialog,
            setMessage,
            isUserPermitted,
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
            vm.getVendor(to.params.id);
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
        doDelete(id, name) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this vendor?"
                    ),
                    message: name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.acquisition;
                    client.vendors.delete(id).then(
                        success => {
                            this.setMessage(
                                this.$__("Vendor %s deleted").format(name),
                                true
                            );
                            this.$router.push({ name: "VendorList" });
                        },
                        error => {}
                    );
                }
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
        DropdownButtons,
    },
    name: "VendorShow",
};
</script>

<style>
.vendor_info {
    display: grid;
}
</style>
