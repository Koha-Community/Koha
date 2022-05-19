<template>
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
                            </ul>
                        </div>
                    </div>
                </aside>
            </div>
        </div>
    </div>
</template>

<script>
import Breadcrumb from "./Breadcrumb.vue"
import Dialog from "./Dialog.vue"
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { fetchVendors } from "../../fetch"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const AVStore = useAVStore()
        AVStore.av_agreement_statuses = agreement_statuses
        AVStore.av_agreement_closure_reasons = agreement_closure_reasons
        AVStore.av_agreement_renewal_priorities = agreement_renewal_priorities
        AVStore.av_agreement_user_roles = agreement_user_roles
        AVStore.av_license_types = license_types
        AVStore.av_license_statuses = license_statuses
        AVStore.av_agreement_license_statuses = agreement_license_statuses
        AVStore.av_agreement_license_location = agreement_license_location

        return {
            vendorStore,
        }
    },
    data() {
        return {
            component: "agreement",
        }
    },
    beforeCreate() {
        fetchVendors().then((vendors) => this.vendorStore.vendors = vendors)
    },
    components: {
        Breadcrumb,
        Dialog,
    },
};
</script>
