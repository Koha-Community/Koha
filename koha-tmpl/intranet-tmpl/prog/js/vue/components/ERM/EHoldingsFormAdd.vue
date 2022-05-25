<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else id="eholdings_add">
        <h2 v-if="eholding.eholding_id">
            {{ $t("Edit eHolding.id", { id: eholding.eholding_id }) }}
        </h2>
        <h2 v-else>{{ $t("New eHolding") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label class="required" for="eholding_name">{{
                                $t("Publication title:")
                            }}</label>
                            <input
                                id="eholding_publication_title"
                                v-model="eholding.publication_title"
                                :placeholder="$t('Publication title')"
                                required
                            />
                            <span class="required">{{ $t("Required") }}</span>
                        </li>

                        <li>
                            <label for="eholding_vendor_id">{{
                                $t("Vendor:")
                            }}</label>
                            <select
                                id="eholding_vendor_id"
                                v-model="eholding.vendor_id"
                            >
                                <option value=""></option>
                                <option
                                    v-for="vendor in vendors"
                                    :key="vendor.vendor_id"
                                    :value="vendor.id"
                                    :selected="
                                        vendor.id == eholding.vendor_id
                                            ? true
                                            : false
                                    "
                                >
                                    {{ vendor.name }}
                                </option>
                            </select>
                        </li>

                        <li>
                            <label for="eholding_print_identifier">{{
                                $t("Print-format identifier:")
                            }}</label>
                            <input
                                id="eholding_print_identifier"
                                v-model="eholding.print_identifier"
                                :placeholder="$t('Print-format identifier')"
                            />
                        </li>

                        <li>
                            <label for="eholding_online_identifier">{{
                                $t("Online-format identifier:")
                            }}</label>
                            <input
                                id="eholding_online_identifier"
                                v-model="eholding.online_identifier"
                                :placeholder="$t('Online-format identifier')"
                            />
                        </li>

                        <li>
                            <label for="eholding_date_first_issue_online">{{
                                $t(
                                    "Date of first serial issue available online:"
                                )
                            }}</label>
                            <input
                                id="eholding_date_first_issue_online"
                                v-model="eholding.date_first_issue_online"
                                :placeholder="
                                    $t(
                                        'Date of first serial issue available online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_num_first_vol_online">{{
                                $t("Number of first volume available online:")
                            }}</label>
                            <input
                                id="eholding_num_first_vol_online"
                                v-model="eholding.num_first_vol_online"
                                :placeholder="
                                    $t(
                                        'Number of first volume available online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_num_first_issue_online">{{
                                $t("Number of first issue available online:")
                            }}</label>
                            <input
                                id="eholding_num_first_issue_online"
                                v-model="eholding.num_first_issue_online"
                                :placeholder="
                                    $t('Number of first issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_date_last_issue_online">{{
                                $t("Date of last issue available online:")
                            }}</label>
                            <input
                                id="eholding_date_last_issue_online"
                                v-model="eholding.date_last_issue_online"
                                :placeholder="
                                    $t('Date of last issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_num_last_vol_online">{{
                                $t("Number of last volume available online:")
                            }}</label>
                            <input
                                id="eholding_num_last_vol_online"
                                v-model="eholding.num_last_vol_online"
                                :placeholder="
                                    $t('Number of last volume available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_num_last_issue_online">{{
                                $t("Number of last issue available online:")
                            }}</label>
                            <input
                                id="eholding_num_last_issue_online"
                                v-model="eholding.num_last_issue_online"
                                :placeholder="
                                    $t('Number of last issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_title_url">{{
                                $t("Title-level URL:")
                            }}</label>
                            <input
                                id="eholding_title_url"
                                v-model="eholding.title_url"
                                :placeholder="$t('Title-level URL')"
                            />
                        </li>

                        <li>
                            <label for="eholding_first_author">{{
                                $t("First author:")
                            }}</label>
                            <input
                                id="eholding_first_author"
                                v-model="eholding.first_author"
                                :placeholder="$t('First author')"
                            />
                        </li>

                        <li>
                            <label for="eholding_title_id">{{
                                $t("Title identifier:")
                            }}</label>
                            <input
                                id="eholding_title_id"
                                v-model="eholding.title_id"
                                :placeholder="$t('Title identifier')"
                            />
                        </li>

                        <li>
                            <label for="eholding_embargo_info">{{
                                $t("Embargo information:")
                            }}</label>
                            <input
                                id="eholding_embargo_info"
                                v-model="eholding.embargo_info"
                                :placeholder="$t('Embargo information')"
                            />
                        </li>

                        <li>
                            <label for="eholding_coverage_depth">{{
                                $t("Coverage depth:")
                            }}</label>
                            <input
                                id="eholding_coverage_depth"
                                v-model="eholding.coverage_depth"
                                :placeholder="$t('Coverage depth')"
                            />
                        </li>

                        <li>
                            <label for="eholding_notes">{{
                                $t("Notes:")
                            }}</label>
                            <input
                                id="eholding_notes"
                                v-model="eholding.notes"
                                :placeholder="$t('Notes')"
                            />
                        </li>

                        <li>
                            <label for="eholding_publisher_name">{{
                                $t("Publisher name:")
                            }}</label>
                            <input
                                id="eholding_publisher_name"
                                v-model="eholding.publisher_name"
                                :placeholder="$t('Publisher name')"
                            />
                        </li>

                        <li>
                            <label for="eholding_publication_type">{{
                                $t("Publication type:")
                            }}</label>
                            <input
                                id="eholding_publication_type"
                                v-model="eholding.publication_type"
                                :placeholder="$t('Publication type')"
                            />
                        </li>

                        <li>
                            <label
                                for="eholding_date_monograph_published_print"
                                >{{
                                    $t(
                                        "Date the monograph is first published in print:"
                                    )
                                }}</label
                            >
                            <input
                                id="eholding_date_monograph_published_print"
                                v-model="
                                    eholding.date_monograph_published_print
                                "
                                :placeholder="
                                    $t(
                                        'Date the monograph is first published in print'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label
                                for="eholding_date_monograph_published_online"
                                >{{
                                    $t(
                                        "Date the monograph is first published online:"
                                    )
                                }}</label
                            >
                            <input
                                id="eholding_date_monograph_published_online"
                                v-model="
                                    eholding.date_monograph_published_online
                                "
                                :placeholder="
                                    $t(
                                        'Date the monograph is first published online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_monograph_volume">{{
                                $t("Number of volume for monograph:")
                            }}</label>
                            <input
                                id="eholding_monograph_volume"
                                v-model="eholding.monograph_volume"
                                :placeholder="
                                    $t('Number of volume for monograph')
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_monograph_edition">{{
                                $t("Edition of the monograph:")
                            }}</label>
                            <input
                                id="eholding_monograph_edition"
                                v-model="eholding.monograph_edition"
                                :placeholder="$t('Edition of the monograph')"
                            />
                        </li>

                        <li>
                            <label for="eholding_first_editor">{{
                                $t("First editor:")
                            }}</label>
                            <input
                                id="eholding_first_editor"
                                v-model="eholding.first_editor"
                                :placeholder="$t('First editor')"
                            />
                        </li>

                        <li>
                            <label for="eholding_parent_publication_title_id">{{
                                $t(
                                    "Title identifier of the parent publication:"
                                )
                            }}</label>
                            <input
                                id="eholding_parent_publication_title_id"
                                v-model="eholding.parent_publication_title_id"
                                :placeholder="
                                    $t(
                                        'Title identifier of the parent publication'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label
                                for="eholding_preceeding_publication_title_id"
                                >{{
                                    $t(
                                        "Title identifier of any preceding publication title:"
                                    )
                                }}</label
                            >
                            <input
                                id="eholding_preceeding_publication_title_id"
                                v-model="
                                    eholding.preceeding_publication_title_id
                                "
                                :placeholder="
                                    $t(
                                        'Title identifier of any preceding publication title'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="eholding_access_type">{{
                                // FIXME May be fee-based (P) or Open Access (F).
                                $t("Access type:")
                            }}</label>
                            <input
                                id="eholding_access_type"
                                v-model="eholding.access_type"
                                :placeholder="$t('Access type')"
                            />
                        </li>

                        <EHoldingPackages
                            :eholding_packages="eholding.eholding_packages"
                        />
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input type="submit" value="Submit" />
                    <router-link
                        to="/cgi-bin/koha/erm/eholdings"
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
import { useVendorStore } from "../../stores/vendors"
import EHoldingPackages from "./EHoldingPackages.vue"
import { setMessage, setError } from "../../messages"
import { fetchEHolding } from '../../fetch'
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        return {
            vendors,
        }
    },
    data() {
        return {
            eholding: {
                eholding_id: null,
                vendor_id: null,
                publication_title: '',
                print_identifier: '',
                online_identifier: '',
                date_first_issue_online: '',
                num_first_vol_online: '',
                num_first_issue_online: '',
                date_last_issue_online: '',
                num_last_vol_online: '',
                num_last_issue_online: '',
                title_url: '',
                first_author: '',
                title_id: '',
                embargo_info: '',
                coverage_depth: '',
                notes: '',
                publisher_name: '',
                publication_type: '',
                date_monograph_published_print: '',
                date_monograph_published_online: '',
                monograph_volume: '',
                monograph_edition: '',
                first_editor: '',
                parent_publication_title_id: '',
                preceeding_publication_title_id: '',
                access_type: '',
                eholding_packages: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.eholding_id) {
                vm.eholding = vm.getEHolding(to.params.eholding_id)
            } else {
                vm.initialized = true
            }
        })
    },
    methods: {
        async getEHolding(eholding_id) {
            const eholding = await fetchEHolding(eholding_id)
            this.eholding = eholding
            this.initialized = true
        },
        onSubmit(e) {
            e.preventDefault()

            let eholding = JSON.parse(JSON.stringify(this.eholding)) // copy
            let apiUrl = '/api/v1/erm/eholdings'

            let method = 'POST'
            if (eholding.eholding_id) {
                method = 'PUT'
                apiUrl += '/' + eholding.eholding_id
            }
            delete eholding.eholding_id

            // Cannot use the map/keepAttrs because of the reserved keywork 'package'
            eholding.eholding_packages.forEach(function(e){ delete e.package });

            const options = {
                method: method,
                body: JSON.stringify(eholding),
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(response => {
                    if (response.status == 200) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings")
                        setMessage(this.$t("EHolding updated"))
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings")
                        setMessage(this.$t("EHolding created"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                }, (error) => {
                    setError(error)
                }).catch(e => { console.log(e) })
        },
    },
    components: { EHoldingPackages },
    name: "EHoldingsFormAdd",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>