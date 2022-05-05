<template>
    <Breadcrumb />
    <div class="main container-fluid">
        <div class="row">
            <div class="col-sm-10 col-sm-push-2">
                <main>
                    <router-view />
                </main>
            </div>

            <div class="col-sm-2 col-sm-pull-10">
                <aside>
                    <div id="navmenu">
                        <div id="navmenulist">
                            <h5>ERM</h5>
                            <ul>
                                <li>
                                    <router-link
                                        to="/cgi-bin/koha/erm/agreements"
                                    >
                                        <i class="fa fa-upload"></i>
                                        Agreements</router-link
                                    >
                                </li>
                                <li>
                                    <router-link
                                        to="/cgi-bin/koha/erm/licenses"
                                    >
                                        <i class="fa fa-file-text-o"></i>
                                        Licenses</router-link
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
import { useVendorStore } from "../../stores/vendors"
import { reactive, computed } from "vue"

export default {
    setup() {
        const vendorStore = useVendorStore()
        return {
            vendorStore
        }
    },
    data() {
        return {
            component: "agreement",
        }
    },
    beforeCreate() {
        const apiUrl = "/api/v1/acquisitions/vendors"

        fetch(apiUrl)
            .then((res) => res.json())
            .then(
                (result) => {
                    this.vendorStore.vendors = result
                },
                (error) => {
                    this.$emit("set-error", error)
                }
            )
    },
    methods: {
        switchComponent(component) {
            this.component = component
        },
    },
    components: {
        Breadcrumb,
    },
};
</script>
