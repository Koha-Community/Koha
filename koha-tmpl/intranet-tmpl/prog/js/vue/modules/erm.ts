import { createApp } from "vue";
import { createWebHistory, createRouter } from "vue-router";
import { createPinia } from "pinia";

import { library } from "@fortawesome/fontawesome-svg-core";
import {
    faPlus,
    faMinus,
    faPencil,
    faTrash,
    faSpinner,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import vSelect from "vue-select";

library.add(faPlus, faMinus, faPencil, faTrash, faSpinner);

import App from "../components/ERM/Main.vue";

import { routes } from "../routes/erm";

const router = createRouter({
    history: createWebHistory(),
    linkActiveClass: "current",
    routes,
});

import { useMainStore } from "../stores/main";
import { useVendorStore } from "../stores/vendors";
import { useAVStore } from "../stores/authorised-values";

const pinia = createPinia();

const i18n = {
    install: (app, options) => {
        app.config.globalProperties.$__ = (key) => {
            return window["__"](key);
        };
    },
};

const app = createApp(App);

const rootComponent = app
    .use(i18n)
    .use(pinia)
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .component("v-select", vSelect);

app.config.unwrapInjectedRef = true;
app.provide("vendorStore", useVendorStore(pinia));
const mainStore = useMainStore(pinia);
app.provide("mainStore", mainStore);
const AVStore = useAVStore(pinia);
app.provide("AVStore", AVStore);

app.mount("#erm");

const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    removeMessages(); // This will actually flag the messages as displayed already
});
router.afterEach((to, from) => {
    let tab_id = 1; // Agreements
    if (to.path.match(/\/erm\/eholdings\/local\/packages/)) {
        tab_id = 2;
    } else if (to.path.match(/\/erm\/eholdings\/local\/titles/)) {
        tab_id = 3;
    }
    let node = document.getElementById("ui-id-" + tab_id);
    if (node) {
        node.click();
    }
});
