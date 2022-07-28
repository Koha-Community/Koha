<template>
    <fieldset class="rows" id="resources">
        <legend>{{ $t("Packages") }}</legend>
        <fieldset
            class="rows"
            v-for="(resource, counter) in resources"
            v-bind:key="counter"
        >
            <legend>
                {{ $t("Package .counter", { counter: counter + 1 }) }}
                <a href="#" @click.prevent="deletePackage(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $t("Remove from this package") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label
                        :for="`resource_package_id_${counter}`"
                        class="required"
                        >{{ $t("Package") }}:
                    </label>
                    <!-- Parse to integer, resource.package_id is an integer, but GET /packages return package_id as string -->
                    <v-select
                        :id="`resource_package_id_${counter}`"
                        v-model="resource.package_id"
                        label="name"
                        :reduce="(p) => parseInt(p.package_id)"
                        :options="packages"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!resource.package_id"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $t("Required") }}</span>
                </li>
                <li>
                    <label :for="`resource_vendor_id_${counter}`"
                        >{{ $t("Vendor") }}:</label
                    >
                    <v-select
                        :id="`resource_vendor_id_${counter}`"
                        v-model="resource.vendor_id"
                        label="name"
                        :reduce="(vendor) => vendor.id"
                        :options="vendors"
                    />
                </li>

                <li>
                    <label :for="`started_on_${counter}`"
                        >{{ $t("Start date") }}:
                    </label>
                    <flat-pickr
                        :id="`started_on_${counter}`"
                        v-model="resource.started_on"
                        :config="fp_config"
                        :data-date_to="`ended_on_${counter}`"
                    />
                </li>
                <li>
                    <label :for="`ended_on_${counter}`"
                        >{{ $t("End date") }}:</label
                    >
                    <flat-pickr
                        :id="`ended_on_${counter}`"
                        v-model="resource.ended_on"
                        :config="fp_config"
                    />
                </li>
                <li>
                    <label :for="`${counter}`">{{ $t("Proxy") }}:</label>
                    <input
                        :id="`proxy_${counter}`"
                        v-model="resource.proxy"
                        :placeholder="$t('Proxy')"
                    />
                </li>
            </ol>
        </fieldset>
        <a v-if="packages.length" class="btn btn-default" @click="addPackage"
            ><font-awesome-icon icon="plus" />
            {{ $t("Add to another package") }}</a
        >
        <span v-else>{{ $t("There are no packages created yet") }}</span>
    </fieldset>
</template>

<script>
import flatPickr from 'vue-flatpickr-component'
import { useVendorStore } from "../../stores/vendors"
import { storeToRefs } from "pinia"
import { fetchLocalPackages } from "../../fetch"

export default {
    setup() {
        const vendorStore = useVendorStore() // FIXME We only need that for 'manual'
        const { vendors } = storeToRefs(vendorStore)
        return { vendors }
    },
    data() {
        return {
            packages: [],
            fp_config: flatpickr_defaults,
            dates_fixed: 0,
        }
    },
    beforeCreate() {
        fetchLocalPackages().then((packages) => this.packages = packages)
        if (!this.dates_fixed) {
            this.resources.forEach(r => {
                r.started_on = $date(r.started_on)
                r.ended_on = $date(r.ended_on)
            })
            this.dates_fixed = 1
        }
    },
    methods: {
        addPackage() {
            this.resources.push({
                package_id: null,
                vendor_id: null,
                started_on: null,
                ended_on: null,
                proxy: '',
            })
        },
        deletePackage(counter) {
            this.resources.splice(counter, 1)
        },
    },
    props: {
        resources: Array,
    },
    components: { flatPickr },
    name: 'EHoldingsLocalTitlesFormAddResources',
}
</script>
