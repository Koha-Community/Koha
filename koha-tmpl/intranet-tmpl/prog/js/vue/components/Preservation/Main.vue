<template>
    <div v-if="initialized && PreservationModule == 1">
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
                    <LeftMenu :title="$__('Preservation')"></LeftMenu>
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

export default {
    setup() {
        const AVStore = inject("AVStore")

        const mainStore = inject("mainStore")

        const { loading, loaded, setError } = mainStore

        const PreservationStore = inject("PreservationStore")
        return {
            AVStore,
            loading,
            loaded,
            setError,
            PreservationStore,
        }
    },
    data() {
        return {
            initialized: false,
            PreservationModule: null,
        }
    },
    beforeCreate() {
        this.loading()

        const fetch_config = () => {
            const sysprefs_client = APIClient.sysprefs
            const av_client = APIClient.authorised_values
            let promises = [
                sysprefs_client.sysprefs
                    .get("PreservationNotForLoanWaitingListIn")
                    .then(
                        value => {
                            this.PreservationStore.settings.not_for_loan_waiting_list_in =
                                value.value
                        },
                        error => {}
                    ),
                sysprefs_client.sysprefs
                    .get("PreservationNotForLoanDefaultTrainIn")
                    .then(
                        value => {
                            this.PreservationStore.settings.not_for_loan_default_train_in =
                                value.value
                        },
                        error => {}
                    ),
                av_client.values.get("NOT_LOAN").then(
                    values => {
                        this.AVStore.av_notforloan = values
                    },
                    error => {}
                ),
            ]

            return Promise.all(promises)
        }

        const sysprefs_client = APIClient.sysprefs
        sysprefs_client.sysprefs
            .get("PreservationModule")
            .then(value => {
                this.PreservationModule = value.value
                if (this.PreservationModule != 1) {
                    return this.setError(
                        this.$__(
                            'The preservation module is disabled, turn on <a href="/cgi-bin/koha/admin/preferences.pl?tab=&op=search&searchfield=PreservationModule">PreservationModule</a> to use it'
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
