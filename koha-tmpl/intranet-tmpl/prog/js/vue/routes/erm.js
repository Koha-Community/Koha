import { markRaw } from "vue";

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

import { $__ } from "../i18n";

export const routes = [
    {
        path: "/cgi-bin/koha/admin/background_jobs/:id",
        is_base: true,
        beforeEnter(to, from, next) {
            window.location.href =
                "/cgi-bin/koha/admin/background_jobs.pl?op=view&id=" +
                to.params.id;
        },
    },
    {
        path: "/cgi-bin/koha/erm/erm.pl",
        is_default: true,
        is_base: true,
        title: $__("E-resource management"),
        children: [
            {
                path: "",
                name: "Home",
                component: markRaw(Home),
                is_navigation_item: false,
            },
            {
                path: "/cgi-bin/koha/erm/agreements",
                title: $__("Agreements"),
                icon: "fa fa-check-circle",
                is_end_node: true,
                children: [
                    {
                        path: "",
                        name: "AgreementsList",
                        component: markRaw(AgreementsList),
                    },
                    {
                        path: ":agreement_id",
                        name: "AgreementsShow",
                        component: markRaw(AgreementsShow),
                        title: $__("Show agreement"),
                    },
                    {
                        path: "add",
                        name: "AgreementsFormAdd",
                        component: markRaw(AgreementsFormAdd),
                        title: $__("Add agreement"),
                    },
                    {
                        path: "edit/:agreement_id",
                        name: "AgreementsFormAddEdit",
                        component: markRaw(AgreementsFormAdd),
                        title: $__("Edit agreement"),
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/erm/licenses",
                title: $__("Licenses"),
                icon: "fa fa-gavel",
                is_end_node: true,
                children: [
                    {
                        path: "",
                        name: "LicensesList",
                        component: markRaw(LicensesList),
                    },
                    {
                        path: ":license_id",
                        name: "LicensesShow",
                        component: markRaw(LicensesShow),
                        title: $__("Show license"),
                    },
                    {
                        path: "add",
                        name: "LicensesFormAdd",
                        component: markRaw(LicensesFormAdd),
                        title: $__("Add license"),
                    },
                    {
                        path: "edit/:license_id",
                        name: "LicensesFormAddEdit",
                        component: markRaw(LicensesFormAdd),
                        title: $__("Edit license"),
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/erm/eholdings",
                title: $__("eHoldings"),
                icon: "fa fa-crosshairs",
                disabled: true,
                children: [
                    {
                        path: "local",
                        title: $__("Local"),
                        icon: "fa-solid fa-location-dot",
                        disabled: true,
                        children: [
                            {
                                path: "packages",
                                title: $__("Packages"),
                                icon: "fa fa-archive",
                                is_end_node: true,
                                children: [
                                    {
                                        path: "",
                                        name: "EHoldingsLocalPackagesList",
                                        component: markRaw(
                                            EHoldingsLocalPackagesList
                                        ),
                                    },
                                    {
                                        path: ":package_id",
                                        name: "EHoldingsLocalPackagesShow",
                                        component: markRaw(
                                            EHoldingsLocalPackagesShow
                                        ),
                                        title: $__("Show package"),
                                    },
                                    {
                                        path: "add",
                                        name: "EHoldingsLocalPackagesFormAdd",
                                        component: markRaw(
                                            EHoldingsLocalPackagesFormAdd
                                        ),
                                        title: $__("Add package"),
                                    },
                                    {
                                        path: "edit/:package_id",
                                        name: "EHoldingsLocalPackagesFormAddEdit",
                                        component: markRaw(
                                            EHoldingsLocalPackagesFormAdd
                                        ),
                                        title: $__("Edit package"),
                                    },
                                ],
                            },
                            {
                                path: "titles",
                                title: $__("Titles"),
                                icon: "fa-solid fa-arrow-down-a-z",
                                is_end_node: true,
                                children: [
                                    {
                                        path: "",
                                        name: "EHoldingsLocalTitlesList",
                                        component: markRaw(
                                            EHoldingsLocalTitlesList
                                        ),
                                    },
                                    {
                                        path: ":title_id",
                                        name: "EHoldingsLocalTitlesShow",
                                        component: markRaw(
                                            EHoldingsLocalTitlesShow
                                        ),
                                        title: $__("Show title"),
                                    },
                                    {
                                        path: "add",
                                        name: "EHoldingsLocalTitlesFormAdd",
                                        component: markRaw(
                                            EHoldingsLocalTitlesFormAdd
                                        ),
                                        title: $__("Add title"),
                                    },
                                    {
                                        path: "edit/:title_id",
                                        name: "EHoldingsLocalTitlesFormAddEdit",
                                        component: markRaw(
                                            EHoldingsLocalTitlesFormAdd
                                        ),
                                        title: $__("Edit title"),
                                    },
                                    {
                                        path: "import",
                                        name: "EHoldingsLocalTitlesFormImport",
                                        component: markRaw(
                                            EHoldingsLocalTitlesFormImport
                                        ),
                                        title: $__("Import from a list"),
                                    },
                                    {
                                        path: "/cgi-bin/koha/erm/eholdings/local/resources/:resource_id",
                                        name: "EHoldingsLocalResourcesShow",
                                        component: markRaw(
                                            EHoldingsLocalResourcesShow
                                        ),
                                        title: $__("Resource"),
                                    },
                                ],
                            },
                        ],
                    },
                    {
                        path: "ebsco",
                        title: $__("EBSCO"),
                        icon: "fa fa-globe",
                        disabled: true,
                        children: [
                            {
                                path: "packages",
                                title: $__("Packages"),
                                icon: "fa fa-archive",
                                is_end_node: true,
                                children: [
                                    {
                                        path: "",
                                        name: "EHoldingsEBSCOPackagesList",
                                        component: markRaw(
                                            EHoldingsEBSCOPackagesList
                                        ),
                                    },
                                    {
                                        path: ":package_id",
                                        name: "EHoldingsEBSCOPackagesShow",
                                        component: markRaw(
                                            EHoldingsEBSCOPackagesShow
                                        ),
                                        title: $__("Show package"),
                                    },
                                ],
                            },
                            {
                                path: "titles",
                                title: $__("Titles"),
                                icon: "fa-solid fa-arrow-down-a-z",
                                is_end_node: true,
                                children: [
                                    {
                                        path: "",
                                        name: "EHoldingsEBSCOTitlesList",
                                        component: markRaw(
                                            EHoldingsEBSCOTitlesList
                                        ),
                                    },
                                    {
                                        path: ":title_id",
                                        name: "EHoldingsEBSCOTitlesShow",
                                        component: markRaw(
                                            EHoldingsEBSCOTitlesShow
                                        ),
                                        title: $__("Show title"),
                                    },
                                    {
                                        path: "/cgi-bin/koha/erm/eholdings/ebsco/resources/:resource_id",
                                        name: "EHoldingsEBSCOResourcesShow",
                                        component: markRaw(
                                            EHoldingsEBSCOResourcesShow
                                        ),
                                        title: $__("Resource"),
                                        is_navigation_item: false,
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
