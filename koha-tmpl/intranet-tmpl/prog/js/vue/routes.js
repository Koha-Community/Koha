import { h } from "vue";
import { RouterView } from "vue-router";
import ERMHome from "./components/ERM/ERMHome.vue";
import AgreementsList from "./components/ERM/AgreementsList.vue";
import AgreementsShow from "./components/ERM/AgreementsShow.vue";
import AgreementsFormAdd from "./components/ERM/AgreementsFormAdd.vue";
import AgreementsFormConfirmDelete from "./components/ERM/AgreementsFormConfirmDelete.vue";
import EHoldingsMain from "./components/ERM/EHoldingsMain.vue";
import EHoldingsPackagesList from "./components/ERM/EHoldingsPackagesList.vue";
import EHoldingsPackagesShow from "./components/ERM/EHoldingsPackagesShow.vue";
import EHoldingsPackagesFormAdd from "./components/ERM/EHoldingsPackagesFormAdd.vue";
import EHoldingsPackagesFormConfirmDelete from "./components/ERM/EHoldingsPackagesFormConfirmDelete.vue";
import EHoldingsResourcesShow from "./components/ERM/EHoldingsResourcesShow.vue";
import EHoldingsTitlesList from "./components/ERM/EHoldingsTitlesList.vue";
import EHoldingsTitlesShow from "./components/ERM/EHoldingsTitlesShow.vue";
import EHoldingsTitlesFormAdd from "./components/ERM/EHoldingsTitlesFormAdd.vue";
import EHoldingsTitlesFormConfirmDelete from "./components/ERM/EHoldingsTitlesFormConfirmDelete.vue";
import LicensesList from "./components/ERM/LicensesList.vue";
import LicensesShow from "./components/ERM/LicensesShow.vue";
import LicensesFormAdd from "./components/ERM/LicensesFormAdd.vue";
import LicensesFormConfirmDelete from "./components/ERM/LicensesFormConfirmDelete.vue";

const breadcrumbs = {
    home: {
        text: "Home", // $t("Home")
        path: "/cgi-bin/koha/mainpage.pl",
    },
    erm_home: {
        text: "E-Resource management", // $t("E-Resource management")
        path: "/cgi-bin/koha/erm/erm.pl",
    },
    agreements: {
        text: "Agreements", // $t("Agreements")
        path: "/cgi-bin/koha/erm/agreements",
    },
    eholdings: {
        home: {
            text: "eHoldings", // $t("eHoldings")
            path: "/cgi-bin/koha/erm/eholdings",
        },
        titles: {
            text: "Titles", // $t("Titles")
            path: "/cgi-bin/koha/erm/eholdings/titles",
        },
        packages: {
            text: "Packages", // $t("Packages")
            path: "/cgi-bin/koha/erm/eholdings/packages",
        },
    },
    licenses: {
        text: "Licenses", // $t("Licenses")
        path: "/cgi-bin/koha/erm/licenses",
    },
};
const breadcrumb_paths = {
    agreements: [
        breadcrumbs.home,
        breadcrumbs.erm_home,
        breadcrumbs.agreements,
    ],
    eholdings: [
        breadcrumbs.home,
        breadcrumbs.erm_home,
        breadcrumbs.eholdings.home,
    ],
    licenses: [breadcrumbs.home, breadcrumbs.erm_home, breadcrumbs.licenses],
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
    { path: "/cgi-bin/koha/mainpage.pl" },
    {
        path: "/cgi-bin/koha/erm/erm.pl",
        component: ERMHome,
        meta: {
            breadcrumb: () => [breadcrumbs.home, breadcrumbs.erm_home],
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements",
        component: { render: () => h(RouterView) },
        children: [
            {
                path: "",
                component: AgreementsList,
                meta: {
                    breadcrumb: () => breadcrumb_paths.agreements,
                },
            },
            {
                path: ":agreement_id",
                component: AgreementsShow,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.agreements,
                            "Show agreement" // $t("Show agreement")
                        ),
                },
            },
            {
                path: "delete/:agreement_id",
                component: AgreementsFormConfirmDelete,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.agreements,
                            "Delete agreement" // $t("Delete agreement")
                        ),
                },
            },
            {
                path: "add",
                component: AgreementsFormAdd,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.agreements,
                            "Add agreement" // $t("Add agreement")
                        ),
                },
            },
            {
                path: "edit/:agreement_id",
                component: AgreementsFormAdd,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.agreements,
                            "Edit agreement" // $t("Edit agreemetn")
                        ),
                },
            },
        ],
    },
    {
        path: "/cgi-bin/koha/erm/eholdings",
        component: { render: () => h(RouterView) },
        children: [
            {
                path: "",
                component: EHoldingsMain,
                meta: {
                    breadcrumb: () => breadcrumb_paths.eholdings,
                },
            },
            {
                path: "packages",
                component: { render: () => h(RouterView) },
                children: [
                    {
                        path: "",
                        component: EHoldingsPackagesList,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb([
                                    breadcrumb_paths.eholdings,
                                    breadcrumbs.eholdings.packages,
                                ]),
                        },
                    },
                    {
                        path: ":package_id",
                        component: EHoldingsPackagesShow,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.packages,
                                    ],
                                    "Show package" // $t("Show package")
                                ),
                        },
                    },
                    {
                        path: "delete/:package_id",
                        component: EHoldingsPackagesFormConfirmDelete,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.packages,
                                    ],
                                    "Delete package" // $t("Delete package")
                                ),
                        },
                    },
                    {
                        path: "add",
                        component: EHoldingsPackagesFormAdd,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.packages,
                                    ],
                                    "Add package" // $t("Add package")
                                ),
                        },
                    },
                    {
                        path: "edit/:package_id",
                        component: EHoldingsPackagesFormAdd,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.packages,
                                    ],
                                    "Edit package" // $t("Edit package")
                                ),
                        },
                    },
                ],
            },
            {
                path: "titles",
                component: { render: () => h(RouterView) },
                children: [
                    {
                        path: "",
                        component: EHoldingsTitlesList,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb([
                                    breadcrumb_paths.eholdings,
                                    breadcrumbs.eholdings.titles,
                                ]),
                        },
                    },
                    {
                        path: ":title_id",
                        component: EHoldingsTitlesShow,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.titles,
                                    ],
                                    "Show title" // $t("Show title")
                                ),
                        },
                    },
                    {
                        path: "delete/:title_id",
                        component: EHoldingsTitlesFormConfirmDelete,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.titles,
                                    ],
                                    "Delete title" // $t("Delete title")
                                ),
                        },
                    },
                    {
                        path: "add",
                        component: EHoldingsTitlesFormAdd,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.titles,
                                    ],
                                    "Add title" // $t("Add title")
                                ),
                        },
                    },
                    {
                        path: "edit/:title_id",
                        component: EHoldingsTitlesFormAdd,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings,
                                        breadcrumbs.eholdings.titles,
                                    ],
                                    "Edit title" // $t("Edit title")
                                ),
                        },
                    },
                ],
            },
            {
                path: "resources/:resource_id",
                component: EHoldingsResourcesShow,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            [
                                breadcrumb_paths.eholdings,
                                breadcrumbs.eholdings.titles,
                            ],
                            "Resource" // $t("Resource")
                        ),
                },
            },
        ],
    },
    {
        path: "/cgi-bin/koha/erm/licenses",
        component: { render: () => h(RouterView) },
        children: [
            {
                path: "",
                component: LicensesList,
                meta: {
                    breadcrumb: () => breadcrumb_paths.licenses,
                },
            },
            {
                path: ":license_id",
                component: LicensesShow,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.licenses,
                            "Show license" // $t("Show license")
                        ),
                },
            },
            {
                path: "delete/:license_id",
                component: LicensesFormConfirmDelete,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.licenses,
                            "Delete license" // $t("Delete license")
                        ),
                },
            },
            {
                path: "add",
                component: LicensesFormAdd,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.licenses,
                            "Add license" // $t("Add license")
                        ),
                },
            },
            {
                path: "edit/:license_id",
                component: LicensesFormAdd,
                meta: {
                    breadcrumb: () =>
                        build_breadcrumb(
                            breadcrumb_paths.licenses,
                            "Edit license" // $t("Edit license")
                        ),
                },
            },
        ],
    },
];
