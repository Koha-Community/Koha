<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="titles_add">
        <h2 v-if="title.title_id">
            {{ $__("Edit title #%s").format(title.title_id) }}
        </h2>
        <h2 v-else>{{ $__("New title") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li v-if="title.title_id">
                            <label for="title_title_id"
                                >{{ $__("Title identifier") }}:</label
                            >
                            <span>
                                {{ title.title_id }}
                            </span>
                        </li>

                        <li>
                            <label class="required" for="title_name"
                                >{{ $__("Publication title") }}:</label
                            >
                            <input
                                id="title_publication_title"
                                v-model="title.publication_title"
                                :placeholder="$__('Publication title')"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>

                        <li>
                            <label for="title_print_identifier"
                                >{{ $__("Print-format identifier") }}:</label
                            >
                            <input
                                id="title_print_identifier"
                                v-model="title.print_identifier"
                                :placeholder="$__('Print-format identifier')"
                            />
                        </li>

                        <li>
                            <label for="title_online_identifier"
                                >{{ $__("Online-format identifier") }}:</label
                            >
                            <input
                                id="title_online_identifier"
                                v-model="title.online_identifier"
                                :placeholder="$__('Online-format identifier')"
                            />
                        </li>

                        <li>
                            <label for="title_date_first_issue_online"
                                >{{
                                    $__(
                                        "Date of first serial issue available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_date_first_issue_online"
                                v-model="title.date_first_issue_online"
                                :placeholder="
                                    $__(
                                        'Date of first serial issue available online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_first_vol_online"
                                >{{
                                    $__(
                                        "Number of first volume available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_num_first_vol_online"
                                v-model="title.num_first_vol_online"
                                :placeholder="
                                    $__(
                                        'Number of first volume available online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_first_issue_online"
                                >{{
                                    $__(
                                        "Number of first issue available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_num_first_issue_online"
                                v-model="title.num_first_issue_online"
                                :placeholder="
                                    $__('Number of first issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_date_last_issue_online"
                                >{{
                                    $__("Date of last issue available online")
                                }}:</label
                            >
                            <input
                                id="title_date_last_issue_online"
                                v-model="title.date_last_issue_online"
                                :placeholder="
                                    $__('Date of last issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_last_vol_online"
                                >{{
                                    $__(
                                        "Number of last volume available online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_num_last_vol_online"
                                v-model="title.num_last_vol_online"
                                :placeholder="
                                    $__('Number of last volume available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_num_last_issue_online"
                                >{{
                                    $__("Number of last issue available online")
                                }}:</label
                            >
                            <input
                                id="title_num_last_issue_online"
                                v-model="title.num_last_issue_online"
                                :placeholder="
                                    $__('Number of last issue available online')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_title_url"
                                >{{ $__("Title-level URL") }}:</label
                            >
                            <input
                                id="title_title_url"
                                v-model="title.title_url"
                                :placeholder="$__('Title-level URL')"
                            />
                        </li>

                        <li>
                            <label for="title_first_author"
                                >{{ $__("First author") }}:</label
                            >
                            <input
                                id="title_first_author"
                                v-model="title.first_author"
                                :placeholder="$__('First author')"
                            />
                        </li>

                        <li>
                            <label for="title_embargo_info"
                                >{{ $__("Embargo information") }}:</label
                            >
                            <input
                                id="title_embargo_info"
                                v-model="title.embargo_info"
                                :placeholder="$__('Embargo information')"
                            />
                        </li>

                        <li>
                            <label for="title_coverage_depth"
                                >{{ $__("Coverage depth") }}:</label
                            >
                            <input
                                id="title_coverage_depth"
                                v-model="title.coverage_depth"
                                :placeholder="$__('Coverage depth')"
                            />
                        </li>

                        <li>
                            <label for="title_notes">{{ $__("Notes") }}:</label>
                            <input
                                id="title_notes"
                                v-model="title.notes"
                                :placeholder="$__('Notes')"
                            />
                        </li>

                        <li>
                            <label for="title_publisher_name"
                                >{{ $__("Publisher name") }}:</label
                            >
                            <input
                                id="title_publisher_name"
                                v-model="title.publisher_name"
                                :placeholder="$__('Publisher name')"
                            />
                        </li>

                        <li>
                            <label for="title_publication_type"
                                >{{ $__("Publication type") }}:</label
                            >
                            <v-select
                                id="title_publication_type"
                                v-model="title.publication_type"
                                label="lib"
                                :reduce="(av) => av.authorised_value"
                                :options="av_title_publication_types"
                            />
                        </li>

                        <li>
                            <label for="title_date_monograph_published_print"
                                >{{
                                    $__(
                                        "Date the monograph is first published in print"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_date_monograph_published_print"
                                v-model="title.date_monograph_published_print"
                                :placeholder="
                                    $__(
                                        'Date the monograph is first published in print'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_date_monograph_published_online"
                                >{{
                                    $__(
                                        "Date the monograph is first published online"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_date_monograph_published_online"
                                v-model="title.date_monograph_published_online"
                                :placeholder="
                                    $__(
                                        'Date the monograph is first published online'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_monograph_volume"
                                >{{
                                    $__("Number of volume for monograph")
                                }}:</label
                            >
                            <input
                                id="title_monograph_volume"
                                v-model="title.monograph_volume"
                                :placeholder="
                                    $__('Number of volume for monograph')
                                "
                            />
                        </li>

                        <li>
                            <label for="title_monograph_edition"
                                >{{ $__("Edition of the monograph") }}:</label
                            >
                            <input
                                id="title_monograph_edition"
                                v-model="title.monograph_edition"
                                :placeholder="$__('Edition of the monograph')"
                            />
                        </li>

                        <li>
                            <label for="title_first_editor"
                                >{{ $__("First editor") }}:</label
                            >
                            <input
                                id="title_first_editor"
                                v-model="title.first_editor"
                                :placeholder="$__('First editor')"
                            />
                        </li>

                        <li>
                            <label for="title_parent_publication_title_id"
                                >{{
                                    $__(
                                        "Title identifier of the parent publication"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_parent_publication_title_id"
                                v-model="title.parent_publication_title_id"
                                :placeholder="
                                    $__(
                                        'Title identifier of the parent publication'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_preceeding_publication_title_id"
                                >{{
                                    $__(
                                        "Title identifier of any preceding publication title"
                                    )
                                }}:</label
                            >
                            <input
                                id="title_preceeding_publication_title_id"
                                v-model="title.preceeding_publication_title_id"
                                :placeholder="
                                    $__(
                                        'Title identifier of any preceding publication title'
                                    )
                                "
                            />
                        </li>

                        <li>
                            <label for="title_access_type"
                                >{{
                                    // FIXME May be fee-based (P) or Open Access (F).
                                    $__("Access type")
                                }}:</label
                            >
                            <input
                                id="title_access_type"
                                v-model="title.access_type"
                                :placeholder="$__('Access type')"
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
                        to="/cgi-bin/koha/erm/eholdings/local/titles"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import { inject } from 'vue'
import EHoldingsTitlesFormAddResources from "./EHoldingsLocalTitlesFormAddResources.vue"
import { setMessage, setError, setWarning } from "../../messages"
import { fetchLocalTitle } from '../../fetch'
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = inject('vendorStore')
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject('AVStore')
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
            const title = await fetchLocalTitle(title_id)
            this.title = title
            this.initialized = true
        },
        checkForm(title) {
            let errors = []

            let resources = title.resources
            const package_ids = resources.map(al => al.package_id)
            const duplicate_package_ids = package_ids.filter((id, i) => package_ids.indexOf(id) !== i)

            if (duplicate_package_ids.length) {
                errors.push(this.$__("A package is used several times"))
            }

            errors.forEach(function (e) {
                setWarning(e)
            })
            return !errors.length
        },
        onSubmit(e) {
            e.preventDefault()

            let title = JSON.parse(JSON.stringify(this.title)) // copy

            if (!this.checkForm(title)) {
                return false
            }
            let apiUrl = '/api/v1/erm/eholdings/local/titles'

            let method = 'POST'
            if (title.title_id) {
                method = 'PUT'
                apiUrl += '/' + title.title_id
            }
            delete title.title_id
            delete title.biblio_id

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
                        this.$router.push("/cgi-bin/koha/erm/eholdings/local/titles")
                        setMessage(this.$__("Title updated"))
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/eholdings/local/titles")
                        setMessage(this.$__("Title created"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                }, (error) => {
                    setError(error)
                }).catch(e => { console.log(e) })
        },
    },
    components: { EHoldingsTitlesFormAddResources },
    name: "EHoldingsLocalTitlesFormAdd",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
