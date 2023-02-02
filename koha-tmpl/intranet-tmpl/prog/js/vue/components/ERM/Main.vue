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
    <div v-else>
        {{
            $__(
                "The e-resource management module is disabled, turn on 'ERMModule' to use it"
            )
        }}
    </div>
</template>

<script>
import { inject } from "vue"
import Breadcrumb from "../../components/Breadcrumb.vue"
import Dialog from "../../components/Dialog.vue"
import { fetchVendors } from "../../fetch/erm.js"
import "vue-select/dist/vue-select.css"

export default {
    setup() {
        const AVStore = inject("AVStore")
        AVStore.av_agreement_statuses = agreement_statuses
        AVStore.av_agreement_closure_reasons = agreement_closure_reasons
        AVStore.av_agreement_renewal_priorities = agreement_renewal_priorities
        AVStore.av_user_roles = user_roles
        AVStore.av_license_types = license_types
        AVStore.av_license_statuses = license_statuses
        AVStore.av_agreement_license_statuses = agreement_license_statuses
        AVStore.av_agreement_license_location = agreement_license_location
        AVStore.av_package_types = package_types
        AVStore.av_package_content_types = package_content_types
        AVStore.av_title_publication_types = title_publication_types

        const vendorStore = inject("vendorStore")

        return {
            vendorStore,
            erm_providers,
            ERMModule,
        }
    },
    data() {
        return {
            component: "agreement",
        }
    },
    beforeCreate() {
        fetchVendors().then(vendors => (this.vendorStore.vendors = vendors))
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
