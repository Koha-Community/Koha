<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else id="titles_add">
        <h2 v-if="title.title_id">
            {{ $t("Edit title .id", { id: title.title_id }) }}
        </h2>
        <h2 v-else>{{ $t("New title") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li v-if="title.title_id">
                            <label for="title_title_id"
                                >{{ $t("Title identifier") }}:</label
                            >
                            <input
                                id="title_title_id"
                                v-model="title.title_id"
                                :placeholder="$t('Title identifier')"
                            />
                        </li>

                        <li>
                            <label class="required" for="title_name"
                                >{{ $t("Publication title") }}:</label
                            >
                            <input
                                id="title_publication_title"
                                v-model="title.publication_title"
                                :placeholder="$t('Publication title')"
                                required
                            />
                            <span class="required">{{ $t("Required") }}</span>
                        </li>

                        <li>
                            <label for="title_print_identifier"
                                >{{ $t("Print-format identifier") }}:</label
                            >
                            <input
                                id="title_print_identifier"
                                v-model="title.print_identifier"
                                :placeholder="$t('Print-format identifier')"
                            />
                        </li>

                        <li>
                            <label for="title_online_identifier"
                                >{{ $t("Online-format identifier") }}:</label
                            >
                            <input
                                id="title_online_identifier"
                                v-model="title.online_identifier"
                                :placeholder="$t('Online-format identifier')"
                            />
                        </li>

                        <li>
                            <label for="title_date_first_issue_online"
                                >{{
                                    $t(
                                        "Date of first serial issue available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_date_first_issue_online"
                                v-model="title.date_first_issue_online"
                                :placeholder="
                                    $t(
                                        'Date of first serial issue available online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_first_vol_online"
                                >{{
                                    $t(
                                        "Number of first volume available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_num_first_vol_online"
                                v-model="title.num_first_vol_online"
                                :placeholder="
                                    $t(
                                        'Number of first volume available online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_first_issue_online"
                                >{{
                                    $t(
                                        "Number of first issue available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_num_first_issue_online"
                                v-model="title.num_first_issue_online"
                                :placeholder="
                                    $t('Number of first issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_date_last_issue_online"
                                >{{
                                    $t("Date of last issue available online")
                                }}:</label
                            >
                            <input
                                id="title_date_last_issue_online"
                                v-model="title.date_last_issue_online"
                                :placeholder="
                                    $t('Date of last issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_last_vol_online"
                                >{{
                                    $t(
                                        "Number of last volume available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_num_last_vol_online"
                                v-model="title.num_last_vol_online"
                                :placeholder="
                                    $t('Number of last volume available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_last_issue_online"
                                >{{
                                    $t("Number of last issue available online")
                                }}:</label
                            >
                            <input
                                id="title_num_last_issue_online"
                                v-model="title.num_last_issue_online"
                                :placeholder="
                                    $t('Number of last issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_title_url"
                                >{{ $t("Title-level URL") }}:</label
                            >
                            <input
                                id="title_title_url"
                                v-model="title.title_url"
                                :placeholder="$t('Title-level URL')"
                            />
                        </li>

                        <li>
                            <label for="title_first_author"
                                >{{ $t("First author") }}:</label
                            >
                            <input
                                id="title_first_author"
                                v-model="title.first_author"
                                :placeholder="$t('First author')"
                            />
                        </li>

                        <li>
                            <label for="title_embargo_info"
                                >{{ $t("Embargo information") }}:</label
                            >
                            <input
                                id="title_embargo_info"
                                v-model="title.embargo_info"
                                :placeholder="$t('Embargo information')"
                            />
                        </li>

                        <li>
                            <label for="title_coverage_depth"
                                >{{ $t("Coverage depth") }}:</label
                            >
                            <input
                                id="title_coverage_depth"
                                v-model="title.coverage_depth"
                                :placeholder="$t('Coverage depth')"
                            />
                        </li>

                        <li>
                            <label for="title_notes">{{ $t("Notes") }}:</label>
                            <input
                                id="title_notes"
                                v-model="title.notes"
                                :placeholder="$t('Notes')"
                            />
                        </li>

                        <li>
                            <label for="title_publisher_name"
                                >{{ $t("Publisher name") }}:</label
                            >
                            <input
                                id="title_publisher_name"
                                v-model="title.publisher_name"
                                :placeholder="$t('Publisher name')"
                            />
                        </li>

                        <li>
                            <label for="title_publication_type"
                                >{{ $t("Publication type") }}:</label
                            >
                            <select
                                id="title_publication_type"
                                v-model="title.publication_type"
                            >
                                <option value=""></option>
                                <option
                                    v-for="type in av_title_publication_types"
                                    :key="type.authorised_values"
                                    :value="type.authorised_value"
                                    :selected="
                                        type.authorised_value ==
                                        title.publication_type
                                            ? true
                                            : false
                                    "
                                >
                                    {{ type.lib }}
                                </option>
                            </select>
                        </li>

                        <li>
                            <label for="title_date_monograph_published_print"
                                >{{
                                    $t(
                                        "Date the monograph is first published in print"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_date_monograph_published_print"
                                v-model="title.date_monograph_published_print"
                                :placeholder="
                                    $t(
                                        'Date the monograph is first published in print'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_date_monograph_published_online"
                                >{{
                                    $t(
                                        "Date the monograph is first published online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_date_monograph_published_online"
                                v-model="title.date_monograph_published_online"
                                :placeholder="
                                    $t(
                                        'Date the monograph is first published online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_monograph_volume"
                                >{{
                                    $t("Number of volume for monograph")
                                }}:</label
                            >
                            <input
                                id="title_monograph_volume"
                                v-model="title.monograph_volume"
                                :placeholder="
                                    $t('Number of volume for monograph')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_monograph_edition"
                                >{{ $t("Edition of the monograph") }}:</label
                            >
                            <input
                                id="title_monograph_edition"
                                v-model="title.monograph_edition"
                                :placeholder="$t('Edition of the monograph')"
                            />
                        </li>

                        <li>
                            <label for="title_first_editor"
                                >{{ $t("First editor") }}:</label
                            >
                            <input
                                id="title_first_editor"
                                v-model="title.first_editor"
                                :placeholder="$t('First editor')"
                            />
                        </li>

                        <li>
                            <label for="title_parent_publication_title_id"
                                >{{
                                    $t(
                                        "Title identifier of the parent publication"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_parent_publication_title_id"
                                v-model="title.parent_publication_title_id"
                                :placeholder="
                                    $t(
                                        'Title identifier of the parent publication'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_preceeding_publication_title_id"
                                >{{
                                    $t(
                                        "Title identifier of any preceding publication title"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_preceeding_publication_title_id"
                                v-model="title.preceeding_publication_title_id"
                                :placeholder="
                                    $t(
                                        'Title identifier of any preceding publication title'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_access_type"
                                >{{
                                    // FIXME May be fee-based (P) or Open Access (F).
                                    $t("Access type")
                                }}:</label
                            >
                            <input
                                id="title_access_type"
                                v-model="title.access_type"
                                :placeholder="$t('Access type')"
                            />
                        </li>

                        <EHoldingsTitlesFormAddResources
                            :resources="title.resources"
                        />
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input type="submit" value="Submit" />
                    <router-link
                        to="/cgi-bin/koha/erm/eholdings/titles"
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
import { useAVStore } from "../../stores/authorised_values"
import EHoldingsTitlesFormAddResources from "./EHoldingsTitlesFormAddResources.vue"
import { setMessage, setError } from "../../messages"
import { fetchTitle } from '../../fetch'
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av } = AVStore

        return {
            vendors,
            av_title_publication_types,
            get_lib_from_av,
        }
    },
    data() {
        return {
            title: {
                title_id: null,
                publication_title: '',
                external_id: '',
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
                resources: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.title_id) {
                vm.title = vm.getTitle(to.params.title_id)
            } else {
                vm.initialized = true
            }
        })
    },
    methods: {
        async getTitle(title_id) {
            const title = await fetchTitle(title_id)
            this.title = title
            this.initialized = true
        },
        onSubmit(e) {
            e.preventDefault()

            let title = JSON.parse(JSON.stringify(this.title)) // copy
            let apiUrl = '/api/v1/erm/eholdings/titles'

            let method = 'POST'
            if (title.title_id) {
                method = 'PUT'
                apiUrl += '/' + title.title_id
            }
            delete title.title_id
            delete title.biblio_id

            title.resources.forEach(r => {
                r.started_on = r.started_on ? $date_to_rfc3339(r.started_on) : null
                r.ended_on = r.ended_on ? $date_to_rfc3339(r.ended_on) : null
            })

            // Cannot use the map/keepAttrs because of the reserved keywork 'package'
            title.resources.forEach(function (e) { delete e.package; delete e.resource_id })

            const options = {
                method: method,
                body: JSON.stringify(title),
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(response => {
                    if (response.status == 200) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/titles")
                        setMessage(this.$t("Title updated"))
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/titles")
                        setMessage(this.$t("Title created"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                }, (error) => {
                    setError(error)
                }).catch(e => { console.log(e) })
        },
    },
    components: { EHoldingsTitlesFormAddResources },
    name: "EHoldingsTitlesFormAdd",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
