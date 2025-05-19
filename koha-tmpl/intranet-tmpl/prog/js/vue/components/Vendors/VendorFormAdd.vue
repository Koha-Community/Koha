<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <template v-else>
        <h1 v-if="vendor.id">
            {{ $__("Edit vendor #%s").format(vendor.id) }}
        </h1>
        <h1 v-else>{{ $__("Add vendor") }}</h1>
        <Toolbar :sticky="true">
            <ButtonSubmit :text="$__('Save')" icon="save" :form="vendorForm" />
            <ToolbarButton
                :to="{ name: 'VendorList' }"
                :title="$__('Cancel')"
                icon="times"
                cssClass="btn btn-link"
            >
            </ToolbarButton>
        </Toolbar>
        <form @submit="onSubmit($event)" ref="vendorForm" id="vendors_add">
            <VendorDetails :vendor="vendor" />
            <VendorContacts :vendor="vendor" />
            <VendorInterfaces :vendor="vendor" />
            <VendorOrderingInformation
                :vendor="vendor"
                :verifyDiscountValue="verifyDiscountValue"
                :discountValid="discountValid"
            />
        </form>
    </template>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue";
import { setMessage, setWarning } from "../../messages";
import { APIClient } from "../../fetch/api-client.js";
import VendorDetails from "./VendorDetails.vue";
import VendorContacts from "./VendorContacts.vue";
import VendorOrderingInformation from "./VendorOrderingInformation.vue";
import VendorInterfaces from "./VendorInterfaces.vue";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { ref } from "vue";

export default {
    setup() {
        const vendorForm = ref();
        return {
            vendorForm,
        };
    },
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
            discountValid: true,
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

                    if (!this.vendor.discount) this.vendor.discount = 0.0;
                    const decimalPlaces =
                        this.vendor.discount.toString().split(".")[1]?.length ||
                        0;
                    if (!decimalPlaces) {
                        this.vendor.discount = this.vendor.discount.toFixed(1);
                    }

                    this.initialized = true;
                },
                error => {}
            );
        },
        onSubmit(e) {
            e.preventDefault();
            const errors = [];
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
            delete vendor.baskets;
            delete vendor.baskets_count;
            delete vendor.subscriptions;
            delete vendor.contracts;
            delete vendor.invoices_count;

            if (!this.discountValid)
                errors.push(this.$__("Invalid discount value"));

            vendor.contacts = this.checkContactOrInterface(
                vendor.contacts.map(
                    ({ id, booksellerid, ...requiredProperties }) =>
                        requiredProperties
                )
            );
            vendor.interfaces = this.checkContactOrInterface(
                vendor.interfaces.map(
                    ({
                        vendor_interface_id,
                        vendor_id,
                        ...requiredProperties
                    }) => requiredProperties
                )
            );

            setWarning(errors.join("<br>"));
            if (errors.length) return false;

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
        checkContactOrInterface(array) {
            return array.reduce((acc, curr) => {
                const atLeastOneFieldFilled = Object.keys(curr).some(
                    key => curr[key]
                );
                if (atLeastOneFieldFilled) {
                    acc.push(curr);
                }
                return acc;
            }, []);
        },
        verifyDiscountValue(e) {
            this.discountValid = /^[\-]?\d{0,2}(\.\d{0,3})*$/.test(
                this.vendor.discount
            );
        },
    },
    components: {
        ButtonSubmit,
        VendorDetails,
        VendorContacts,
        VendorOrderingInformation,
        VendorInterfaces,
        Toolbar,
        ToolbarButton,
    },
    name: "VendorFormAdd",
};
</script>
