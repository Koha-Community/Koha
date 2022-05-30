<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else id="packages_show">
        <h2>
            {{ $t("Package .id", { id: erm_package.package_id }) }}
            <span class="action_links">
                <router-link
                    :to="`/cgi-bin/koha/erm/eholdings/packages/edit/${erm_package.package_id}`"
                    :title="$t('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>

                <router-link
                    :to="`/cgi-bin/koha/erm/eholdings/packages/delete/${erm_package.package_id}`"
                    :title="$t('Delete')"
                    ><i class="fa fa-trash"></i
                ></router-link>
            </span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $t("Package name") }}:</label>
                        <span>
                            {{ erm_package.name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Vendor") }}:</label>
                        <span v-if="erm_package.vendor_id">
                            {{
                                vendors.find(
                                    (e) => e.id == erm_package.vendor_id
                                ).name
                            }}
                        </span>
                    </li>
                    <li v-if="erm_package.external_id">
                        <label>{{ $t("External ID") }}:</label>
                        <span>
                            {{ erm_package.external_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Package type") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_package_types",
                                erm_package.package_type
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $t("Content type") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_package_content_types",
                                erm_package.content_type
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $t("Created on") }}:</label>
                        <span>{{ format_date(erm_package.created_on) }}</span>
                    </li>

                    <li v-if="erm_package.resources.length">
                        <label>{{ $t("Titles") }}</label>
                        <table>
                            <thead>
                                <tr>
                                    <th>Name</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(
                                        r, counter
                                    ) in erm_package.resources"
                                    v-bind:key="counter"
                                >
                                    <td>
                                        <router-link
                                            :to="`/cgi-bin/koha/erm/eholdings/resources/${r.resource_id}`"
                                            :title="$t('Show resource')"
                                        >
                                            {{ r.title.publication_title }}
                                        </router-link>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/erm/eholdings/packages"
                    role="button"
                    class="cancel"
                    >{{ $t("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { fetchPackage } from "../../fetch"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const format_date = $date

        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { get_lib_from_av } = AVStore

        return {
            format_date,
            get_lib_from_av,
            vendors,
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
                created_on: null,
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackage(to.params.package_id)
        })
    },
    beforeRouteUpdate(to, from) {
        this.erm_package = this.getPackage(to.params.package_id)
    },
    methods: {
        async getPackage(package_id) {
            const erm_package = await fetchPackage(package_id)
            this.erm_package = erm_package
            this.initialized = true
        },
    },
    name: "EHoldingsPackagesShow",
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
}
</style>
