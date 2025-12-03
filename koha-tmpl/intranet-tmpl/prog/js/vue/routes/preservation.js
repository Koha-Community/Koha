import { markRaw } from "vue";

import Home from "../components/Preservation/Home.vue";
import TrainsFormAddItem from "../components/Preservation/TrainsFormAddItem.vue";
import TrainsFormAddItems from "../components/Preservation/TrainsFormAddItems.vue";
import Settings from "../components/Preservation/Settings.vue";
import SettingsProcessingsShow from "../components/Preservation/SettingsProcessingsShow.vue";
import SettingsProcessingsFormAdd from "../components/Preservation/SettingsProcessingsFormAdd.vue";

import ResourceWrapper from "../components/ResourceWrapper.vue";

import { $__ } from "@koha-vue/i18n";

export const routes = [
    {
        path: "/cgi-bin/koha/mainpage.pl",
        is_base: true,
        beforeEnter(to, from, next) {
            window.location.href = "/cgi-bin/koha/mainpage.pl";
        },
    },
    {
        path: "/cgi-bin/koha/preservation/home.pl",
        is_default: true,
        is_base: true,
        title: $__("Preservation"),
        children: [
            {
                path: "",
                name: "Home",
                component: markRaw(Home),
                title: $__("Home"),
                icon: "fa fa-home",
            },
            {
                path: "/cgi-bin/koha/preservation/trains",
                title: $__("Trains"),
                icon: "fa fa-train",
                is_end_node: true,
                resource: "Preservation/TrainResource.vue",
                children: [
                    {
                        path: "",
                        name: "TrainsList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":train_id",
                        title: "{name}",
                        is_end_node: true,
                        children: [
                            {
                                path: "",
                                name: "TrainsShow",
                                component: markRaw(ResourceWrapper),
                            },
                            {
                                path: "items",
                                is_empty: true,
                                children: [
                                    {
                                        path: "add",
                                        name: "TrainsFormAddItem",
                                        component: markRaw(TrainsFormAddItem),
                                        title: $__("Add item to train"),
                                    },
                                    {
                                        path: "add/:item_ids",
                                        name: "TrainsFormAddItems",
                                        component: markRaw(TrainsFormAddItems),
                                        title: $__("Add items to train"),
                                    },
                                    {
                                        path: "edit/:train_item_id",
                                        name: "TrainsFormEditItem",
                                        component: markRaw(TrainsFormAddItem),
                                        title: $__("Edit item in train"),
                                    },
                                ],
                            },
                        ],
                    },
                    {
                        path: "add",
                        name: "TrainsFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add train"),
                    },
                    {
                        path: "edit/:train_id",
                        name: "TrainsFormAddEdit",
                        component: markRaw(ResourceWrapper),
                        title: "{name}",
                        breadcrumbFormat: ({ match, params, query }) => {
                            match.name = "TrainsShow";
                            return match;
                        },
                        additionalBreadcrumbs: [
                            { title: $__("Modify train"), disabled: true },
                        ],
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/preservation/waiting-list",
                title: $__("Waiting list"),
                icon: "fa fa-recycle",
                is_end_node: true,
                resource: "Preservation/WaitingListResource.vue",
                children: [
                    {
                        path: "",
                        name: "WaitingList",
                        component: markRaw(ResourceWrapper),
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/preservation/settings",
                title: $__("Settings"),
                icon: "fa fa-cog",
                is_end_node: true,
                children: [
                    {
                        path: "",
                        name: "Settings",
                        component: markRaw(Settings),
                    },
                    {
                        path: "processings",
                        title: $__("Processings"),
                        disabled: true,
                        children: [
                            {
                                path: ":processing_id",
                                name: "SettingsProcessingsShow",
                                component: markRaw(SettingsProcessingsShow),
                                title: $__("Show processing"),
                            },
                            {
                                path: "add",
                                name: "SettingsProcessingsFormAdd",
                                component: markRaw(SettingsProcessingsFormAdd),
                                title: $__("Add processing"),
                            },
                            {
                                path: "edit/:processing_id",
                                name: "SettingsProcessingsFormEdit",
                                component: markRaw(SettingsProcessingsFormAdd),
                                title: $__("Edit processing"),
                            },
                        ],
                    },
                ],
            },
        ],
    },
];
