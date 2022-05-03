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


import { reactive, computed } from "vue"

export default {
    data() {
        return {
            component: "agreement",
        }
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
