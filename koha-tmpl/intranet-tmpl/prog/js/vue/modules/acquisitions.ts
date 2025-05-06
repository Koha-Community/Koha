import { createApp } from "vue";
import { createWebHistory, createRouter } from "vue-router";
import { createPinia } from "pinia";

import { library } from "@fortawesome/fontawesome-svg-core";
import {
    faEye,
    faEyeSlash,
    faInbox,
    faMinus,
    faPencil,
    faPlus,
    faSpinner,
    faTrash,
    faTimes,
    faSave,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import vSelect from "vue-select";

library.add(
    faEye,
    faEyeSlash,
    faInbox,
    faMinus,
    faPencil,
    faPlus,
    faSpinner,
    faTrash,
    faTimes,
    faSave
);

import App from "../components/Vendors/Main.vue";

import { routes as routesDef } from "../routes/acquisitions";

import { useMainStore } from "../stores/main";
import { useVendorStore } from "../stores/vendors";
import { useNavigationStore } from "../stores/navigation";
import { usePermissionsStore } from "../stores/permissions";
import i18n from "../i18n";

const pinia = createPinia();

const mainStore = useMainStore(pinia);
const navigationStore = useNavigationStore(pinia);
const permissionsStore = usePermissionsStore(pinia);

const routes = navigationStore.setRoutes(routesDef);

const router = createRouter({
    history: createWebHistory(),
    linkActiveClass: "current",
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
app.provide("navigationStore", navigationStore);
app.provide("permissionsStore", permissionsStore);

app.mount("#vendors");

const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    if (to.path === "/cgi-bin/koha/acqui/vendors.pl") {
        router.push({ name: "VendorList" });
    }
    navigationStore.$patch({
        current: to.matched,
        params: to.params || {},
        query: to.query || {},
    });
    removeMessages(); // This will actually flag the messages as displayed already
});
