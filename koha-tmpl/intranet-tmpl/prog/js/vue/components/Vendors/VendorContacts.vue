<template>
    <fieldset class="rows">
        <h2>
            {{ $__("Contact") }}
        </h2>
        <span v-if="vendor.contacts.length === 0">{{
            $__("No contacts")
        }}</span>
        <ol v-for="contact in vendor.contacts" :key="contact.id">
            <legend>{{ contact.name }}</legend>
            <li>
                <label>{{ $__("Position") }}:</label>
                <span>{{ contact.position }}</span>
            </li>
            <li>
                <label>{{ $__("Phone") }}:</label>
                <span>{{ contact.phone }}</span>
            </li>
            <li>
                <label>{{ $__("Alternative phone") }}:</label>
                <span>{{ contact.altphone }}</span>
            </li>
            <li>
                <label>{{ $__("Fax") }}:</label>
                <span>{{ contact.fax }}</span>
            </li>
            <li v-if="contact.email">
                <label>{{ $__("Email") }}:</label>
                <span>
                    <a :href="`mailto:${contact.email}`" target="_blank">{{
                        contact.email
                    }}</a>
                </span>
            </li>
            <li v-if="contact.notes">
                <label>{{ $__("Notes") }}:</label>
                <span>{{ contact.notes }}</span>
            </li>
            <li
                v-if="
                    contact.acqprimary ||
                    contact.orderacquisition ||
                    contact.claimacquisition
                "
            >
                <span class="label">{{ $__("Acquisitions options") }}:</span>
                <ol>
                    <li v-if="contact.acqprimary">
                        <span
                            ><i class="fa fa-check"></i>
                            {{ $__("Primary acquisitions contact") }}</span
                        >
                    </li>
                    <li v-if="contact.orderacquisition">
                        <span
                            ><i class="fa fa-check"></i>
                            {{ $__("Receives orders") }}</span
                        >
                    </li>
                    <li v-if="contact.claimacquisition">
                        <span
                            ><i class="fa fa-check"></i>
                            {{ $__("Receives claims for late orders") }}</span
                        >
                    </li>
                </ol>
            </li>
            <li v-if="contact.serialsprimary || contact.claimissues">
                <span class="label">{{ $__("Serials options") }}:</span>
                <ol>
                    <li v-if="contact.serialsprimary">
                        <span
                            ><i class="fa fa-check"></i>
                            {{ $__("Primary serials contact") }}</span
                        >
                    </li>
                    <li v-if="contact.claimissues">
                        <span
                            ><i class="fa fa-check"></i>
                            {{ $__("Receives claims for late issues") }}</span
                        >
                    </li>
                </ol>
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
