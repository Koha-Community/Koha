<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else id="eholdings_title_show">
        <h2>
            {{ $t("Title .id", { id: title.title_id }) }}
            <span class="action_links">
                <router-link
                    :to="`/cgi-bin/koha/erm/eholdings/titles/edit/${title.title_id}`"
                    :title="$t('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>

                <router-link
                    :to="`/cgi-bin/koha/erm/eholdings/titles/delete/${title.title_id}`"
                    :title="$t('Delete')"
                    ><i class="fa fa-trash"></i
                ></router-link>
            </span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li v-if="title.title_id">
                        <label
                            >{{ $t("Title identifier") }}:</label
                        >
                        <span>
                            {{ title.title_id}}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publication title") }}:</label>
                        <span>
                            {{ title.publication_title }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Vendor") }}:</label>
                        <span v-if="title.vendor_id">
                            {{
                                vendors.find((e) => e.id == title.vendor_id)
                                    .name
                            }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Print-format identifier") }}:</label>
                        <span>
                            {{ title.print_identifier }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Online-format identifier") }}:</label>
                        <span>
                            {{ title.online_identifier }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t(
                                    "Date of first serial issue available online"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.date_first_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t("Number of first volume available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_first_vol_online }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t("Number of first issue available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_first_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t("Date of last issue available online")
                            }}:</label
                        >
                        <span>
                            {{ title.date_last_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t("Number of last volume available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_last_vol_online }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t("Number of last issue available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_last_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Title-level URL") }}:</label>
                        <span>
                            {{ title.title_url }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("First author") }}:</label>
                        <span>
                            {{ title.first_author }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Embargo information") }}:</label>
                        <span>
                            {{ title.embargo_info }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Coverage depth") }}:</label>
                        <span>
                            {{ title.coverage_depth }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Notes") }}:</label>
                        <span>
                            {{ title.notes }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publisher name") }}:</label>
                        <span>
                            {{ title.publisher_name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publication type") }}:</label>
                        <span>
                            {{ title.publication_type }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t(
                                    "Date the monograph is first published in print"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.date_monograph_published_print }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t(
                                    "Date the monograph is first published online"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.date_monograph_published_online }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{ $t("Number of volume for monograph") }}:</label
                        >
                        <span>
                            {{ title.monograph_volume }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Edition of the monograph") }}:</label>
                        <span>
                            {{ title.monograph_edition }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("First editor") }}:</label>
                        <span>
                            {{ title.first_editor }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t(
                                    "Title identifier of the parent publication"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.parent_publication_title_id }}
                        </span>
                    </li>
                    <li>
                        <label
                            >{{
                                $t(
                                    "Title identifier of any preceding publication title"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.preceeding_publication_title_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Acces type") }}:</label>
                        <span>
                            {{ title.access_type }}
                        </span>
                    </li>

                    <li v-if="title.resources.length">
                        <label>{{ $t("Packages") }}</label>
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
                                    ) in title.resources"
                                    v-bind:key="counter"
                                >
                                    <td>
                                        <router-link
                                            :to="`/cgi-bin/koha/erm/eholdings/packages/${r.package_id}`"
                                            :title="$t('Show package')"
                                        >
                                            {{ r.package.name }}
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
                    to="/cgi-bin/koha/erm/eholdings/titles"
                    role="button"
                    class="cancel"
                    >{{ $t("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { fetchTitle } from "../../fetch"
import { useVendorStore } from "../../stores/vendors"
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
            title: {
                title_id: null,
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
            vm.getTitle(to.params.title_id)
        })
    },
    beforeRouteUpdate(to, from) {
        this.title = this.getTitle(to.params.title_id)
    },
    methods: {
        async getTitle(title_id) {
            const title= await fetchTitle(title_id)
            this.title = title
            this.initialized = true
        },
    },
    name: "EHoldingsTitlesShow",
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
}
fieldset.rows label {
    width: 25rem;
}
</style>
