<template>
    <fieldset class="rows" id="package_agreements">
        <legend>{{ $t("Agreements") }}</legend>
        <fieldset
            class="rows"
            v-for="(package_agreement, counter) in package_agreements"
            v-bind:key="counter"
        >
            <legend>
                {{ $t("Agreement .counter", { counter: counter + 1 }) }}
                <a href="#" @click.prevent="deleteAgreement(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $t("Remove this agreement") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`agreement_id_${counter}`" class="required"
                        >{{ $t("Agreement") }}:
                    </label>
                    <v-select
                        :id="`agreement_id_${counter}`"
                        v-model="package_agreement.agreement_id"
                        label="name"
                        :reduce="(a) => a.agreement_id"
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
                    <span class="required">{{ $t("Required") }}</span>
                </li>
            </ol>
        </fieldset>
        <a
            v-if="agreements.length"
            class="btn btn-default"
            @click="addAgreement"
            ><font-awesome-icon icon="plus" /> {{ $t("Add new agreement") }}</a
        >
        <span v-else>{{ $t("There are no agreements created yet") }}</span>
    </fieldset>
</template>

<script>
import { fetchAgreements } from "../../fetch"

export default {
    data() {
        return {
            agreements: [],
        }
    },
    beforeCreate() {
        fetchAgreements().then((agreements) => {
            this.agreements = agreements
        })
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
    name: 'EHoldingsLocalPackageAgreements',
}
</script>
