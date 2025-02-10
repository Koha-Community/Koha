import { markRaw } from "vue";

import Home from "../components/SIP2/Home.vue";
import ResourceWrapper from "../components/ResourceWrapper.vue";
import ServerParams from "../components/SIP2/SIP2ServerParams.vue";
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
                resource: "SIP2/SIP2InstitutionResource.vue",
                children: [
                    {
                        path: "",
                        name: "SIP2InstitutionsList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":sip_institution_id",
                        name: "SIP2InstitutionsShow",
                        component: markRaw(ResourceWrapper),
                        title: $__("Show institution"),
                    },
                    {
                        path: "add",
                        name: "SIP2InstitutionsFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add institution"),
                    },
                    {
                        path: "edit/:sip_institution_id",
                        name: "SIP2InstitutionsFormAddEdit",
                        component: markRaw(ResourceWrapper),
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
            {
                path: "/cgi-bin/koha/sip2/listeners",
                title: $__("Listeners"),
                icon: "fa fa-signal",
                is_end_node: true,
                resource: "SIP2/SIP2ListenerResource.vue",
                children: [
                    {
                        path: "",
                        name: "SIP2ListenersList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":sip_listener_id",
                        name: "SIP2ListenersShow",
                        component: markRaw(ResourceWrapper),
                        title: $__("Show listener"),
                    },
                    {
                        path: "add",
                        name: "SIP2ListenersFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add listener"),
                    },
                    {
                        path: "edit/:sip_listener_id",
                        name: "SIP2ListenersFormAddEdit",
                        component: markRaw(ResourceWrapper),
                        title: $__("Edit listener"),
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/sip2/system_preference_overrides",
                title: $__("System preference overrides"),
                icon: "fa fa-cog",
                is_end_node: true,
                resource: "SIP2/SIP2SystemPreferenceOverrideResource.vue",
                children: [
                    {
                        path: "",
                        name: "SIP2SystemPreferenceOverridesList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":sip_system_preference_override_id",
                        name: "SIP2SystemPreferenceOverridesShow",
                        component: markRaw(ResourceWrapper),
                        title: $__("Show system preference override"),
                    },
                    {
                        path: "add",
                        name: "SIP2SystemPreferenceOverridesFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add system preference override"),
                    },
                    {
                        path: "edit/:sip_system_preference_override_id",
                        name: "SIP2SystemPreferenceOverridesFormAddEdit",
                        component: markRaw(ResourceWrapper),
                        title: $__("Edit system preference override"),
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/sip2/serverparams",
                title: $__("Server params"),
                icon: "fa fa-server",
                is_end_node: true,
                children: [
                    {
                        path: "",
                        name: "SIP2ServerParams",
                        component: markRaw(ServerParams),
                    },
                ],
            },
        ],
    },
];
