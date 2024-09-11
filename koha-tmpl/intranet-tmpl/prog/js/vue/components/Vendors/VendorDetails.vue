<template>
    <fieldset class="rows">
        <h2>
            {{ $__("Vendor details") }}
        </h2>
        <ol>
            <li>
                <label>{{ $__("Type") }}:</label>
                <span>
                    {{ vendor.type }}
                </span>
            </li>
            <li>
                <label>{{ $__("Company name") }}:</label>
                <span>
                    {{ vendor.name }}
                </span>
            </li>
            <li>
                <label>{{ $__("Postal address") }}:</label>
                <span>
                    {{ vendor.postal }}
                </span>
            </li>
            <li>
                <label>{{ $__("Physical address") }}:</label>
                <span>
                    {{ vendor.address1 }}
                    {{ vendor.address2 }}
                    {{ vendor.address3 }}
                    {{ vendor.address4 }}
                </span>
            </li>
            <li>
                <label>{{ $__("Phone") }}:</label>
                <span>
                    {{ vendor.phone }}
                </span>
            </li>
            <li>
                <label>{{ $__("Fax") }}:</label>
                <span>
                    {{ vendor.fax }}
                </span>
            </li>
            <li v-if="vendor.url">
                <label>{{ $__("Website") }}:</label>
                <span>
                    {{ vendor.url }}
                </span>
            </li>
            <li v-if="vendor.accountnumber">
                <label>{{ $__("Account number") }}:</label>
                <span>
                    {{ vendor.accountnumber }}
                </span>
            </li>
            <li v-if="vendor.aliases.count">
                <label>{{ $__("Aliases") }}:</label>
                <ul>
                    <li v-for="alias in vendor.aliases" :key="alias">
                        {{ alias }}
                    </li>
                </ul>
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
