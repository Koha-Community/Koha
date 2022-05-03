import { createApp } from "vue";
import { createWebHistory, createRouter } from "vue-router";

import { library } from "@fortawesome/fontawesome-svg-core";
import { faPlus, faPencil, faTrash } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

library.add(faPlus, faPencil, faTrash);

import App from "./components/ERM/ERMMain.vue";
import Agreements from "./components/ERM/Agreements.vue";

const Bar = { template: "<div>bar</div>" };
const Foo = { template: "<div>foo</div>" };
const routes = [
    { path: "/cgi-bin/koha/erm/agreements", component: Agreements },
    { path: "/cgi-bin/koha/erm/licenses", component: Bar },
    { path: "/cgi-bin/koha/erm/erm.pl", component: Foo },
];

const router = createRouter({ history: createWebHistory(), routes });

createApp(App)
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .mount("#erm");
