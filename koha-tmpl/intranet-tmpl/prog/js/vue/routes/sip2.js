import { markRaw } from "vue";

import Home from "../components/SIP2/Home.vue";
import SIP2InstitutionsList from "../components/SIP2/SIP2InstitutionsList.vue";
import SIP2InstitutionsFormAdd from "../components/SIP2/SIP2InstitutionsFormAdd.vue";
import SIP2InstitutionsShow from "../components/SIP2/SIP2InstitutionsShow.vue";

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
                    {
                        path: ":sip_institution_id",
                        name: "SIP2InstitutionsShow",
                        component: markRaw(SIP2InstitutionsShow),
                        title: $__("Show institution"),
                    },
                    {
                        path: "add",
                        name: "SIP2InstitutionsFormAdd",
                        component: markRaw(SIP2InstitutionsFormAdd),
                        title: $__("Add institution"),
                    },
                    {
                        path: "edit/:sip_institution_id",
                        name: "SIP2InstitutionsFormAddEdit",
                        component: markRaw(SIP2InstitutionsFormAdd),
                        title: $__("Edit institution"),
                    },
                ],
            },
        ],
    },
];
