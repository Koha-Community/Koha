import { markRaw } from "vue";

import Home from "../components/SIP2/Home.vue";
import SIP2InstitutionsList from "../components/SIP2/SIP2InstitutionsList.vue";

import { $__ } from "../i18n";

export const routes = [
    {
        path: "/cgi-bin/koha/sip2/sip2.pl",
        is_default: true,
        is_base: true,
        title: $__("SIP2"),
        children: [
            {
                path: "",
                name: "Home",
                component: markRaw(Home),
                is_navigation_item: false,
            },
            {
                path: "/cgi-bin/koha/sip2/institutions",
                title: $__("Institutions"),
                icon: "fa fa-building-columns",
                is_end_node: true,
                children: [
                    {
                        path: "",
                        name: "SIP2InstitutionsList",
                        component: markRaw(SIP2InstitutionsList),
                    },
                ],
            },
        ],
    },
];
