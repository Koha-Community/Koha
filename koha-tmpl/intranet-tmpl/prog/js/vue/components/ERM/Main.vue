<template>
    <div v-if="initialized && sysprefs.ERMModule == 1">
        <div id="sub-header">
            <Breadcrumbs />
            <Help />
        </div>
        <div class="main container-fluid">
            <div class="row">
                <div class="col-sm-10 col-sm-push-2">
                    <main>
                        <Dialog />
                        <router-view />
                    </main>
                </div>

                <div class="col-sm-2 col-sm-pull-10">
                    <LeftMenu
                        :title="$__('E-resource management')"
                        :condition="filterProviders"
                    ></LeftMenu>
                </div>
            </div>
        </div>
    </div>
    <div class="main container-fluid" v-else>
        <Dialog />
    </div>
</template>

<script>
import { inject } from "vue"
import Breadcrumbs from "../Breadcrumbs.vue"
import Help from "../Help.vue"
import LeftMenu from "../LeftMenu.vue"
import Dialog from "../Dialog.vue"
import { APIClient } from "../../fetch/api-client.js"
import "vue-select/dist/vue-select.css"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = inject("vendorStore")

        const AVStore = inject("AVStore")

        const mainStore = inject("mainStore")

        const { loading, loaded, setError } = mainStore

        const ERMStore = inject("ERMStore")

        const { sysprefs } = storeToRefs(ERMStore)

        return {
            vendorStore,
            AVStore,
            ERMStore,
            sysprefs,
            setError,
            loading,
            loaded,
        }
    },
    data() {
        return {
            component: "agreement",
            initialized: false,
        }
    },
    beforeCreate() {
        this.loading()

        const fetch_config = () => {
            let promises = []

            const acq_client = APIClient.acquisition
            acq_client.vendors.getAll().then(
                vendors => {
                    this.vendorStore.vendors = vendors.map(v => ({
                        ...v,
                        display_name:
                            v.name +
                            (v.aliases.length > 0
                                ? " (" +
                                  v.aliases.map(a => a.alias).join(", ") +
                                  ")"
                                : ""),
                    }))
                },
                error => {}
            )

            const av_client = APIClient.authorised_values
            const authorised_values = {
                av_agreement_statuses: "ERM_AGREEMENT_STATUS",
                av_agreement_closure_reasons: "ERM_AGREEMENT_CLOSURE_REASON",
                av_agreement_renewal_priorities:
                    "ERM_AGREEMENT_RENEWAL_PRIORITY",
                av_user_roles: "ERM_USER_ROLES",
                av_license_types: "ERM_LICENSE_TYPE",
                av_license_statuses: "ERM_LICENSE_STATUS",
                av_agreement_license_statuses: "ERM_AGREEMENT_LICENSE_STATUS",
                av_agreement_license_location: "ERM_AGREEMENT_LICENSE_LOCATION",
                av_package_types: "ERM_PACKAGE_TYPE",
                av_package_content_types: "ERM_PACKAGE_CONTENT_TYPE",
                av_title_publication_types: "ERM_TITLE_PUBLICATION_TYPE",
            }

            let av_cat_array = Object.keys(authorised_values).map(function (
                av_cat
            ) {
                return '"' + authorised_values[av_cat] + '"'
            })

            promises.push(
                av_client.values
                    .getCategoriesWithValues(av_cat_array)
                    .then(av_categories => {
                        Object.entries(authorised_values).forEach(
                            ([av_var, av_cat]) => {
                                const av_match = av_categories.find(
                                    element => element.category_name == av_cat
                                )
                                this.AVStore[av_var] =
                                    av_match.authorised_values
                            }
                        )
                    })
            )

            promises.push(
                sysprefs_client.sysprefs.get("ERMProviders").then(
                    providers => {
                        this.sysprefs.ERMProviders = providers.value.split(",")
                    },
                    error => {}
                )
            )
            return Promise.all(promises)
        }

        const sysprefs_client = APIClient.sysprefs
        sysprefs_client.sysprefs
            .get("ERMModule")
            .then(value => {
                this.sysprefs.ERMModule = value.value
                if (this.sysprefs.ERMModule != 1) {
                    return this.setError(
                        this.$__(
                            'The e-resource management module is disabled, turn on <a href="/cgi-bin/koha/admin/preferences.pl?tab=&op=search&searchfield=ERMModule">ERMModule</a> to use it'
                        ),
                        false
                    )
                }
                return fetch_config()
            })
            .then(() => {
                this.loaded()
                this.initialized = true
            })
    },
    methods: {
        async filterProviders(navigationTree) {
            const eHoldings = navigationTree.find(
                element => element.path === "/cgi-bin/koha/erm/eholdings"
            )
            const providers = this.sysprefs.ERMProviders
            eHoldings.children = eHoldings.children.filter(element =>
                providers
                    .map(provider => `${eHoldings.path}/${provider}`)
                    .includes(element.path)
            )
            return navigationTree
        },
    },
    components: {
        Breadcrumbs,
        Dialog,
        Help,
        LeftMenu,
    },
}
</script>

<style>
#menu ul ul,
#navmenulist ul ul {
    padding-left: 2em;
    font-size: 100%;
}

form .v-select {
    display: inline-block;
    background-color: white;
    width: 30%;
}

.v-select,
input:not([type="submit"]):not([type="search"]):not([type="button"]):not([type="checkbox"]):not([type="radio"]),
textarea {
    border-color: rgba(60, 60, 60, 0.26);
    border-width: 1px;
    border-radius: 4px;
    min-width: 30%;
}
.flatpickr-input {
    width: 30%;
}
#navmenulist ul li a.current.disabled {
    background-color: inherit;
    border-left: 5px solid #e6e6e6;
    color: #000;
}
#navmenulist ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
</style>
