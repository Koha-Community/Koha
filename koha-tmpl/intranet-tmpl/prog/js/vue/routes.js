import { h } from "vue";
import ERMHome from "./components/ERM/ERMHome.vue";
import AgreementsList from "./components/ERM/AgreementsList.vue";
import AgreementsShow from "./components/ERM/AgreementsShow.vue";
import AgreementsFormAdd from "./components/ERM/AgreementsFormAdd.vue";
import AgreementsFormConfirmDelete from "./components/ERM/AgreementsFormConfirmDelete.vue";
import EHoldingsMain from "./components/ERM/EHoldingsMain.vue";
import EHoldingsLocalHome from "./components/ERM/EHoldingsLocalHome.vue";
import EHoldingsLocalPackagesFormAdd from "./components/ERM/EHoldingsLocalPackagesFormAdd.vue";
import EHoldingsLocalTitlesFormConfirmDelete from "./components/ERM/EHoldingsLocalTitlesFormConfirmDelete.vue";
import EHoldingsLocalTitlesFormAdd from "./components/ERM/EHoldingsLocalTitlesFormAdd.vue";
import EHoldingsLocalTitlesFormImport from "./components/ERM/EHoldingsLocalTitlesFormImport.vue";
import EHoldingsLocalPackagesList from "./components/ERM/EHoldingsLocalPackagesList.vue";
import EHoldingsLocalPackagesShow from "./components/ERM/EHoldingsLocalPackagesShow.vue";
import EHoldingsLocalPackagesFormConfirmDelete from "./components/ERM/EHoldingsLocalPackagesFormConfirmDelete.vue";
import EHoldingsLocalResourcesShow from "./components/ERM/EHoldingsLocalResourcesShow.vue";
import EHoldingsLocalTitlesList from "./components/ERM/EHoldingsLocalTitlesList.vue";
import EHoldingsLocalTitlesShow from "./components/ERM/EHoldingsLocalTitlesShow.vue";
import EHoldingsEBSCOHome from "./components/ERM/EHoldingsEBSCOHome.vue";
import EHoldingsEBSCOPackagesList from "./components/ERM/EHoldingsEBSCOPackagesList.vue";
import EHoldingsEBSCOPackagesShow from "./components/ERM/EHoldingsEBSCOPackagesShow.vue";
import EHoldingsEBSCOResourcesShow from "./components/ERM/EHoldingsEBSCOResourcesShow.vue";
import EHoldingsEBSCOTitlesList from "./components/ERM/EHoldingsEBSCOTitlesList.vue";
import EHoldingsEBSCOTitlesShow from "./components/ERM/EHoldingsEBSCOTitlesShow.vue";
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
        local: {
            home: {
                text: "Local", // $t("Local")
                path: "/cgi-bin/koha/erm/eholdings/local",
            },
            titles: {
                text: "Titles", // $t("Titles")
                path: "/cgi-bin/koha/erm/eholdings/local/titles",
            },
            packages: {
                text: "Packages", // $t("Packages")
                path: "/cgi-bin/koha/erm/eholdings/local/packages",
            },
        },
        ebsco: {
            home: {
                text: "EBSCO", // $t("EBSCO")
                path: "/cgi-bin/koha/erm/eholdings/ebsco",
            },
            titles: {
                text: "Titles", // $t("Titles")
                path: "/cgi-bin/koha/erm/eholdings/ebsco/titles",
            },
            packages: {
                text: "Packages", // $t("Packages")
                path: "/cgi-bin/koha/erm/eholdings/ebsco/packages",
            },
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
    eholdings_local: [
        breadcrumbs.home,
        breadcrumbs.erm_home,
        breadcrumbs.eholdings.home,
        breadcrumbs.eholdings.local.home,
    ],
    eholdings_ebsco: [
        breadcrumbs.home,
        breadcrumbs.erm_home,
        breadcrumbs.eholdings.home,
        breadcrumbs.eholdings.ebsco.home,
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
    {
        path: "/cgi-bin/koha/mainpage.pl",
        beforeEnter(to, from, next) {
            window.location.href = "/cgi-bin/koha/mainpage.pl";
        },
    },
    {
        path: "/cgi-bin/koha/admin/background_jobs/:id",
        beforeEnter(to, from, next) {
            window.location.href =
                "/cgi-bin/koha/admin/background_jobs.pl?op=view&id=" +
                to.params.id;
        },
    },
    {
        path: "/cgi-bin/koha/erm/erm.pl",
        component: ERMHome,
        meta: {
            breadcrumb: () => [breadcrumbs.home, breadcrumbs.erm_home],
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements",
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
                            "Edit agreement" // $t("Edit agreement")
                        ),
                },
            },
        ],
    },
    {
        path: "/cgi-bin/koha/erm/eholdings",
        meta: {
            breadcrumb: () => breadcrumb_paths.eholdings,
        },
        children: [
            {
                path: "",
                component: EHoldingsMain,
                meta: {
                    breadcrumb: () => breadcrumb_paths.eholdings,
                },
            },
            {
                path: "local",
                children: [
                    {
                        path: "",
                        component: EHoldingsLocalHome,
                        meta: {
                            breadcrumb: () => breadcrumb_paths.eholdings_local,
                        },
                    },
                    {
                        path: "packages",
                        children: [
                            {
                                path: "",
                                component: EHoldingsLocalPackagesList,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb([
                                            breadcrumb_paths.eholdings_local,
                                            breadcrumbs.eholdings.local
                                                .packages,
                                        ]),
                                },
                            },
                            {
                                path: ":package_id",
                                component: EHoldingsLocalPackagesShow,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .packages,
                                            ],
                                            "Show package" // $t("Show package")
                                        ),
                                },
                            },
                            {
                                path: "delete/:package_id",
                                component:
                                    EHoldingsLocalPackagesFormConfirmDelete,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .packages,
                                            ],
                                            "Delete package" // $t("Delete package")
                                        ),
                                },
                            },
                            {
                                path: "add",
                                component: EHoldingsLocalPackagesFormAdd,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .packages,
                                            ],
                                            "Add package" // $t("Add package")
                                        ),
                                },
                            },
                            {
                                path: "edit/:package_id",
                                component: EHoldingsLocalPackagesFormAdd,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .packages,
                                            ],
                                            "Edit package" // $t("Edit package")
                                        ),
                                },
                            },
                        ],
                    },
                    {
                        path: "titles",
                        children: [
                            {
                                path: "",
                                component: EHoldingsLocalTitlesList,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb([
                                            breadcrumb_paths.eholdings_local,
                                            breadcrumbs.eholdings.local.titles,
                                        ]),
                                },
                            },
                            {
                                path: ":title_id",
                                component: EHoldingsLocalTitlesShow,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .titles,
                                            ],
                                            "Show title" // $t("Show title")
                                        ),
                                },
                            },
                            {
                                path: "delete/:title_id",
                                component:
                                    EHoldingsLocalTitlesFormConfirmDelete,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .titles,
                                            ],
                                            "Delete title" // $t("Delete title")
                                        ),
                                },
                            },
                            {
                                path: "add",
                                component: EHoldingsLocalTitlesFormAdd,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .titles,
                                            ],
                                            "Add title" // $t("Add title")
                                        ),
                                },
                            },
                            {
                                path: "edit/:title_id",
                                component: EHoldingsLocalTitlesFormAdd,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .titles,
                                            ],
                                            "Edit title" // $t("Edit title")
                                        ),
                                },
                            },
                            {
                                path: "import",
                                component: EHoldingsLocalTitlesFormImport,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_local,
                                                breadcrumbs.eholdings.local
                                                    .titles,
                                            ],
                                            "Import from a list" // $t("Import from a list")
                                        ),
                                },
                            },
                        ],
                    },
                    {
                        path: "resources/:resource_id",
                        component: EHoldingsLocalResourcesShow,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings_local,
                                        breadcrumbs.eholdings.local.titles,
                                    ],
                                    "Resource" // $t("Resource")
                                ),
                        },
                    },
                ],
            },
            {
                path: "ebsco",
                children: [
                    {
                        path: "",
                        component: EHoldingsEBSCOHome,
                        meta: {
                            breadcrumb: () => breadcrumb_paths.eholdings_ebsco,
                        },
                    },
                    {
                        path: "packages",
                        children: [
                            {
                                path: "",
                                component: EHoldingsEBSCOPackagesList,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb([
                                            breadcrumb_paths.eholdings_ebsco,
                                            breadcrumbs.eholdings.ebsco
                                                .packages,
                                        ]),
                                },
                            },
                            {
                                path: ":package_id",
                                component: EHoldingsEBSCOPackagesShow,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_ebsco,
                                                breadcrumbs.eholdings.ebsco
                                                    .packages,
                                            ],
                                            "Show package" // $t("Show package")
                                        ),
                                },
                            },
                        ],
                    },
                    {
                        path: "titles",
                        children: [
                            {
                                path: "",
                                component: EHoldingsEBSCOTitlesList,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb([
                                            breadcrumb_paths.eholdings_ebsco,
                                            breadcrumbs.eholdings.ebsco.titles,
                                        ]),
                                },
                            },
                            {
                                path: ":title_id",
                                component: EHoldingsEBSCOTitlesShow,
                                meta: {
                                    breadcrumb: () =>
                                        build_breadcrumb(
                                            [
                                                breadcrumb_paths.eholdings_ebsco,
                                                breadcrumbs.eholdings.ebsco
                                                    .titles,
                                            ],
                                            "Show title" // $t("Show title")
                                        ),
                                },
                            },
                        ],
                    },
                    {
                        path: "resources/:resource_id",
                        component: EHoldingsEBSCOResourcesShow,
                        meta: {
                            breadcrumb: () =>
                                build_breadcrumb(
                                    [
                                        breadcrumb_paths.eholdings_ebsco,
                                        breadcrumbs.eholdings.ebsco.titles,
                                    ],
                                    "Resource" // $t("Resource")
                                ),
                        },
                    },
                ],
            },
        ],
    },
    {
        path: "/cgi-bin/koha/erm/licenses",
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
