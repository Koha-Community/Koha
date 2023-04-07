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
    faClose,
    faPaperPlane,
    faInbox,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import vSelect from "vue-select";

library.add(
    faPlus,
    faMinus,
    faPencil,
    faTrash,
    faSpinner,
    faClose,
    faPaperPlane,
    faInbox
);

import App from "../components/Preservation/Main.vue";

import { routes } from "../routes/preservation";

const router = createRouter({
    history: createWebHistory(),
    linkActiveClass: "current",
    routes,
});

import { useMainStore } from "../stores/main";
import { useAVStore } from "../stores/authorised-values";
import { usePreservationStore } from "../stores/preservation";

const pinia = createPinia();

const i18n = {
    install: (app, options) => {
        app.config.globalProperties.$__ = key => {
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
const mainStore = useMainStore(pinia);
app.provide("mainStore", mainStore);
app.provide("AVStore", useAVStore(pinia));
app.provide("PreservationStore", usePreservationStore(pinia));

app.mount("#preservation");

const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    removeMessages(); // This will actually flag the messages as displayed already
});
