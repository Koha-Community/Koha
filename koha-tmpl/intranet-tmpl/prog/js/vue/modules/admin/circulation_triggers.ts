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
import { useCircRulesStore } from "../../stores/circulation-rules";
import routesDef from "../../routes/admin/circulation_triggers";

library.add(faPlus, faMinus, faPencil, faTrash, faSpinner);

const pinia = createPinia();
const navigationStore = useNavigationStore(pinia);
const mainStore = useMainStore(pinia);
const circRulesStore = useCircRulesStore(pinia);
const { removeMessages } = mainStore;
const { setRoutes } = navigationStore;
const routes = setRoutes(routesDef);

const router = createRouter({
    history: createWebHistory(),
    linkExactActiveClass: "current",
    routes,
});

import "../../../../css/vue.css";
import App from "../../components/Admin/CirculationTriggers/Main.vue";
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
app.provide("circRulesStore", circRulesStore);
app.mount("#__app");

router.beforeEach((to, from, next) => {
    circRulesStore
        .loadUserPermissions()
        .then(() => {
            if (
                !circRulesStore.isUserPermitted(
                    "CAN_user_parameters_manage_circ_triggers"
                )
            ) {
                navigationStore.$patch({
                    navigationBlocked: true,
                    currentPermission: null,
                });
                removeMessages(); // This will actually flag the messages as displayed already
                window.location.href = "/cgi-bin/koha/admin/admin-home.pl";
                return;
            }
            navigationStore.$patch({
                current: to.matched,
                params: to.params || {},
            });
            removeMessages(); // This will actually flag the messages as displayed already
            next();
        })
        .catch(() => {
            window.location.href = "/cgi-bin/koha/admin/admin-home.pl";
        });
});
