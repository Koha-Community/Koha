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

import App from "./components/ERM/ERMMain.vue";

import { routes } from "./routes";

const router = createRouter({ history: createWebHistory(), routes });

import { useMainStore } from "./stores/main";
import { useVendorStore } from "./stores/vendors";
import { useAVStore } from "./stores/authorised_values";

const pinia = createPinia();

const i18n = {
    install: (app, options) => {
        app.config.globalProperties.__ = (key) => {
            return window["__"](key);
        };
    },
};

const app = createApp(App);

const rootComponent = app
    .use(pinia)
    .use(router)
    .use(i18n)
    .component("font-awesome-icon", FontAwesomeIcon)
    .component("v-select", vSelect);

app.config.unwrapInjectedRef = true;
app.provide("vendorStore", useVendorStore(pinia));
const mainStore = useMainStore(pinia);
app.provide("mainStore", mainStore);
app.provide("AVStore", useAVStore(pinia));

app.mount("#erm");

const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    removeMessages(); // This will actually flag the messages as displayed already
});
