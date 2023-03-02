<template>
    <div v-if="ERMModule">
        <Breadcrumb />
        <div class="main container-fluid">
            <div class="row">
                <div class="col-sm-10 col-sm-push-2">
                    <main>
                        <Dialog />
                        <router-view />
                    </main>
                </div>

                <div class="col-sm-2 col-sm-pull-10">
                    <aside>
                        <div id="navmenu">
                            <div id="navmenulist">
                                <h5>{{ $__("E-resource management") }}</h5>
                                <ul>
                                    <li>
                                        <router-link
                                            to="/cgi-bin/koha/erm/agreements"
                                        >
                                            <i class="fa fa-check-circle-o"></i>
                                            {{ $__("Agreements") }}</router-link
                                        >
                                    </li>
                                    <li>
                                        <router-link
                                            to="/cgi-bin/koha/erm/licenses"
                                        >
                                            <i class="fa fa-gavel"></i>
                                            {{ $__("Licenses") }}</router-link
                                        >
                                    </li>
                                    <li>
                                        <router-link
                                            to="/cgi-bin/koha/erm/eholdings"
                                            class="disabled"
                                        >
                                            <i class="fa fa-crosshairs"></i>
                                            {{ $__("eHoldings") }}
                                        </router-link>
                                    </li>

                                    <li>
                                        <ul>
                                            <li
                                                v-for="provider in erm_providers"
                                                :key="provider"
                                            >
                                                <router-link
                                                    v-if="provider == 'local'"
                                                    :to="`/cgi-bin/koha/erm/eholdings/local`"
                                                    class="disabled"
                                                >
                                                    <i
                                                        class="fa fa-map-marker"
                                                    ></i>
                                                    {{
                                                        $__("Local")
                                                    }}</router-link
                                                >
                                                <router-link
                                                    v-else-if="
                                                        provider == 'ebsco'
                                                    "
                                                    :to="`/cgi-bin/koha/erm/eholdings/ebsco`"
                                                    class="disabled"
                                                >
                                                    <i class="fa fa-globe"></i>
                                                    {{
                                                        $__("EBSCO")
                                                    }}</router-link
                                                >
                                                <ul>
                                                    <li>
                                                        <router-link
                                                            :to="`/cgi-bin/koha/erm/eholdings/${provider}/packages`"
                                                        >
                                                            <i
                                                                class="fa fa-archive"
                                                            ></i>
                                                            {{
                                                                $__("Packages")
                                                            }}</router-link
                                                        >
                                                    </li>
                                                    <li>
                                                        <router-link
                                                            :to="`/cgi-bin/koha/erm/eholdings/${provider}/titles`"
                                                        >
                                                            <i
                                                                class="fa fa-sort-alpha-asc"
                                                            ></i>
                                                            {{
                                                                $__("Titles")
                                                            }}</router-link
                                                        >
                                                    </li>
                                                </ul>
                                            </li>
                                        </ul>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </aside>
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
import Breadcrumb from "../../components/Breadcrumb.vue"
import Dialog from "../../components/Dialog.vue"
import { APIClient } from "../../fetch/api-client.js"
import "vue-select/dist/vue-select.css"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = inject("vendorStore")

        const AVStore = inject("AVStore")

        const mainStore = inject("mainStore")

        const { loading, loaded, setError } = mainStore

        return {
            vendorStore,
            AVStore,
            setError,
            erm_providers,
            ERMModule,
            loading,
            loaded,
        }
    },
    data() {
        return {
            component: "agreement",
        }
    },
    beforeCreate() {
        if (!this.ERMModule) {
            return this.setError(
                this.$__(
                    'The e-resource management module is disabled, turn on <a href="/cgi-bin/koha/admin/preferences.pl?tab=&op=search&searchfield=ERMModule">ERMModule</a> to use it'
                ),
                false
            )
        }
        this.loading()

        const acq_client = APIClient.acquisition
        acq_client.vendors.getAll().then(
            vendors => {
                this.vendorStore.vendors = vendors
                this.initialized = true
            },
            error => {}
        )

        const av_client = APIClient.authorised_values
        const authorised_values = {
            av_agreement_statuses: "ERM_AGREEMENT_STATUS",
            av_agreement_closure_reasons: "ERM_AGREEMENT_CLOSURE_REASON",
            av_agreement_renewal_priorities: "ERM_AGREEMENT_RENEWAL_PRIORITY",
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

        av_client.values
            .getCategoriesWithValues(av_cat_array)
            .then(av_categories => {
                Object.entries(authorised_values).forEach(
                    ([av_var, av_cat]) => {
                        const av_match = av_categories.find(
                            element => element.category_name == av_cat
                        )
                        this.AVStore[av_var] = av_match.authorised_values
                    }
                )
            })
            .then(() => this.loaded())
    },
    components: {
        Breadcrumb,
        Dialog,
    },
}
</script>

<style>
#navmenulist a.router-link-active {
    font-weight: 700;
}
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
input:not([type="submit"]):not([type="search"]):not([type="button"]):not([type="checkbox"]),
textarea {
    border-color: rgba(60, 60, 60, 0.26);
    border-width: 1px;
    border-radius: 4px;
    min-width: 30%;
}
.flatpickr-input {
    width: 30%;
}

#navmenulist ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
#navmenulist ul li a.disabled.router-link-active {
    color: #000;
}
</style>
