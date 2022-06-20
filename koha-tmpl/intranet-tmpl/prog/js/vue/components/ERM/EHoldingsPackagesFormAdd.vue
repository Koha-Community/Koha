<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else id="packages_add">
        <h2 v-if="erm_package.package_id">
            {{ $t("Edit package .id", { id: erm_package.package_id }) }}
        </h2>
        <h2 v-else>{{ $t("New package") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label class="required" for="package_name"
                                >{{ $t("Package name") }}:</label
                            >
                            <input
                                id="package_name"
                                v-model="erm_package.name"
                                :placeholder="$t('Package name')"
                                required
                            />
                            <span class="required">{{ $t("Required") }}</span>
                        </li>
                        <li>
                            <label for="package_vendor_id"
                                >{{ $t("Vendor") }}:</label
                            >
                            <select
                                id="package_vendor_id"
                                v-model="erm_package.vendor_id"
                            >
                                <option value=""></option>
                                <option
                                    v-for="vendor in vendors"
                                    :key="vendor.vendor_id"
                                    :value="vendor.id"
                                    :selected="
                                        vendor.id == erm_package.vendor_id
                                            ? true
                                            : false
                                    "
                                >
                                    {{ vendor.name }}
                                </option>
                            </select>
                        </li>
                        <li>
                            <label for="package_type">{{ $t("Type") }}:</label>
                            <select
                                id="package_type"
                                v-model="erm_package.package_type"
                            >
                                <option value=""></option>
                                <option
                                    v-for="type in av_package_types"
                                    :key="type.authorised_values"
                                    :value="type.authorised_value"
                                    :selected="
                                        type.authorised_value ==
                                        erm_package.package_type
                                            ? true
                                            : false
                                    "
                                >
                                    {{ type.lib }}
                                </option>
                            </select>
                        </li>
                        <li>
                            <label for="package_content_type">{{
                                $t("Content type: ")
                            }}</label>
                            <select
                                id="package_content_type"
                                v-model="erm_package.content_type"
                            >
                                <option value=""></option>
                                <option
                                    v-for="type in av_package_content_types"
                                    :key="type.authorised_values"
                                    :value="type.authorised_value"
                                    :selected="
                                        type.authorised_value ==
                                        erm_package.content_type
                                            ? true
                                            : false
                                    "
                                >
                                    {{ type.lib }}
                                </option>
                            </select>
                        </li>

                        <EHoldingsPackageAgreements
                            :package_agreements="erm_package.package_agreements"
                        />
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input type="submit" value="Submit" />
                    <router-link
                        to="/cgi-bin/koha/erm/eholdings/packages"
                        role="button"
                        class="cancel"
                        >{{ $t("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import EHoldingsPackageAgreements from "./EHoldingsPackageAgreements.vue"
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { setMessage, setError } from "../../messages"
import { fetchPackage } from '../../fetch'
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)
        const AVStore = useAVStore()
        const {
            av_package_types,
            av_package_content_types,
        } = storeToRefs(AVStore)

        return {
            vendors,
            av_package_types,
            av_package_content_types,
        }
    },
    data() {
        return {
            erm_package: {
                package_id: null,
                name: '',
                external_id: '',
                package_type: '',
                content_type: '',
                package_agreements: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.package_id) {
                vm.erm_package = vm.getPackage(to.params.package_id)
            } else {
                vm.initialized = true
            }
        })
    },
    methods: {
        async getPackage(package_id) {
            const erm_package = await fetchPackage(package_id)
            this.erm_package = erm_package
            this.initialized = true
        },
        onSubmit(e) {
            e.preventDefault()

            let erm_package = JSON.parse(JSON.stringify(this.erm_package)) // copy
            let apiUrl = '/api/v1/erm/eholdings/packages'

            let method = 'POST'
            if (erm_package.package_id) {
                method = 'PUT'
                apiUrl += '/' + erm_package.package_id
            }
            delete erm_package.package_id
            delete erm_package.resources
            delete erm_package.vendor
            delete erm_package.resources_count

            erm_package.package_agreements = erm_package.package_agreements.map(({ package_id, agreement, ...keepAttrs }) => keepAttrs)

            const options = {
                method: method,
                body: JSON.stringify(erm_package),
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(response => {
                    if (response.status == 200) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/packages")
                        setMessage(this.$t("Package updated"))
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/packages")
                        setMessage(this.$t("Package created"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                }, (error) => {
                    setError(error)
                }).catch(e => { console.log(e) })
        },
    },
    components: {
        EHoldingsPackageAgreements,
    },
    name: "EHoldingsPackagesFormAdd",
}
</script>
