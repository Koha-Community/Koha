<template>
    <fieldset class="rows" id="agreement_relationships">
        <legend>Related agreements</legend>
        <fieldset
            class="rows"
            v-for="(relationship, counter) in relationships"
            v-bind:key="counter"
        >
            <legend>
                Related agreement {{ counter + 1 }}
                <a href="#" @click.prevent="deleteRelationship(counter)"
                    ><i class="fa fa-trash"></i> Remove this relationship</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`related_agreement_id_${counter}`"
                        >Related agreement:
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
                        >Relationship:
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
                    <span class="required">Required</span>
                </li>
                <li>
                    <label :for="`related_agreement_notes${counter}`"
                        >Notes:</label
                    >
                    <input
                        :id="`related_agreement_notes_${counter}`"
                        v-model="relationship.notes"
                        placeholder="Notes"
                    />
                </li>
            </ol>
        </fieldset>
        <a class="btn btn-default" @click="addRelationship"
            ><font-awesome-icon icon="plus" /> Add new related agreement</a
        >
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