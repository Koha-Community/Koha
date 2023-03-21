import Home from "../components/ERM/Home.vue";
import AgreementsList from "../components/ERM/AgreementsList.vue";
import AgreementsShow from "../components/ERM/AgreementsShow.vue";
import AgreementsFormAdd from "../components/ERM/AgreementsFormAdd.vue";
import EHoldingsLocalPackagesFormAdd from "../components/ERM/EHoldingsLocalPackagesFormAdd.vue";
import EHoldingsLocalTitlesFormAdd from "../components/ERM/EHoldingsLocalTitlesFormAdd.vue";
import EHoldingsLocalTitlesFormImport from "../components/ERM/EHoldingsLocalTitlesFormImport.vue";
import EHoldingsLocalPackagesList from "../components/ERM/EHoldingsLocalPackagesList.vue";
import EHoldingsLocalPackagesShow from "../components/ERM/EHoldingsLocalPackagesShow.vue";
import EHoldingsLocalResourcesShow from "../components/ERM/EHoldingsLocalResourcesShow.vue";
import EHoldingsLocalTitlesList from "../components/ERM/EHoldingsLocalTitlesList.vue";
import EHoldingsLocalTitlesShow from "../components/ERM/EHoldingsLocalTitlesShow.vue";
import EHoldingsEBSCOPackagesList from "../components/ERM/EHoldingsEBSCOPackagesList.vue";
import EHoldingsEBSCOPackagesShow from "../components/ERM/EHoldingsEBSCOPackagesShow.vue";
import EHoldingsEBSCOResourcesShow from "../components/ERM/EHoldingsEBSCOResourcesShow.vue";
import EHoldingsEBSCOTitlesList from "../components/ERM/EHoldingsEBSCOTitlesList.vue";
import EHoldingsEBSCOTitlesShow from "../components/ERM/EHoldingsEBSCOTitlesShow.vue";
import LicensesList from "../components/ERM/LicensesList.vue";
import LicensesShow from "../components/ERM/LicensesShow.vue";
import LicensesFormAdd from "../components/ERM/LicensesFormAdd.vue";

const breadcrumbs = {
    home: {
        text: "Home", // $t("Home")
        path: "/cgi-bin/koha/mainpage.pl",
    },
    erm_home: {
        text: "E-resource management", // $t("E-resource management")
        path: "/cgi-bin/koha/erm/erm.pl",
    },
    agreements: {
        text: "Agreements", // $t("Agreements")
        path: "/cgi-bin/koha/erm/agreements",
    },
    eholdings: {
        home: {
            text: "eHoldings", // $t("eHoldings")
        },
        local: {
            home: {
                text: "Local", // $t("Local")
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
        name: "Home",
        component: Home,
        meta: {
            breadcrumb: () => [breadcrumbs.home, breadcrumbs.erm_home],
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements",
        children: [
            {
                path: "",
                name: "AgreementsList",
                component: AgreementsList,
                meta: {
                    breadcrumb: () => breadcrumb_paths.agreements,
                },
            },
            {
                path: ":agreement_id",
                name: "AgreementsShow",
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
                path: "add",
                name: "AgreementsFormAdd",
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
                name: "AgreementsFormAddEdit",
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
                meta: {
                    breadcrumb: () => breadcrumb_paths.eholdings,
                },
            },
            {
                path: "local",
                children: [
                    {
                        path: "",
                        meta: {
                            breadcrumb: () => breadcrumb_paths.eholdings_local,
                        },
                    },
                    {
                        path: "packages",
                        children: [
                            {
                                path: "",
                                name: "EHoldingsLocalPackagesList",
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
                                name: "EHoldingsLocalPackagesShow",
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
                                path: "add",
                                name: "EHoldingsLocalPackagesFormAdd",
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
                                name: "EHoldingsLocalPackagesFormAddEdit",
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
                                name: "EHoldingsLocalTitlesList",
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
                                name: "EHoldingsLocalTitlesShow",
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
                                path: "add",
                                name: "EHoldingsLocalTitlesFormAdd",
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
                                name: "EHoldingsLocalTitlesFormAddEdit",
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
                                name: "EHoldingsLocalTitlesFormImport",
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
                        name: "EHoldingsLocalResourcesShow",
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
                        meta: {
                            breadcrumb: () => breadcrumb_paths.eholdings_ebsco,
                        },
                    },
                    {
                        path: "packages",
                        children: [
                            {
                                path: "",
                                name: "EHoldingsEBSCOPackagesList",
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
                                name: "EHoldingsEBSCOPackagesShow",
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
                                name: "EHoldingsEBSCOTitlesList",
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
                                name: "EHoldingsEBSCOTitlesShow",
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
                        name: "EHoldingsEBSCOResourcesShow",
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
                name: "LicensesList",
                component: LicensesList,
                meta: {
                    breadcrumb: () => breadcrumb_paths.licenses,
                },
            },
            {
                path: ":license_id",
                name: "LicensesShow",
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
                path: "add",
                name: "LicensesFormAdd",
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
                name: "LicensesFormAddEdit",
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
