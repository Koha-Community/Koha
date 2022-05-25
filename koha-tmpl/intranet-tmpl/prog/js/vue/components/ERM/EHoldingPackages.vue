<template>
    <fieldset class="rows" id="eholding_packages">
        <legend>{{ $t("Packages") }}</legend>
        <fieldset
            class="rows"
            v-for="(eholding_package, counter) in eholding_packages"
            v-bind:key="counter"
        >
            <legend>
                {{ $t("Package.counter", { counter: counter + 1 }) }}
                <a href="#" @click.prevent="deletePackage(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $t("Remove from this package") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label
                        :for="`eholding_package_id_${counter}`"
                        class="required"
                        >{{ $t("Package:") }}
                    </label>
                    <select
                        v-model="eholding_package.package_id"
                        :id="`eholding_package_id_${counter}`"
                        required
                    >
                        <option value=""></option>
                        <option
                            v-for="p in packages"
                            :key="p.package_id"
                            :value="p.package_id"
                            :selected="
                                p.package_id == eholding_package.package_id
                                    ? true
                                    : false
                            "
                        >
                            {{ p.name }}
                        </option>
                    </select>
                    <span class="required">{{ $t("Required") }}</span>
                </li>
                <li>
                    <label :for="`started_on_${counter}`"
                        >{{ $t("Start date:") }}
                    </label>
                    <flat-pickr
                        :id="`started_on_${counter}`"
                        v-model="eholding_package.started_on"
                        :config="fp_config"
                        :data-date_to="`ended_on_${counter}`"
                    />
                </li>
                <li>
                    <label :for="`ended_on_${counter}`">{{
                        $t("End date:")
                    }}</label>
                    <flat-pickr
                        :id="`ended_on_${counter}`"
                        v-model="eholding_package.ended_on"
                        :config="fp_config"
                    />
                </li>
                <li>
                    <label :for="`${counter}`">{{ $t("Proxy:") }}</label>
                    <input
                        :id="`proxy_${counter}`"
                        v-model="eholding_package.proxy"
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
import { fetchPackages } from "../../fetch"

export default {
    data() {
        return {
            packages: [],
            fp_config: flatpickr_defaults,
            dates_fixed: 0,
        }
    },
    beforeCreate() {
        fetchPackages().then((packages) => this.packages = packages)
    },
    methods: {
        addPackage() {
            this.eholding_packages.push({
                package_id: null,
                started_on: null,
                ended_on: null,
                proxy: '',
            })
        },
        deletePackage(counter) {
            this.eholding_packages.splice(counter, 1)
        },
    },
    props: {
        eholding_packages: Array,
    },
    components: { flatPickr },
    name: 'EHoldingPackages',
}
</script>
