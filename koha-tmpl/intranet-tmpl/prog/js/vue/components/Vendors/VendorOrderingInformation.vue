<template>
    <fieldset class="rows" v-if="display">
        <h2>
            {{ $__("Ordering information") }}
        </h2>
        <ol>
            <li>
                <label>{{ $__("Vendor is") }}:</label>
                <span>
                    {{ vendor.active ? $__("Active") : $__("Inactive") }}
                </span>
            </li>
            <li>
                <label>{{ $__("List prices are") }}:</label>
                <span>
                    {{ vendor.list_currency }}
                </span>
            </li>
            <li>
                <label>{{ $__("Invoice prices are") }}:</label>
                <span>
                    {{ vendor.invoice_currency }}
                </span>
            </li>
            <li v-if="vendor.tax_rate">
                <label>{{ $__("Tax number registered") }}:</label>
                <span>
                    {{ vendor.gst ? $__("Yes") : $__("No") }}
                </span>
            </li>
            <li v-if="vendor.tax_rate">
                <label>{{ $__("List item price includes tax") }}:</label>
                <span>
                    {{ vendor.list_includes_gst ? $__("Yes") : $__("No") }}
                </span>
            </li>
            <li v-if="vendor.tax_rate">
                <label>{{ $__("Invoice item price includes tax") }}:</label>
                <span>
                    {{ vendor.invoice_includes_gst ? $__("Yes") : $__("No") }}
                </span>
            </li>
            <li>
                <label>{{ $__("Discount") }}:</label>
                <span> {{ vendor.discount || 0 }}% </span>
            </li>
            <li>
                <label>{{ $__("Tax rate") }}:</label>
                <span> {{ formatTaxRate(vendor.tax_rate) }}% </span>
            </li>
            <li v-if="vendor.deliverytime">
                <label>{{ $__("Delivery time") }}:</label>
                <span> {{ vendor.deliverytime + " " + $__("days") }}</span>
            </li>
            <li v-if="vendor.notes">
                <label>{{ $__("Notes") }}:</label>
                <span> {{ vendor.notes }}</span>
            </li>
        </ol>
    </fieldset>
    <fieldset class="rows" v-else>
        <legend>{{ $__("Ordering information") }}</legend>
        <ol>
            <li>
                <label for="activestatus">{{ $__("Vendor is") }}:</label>
                <input
                    type="radio"
                    name="active"
                    id="activestatus_active"
                    :value="true"
                    v-model="vendor.active"
                />
                <label class="radio" for="activestatus_active"
                    >{{ $__("Active") }}
                </label>
                <input
                    type="radio"
                    name="active"
                    id="activestatus_inactive"
                    :value="false"
                    v-model="vendor.active"
                />
                <label class="radio" for="activestatus_inactive"
                    >{{ $__("Inactive") }}
                </label>
            </li>
            <li>
                <label for="list_currency">{{ $__("List prices are") }}:</label>
                <v-select
                    id="list_currency"
                    v-model="vendor.list_currency"
                    label="currency"
                    :reduce="av => av.currency"
                    :options="currencies"
                />
            </li>
            <li>
                <label for="invoice_currency"
                    >{{ $__("Invoice prices are") }}:</label
                >
                <v-select
                    id="invoice_currency"
                    v-model="vendor.invoice_currency"
                    label="currency"
                    :reduce="av => av.currency"
                    :options="currencies"
                />
            </li>
            <li>
                <label for="gst">{{ $__("Tax number registered") }}:</label>
                <input
                    type="radio"
                    name="gst"
                    id="gst_yes"
                    :value="true"
                    v-model="vendor.gst"
                />
                <label class="radio" for="gst_yes">{{ $__("Yes") }} </label>
                <input
                    type="radio"
                    name="gst"
                    id="gst_no"
                    :value="false"
                    v-model="vendor.gst"
                />
                <label class="radio" for="gst_no">{{ $__("No") }} </label>
            </li>
            <li>
                <label for="invoice_gst">{{ $__("Invoice prices") }}:</label>
                <input
                    type="radio"
                    name="invoice_gst"
                    id="invoice_gst_yes"
                    :value="true"
                    v-model="vendor.invoice_includes_gst"
                />
                <label class="radio" for="invoice_gst_yes"
                    >{{ $__("Include tax") }}
                </label>
                <input
                    type="radio"
                    name="invoice_gst"
                    id="invoice_gst_no"
                    :value="false"
                    v-model="vendor.invoice_includes_gst"
                />
                <label class="radio" for="invoice_gst_no"
                    >{{ $__("Don't include tax") }}
                </label>
            </li>
            <li>
                <label for="list_gst">{{ $__("List prices") }}:</label>
                <input
                    type="radio"
                    name="list_gst"
                    id="list_gst_yes"
                    :value="true"
                    v-model="vendor.list_includes_gst"
                />
                <label class="radio" for="list_gst_yes"
                    >{{ $__("Include tax") }}
                </label>
                <input
                    type="radio"
                    name="list_gst"
                    id="list_gst_no"
                    :value="false"
                    v-model="vendor.list_includes_gst"
                />
                <label class="radio" for="list_gst_no"
                    >{{ $__("Don't include tax") }}
                </label>
            </li>
            <li>
                <label for="tax_rate">{{ $__("Tax rate") }}:</label>
                <v-select
                    id="tax_rate"
                    v-model="vendor.tax_rate"
                    label="label"
                    :reduce="av => av.value"
                    :options="gstValues"
                />
            </li>
            <li>
                <label for="discount">{{ $__("Discount") }}: </label>
                <input
                    type="text"
                    inputmode="numeric"
                    size="6"
                    id="discount"
                    name="discount"
                    v-model="vendor.discount"
                    @change="verifyDiscountValue(e)"
                />
                %
                <span class="error" v-if="!discountValid">
                    {{
                        $__("Please enter a decimal number in the format: 0.0")
                    }}
                </span>
            </li>
            <li>
                <label for="deliverytime">{{ $__("Delivery time") }}: </label>
                <input
                    type="text"
                    inputmode="numeric"
                    size="6"
                    id="deliverytime"
                    name="deliverytime"
                    v-model="vendor.deliverytime"
                />
                {{ $__("days") }}
            </li>
            <li>
                <label for="notes">{{ $__("Notes") }}:</label>
                <textarea
                    id="notes"
                    v-model="vendor.notes"
                    cols="40"
                    rows="3"
                />
            </li>
        </ol>
    </fieldset>
</template>

<script>
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    props: {
        vendor: Object,
        display: Boolean,
        verifyDiscountValue: Function,
        discountValid: Boolean,
    },
    setup() {
        const vendorStore = inject("vendorStore");
        const { currencies, gstValues } = storeToRefs(vendorStore);

        return {
            currencies,
            gstValues,
        };
    },
    methods: {
        formatTaxRate(taxRate) {
            if (!taxRate) return 0;
            const decimalPlaces = taxRate.toString().split(".")[1]?.length || 0;
            const multiplier = 10 ** decimalPlaces;
            return Math.round(taxRate * multiplier) / (multiplier / 100);
        },
        formatDiscount() {
            if (!this.vendor.discount) return 0.0;
            const decimalPlaces =
                this.vendor.discount.toString().split(".")[1]?.length || 0;
            if (decimalPlaces) {
                return this.vendor.discount;
            } else {
                return this.vendor.discount.toFixed(1);
            }
        },
    },
};
</script>
