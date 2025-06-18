<template>
    <fieldset class="rows" style="margin-top: 10px">
        <div style="display: flex">
            <div>
                <fieldset class="rows">
                    <legend>{{ $__("Acquisitions options") }}</legend>
                    <ol class="radio">
                        <li>
                            <label>
                                <input
                                    type="checkbox"
                                    :id="`contact_acqprimary_${index}`"
                                    class="contact_acqprimary"
                                    v-model="contact.acqprimary"
                                    @change="
                                        handlePrimaryContact(
                                            'acqprimary',
                                            index
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
                                    :id="`contact_orderacquisition_${index}`"
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
                                    :id="`contact_claimacquisition_${index}`"
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
                                    :id="`contact_serialsprimary_${index}`"
                                    class="contact_serialsprimary"
                                    v-model="contact.serialsprimary"
                                    @change="
                                        handlePrimaryContact(
                                            'serialsprimary',
                                            index
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
                                    :id="`contact_claimissues_${index}`"
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
    </fieldset>
</template>

<script>
import { inject } from "vue";
export default {
    props: {
        contact: Object,
        index: Number | null,
    },
    setup(props) {
        const resourceRelationships = inject("resourceRelationships");

        const handlePrimaryContact = (type, index) => {
            const contact = resourceRelationships[index];
            if (contact[type]) {
                resourceRelationships.forEach((contact, j) => {
                    if (j !== index) {
                        contact[type] = false;
                    }
                });
            }
        };

        return {
            handlePrimaryContact,
        };
    },
};
</script>

<style scoped>
.contact_details {
    margin-left: 9em;
}
</style>
