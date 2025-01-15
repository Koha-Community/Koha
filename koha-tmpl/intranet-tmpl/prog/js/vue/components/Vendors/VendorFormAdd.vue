<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="vendor_add">
        <h1 v-if="vendor.id">
            {{ $__("Edit vendor #%s").format(vendor.id) }}
        </h1>
        <h1 v-else>{{ $__("Add vendor") }}</h1>
        <div>
            <form @submit="onSubmit($event)">
                <VendorDetails :vendor="vendor" />
                <VendorContacts :vendor="vendor" />
                <VendorInterfaces :vendor="vendor" />
                <VendorOrderingInformation :vendor="vendor" />
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        :to="{ name: 'VendorList' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue";
import { setMessage } from "../../messages";
import { APIClient } from "../../fetch/api-client.js";
import VendorDetails from "./VendorDetails.vue";
import VendorContacts from "./VendorContacts.vue";
import VendorOrderingInformation from "./VendorOrderingInformation.vue";
import VendorInterfaces from "./VendorInterfaces.vue";

export default {
    data() {
        return {
            vendor: {
                id: null,
                name: "",
                address1: "",
                address2: "",
                address3: "",
                address4: "",
                phone: "",
                accountnumber: "",
                type: "",
                notes: "",
                postal: "",
                url: "",
                active: true,
                list_currency: null,
                invoice_currency: null,
                tax_rate: null,
                gst: false,
                list_includes_gst: false,
                invoice_includes_gst: false,
                discount: null,
                deliverytime: null,
                fax: "",
                external_id: "",
                aliases: [],
                contacts: [],
                interfaces: [],
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.id) {
                vm.getVendor(to.params.id);
            } else {
                vm.initialized = true;
            }
        });
    },
    methods: {
        async getVendor(vendor_id) {
            const client = APIClient.acquisition;
            client.vendors.get(vendor_id).then(
                vendor => {
                    this.vendor = vendor;
                    let physical = "";
                    vendor.address1 && (physical += vendor.address1 + "\n");
                    vendor.address2 && (physical += vendor.address2 + "\n");
                    vendor.address3 && (physical += vendor.address3 + "\n");
                    vendor.address4 && (physical += vendor.address4 + "\n");
                    this.vendor.physical = physical;
                    this.initialized = true;
                },
                error => {}
            );
        },
        onSubmit(e) {
            e.preventDefault();

            const vendor = JSON.parse(JSON.stringify(this.vendor));

            const vendorId = vendor.id;
            delete vendor.id;

            if (vendor.physical) {
                const addressLines = vendor.physical.split("\n");
                if (addressLines.length > 4) {
                    addressLines.length = 4;
                }
                addressLines.forEach((line, i) => {
                    vendor[`address${i + 1}`] = line;
                });
            }
            delete vendor.physical;
            delete vendor.subscriptions_count;

            vendor.contacts = vendor.contacts.map(
                ({ id, booksellerid, ...requiredProperties }) =>
                    requiredProperties
            );
            vendor.interfaces = vendor.interfaces.map(
                ({ interface_id, vendor_id, ...requiredProperties }) =>
                    requiredProperties
            );

            const client = APIClient.acquisition;
            if (vendorId) {
                client.vendors.update(vendor, vendorId).then(
                    success => {
                        setMessage(this.$__("Vendor updated"));
                        this.$router.push({ name: "VendorList" });
                    },
                    error => {}
                );
            } else {
                client.vendors.create(vendor).then(
                    success => {
                        setMessage(this.$__("Vendor created"));
                        this.$router.push({ name: "VendorList" });
                    },
                    error => {}
                );
            }
        },
    },
    components: {
        ButtonSubmit,
        VendorDetails,
        VendorContacts,
        VendorOrderingInformation,
        VendorInterfaces,
    },
    name: "VendorFormAdd",
};
</script>
