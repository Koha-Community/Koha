<template>
    <fieldset class="rows" id="agreement_licenses">
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
                    <select
                        :id="`license_id_${counter}`"
                        v-model="agreement_license.license_id"
                        required
                    >
                        <option value=""></option>
                        <option
                            v-for="license in licenses"
                            :key="license.license_id"
                            :value="license.license_id"
                            :selected="
                                license.license_id ==
                                agreement_license.license_id
                                    ? true
                                    : false
                            "
                        >
                            {{ license.name }}
                        </option>
                    </select>
                    <span class="required">{{ $t("Required") }}</span>
                </li>
                <li>
                    <label :for="`license_status_${counter}`"
                        >{{ $t("Status") }}:</label
                    >
                    <select v-model="agreement_license.status" required>
                        <option value=""></option>
                        <option
                            v-for="r in av_agreement_license_statuses"
                            :key="r.authorised_values"
                            :value="r.authorised_value"
                            :selected="
                                r.authorised_value == agreement_license.status
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
                    <label :for="`license_location_${counter}`"
                        >{{ $t("Physical location") }}:
                    </label>
                    <select v-model="agreement_license.physical_location">
                        <option value=""></option>
                        <option
                            v-for="r in av_agreement_license_location"
                            :key="r.authorised_values"
                            :value="r.authorised_value"
                            :selected="
                                r.authorised_value ==
                                agreement_license.physical_location
                                    ? true
                                    : false
                            "
                        >
                            {{ r.lib }}
                        </option>
                    </select>
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
    </fieldset>
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
