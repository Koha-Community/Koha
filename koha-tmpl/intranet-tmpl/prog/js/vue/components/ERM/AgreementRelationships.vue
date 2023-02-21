<template>
    <div class="page-section" id="agreement_relationships">
        <legend>{{ $__("Related agreements") }}</legend>
        <fieldset
            :id="`related_agreement_${counter}`"
            class="rows"
            v-for="(relationship, counter) in relationships"
            v-bind:key="counter"
        >
            <legend>
                {{ $__("Related agreement %s").format(counter + 1) }}
                <a href="#" @click.prevent="deleteRelationship(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this relationship") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`related_agreement_id_${counter}`"
                        >{{ $__("Related agreement") }}:
                    </label>
                    <v-select
                        :id="`related_agreement_id_${counter}`"
                        v-model="relationship.related_agreement_id"
                        label="name"
                        :reduce="a => a.agreement_id"
                        :options="agreements"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!relationship.related_agreement_id"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $__("Required") }}</span>
                </li>
                <li>
                    <label :for="`related_agreement_relationship_${counter}`"
                        >{{ $__("Relationship") }}:
                    </label>
                    <v-select
                        :id="`related_agreement_relationship_${counter}`"
                        v-model="relationship.relationship"
                        label="lib"
                        :reduce="av => av.authorised_value"
                        :options="av_agreement_relationships"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!relationship.relationship"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $__("Required") }}</span>
                </li>
                <li>
                    <label :for="`related_agreement_notes_${counter}`"
                        >{{ $__("Notes") }}:</label
                    >
                    <input
                        :id="`related_agreement_notes_${counter}`"
                        v-model="relationship.notes"
                        :placeholder="$__('Notes')"
                    />
                </li>
            </ol>
        </fieldset>
        <a
            v-if="agreements.length"
            class="btn btn-default"
            @click="addRelationship"
            ><font-awesome-icon icon="plus" />
            {{ $__("Add new related agreement") }}</a
        >
        <span v-else>{{
            $__("There are no other agreements created yet")
        }}</span>
    </div>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js"

export default {
    data() {
        return {
            agreements: [],
        }
    },
    beforeCreate() {
        const client = APIClient.erm
        client.agreements.getAll().then(
            agreements => {
                this.agreements = agreements.filter(
                    agreement => agreement.agreement_id !== this.agreement_id
                )
                this.initialized = true
            },
            error => {}
        )
    },
    methods: {
        addRelationship() {
            this.relationships.push({
                related_agreement_id: null,
                relationship: null,
                notes: "",
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
    name: "AgreementRelationships",
}
</script>
