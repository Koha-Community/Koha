import { markRaw } from "vue";

import Home from "../components/SIP2/Home.vue";
import SIP2InstitutionsList from "../components/SIP2/SIP2InstitutionsList.vue";
import SIP2InstitutionsFormAdd from "../components/SIP2/SIP2InstitutionsFormAdd.vue";
import SIP2InstitutionsShow from "../components/SIP2/SIP2InstitutionsShow.vue";
import SIP2AccountsList from "../components/SIP2/SIP2AccountsList.vue";
import SIP2AccountsFormAdd from "../components/SIP2/SIP2AccountsFormAdd.vue";
import SIP2AccountsShow from "../components/SIP2/SIP2AccountsShow.vue";

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
            {
                path: "/cgi-bin/koha/sip2/accounts",
                title: $__("Accounts"),
                icon: "fa fa-user",
                is_end_node: true,
                resource: "SIP2/SIP2AccountResource.vue",
                children: [
                    {
                        path: "",
                        name: "SIP2AccountsList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":sip_account_id",
                        name: "SIP2AccountsShow",
                        component: markRaw(ResourceWrapper),
                        title: $__("Show account"),
                    },
                    {
                        path: "add",
                        name: "SIP2AccountsFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add account"),
                    },
                    {
                        path: "edit/:sip_account_id",
                        name: "SIP2AccountsFormAddEdit",
                        component: markRaw(ResourceWrapper),
                        title: $__("Edit account"),
                    },
                ],
            },
        ],
    },
];
