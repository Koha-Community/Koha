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
                                <h5>{{ $t("E-Resource management") }}</h5>
                                <ul>
                                    <li>
                                        <router-link
                                            to="/cgi-bin/koha/erm/agreements"
                                        >
                                            <i class="fa fa-upload"></i>
                                            {{ $t("Agreements") }}</router-link
                                        >
                                    </li>
                                    <li>
                                        <router-link
                                            to="/cgi-bin/koha/erm/licenses"
                                        >
                                            <i class="fa fa-file-text-o"></i>
                                            {{ $t("Licenses") }}</router-link
                                        >
                                    </li>
                                    <li>
                                        <router-link
                                            to="/cgi-bin/koha/erm/eholdings"
                                        >
                                            <i class="fa fa-file-text-o"></i>
                                            {{ $t("eHoldings") }}</router-link
                                        >
                                    </li>

                                    <ul>
                                        <li
                                            v-for="provider in erm_providers"
                                            :key="provider"
                                        >
                                            <router-link
                                                v-if="provider == 'local'"
                                                :to="`/cgi-bin/koha/erm/eholdings/local`"
                                            >
                                                <i
                                                    class="fa fa-file-text-o"
                                                ></i>
                                                {{ $t("Local") }}</router-link
                                            >
                                            <router-link
                                                v-else-if="provider == 'ebsco'"
                                                :to="`/cgi-bin/koha/erm/eholdings/ebsco`"
                                            >
                                                <i
                                                    class="fa fa-file-text-o"
                                                ></i>
                                                {{ $t("EBSCO") }}</router-link
                                            >
                                            <ul>
                                                <li>
                                                    <router-link
                                                        :to="`/cgi-bin/koha/erm/eholdings/${provider}/packages`"
                                                    >
                                                        <i
                                                            class="
                                                                fa
                                                                fa-file-text-o
                                                            "
                                                        ></i>
                                                        {{
                                                            $t("Packages")
                                                        }}</router-link
                                                    >
                                                </li>
                                                <li>
                                                    <router-link
                                                        :to="`/cgi-bin/koha/erm/eholdings/${provider}/titles`"
                                                    >
                                                        <i
                                                            class="
                                                                fa
                                                                fa-file-text-o
                                                            "
                                                        ></i>
                                                        {{
                                                            $t("Titles")
                                                        }}</router-link
                                                    >
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>
                                </ul>
                            </div>
                        </div>
                    </aside>
                </div>
            </div>
        </div>
    </div>
    <div v-else>
        {{
            $t(
                "The E-Resource management module is disabled, turn on 'ERMModule' to use it"
            )
        }}
    </div>
</template>

<script>
import { inject } from 'vue'
import Breadcrumb from "./Breadcrumb.vue"
import Dialog from "./Dialog.vue"
import { fetchVendors } from "../../fetch"
import "vue-select/dist/vue-select.css";

export default {
    setup() {
        const AVStore = inject('AVStore')
        AVStore.av_agreement_statuses = agreement_statuses
        AVStore.av_agreement_closure_reasons = agreement_closure_reasons
        AVStore.av_agreement_renewal_priorities = agreement_renewal_priorities
        AVStore.av_agreement_user_roles = agreement_user_roles
        AVStore.av_license_types = license_types
        AVStore.av_license_statuses = license_statuses
        AVStore.av_agreement_license_statuses = agreement_license_statuses
        AVStore.av_agreement_license_location = agreement_license_location
        AVStore.av_package_types = package_types
        AVStore.av_package_content_types = package_content_types
        AVStore.av_title_publication_types = title_publication_types

        const vendorStore = inject('vendorStore')

        return {
            vendorStore,
            erm_providers,
            ERMModule,
            lang,
        }
    },
    data() {
        return {
            component: "agreement",
        }
    },
    beforeCreate() {
        fetchVendors().then((vendors) => this.vendorStore.vendors = vendors)
        this.$i18n.locale = this.lang
    },
    components: {
        Breadcrumb,
        Dialog,
    },
};
</script>

<style>
#navmenulist a.router-link-active {
    font-weight: 700;
}
#menu ul ul, #navmenulist ul ul {
    padding-left: 2em;
    font-size: 100%;
}

form .v-select {
    display: inline-block;
    background-color: white;
    width: 30%;
}

.v-select, input:not([type=submit]):not([type=search]):not([type=button]):not([type=checkbox]), textarea {
    border-color: rgba(60,60,60,0.26);
    border-width: 1px;
    border-radius: 4px;
    min-width: 30%;
}
</style>
