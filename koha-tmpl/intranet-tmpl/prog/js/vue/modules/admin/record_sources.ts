import { createApp } from "vue";
import { createPinia } from "pinia";
import { createWebHistory, createRouter } from "vue-router";

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
import { useNavigationStore } from "../../stores/navigation";
import { useMainStore } from "../../stores/main";
import routesDef from "../../routes/admin/record_sources";

library.add(faPlus, faMinus, faPencil, faTrash, faSpinner);

const pinia = createPinia();
const navigationStore = useNavigationStore(pinia);
const mainStore = useMainStore(pinia);
const { removeMessages } = mainStore;
const { setRoutes } = navigationStore;
const routes = setRoutes(routesDef);

const router = createRouter({
    history: createWebHistory(),
    linkExactActiveClass: "current",
    routes,
});

import App from "../../components/Admin/RecordSources/Main.vue";
import i18n from "../../i18n";

const app = createApp(App);

const rootComponent = app
    .use(i18n)
    .use(pinia)
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .component("v-select", vSelect);

app.config.unwrapInjectedRef = true;
app.provide("mainStore", mainStore);
app.provide("navigationStore", navigationStore);
app.mount("#record-source");

router.beforeEach(to => {
    navigationStore.$patch({ current: to.matched, params: to.params || {} });
    removeMessages(); // This will actually flag the messages as displayed already
});
