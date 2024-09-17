<template>
    <fieldset class="rows">
        <h2>
            {{ $__("Interfaces") }}
        </h2>
        <ol v-for="vi in vendor.interfaces" :key="vi.id">
            <legend>{{ vi.name }}</legend>
            <li>
                <label>{{ $__("Type") }}:</label>
                <span>
                    {{ get_lib_from_av("vendor_interface_types", vi.type) }}
                </span>
            </li>
            <li v-if="vi.uri">
                <label>{{ $__("URI") }}:</label>
                <span>
                    <a :href="vi.uri" target="_blank">{{ vi.uri }}</a>
                </span>
            </li>
            <li v-if="vi.login">
                <label>{{ $__("Login") }}:</label>
                <span>
                    {{ vi.login }}
                </span>
            </li>
            <li v-if="vi.password">
                <label>{{ $__("Password") }}:</label>
                <span>
                    {{ vi.password }}
                </span>
            </li>
            <li v-if="vi.account_email">
                <label>{{ $__("Account email") }}:</label>
                <span>
                    {{ vi.account_email }}
                </span>
            </li>
            <li v-if="vi.notes">
                <label>{{ $__("Notes") }}:</label>
                <span>
                    {{ vi.notes }}
                </span>
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
