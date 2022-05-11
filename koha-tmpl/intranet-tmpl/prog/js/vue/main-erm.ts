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
createApp(App)
    .use(createPinia())
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .mount("#erm");

const mainStore = useMainStore();
const { removeMessages } = mainStore;
router.beforeEach((to, from) => {
    removeMessages(); // This will actually flag the messages as displayed already
});
