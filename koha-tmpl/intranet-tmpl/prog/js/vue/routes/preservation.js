import Home from "../components/Preservation/Home.vue";
import TrainsList from "../components/Preservation/TrainsList.vue";
import TrainsShow from "../components/Preservation/TrainsShow.vue";
import TrainsFormAdd from "../components/Preservation/TrainsFormAdd.vue";
import TrainsFormAddItem from "../components/Preservation/TrainsFormAddItem.vue";
import TrainsFormAddItems from "../components/Preservation/TrainsFormAddItems.vue";
import WaitingList from "../components/Preservation/WaitingList.vue";
import Settings from "../components/Preservation/Settings.vue";
import SettingsProcessingsShow from "../components/Preservation/SettingsProcessingsShow.vue";
import SettingsProcessingsFormAdd from "../components/Preservation/SettingsProcessingsFormAdd.vue";

const breadcrumbs = {
    home: {
        text: "Home", // $t("Home")
        path: "/cgi-bin/koha/mainpage.pl",
    },
    preservation_home: {
        text: "Preservation", //$t("Preservation")
        path: "/cgi-bin/koha/preservation/home.pl",
    },
    trains: {
        text: "Trains", // $t("Trains")
        path: "/cgi-bin/koha/preservation/trains",
    },
    waiting_list: {
        text: "Waiting list", // $t("Waiting list")
        path: "/cgi-bin/koha/preservation/waiting-list",
    },
    settings: {
        home: {
            text: "Settings", // $t("Settings")
            path: "/cgi-bin/koha/preservation/settings",
        },
        processings: {
            home: {
                text: "Processings", //$t("Processings")
            },
        },
    },
};
const breadcrumb_paths = {
    trains: [
        breadcrumbs.home,
        breadcrumbs.preservation_home,
        breadcrumbs.trains,
    ],
    settings: [
        breadcrumbs.home,
        breadcrumbs.preservation_home,
        breadcrumbs.settings.home,
    ],
    settings_processings: [
        breadcrumbs.home,
        breadcrumbs.preservation_home,
        breadcrumbs.settings.home,
    ],
};

function build_breadcrumb(parent_breadcrumb, current) {
    let breadcrumb = parent_breadcrumb.flat(Infinity);
    if (current) {
        breadcrumb.push({
            text: current,
        });
    }
    return breadcrumb;
}

export const routes = [
    {
        path: "/cgi-bin/koha/mainpage.pl",
        beforeEnter(to, from, next) {
            window.location.href = "/cgi-bin/koha/mainpage.pl";
        },
    },
    {
        path: "/cgi-bin/koha/preservation/home.pl",
        name: "Home",
        component: Home,
        meta: {
            breadcrumb: () => [breadcrumbs.home, breadcrumbs.preservation_home],
        },
    },
    {
        path: "/cgi-bin/koha/preservation/trains",
        children: [
            {
                path: "",
                name: "TrainsList",
                component: TrainsList,
                meta: {
                    breadcrumb: () => breadcrumb_paths.trains,
                },
            },
            {
                path: ":train_id",
                children: [
                    {
                        path: "",
                        name: "TrainsShow",
                        component: TrainsShow,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    breadcrumb_paths.trains,
                                    "Show train" // $t("Show train")
                                ),
                        },
                    },
                    {
                        path: "items",
                        children: [
                            {
                                path: "add",
                                name: "TrainsFormAddItem",
                                component: TrainsFormAddItem,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            breadcrumb_paths.trains,
                                            "Add item to train" // $t("Add item to train")
                                        ),
                                },
                            },
                            {
                                path: "add/:item_ids",
                                name: "TrainsFormAddItems",
                                component: TrainsFormAddItems,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            breadcrumb_paths.trains,
                                            "Add items to train" // $t("Add items to train")
                                        ),
                                },
                            },
                            {
                                path: "edit/:train_item_id",
                                name: "TrainsFormEditItem",
                                component: TrainsFormAddItem,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            breadcrumb_paths.trains,
                                            "Edit item in train" // $t("Edit item in train")
                                        ),
                                },
                            },
                        ],
                    },
                ],
            },
            {
                path: "add",
                name: "TrainsFormAdd",
                component: TrainsFormAdd,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.trains,
                            "Add train" // $t("Add train")
                        ),
                },
            },
            {
                path: "edit/:train_id",
                name: "TrainsFormEdit",
                component: TrainsFormAdd,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.trains,
                            "Edit train" // $t("Edit train")
                        ),
                },
            },
        ],
    },
    {
        path: "/cgi-bin/koha/preservation/waiting-list",
        name: "WaitingList",
        component: WaitingList,
        meta: {
            breadcrumb: () => [
                breadcrumbs.home,
                breadcrumbs.preservation_home,
                breadcrumbs.waiting_list,
            ],
        },
    },
    {
        path: "/cgi-bin/koha/preservation/settings",
        children: [
            {
                path: "",
                name: "Settings",
                component: Settings,
                meta: {
                    breadcrumb: () => breadcrumb_paths.settings,
                },
            },
            {
                path: "processings",
                children: [
                    {
                        path: ":processing_id",
                        name: "SettingsProcessingsShow",
                        component: SettingsProcessingsShow,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    breadcrumb_paths.settings_processings,
                                    "Show processing" // $t("Show processing")
                                ),
                        },
                    },
                    {
                        path: "add",
                        name: "SettingsProcessingsFormAdd",
                        component: SettingsProcessingsFormAdd,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    breadcrumb_paths.settings_processings,
                                    "Add processing" // $t("Add processing")
                                ),
                        },
                    },
                    {
                        path: "edit/:processing_id",
                        name: "SettingsProcessingsFormEdit",
                        component: SettingsProcessingsFormAdd,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    breadcrumb_paths.settings_processings,
                                    "Edit processing" // $t("Edit processing")
                                ),
                        },
                    },
                ],
            },
        ],
    },
];
