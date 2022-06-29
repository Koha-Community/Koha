import { createApp } from "vue";
import { createWebHistory, createRouter } from "vue-router";
import { createPinia } from "pinia";

import { library } from "@fortawesome/fontawesome-svg-core";
import { faPlus, faPencil, faTrash } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

library.add(faPlus, faPencil, faTrash);

import App from "./components/ERM/ERMMain.vue";

import { routes } from "./routes";

const router = createRouter({ history: createWebHistory(), routes });

import { useMainStore } from "./stores/main";

import { createI18n } from "vue-i18n";

import * as en from "./locales/en.json"; // We could async the load here, see https://vue-i18n.intlify.dev/guide/advanced/lazy.html
const languages = { en };
const messages = Object.assign(languages);
const i18n = createI18n({ locale: "en", messages });

const app = createApp(App)
    .use(createPinia())
    .use(router)
    .use(i18n)
    .component("font-awesome-icon", FontAwesomeIcon);
app.config.unwrapInjectedRef = true
app.mount("#erm");
const mainStore = useMainStore();
const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    removeMessages(); // This will actually flag the messages as displayed already
});
