<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
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
                            <v-select
                                id="package_vendor_id"
                                v-model="erm_package.vendor_id"
                                label="name"
                                :reduce="(vendor) => vendor.id"
                                :options="vendors"
                            />
                        </li>
                        <li>
                            <label for="package_type">{{ $t("Type") }}:</label>
                            <v-select
                                id="package_type"
                                v-model="erm_package.package_type"
                                label="lib"
                                :reduce="(av) => av.authorised_value"
                                :options="av_package_types"
                            />
                        </li>
                        <li>
                            <label for="package_content_type">{{
                                $t("Content type: ")
                            }}</label>
                            <v-select
                                id="package_content_type"
                                v-model="erm_package.content_type"
                                label="lib"
                                :reduce="(av) => av.authorised_value"
                                :options="av_package_content_types"
                            />
                        </li>
                        <li>
                            <label for="package_notes">{{
                                $t("Notes")
                            }}:</label>
                            <textarea
                                id="package_notes"
                                v-model="erm_package.notes"
                            />
                        </li>

                        <EHoldingsPackageAgreements
                            :package_agreements="erm_package.package_agreements"
                        />
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input type="submit" value="Submit" />
                    <router-link
                        to="/cgi-bin/koha/erm/eholdings/local/packages"
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
import { inject } from 'vue'
import EHoldingsPackageAgreements from "./EHoldingsLocalPackageAgreements.vue"
import { setMessage, setError, setWarning } from "../../messages"
import { fetchLocalPackage, createPackage, editPackage } from '../../fetch'
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = inject('vendorStore')
        const { vendors } = storeToRefs(vendorStore)
        const AVStore = inject('AVStore')
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
                vendor_id: null,
                name: '',
                external_id: '',
                package_type: '',
                content_type: '',
                notes: '',
                created_on: null,
                resources: null,
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
            const erm_package = await fetchLocalPackage(package_id)
            this.erm_package = erm_package
            this.initialized = true
        },
        checkForm(erm_package) {
            let errors = []
            let package_agreements = erm_package.package_agreements
            const agreement_ids = package_agreements.map(pa => pa.agreement_id)
            const duplicate_agreement_ids = agreement_ids.filter((id, i) => agreement_ids.indexOf(id) !== i)

            if (duplicate_agreement_ids.length) {
                errors.push(this.$t("An agreement is used several times"))
            }

            errors.forEach(function (e) {
                setWarning(e)
            })
            return !errors.length
        },
        onSubmit(e) {
            e.preventDefault()

            let erm_package = JSON.parse(JSON.stringify(this.erm_package)) // copy

            if (!this.checkForm(erm_package)) {
                return false
            }

            if (erm_package.package_id) {
                editPackage(erm_package).then(response => {
                    if (response.status == 200) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/local/packages")
                        setMessage(this.$t("Package updated"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                })
            } else {
                createPackage(erm_package).then(response => {
                    if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/local/packages")
                        setMessage(this.$t("Package created"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                })
            }
        },
    },
    components: {
        EHoldingsPackageAgreements,
    },
    name: "EHoldingsEBSCOPackagesFormAdd",
}
</script>
