import { markRaw } from "vue";

import Home from "../components/ERM/Home.vue";
import EHoldingsLocalTitlesFormImport from "../components/ERM/EHoldingsLocalTitlesFormImport.vue";
import EHoldingsLocalTitlesKBARTImport from "../components/ERM/EHoldingsLocalTitlesKBARTImport.vue";
import EHoldingsLocalResourcesShow from "../components/ERM/EHoldingsLocalResourcesShow.vue";
import EHoldingsEBSCOPackagesList from "../components/ERM/EHoldingsEBSCOPackagesList.vue";
import EHoldingsEBSCOPackagesShow from "../components/ERM/EHoldingsEBSCOPackagesShow.vue";
import EHoldingsEBSCOResourcesShow from "../components/ERM/EHoldingsEBSCOResourcesShow.vue";
import EHoldingsEBSCOTitlesList from "../components/ERM/EHoldingsEBSCOTitlesList.vue";
import EHoldingsEBSCOTitlesShow from "../components/ERM/EHoldingsEBSCOTitlesShow.vue";
import UsageStatisticsDataProvidersList from "../components/ERM/UsageStatisticsDataProvidersList.vue";
import UsageStatisticsDataProvidersSummary from "../components/ERM/UsageStatisticsDataProvidersSummary.vue";
import UsageStatisticsDataProvidersFormAdd from "../components/ERM/UsageStatisticsDataProvidersFormAdd.vue";
import UsageStatisticsDataProvidersShow from "../components/ERM/UsageStatisticsDataProvidersShow.vue";
import UsageStatisticsReportsHome from "../components/ERM/UsageStatisticsReportsHome.vue";
import UsageStatisticsReportsViewer from "../components/ERM/UsageStatisticsReportsViewer.vue";

import ResourceWrapper from "../components/ResourceWrapper.vue";

import { $__ } from "@koha-vue/i18n";

export const routes = [
    {
        path: "/cgi-bin/koha/erm/erm.pl",
        name: "ERMHome",
        redirect: "/cgi-bin/koha/erm/home",
        is_default: true,
        is_base: true,
        title: $__("E-resource management"),
        children: [
            {
                path: "/cgi-bin/koha/erm/home",
                name: "Home",
                component: markRaw(Home),
                title: $__("Home"),
                icon: "fa fa-home",
            },
            {
                path: "/cgi-bin/koha/erm/agreements",
                title: $__("Agreements"),
                icon: "fa fa-check-circle",
                is_end_node: true,
                resource: "ERM/AgreementResource.vue",
                children: [
                    {
                        path: "",
                        name: "AgreementsList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":agreement_id",
                        name: "AgreementsShow",
                        component: markRaw(ResourceWrapper),
                        title: "{name}",
                    },
                    {
                        path: "add",
                        name: "AgreementsFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add agreement"),
                    },
                    {
                        path: "edit/:agreement_id",
                        name: "AgreementsFormAddEdit",
                        component: markRaw(ResourceWrapper),
                        title: "{name}",
                        breadcrumbFormat: ({ match, params, query }) => {
                            match.name = "AgreementsShow";
                            return match;
                        },
                        additionalBreadcrumbs: [
                            { title: $__("Modify agreement"), disabled: true },
                        ],
                    },
                ],
            },
            {
                path: "/cgi-bin/koha/erm/licenses",
                title: $__("Licenses"),
                icon: "fa fa-gavel",
                is_end_node: true,
                resource: "ERM/LicenseResource.vue",
                children: [
                    {
                        path: "",
                        name: "LicensesList",
                        component: markRaw(ResourceWrapper),
                    },
                    {
                        path: ":license_id",
                        name: "LicensesShow",
                        component: markRaw(ResourceWrapper),
                        title: "{name}",
                    },
                    {
                        path: "add",
                        name: "LicensesFormAdd",
                        component: markRaw(ResourceWrapper),
                        title: $__("Add license"),
                    },
                    {
                        path: "edit/:license_id",
                        name: "LicensesFormAddEdit",
                        component: markRaw(ResourceWrapper),
                        title: "{name}",
                        breadcrumbFormat: ({ match, params, query }) => {
                            match.name = "LicensesShow";
                            return match;
                        },
                        additionalBreadcrumbs: [
                            { title: $__("Modify license"), disabled: true },
                        ],
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
                                resource:
                                    "ERM/EHoldingsLocalPackageResource.vue",
                                children: [
                                    {
                                        path: "",
                                        name: "EHoldingsLocalPackagesList",
                                        component: markRaw(ResourceWrapper),
                                    },
                                    {
                                        path: ":package_id",
                                        name: "EHoldingsLocalPackagesShow",
                                        component: markRaw(ResourceWrapper),
                                        title: "{name}",
                                    },
                                    {
                                        path: "add",
                                        name: "EHoldingsLocalPackagesFormAdd",
                                        component: markRaw(ResourceWrapper),
                                        title: $__("Add package"),
                                    },
                                    {
                                        path: "edit/:package_id",
                                        name: "EHoldingsLocalPackagesFormAddEdit",
                                        component: markRaw(ResourceWrapper),
                                        title: "{name}",
                                        breadcrumbFormat: ({
                                            match,
                                            params,
                                            query,
                                        }) => {
                                            match.name =
                                                "EHoldingsLocalPackagesShow";
                                            return match;
                                        },
                                        additionalBreadcrumbs: [
                                            {
                                                title: $__("Modify package"),
                                                disabled: true,
                                            },
                                        ],
                                    },
                                ],
                            },
                            {
                                path: "titles",
                                title: $__("Titles"),
                                icon: "fa-solid fa-arrow-down-a-z",
                                is_end_node: true,
                                resource: "ERM/EHoldingsLocalTitleResource.vue",
                                children: [
                                    {
                                        path: "",
                                        name: "EHoldingsLocalTitlesList",
                                        component: markRaw(ResourceWrapper),
                                    },
                                    {
                                        path: ":title_id",
                                        name: "EHoldingsLocalTitlesShow",
                                        component: markRaw(ResourceWrapper),
                                        title: "{publication_title}",
                                    },
                                    {
                                        path: "add",
                                        name: "EHoldingsLocalTitlesFormAdd",
                                        component: markRaw(ResourceWrapper),
                                        title: $__("Add title"),
                                    },
                                    {
                                        path: "edit/:title_id",
                                        name: "EHoldingsLocalTitlesFormAddEdit",
                                        component: markRaw(ResourceWrapper),
                                        title: "{publication_title}",
                                        breadcrumbFormat: ({
                                            match,
                                            params,
                                            query,
                                        }) => {
                                            match.name =
                                                "EHoldingsLocalTitlesShow";
                                            return match;
                                        },
                                        additionalBreadcrumbs: [
                                            {
                                                title: $__("Modify title"),
                                                disabled: true,
                                            },
                                        ],
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
                                        path: "kbart-import",
                                        name: "EHoldingsLocalTitlesKBARTImport",
                                        component: markRaw(
                                            EHoldingsLocalTitlesKBARTImport
                                        ),
                                        title: $__("Import from a KBART file"),
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
            {
                path: "/cgi-bin/koha/erm/eusage",
                title: $__("eUsage"),
                icon: "fa fa-tasks",
                disabled: true,
                children: [
                    {
                        path: "usage_data_providers",
                        title: $__("Data providers"),
                        icon: "fa fa-exchange",
                        is_end_node: true,
                        children: [
                            {
                                path: "",
                                name: "UsageStatisticsDataProvidersList",
                                component: markRaw(
                                    UsageStatisticsDataProvidersList
                                ),
                            },
                            {
                                path: ":erm_usage_data_provider_id",
                                name: "UsageStatisticsDataProvidersShow",
                                component: markRaw(
                                    UsageStatisticsDataProvidersShow
                                ),
                                title: $__("Show provider"),
                            },
                            {
                                path: "add",
                                name: "UsageStatisticsDataProvidersFormAdd",
                                component: markRaw(
                                    UsageStatisticsDataProvidersFormAdd
                                ),
                                title: $__("Add data provider"),
                            },
                            {
                                path: "edit/:erm_usage_data_provider_id",
                                name: "UsageStatisticsDataProvidersFormAddEdit",
                                component: markRaw(
                                    UsageStatisticsDataProvidersFormAdd
                                ),
                                title: $__("Edit data provider"),
                            },
                            {
                                path: "summary",
                                name: "UsageStatisticsDataProvidersSummary",
                                component: markRaw(
                                    UsageStatisticsDataProvidersSummary
                                ),
                                title: $__("Data providers summary"),
                            },
                        ],
                    },
                    {
                        path: "reports",
                        title: $__("Reports"),
                        icon: "fa fa-bar-chart",
                        is_end_node: true,
                        children: [
                            {
                                path: "",
                                name: "UsageStatisticsReportsHome",
                                component: markRaw(UsageStatisticsReportsHome),
                            },
                            {
                                path: "viewer",
                                name: "UsageStatisticsReportsViewer",
                                component: markRaw(
                                    UsageStatisticsReportsViewer
                                ),
                                title: $__("View report"),
                            },
                        ],
                    },
                ],
            },
        ],
    },
];
