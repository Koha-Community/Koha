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
import EHoldingsTitlesList from "./components/ERM/EHoldingsTitlesList.vue";
import EHoldingsTitlesShow from "./components/ERM/EHoldingsTitlesShow.vue";
import EHoldingsTitlesFormAdd from "./components/ERM/EHoldingsTitlesFormAdd.vue";
import EHoldingsTitlesFormConfirmDelete from "./components/ERM/EHoldingsTitlesFormConfirmDelete.vue";
import LicensesList from "./components/ERM/LicensesList.vue";
import LicensesShow from "./components/ERM/LicensesShow.vue";
import LicensesFormAdd from "./components/ERM/LicensesFormAdd.vue";
import LicensesFormConfirmDelete from "./components/ERM/LicensesFormConfirmDelete.vue";

const breadcrumbs = {
    home: { text: "Home", path: "/cgi-bin/koha/mainpage.pl" },
    erm_home: {
        text: "E-Resource management",
        path: "/cgi-bin/koha/erm/erm.pl",
    },
    agreements: { text: "Agreements", path: "/cgi-bin/koha/erm/agreements" },
    eholdings: {
        home: { text: "eHoldings", path: "/cgi-bin/koha/erm/eholdings" },
        titles: { text: "Titles", path: "/cgi-bin/koha/erm/eholdings/titles" },
        packages: {
            text: "Packages",
            path: "/cgi-bin/koha/erm/eholdings/packages",
        },
    },
    licenses: { text: "Licenses", path: "/cgi-bin/koha/erm/licenses" },
};
export const routes = [
    { path: "/cgi-bin/koha/mainpage.pl" },
    {
        path: "/cgi-bin/koha/erm/erm.pl",
        component: ERMHome,
        meta: {
            breadcrumb: [breadcrumbs.home, breadcrumbs.erm_home],
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements",
        component: AgreementsList,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.agreements,
            ],
            view: "list",
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements/:agreement_id",
        component: AgreementsShow,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.agreements,
            ],
            view: "show",
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements/delete/:agreement_id",
        component: AgreementsFormConfirmDelete,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.agreements,
            ],
            view: "confirm-delete",
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements/add",
        component: AgreementsFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.agreements,
            ],
            view: "add",
        },
    },
    {
        path: "/cgi-bin/koha/erm/agreements/edit/:agreement_id",
        component: AgreementsFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.agreements,
            ],
            view: "edit",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings",
        component: EHoldingsMain,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
            ],
            view: "list",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/packages",
        component: EHoldingsPackagesList,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.packages,
            ],
            view: "list",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/packages/:package_id",
        component: EHoldingsPackagesShow,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.packages,
            ],
            view: "show",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/packages/delete/:package_id",
        component: EHoldingsPackagesFormConfirmDelete,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.packages,
            ],
            view: "confirm-delete-form",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/packages/add",
        component: EHoldingsPackagesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.packages,
            ],
            view: "add",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/packages/edit/:package_id",
        component: EHoldingsPackagesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.packages,
            ],
            view: "edit",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/titles",
        component: EHoldingsTitlesList,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.titles,
            ],
            view: "list",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/titles/:title_id",
        component: EHoldingsTitlesShow,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.titles,
            ],
            view: "show",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/titles/delete/:title_id",
        component: EHoldingsTitlesFormConfirmDelete,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.titles,
            ],
            view: "confirm-delete-form",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/titles/add",
        component: EHoldingsTitlesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.titles,
            ],
            view: "add",
        },
    },
    {
        path: "/cgi-bin/koha/erm/eholdings/titles/edit/:title_id",
        component: EHoldingsTitlesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.eholdings.home,
                breadcrumbs.eholdings.titles,
            ],
            view: "edit",
        },
    },
    {
        path: "/cgi-bin/koha/erm/licenses",
        component: LicensesList,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.licenses,
            ],
            view: "list",
        },
    },
    {
        path: "/cgi-bin/koha/erm/licenses/:license_id",
        component: LicensesShow,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.licenses,
            ],
            view: "show",
        },
    },
    {
        path: "/cgi-bin/koha/erm/licenses/delete/:license_id",
        component: LicensesFormConfirmDelete,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.licenses,
            ],
            view: "confirm-delete-form",
        },
    },
    {
        path: "/cgi-bin/koha/erm/licenses/add",
        component: LicensesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.licenses,
            ],
            view: "add",
        },
    },
    {
        path: "/cgi-bin/koha/erm/licenses/edit/:license_id",
        component: LicensesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.licenses,
            ],
            view: "edit",
        },
    },
];
