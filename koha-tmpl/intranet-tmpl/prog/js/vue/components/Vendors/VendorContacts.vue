<template>
    <fieldset class="rows" v-if="display">
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
                        <span class="contact_details"
                            ><i class="fa fa-check"></i>
                            {{ $__("Primary acquisitions contact") }}</span
                        >
                    </li>
                    <li v-if="contact.orderacquisition">
                        <span class="contact_details"
                            ><i class="fa fa-check"></i>
                            {{ $__("Receives orders") }}</span
                        >
                    </li>
                    <li v-if="contact.claimacquisition">
                        <span class="contact_details"
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
                        <span class="contact_details"
                            ><i class="fa fa-check"></i>
                            {{ $__("Primary serials contact") }}</span
                        >
                    </li>
                    <li v-if="contact.claimissues">
                        <span class="contact_details"
                            ><i class="fa fa-check"></i>
                            {{ $__("Receives claims for late issues") }}</span
                        >
                    </li>
                </ol>
            </li>
        </ol>
    </fieldset>
    <fieldset class="rows" v-else>
        <legend>{{ $__("Contacts") }}</legend>
        <fieldset
            class="rows"
            v-for="(contact, i) in vendor.contacts"
            v-bind:key="i"
            :id="`contact_${i}`"
        >
            <legend>{{ $__("Contact details") }}</legend>
            <ol>
                <li>
                    <label :for="`contact_${i}_name`"
                        >{{ $__("Contact name") }}:</label
                    >
                    <input :id="`contact_${i}_name`" v-model="contact.name" />
                </li>
                <li>
                    <label :for="`contact_${i}_position`"
                        >{{ $__("Position") }}:</label
                    >
                    <input
                        :id="`contact_${i}_position`"
                        v-model="contact.position"
                    />
                </li>
                <li>
                    <label :for="`contact_${i}_phone`"
                        >{{ $__("Phone") }}:</label
                    >
                    <input :id="`contact_${i}_phone`" v-model="contact.phone" />
                </li>
                <li>
                    <label :for="`contact_${i}_altphone`"
                        >{{ $__("Alternative phone") }}:</label
                    >
                    <input
                        :id="`contact_${i}_altphone`"
                        v-model="contact.altphone"
                    />
                </li>
                <li>
                    <label :for="`contact_${i}_fax`">{{ $__("Fax") }}:</label>
                    <input :id="`contact_${i}_fax`" v-model="contact.fax" />
                </li>
                <li>
                    <label :for="`contact_${i}_email`"
                        >{{ $__("Email") }}:</label
                    >
                    <input
                        :id="`contact_${i}_email`"
                        v-model="contact.email"
                        type="email"
                    />
                </li>
                <li>
                    <label :for="`contact_${i}_notes`"
                        >{{ $__("Notes") }}:</label
                    >
                    <textarea
                        :id="`contact_${i}_notes`"
                        v-model="contact.notes"
                        cols="40"
                        rows="3"
                    />
                </li>
            </ol>
            <div style="display: flex">
                <div>
                    <fieldset class="rows">
                        <legend>{{ $__("Acquisitions options") }}</legend>
                        <ol class="radio">
                            <li>
                                <label>
                                    <input
                                        type="checkbox"
                                        :id="`contact_acqprimary_${i}`"
                                        class="contact_acqprimary"
                                        v-model="contact.acqprimary"
                                        @change="
                                            handlePrimaryContact(
                                                'acqprimary',
                                                i
                                            )
                                        "
                                    />
                                    {{ $__("Primary acquisitions contact") }}
                                </label>
                            </li>
                            <li>
                                <label>
                                    <input
                                        type="checkbox"
                                        :id="`contact_orderacquisition_${i}`"
                                        class="contact_orderacquisition"
                                        v-model="contact.orderacquisition"
                                    />
                                    {{ $__("Contact when ordering") }}
                                </label>
                            </li>
                            <li>
                                <label>
                                    <input
                                        type="checkbox"
                                        :id="`contact_claimacquisition_${i}`"
                                        class="contact_claimacquisition"
                                        v-model="contact.claimacquisition"
                                    />
                                    {{ $__("Contact about late orders") }}
                                </label>
                            </li>
                        </ol>
                    </fieldset>
                </div>
                <div>
                    <fieldset class="rows">
                        <legend>{{ $__("Serials options") }}</legend>
                        <ol class="radio">
                            <li>
                                <label>
                                    <input
                                        type="checkbox"
                                        :id="`contact_serialsprimary_${i}`"
                                        class="contact_serialsprimary"
                                        v-model="contact.serialsprimary"
                                        @change="
                                            handlePrimaryContact(
                                                'serialsprimary',
                                                i
                                            )
                                        "
                                    />
                                    {{ $__("Primary serials contact") }}
                                </label>
                            </li>
                            <li>
                                <label>
                                    <input
                                        type="checkbox"
                                        :id="`contact_claimissues_${i}`"
                                        class="contact_claimissues"
                                        v-model="contact.claimissues"
                                    />
                                    {{ $__("Contact about late issues") }}
                                </label>
                            </li>
                        </ol>
                    </fieldset>
                </div>
            </div>
            <span class="btn btn-default" @click.prevent="deleteContact(i)"
                ><font-awesome-icon icon="trash" />
                {{ $__("Delete contact") }}</span
            >
        </fieldset>
        <span class="btn btn-default" @click="addContact"
            ><font-awesome-icon icon="plus" />
            {{ $__("Add new contact") }}</span
        >
    </fieldset>
</template>

<script>
export default {
    props: {
        vendor: Object,
        display: Boolean,
    },
    methods: {
        addContact() {
            this.vendor.contacts.push({
                name: "",
                position: "",
                email: "",
                phone: "",
                notes: "",
                altphone: "",
                fax: "",
                acqprimary: false,
                orderacquisition: false,
                claimacquisition: false,
                serialsprimary: false,
                claimissues: false,
            });
        },
        handlePrimaryContact(type, i) {
            const contact = this.vendor.contacts[i];
            if (contact[type]) {
                this.vendor.contacts.forEach((contact, j) => {
                    if (j !== i) {
                        contact[type] = false;
                    }
                });
            }
        },
        deleteContact(i) {
            this.vendor.contacts.splice(i, 1);
        },
    },
};
</script>

<style scoped>
.contact_details {
    margin-left: 9em;
}
</style>
