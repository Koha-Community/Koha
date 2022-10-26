<template>
    <fieldset class="rows" id="resources">
        <legend>{{ $__("Packages") }}</legend>
        <fieldset
            class="rows"
            v-for="(resource, counter) in resources"
            v-bind:key="counter"
        >
            <legend>
                {{ $__("Package %s").format(counter + 1) }}
                <a href="#" @click.prevent="deletePackage(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove from this package") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label
                        :for="`resource_package_id_${counter}`"
                        class="required"
                        >{{ $__("Package") }}:
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
                    <span class="required">{{ $__("Required") }}</span>
                </li>
                <li>
                    <label :for="`resource_vendor_id_${counter}`"
                        >{{ $__("Vendor") }}:</label
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
                        >{{ $__("Start date") }}:
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
                        >{{ $__("End date") }}:</label
                    >
                    <flat-pickr
                        :id="`ended_on_${counter}`"
                        v-model="resource.ended_on"
                        :config="fp_config"
                    />
                </li>
                <li>
                    <label :for="`${counter}`">{{ $__("Proxy") }}:</label>
                    <input
                        :id="`proxy_${counter}`"
                        v-model="resource.proxy"
                        :placeholder="$__('Proxy')"
                    />
                </li>
            </ol>
        </fieldset>
        <a v-if="packages.length" class="btn btn-default" @click="addPackage"
            ><font-awesome-icon icon="plus" />
            {{ $__("Add to another package") }}</a
        >
        <span v-else>{{ $__("There are no packages created yet") }}</span>
    </fieldset>
</template>

<script>
import { inject } from 'vue'
import flatPickr from 'vue-flatpickr-component'
import { storeToRefs } from "pinia"
import { fetchLocalPackages } from "../../fetch"

export default {
    setup() {
        const vendorStore = inject('vendorStore')
        const { vendors } = storeToRefs(vendorStore)
        return { vendors }
    },
    data() {
        return {
            packages: [],
            fp_config: flatpickr_defaults,
        }
    },
    beforeCreate() {
        fetchLocalPackages().then((packages) => this.packages = packages)
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
