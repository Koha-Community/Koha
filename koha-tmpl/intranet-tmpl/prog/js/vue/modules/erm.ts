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

import { routes as routesDef } from "../routes/erm";

import { useMainStore } from "../stores/main";
import { useVendorStore } from "../stores/vendors";
import { useAVStore } from "../stores/authorised-values";
import { useERMStore } from "../stores/erm";
import { useNavigationStore } from "../stores/navigation";
import i18n from "../i18n";

const pinia = createPinia();

const mainStore = useMainStore(pinia);
const AVStore = useAVStore(pinia);
const navigationStore = useNavigationStore(pinia);
const routes = navigationStore.setRoutes(routesDef);

const router = createRouter({
    history: createWebHistory(),
    linkExactActiveClass: "current",
    routes,
});

const app = createApp(App);

const rootComponent = app
    .use(i18n)
    .use(pinia)
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .component("v-select", vSelect);

app.config.unwrapInjectedRef = true;
app.provide("vendorStore", useVendorStore(pinia));
app.provide("mainStore", mainStore);
app.provide("AVStore", AVStore);
app.provide("navigationStore", navigationStore);
const ERMStore = useERMStore(pinia);
app.provide("ERMStore", ERMStore);

app.mount("#erm");

const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    navigationStore.$patch({ current: to.matched, params: to.params || {} });
    removeMessages(); // This will actually flag the messages as displayed already
});
router.afterEach((to, from) => {
    let tab_id = "agreement"; // Agreements

    if (to.path.match(/\/erm\/licenses/)) {
        tab_id = "license";
    } else if (to.path.match(/\/erm\/eholdings\/local\/packages/)) {
        tab_id = "package";
    } else if (to.path.match(/\/erm\/eholdings\/local\/titles/)) {
        tab_id = "title";
    }
    let node = document.getElementById(`${tab_id}_search_tab`);

    if (node) {
        node.click();
    }
});
