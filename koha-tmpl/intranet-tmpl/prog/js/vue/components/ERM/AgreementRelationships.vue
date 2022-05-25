<template>
    <fieldset class="rows" id="agreement_relationships">
        <legend>{{ $t("Related agreements") }}</legend>
        <fieldset
            class="rows"
            v-for="(relationship, counter) in relationships"
            v-bind:key="counter"
        >
            <legend>
                {{ $t("Related agreement.counter", { counter: counter + 1 }) }}
                <a href="#" @click.prevent="deleteRelationship(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $t("Remove this relationship") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`related_agreement_id_${counter}`"
                        >{{ $t("Related agreement") }}:
                    </label>
                    <select
                        v-model="relationship.related_agreement_id"
                        :id="`related_agreement_id_${counter}`"
                    >
                        <option value=""></option>
                        <option
                            v-for="agreement in agreements"
                            :key="agreement.agreement_id"
                            :value="agreement.agreement_id"
                            :selected="
                                agreement.agreement_id ==
                                relationship.related_agreement_id
                                    ? true
                                    : false
                            "
                        >
                            {{ agreement.name }}
                        </option>
                    </select>
                </li>
                <li>
                    <label :for="`related_agreement_relationship_${counter}`"
                        >{{ $t("Relationship") }}:
                    </label>
                    <select
                        v-model="relationship.relationship"
                        :id="`related_agreement_relationship_${counter}`"
                        required
                    >
                        <option value=""></option>
                        <option
                            v-for="r in av_agreement_relationships"
                            :key="r.authorised_values"
                            :value="r.authorised_value"
                            :selected="
                                r.authorised_value == relationship.relationship
                                    ? true
                                    : false
                            "
                        >
                            {{ r.lib }}
                        </option>
                    </select>
                    <span class="required">{{ $t("Required") }}</span>
                </li>
                <li>
                    <label :for="`related_agreement_notes_${counter}`"
                        >{{ $t("Notes") }}:</label
                    >
                    <input
                        :id="`related_agreement_notes_${counter}`"
                        v-model="relationship.notes"
                        :placeholder="$t('Notes')"
                    />
                </li>
            </ol>
        </fieldset>
        <a
            v-if="agreements.length"
            class="btn btn-default"
            @click="addRelationship"
            ><font-awesome-icon icon="plus" />
            {{ $t("Add new related agreement") }}</a
        >
        <span v-else>{{
            $t("There are no other agreements created yet")
        }}</span>
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
            this.agreements = agreements.filter((agreement) => agreement.agreement_id !== this.agreement_id)
        })
    },
    methods: {
        addRelationship() {
            this.relationships.push({
                related_agreement_id: null,
                relationship: null,
                notes: '',
            })
        },
        deleteRelationship(counter) {
            this.relationships.splice(counter, 1)
        },
    },
    props: {
        agreement_id: Number,
        av_agreement_relationships: Array,
        relationships: Array,
    },
    name: 'AgreementRelationships',
}
</script>
