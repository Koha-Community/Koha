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
                    <label :for="`agreement_id_${counter}`"
                        >{{ $t("Agreement") }}:
                    </label>
                    <select
                        v-model="package_agreement.agreement_id"
                        :id="`agreement_id_${counter}`"
                        required
                    >
                        <option value=""></option>
                        <option
                            v-for="agreement in agreements"
                            :key="agreement.agreement_id"
                            :value="agreement.agreement_id"
                            :selected="
                                agreement.agreement_id ==
                                package_agreement.agreement_id
                                    ? true
                                    : false
                            "
                        >
                            {{ agreement.name }}
                        </option>
                    </select>
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
