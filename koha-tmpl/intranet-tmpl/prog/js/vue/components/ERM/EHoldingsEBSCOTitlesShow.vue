<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="title" id="eholdings_title_show">
        <h2>
            {{ $__("Title #%s").format(title.title_id) }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li v-if="title.title_id">
                        <label>{{ $__("Title identifier") }}:</label>
                        <span>
                            {{ title.title_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Publication title") }}:</label>
                        <span>
                            {{ title.publication_title }}
                            <a
                                v-if="title.biblio_id"
                                :href="`/cgi-bin/koha/catalogue/detail.pl?biblionumber=${title.biblio_id}`"
                            >
                                {{ $__("Local bibliographic record") }}
                            </a>
                        </span>
                    </li>
                    <li v-if="title.print_identifier">
                        <label>{{ $__("Print-format identifier") }}:</label>
                        <span>
                            {{ title.print_identifier }}
                        </span>
                    </li>
                    <li v-if="title.online_identifier">
                        <label>{{ $__("Online-format identifier") }}:</label>
                        <span>
                            {{ title.online_identifier }}
                        </span>
                    </li>
                    <li v-if="title.date_first_issue_online">
                        <label
                            >{{
                                $__(
                                    "Date of first serial issue available online"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.date_first_issue_online }}
                        </span>
                    </li>
                    <li v-if="title.num_first_vol_online">
                        <label
                            >{{
                                $__("Number of first volume available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_first_vol_online }}
                        </span>
                    </li>
                    <li v-if="title.num_first_issue_online">
                        <label
                            >{{
                                $__("Number of first issue available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_first_issue_online }}
                        </span>
                    </li>
                    <li v-if="title.date_last_issue_online">
                        <label
                            >{{
                                $__("Date of last issue available online")
                            }}:</label
                        >
                        <span>
                            {{ title.date_last_issue_online }}
                        </span>
                    </li>
                    <li v-if="title.num_last_vol_online">
                        <label
                            >{{
                                $__("Number of last volume available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_last_vol_online }}
                        </span>
                    </li>
                    <li v-if="title.num_last_issue_online">
                        <label
                            >{{
                                $__("Number of last issue available online")
                            }}:</label
                        >
                        <span>
                            {{ title.num_last_issue_online }}
                        </span>
                    </li>
                    <li v-if="title.title_url">
                        <label>{{ $__("Title-level URL") }}:</label>
                        <span>
                            {{ title.title_url }}
                        </span>
                    </li>
                    <li v-if="title.first_author">
                        <label>{{ $__("First author") }}:</label>
                        <span>
                            {{ title.first_author }}
                        </span>
                    </li>
                    <li v-if="title.embargo_info">
                        <label>{{ $__("Embargo information") }}:</label>
                        <span>
                            {{ title.embargo_info }}
                        </span>
                    </li>
                    <li v-if="title.coverage_depth">
                        <label>{{ $__("Coverage depth") }}:</label>
                        <span>
                            {{ title.coverage_depth }}
                        </span>
                    </li>
                    <li v-if="title.notes">
                        <label>{{ $__("Notes") }}:</label>
                        <span>
                            {{ title.notes }}
                        </span>
                    </li>
                    <li v-if="title.publisher_name">
                        <label>{{ $__("Publisher name") }}:</label>
                        <span>
                            {{ title.publisher_name }}
                        </span>
                    </li>
                    <li v-if="title.publication_type">
                        <label>{{ $__("Publication type") }}:</label>
                        <span
                            >{{
                                get_lib_from_av(
                                    "av_title_publication_types",
                                    title.publication_type
                                )
                            }}
                        </span>
                    </li>
                    <li v-if="title.date_monograph_published_print">
                        <label
                            >{{
                                $__(
                                    "Date the monograph is first published in print"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.date_monograph_published_print }}
                        </span>
                    </li>
                    <li v-if="title.date_monograph_published_online">
                        <label
                            >{{
                                $__(
                                    "Date the monograph is first published online"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.date_monograph_published_online }}
                        </span>
                    </li>
                    <li v-if="title.monograph_volume">
                        <label
                            >{{ $__("Number of volume for monograph") }}:</label
                        >
                        <span>
                            {{ title.monograph_volume }}
                        </span>
                    </li>
                    <li v-if="title.monograph_edition">
                        <label>{{ $__("Edition of the monograph") }}:</label>
                        <span>
                            {{ title.monograph_edition }}
                        </span>
                    </li>
                    <li v-if="title.first_editor">
                        <label>{{ $__("First editor") }}:</label>
                        <span>
                            {{ title.first_editor }}
                        </span>
                    </li>
                    <li v-if="title.parent_publication_title_id">
                        <label
                            >{{
                                $__(
                                    "Title identifier of the parent publication"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.parent_publication_title_id }}
                        </span>
                    </li>
                    <li v-if="title.preceding_publication_title_id">
                        <label
                            >{{
                                $__(
                                    "Title identifier of any preceding publication title"
                                )
                            }}:</label
                        >
                        <span>
                            {{ title.preceding_publication_title_id }}
                        </span>
                    </li>
                    <li v-if="title.access_type">
                        <label>{{ $__("Access type") }}:</label>
                        <span>
                            {{ title.access_type }}
                        </span>
                    </li>
                    <li>
                        <label>Packages ({{ title.resources.length }})</label>
                        <div v-if="title.resources.length">
                            <EHoldingsTitlePackagesList
                                :resources="title.resources"
                            />
                        </div>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    :to="{ name: 'EHoldingsEBSCOTitlesList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject } from "vue";
import EHoldingsTitlePackagesList from "./EHoldingsEBSCOTitlePackagesList.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    setup() {
        const ERMStore = inject("ERMStore");
        const { get_lib_from_av } = ERMStore;

        return {
            get_lib_from_av,
        };
    },
    data() {
        return {
            title: {
                title_id: null,
                publication_title: "",
                external_id: "",
                print_identifier: "",
                online_identifier: "",
                date_first_issue_online: "",
                num_first_vol_online: "",
                num_first_issue_online: "",
                date_last_issue_online: "",
                num_last_vol_online: "",
                num_last_issue_online: "",
                title_url: "",
                first_author: "",
                embargo_info: "",
                coverage_depth: "",
                notes: "",
                publisher_name: "",
                publication_type: "",
                date_monograph_published_print: "",
                date_monograph_published_online: "",
                monograph_volume: "",
                monograph_edition: "",
                first_editor: "",
                parent_publication_title_id: "",
                preceding_publication_title_id: "",
                access_type: "",
                resources: [],
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTitle(to.params.title_id);
        });
    },
    beforeRouteUpdate(to, from) {
        this.title = this.getTitle(to.params.title_id);
    },
    methods: {
        getTitle(title_id) {
            const client = APIClient.erm;
            client.EBSCOTitles.get(title_id).then(
                title => {
                    this.title = title;
                    this.initialized = true;
                },
                error => {}
            );
        },
    },
    components: {
        EHoldingsTitlePackagesList,
    },
    name: "EHoldingsEBSCOTitlesShow",
};
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
