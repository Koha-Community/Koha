<template>
    <div>
        <div id="sub-header">
            <Breadcrumbs />
            <Help />
        </div>
        <div class="main container-fluid">
            <div class="row">
                <div class="col-md-10 order-md-2 order-sm-1">
                    <main>
                        <Dialog />
                        <router-view />
                    </main>
                </div>

                <div class="col-md-2 order-sm-2 order-md-1"></div>
            </div>
        </div>
    </div>
</template>

<script>
import Breadcrumbs from "../../Breadcrumbs.vue";
import Help from "../../Help.vue";
import Dialog from "../../Dialog.vue";
import "vue-select/dist/vue-select.css";
import { inject } from "vue";
import { $__ } from "@koha-vue/i18n";

export default {
    setup() {
        const circRulesStore = inject("circRulesStore");
        circRulesStore.init(default_view, user_library_id).catch(() => {});

        // format letters for display as "name (notice code)" in drop downs.
        letters
            .sort(circRulesStore.compareByProperty("name"))
            .forEach(letter => {
                letter.name =
                    letter?.name?.concat(` (${letter.code})`) ?? letter.code;
            });

        letters.unshift({
            name: $__("No letter"),
            code: "",
            branchcode: "",
            value: "",
        });
        circRulesStore.letters = letters;

        return {
            letters,
        };
    },
    components: {
        Breadcrumbs,
        Dialog,
        Help,
    },
};
</script>

<style>
.page-section.bg-info {
    background-color: #daecfb !important;
}

/* overrides the 30% width set in css/vue.css */
form .v-select {
    width: 50%;
}
</style>
