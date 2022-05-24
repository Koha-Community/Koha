<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else id="eholdings_show">
        <h2>
            {{ $t("EHolding.id", { id: eholding.eholding_id }) }}
            <span class="action_links">
                <router-link
                    :to="`/cgi-bin/koha/erm/eholdings/edit/${eholding.eholding_id}`"
                    :title="$t('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>

                <router-link
                    :to="`/cgi-bin/koha/erm/eholdings/delete/${eholding.eholding_id}`"
                    :title="$t('Delete')"
                    ><i class="fa fa-trash"></i
                ></router-link>
            </span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $t("Publication title:") }}</label>
                        <span>
                            {{ eholding.publication_title }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Print-format identifier:") }}</label>
                        <span>
                            {{ eholding.print_identifier }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Online-format identifier:") }}</label>
                        <span>
                            {{ eholding.online_identifier }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Date of first serial issue available online:") }}</label>
                        <span>
                            {{ eholding.date_first_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Number of first volume available online:") }}</label>
                        <span>
                            {{ eholding.num_first_vol_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Number of first issue available online:") }}</label>
                        <span>
                            {{ eholding.num_first_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Date of last issue available online:") }}</label>
                        <span>
                            {{ eholding.date_last_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Number of last volume available online:") }}</label>
                        <span>
                            {{ eholding.num_last_vol_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Number of last issue available online:") }}</label>
                        <span>
                            {{ eholding.num_last_issue_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Title-level URL:") }}</label>
                        <span>
                            {{ eholding.title_url }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("First author:") }}</label>
                        <span>
                            {{ eholding.first_author }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Title identifier:") }}</label>
                        <span>
                            {{ eholding.title_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Embargo information:") }}</label>
                        <span>
                            {{ eholding.embargo_info }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Coverage depth:") }}</label>
                        <span>
                            {{ eholding.coverage_depth }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Notes:") }}</label>
                        <span>
                            {{ eholding.notes }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publisher name:") }}</label>
                        <span>
                            {{ eholding.publisher_name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publication type:") }}</label>
                        <span>
                            {{ eholding.publication_type }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Date the monograph is first published in print:") }}</label>
                        <span>
                            {{ eholding.date_monograph_published_print }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Date the monograph is first published online:") }}</label>
                        <span>
                            {{ eholding.date_monograph_published_online }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Number of volume for monograph:") }}</label>
                        <span>
                            {{ eholding.monograph_volume }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Edition of the monograph:") }}</label>
                        <span>
                            {{ eholding.monograph_edition }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("First editor:") }}</label>
                        <span>
                            {{ eholding.first_editor }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Title identifier of the parent publication:") }}</label>
                        <span>
                            {{ eholding.parent_publication_title_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Title identifier of any preceding publication title:") }}</label>
                        <span>
                            {{ eholding.preceeding_publication_title_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Acces type:") }}</label>
                        <span>
                            {{ eholding.access_type }}
                        </span>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/erm/eholdings"
                    role="button"
                    class="cancel"
                    >{{ $t("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { fetchEHolding } from "../../fetch"

export default {
    setup() {
    },
    data() {
        return {
            eholding: {
                eholding_id: null,
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
            },
            initialized: false,
        }
    },

    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getEHolding(to.params.eholding_id)
            vm.initialized = true
        })
    },
    beforeRouteUpdate(to, from) {
        this.eholding = this.getEHolding(to.params.eholding_id)
    },
    methods: {
        async getEHolding(eholding_id) {
            const eholding = await fetchEHolding(eholding_id)
            this.eholding = eholding
        },
    },
    name: "EHoldingsShow",
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