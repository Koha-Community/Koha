<template>
    <fieldset class="rows">
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
                    {{ vendor.listprice }}
                </span>
            </li>
            <li>
                <label>{{ $__("Invoice prices are") }}:</label>
                <span>
                    {{ vendor.invoiceprice }}
                </span>
            </li>
            <li v-if="vendor.tax_rate">
                <label>{{ $__("Tax number registered") }}:</label>
                <span>
                    {{ vendor.gstreg ? $__("Yes") : $__("No") }}
                </span>
            </li>
            <li v-if="vendor.tax_rate">
                <label>{{ $__("List item price includes tax") }}:</label>
                <span>
                    {{ vendor.listincgst ? $__("Yes") : $__("No") }}
                </span>
            </li>
            <li v-if="vendor.tax_rate">
                <label>{{ $__("Invoice item price includes tax") }}:</label>
                <span>
                    {{ vendor.invoiceincgst ? $__("Yes") : $__("No") }}
                </span>
            </li>
            <li>
                <label>{{ $__("Discount") }}:</label>
                <span>
                    {{ vendor.discount || 0 }}
                </span>
            </li>
            <li>
                <label>{{ $__("Tax rate") }}:</label>
                <span>
                    {{ (vendor.tax_rate || 0) * 100 }}
                </span>
            </li>
            <li v-if="vendor.deliverytime">
                <label>{{ $__("Delivery time") }}:</label>
                <span> {{ vendor.deliverytime }} days </span>
            </li>
            <li v-if="vendor.notes">
                <label>{{ $__("Notes") }}:</label>
                <span> {{ vendor.notes }} days </span>
            </li>
        </ol>
    </fieldset>
</template>

<script>
export default {
    props: {
        vendor: Object,
    },
};
</script>

<style></style>
