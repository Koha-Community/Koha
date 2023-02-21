<template>
    <fieldset class="rows" id="package_agreements">
        <legend>{{ $__("Agreements") }}</legend>

        <div v-if="!initialized">{{ $__("Loading") }}</div>
        <fieldset
            v-else
            :id="`package_agreement_${counter}`"
            class="rows"
            v-for="(package_agreement, counter) in package_agreements"
            v-bind:key="counter"
        >
            <legend>
                {{ $__("Agreement %s").format(counter + 1) }}
                <a href="#" @click.prevent="deleteAgreement(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this agreement") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`agreement_id_${counter}`" class="required"
                        >{{ $__("Agreement") }}:
                    </label>
                    <v-select
                        :id="`agreement_id_${counter}`"
                        v-model="package_agreement.agreement_id"
                        label="name"
                        :reduce="a => a.agreement_id"
                        :options="agreements"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!package_agreement.agreement_id"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $__("Required") }}</span>
                </li>
            </ol>
        </fieldset>
        <a
            v-if="initialized && agreements.length"
            class="btn btn-default"
            @click="addAgreement"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new agreement") }}</a
        >
        <span v-else-if="initialized">{{
            $__("There are no agreements created yet")
        }}</span>
    </fieldset>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js"

export default {
    data() {
        return {
            agreements: [],
            initialized: false,
        }
    },
    beforeCreate() {
        const client = APIClient.erm
        client.agreements.getAll().then(
            agreements => {
                this.agreements = agreements
                this.initialized = true
            },
            error => {}
        )
    },
    methods: {
        addAgreement() {
            this.package_agreements.push({
                agreement_id: null,
            })
        },
        deleteAgreement(counter) {
            this.package_agreements.splice(counter, 1)
        },
    },
    props: {
        package_agreements: Array,
    },
    name: "EHoldingsLocalPackageAgreements",
}
</script>
