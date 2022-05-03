import { createApp } from "vue";
import { createWebHistory, createRouter } from "vue-router";

import { library } from "@fortawesome/fontawesome-svg-core";
import { faPlus, faPencil, faTrash } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

library.add(faPlus, faPencil, faTrash);

import App from "./components/ERM/ERMMain.vue";
import ERMHome from "./components/ERM/ERMHome.vue";
import Agreements from "./components/ERM/Agreements.vue";

const Bar = { template: "<div>bar</div>" };
const routes = [
    {
        path: "/cgi-bin/koha/erm/erm.pl",
        component: ERMHome,
        meta: {
            breadcrumb: [
                { text: "Home", path: "/cgi-bin/koha/mainpage.pl" },
                {
                    text: "Electronic resources management",
                    path: "/cgi-bin/koha/erm/erm.pl",
                },
            ],
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements",
        component: Agreements,
        meta: {
            breadcrumb: [
                { text: "Home", path: "/cgi-bin/koha/mainpage.pl" },
                {
                    text: "Electronic resources management",
                    path: "/cgi-bin/koha/erm/erm.pl",
                },
                { text: "Agreements", path: "/cgi-bin/koha/erm/agreements" },
            ],
        },
    },
];

const router = createRouter({ history: createWebHistory(), routes });

createApp(App)
    .use(router)
    .component("font-awesome-icon", FontAwesomeIcon)
    .mount("#erm");
