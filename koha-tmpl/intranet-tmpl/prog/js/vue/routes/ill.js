import { markRaw } from "vue";

import Home from "../components/ILL/Home.vue";
import ResourceWrapper from "../components/ResourceWrapper.vue";

import { $__ } from "@koha-vue/i18n";

export const routes = [
    {
        path: "/cgi-bin/koha/ill/ill.pl",
        redirect: "/cgi-bin/koha/ill/home",
        is_default: true,
        is_base: true,
        title: $__("Interlibrary loans"),
        children: [
            {
                path: "/cgi-bin/koha/ill/home",
                name: "Home",
                component: markRaw(Home),
                title: $__("Home"),
                icon: "fa fa-home",
            },
            {
                path: "/cgi-bin/koha/ill",
                title: $__("Borrowing"),
                icon: "fa fa-arrow-circle-down",
                disabled: true,
                children: [
                    {
                        path: "/cgi-bin/koha/ill/ill-requests.pl",
                        title: $__("Requests"),
                        icon: "fa fa-download",
                        is_external: true,
                        is_navigation_item: true,
                    },
                    {
                        path: "/cgi-bin/koha/ill/ill-requests.pl?method=batch_list",
                        title: $__("Batches"),
                        icon: "fa fa-clone",
                        is_external: true,
                        is_navigation_item: true,
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/ill",
                title: $__("Lending"),
                icon: "fa fa-arrow-circle-up",
                disabled: true,
                children: [
                    {
                        path: "/cgi-bin/koha/ill/iso18626_requests",
                        title: $__("Supplying ILLs"),
                        icon: "fa fa-upload",
                        is_end_node: true,
                        resource: "ILL/SupplyingResource.vue",
                        children: [
                            {
                                path: "",
                                name: "SupplyingList",
                                component: markRaw(ResourceWrapper),
                            },
                            {
                                path: ":iso18626_request_id",
                                name: "SupplyingShow",
                                component: markRaw(ResourceWrapper),
                                title: "{iso18626_request_id}",
                            },
                        ],
                    },
                    {
                        path: "/cgi-bin/koha/ill/iso18626_requesting_agencies",
                        title: $__("Requesting Agencies"),
                        icon: "fa fa-building-columns",
                        is_end_node: true,
                        resource: "ILL/RequestingAgencyResource.vue",
                        children: [
                            {
                                path: "",
                                name: "RequestingAgenciesList",
                                component: markRaw(ResourceWrapper),
                            },
                            {
                                path: ":iso18626_requesting_agency_id",
                                name: "RequestingAgenciesShow",
                                component: markRaw(ResourceWrapper),
                                title: "{name}",
                            },
                            {
                                path: "add",
                                name: "RequestingAgenciesFormAdd",
                                component: markRaw(ResourceWrapper),
                                title: $__("Add requesting agency"),
                            },
                            {
                                path: "edit/:iso18626_requesting_agency_id",
                                name: "RequestingAgenciesFormAddEdit",
                                component: markRaw(ResourceWrapper),
                                title: "{name}",
                                breadcrumbFormat: ({
                                    match,
                                    params,
                                    query,
                                }) => {
                                    match.name = "RequestingAgenciesShow";
                                    return match;
                                },
                                additionalBreadcrumbs: [
                                    {
                                        title: $__("Modify requesting agency"),
                                        disabled: true,
                                    },
                                ],
                            },
                        ],
                    },
                ],
            },
        ],
    },
];
