<template>
    <div class="page-section" id="agreement_licenses">
        <legend>{{ $t("Licenses") }}</legend>
        <fieldset
            :id="`agreement_license_${counter}`"
            class="rows"
            v-for="(agreement_license, counter) in agreement_licenses"
            v-bind:key="counter"
        >
            <legend>
                {{ $t("Agreement license .counter", { counter: counter + 1 }) }}
                <a href="#" @click.prevent="deleteLicense(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $t("Remove this license") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`license_id_${counter}`"
                        >{{ $t("License") }}:</label
                    >
                    <v-select
                        :id="`license_id_${counter}`"
                        v-model="agreement_license.license_id"
                        label="name"
                        :reduce="(l) => l.license_id"
                        :options="licenses"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!agreement_license.license_id"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $t("Required") }}</span>
                </li>
                <li>
                    <label :for="`license_status_${counter}`"
                        >{{ $t("Status") }}:</label
                    >
                    <v-select
                        :id="`license_status_${counter}`"
                        v-model="agreement_license.status"
                        label="lib"
                        :reduce="(av) => av.authorised_value"
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
                    <span class="required">{{ $t("Required") }}</span>
                </li>
                <li>
                    <label :for="`license_location_${counter}`"
                        >{{ $t("Physical location") }}:
                    </label>
                    <v-select
                        :id="`license_location_${counter}`"
                        v-model="agreement_license.physical_location"
                        label="lib"
                        :reduce="(av) => av.authorised_value"
                        :options="av_agreement_license_location"
                    />
                </li>
                <li>
                    <label :for="`license_notes_${counter}`"
                        >{{ $t("Notes") }}:</label
                    >
                    <input
                        :id="`license_notes_${counter}`"
                        v-model="agreement_license.notes"
                        :placeholder="$t('Notes')"
                    />
                </li>
                <li>
                    <label :for="`license_uri_${counter}`"
                        >{{ $t("URI") }}:</label
                    >
                    <input
                        :id="`license_uri_${counter}`"
                        v-model="agreement_license.uri"
                        :placeholder="$t('URI')"
                    />
                </li>
            </ol>
        </fieldset>
        <a v-if="licenses.length" class="btn btn-default" @click="addLicense"
            ><font-awesome-icon icon="plus" /> {{ $t("Add new license") }}</a
        >
        <span v-else>{{ $t("There are no licenses created yet") }}</span>
    </div>
</template>

<script>
import { fetchLicenses } from '../../fetch'
export default {
    name: 'AgreementLicenses',
    data() {
        return {
            licenses: [],
        }
    },
    props: {
        av_agreement_license_statuses: Array,
        av_agreement_license_location: Array,
        agreement_licenses: Array,
    },
    beforeCreate() {
        fetchLicenses().then((licenses) => this.licenses = licenses)
    },
    methods: {
        addLicense() {
            this.agreement_licenses.push({
                license_id: null,
                status: null,
                physical_location: null,
                notes: '',
                uri: '',
            })
        },
        deleteLicense(counter) {
            this.agreement_licenses.splice(counter, 1)
        },
    },
}
</script>
