<template>
    <fieldset class="rows" id="agreement_licenses">
        <legend>{{ $__("Licenses") }}</legend>
        <fieldset
            :id="`agreement_license_${counter}`"
            class="rows"
            v-for="(agreement_license, counter) in agreement_licenses"
            v-bind:key="counter"
        >
            <legend>
                {{ $__("Agreement license %s").format(counter + 1) }}
                <a href="#" @click.prevent="deleteLicense(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this license") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`license_id_${counter}`" class="required"
                        >{{ $__("License") }}:</label
                    >
                    <InfiniteScrollSelect
                        :id="`license_id_${counter}`"
                        v-model="agreement_license.license_id"
                        :selectedData="agreement_license.license"
                        dataType="licenses"
                        dataIdentifier="license_id"
                        label="name"
                        :required="true"
                    />
                    <span class="required">{{ $__("Required") }}</span>
                </li>
                <li>
                    <label :for="`license_status_${counter}`" class="required"
                        >{{ $__("Status") }}:</label
                    >
                    <v-select
                        :id="`license_status_${counter}`"
                        v-model="agreement_license.status"
                        label="description"
                        :reduce="av => av.value"
                        :options="av_agreement_license_statuses"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!agreement_license.status"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $__("Required") }}</span>
                </li>
                <li>
                    <label :for="`license_location_${counter}`"
                        >{{ $__("Physical location") }}:
                    </label>
                    <v-select
                        :id="`license_location_${counter}`"
                        v-model="agreement_license.physical_location"
                        label="description"
                        :reduce="av => av.value"
                        :options="av_agreement_license_location"
                    />
                </li>
                <li>
                    <label :for="`license_notes_${counter}`"
                        >{{ $__("Notes") }}:</label
                    >
                    <input
                        :id="`license_notes_${counter}`"
                        v-model="agreement_license.notes"
                        :placeholder="$__('Notes')"
                    />
                </li>
                <li>
                    <label :for="`license_uri_${counter}`"
                        >{{ $__("URI") }}:</label
                    >
                    <input
                        :id="`license_uri_${counter}`"
                        v-model="agreement_license.uri"
                        :placeholder="$__('URI')"
                    />
                </li>
            </ol>
        </fieldset>
        <a v-if="license_count > 0" class="btn btn-default" @click="addLicense"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new license") }}</a
        >
        <span v-else>{{ $__("There are no licenses created yet") }}</span>
    </fieldset>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js";
import InfiniteScrollSelect from "../InfiniteScrollSelect.vue";

export default {
    name: "AgreementLicenses",
    data() {
        return {
            license_count: null,
        };
    },
    props: {
        av_agreement_license_statuses: Array,
        av_agreement_license_location: Array,
        agreement_licenses: Array,
    },
    beforeCreate() {
        const client = APIClient.erm;
        client.licenses.count().then(
            count => {
                this.license_count = count;
                this.initialized = true;
            },
            error => {}
        );
    },
    methods: {
        addLicense() {
            this.agreement_licenses.push({
                license_id: null,
                status: null,
                physical_location: null,
                notes: "",
                uri: "",
                license: { name: "" },
            });
        },
        deleteLicense(counter) {
            this.agreement_licenses.splice(counter, 1);
        },
    },
    components: {
        InfiniteScrollSelect,
    },
};
</script>
