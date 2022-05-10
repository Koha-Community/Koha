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

createApp(App)
    .use(createPinia())
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .mount("#erm");
