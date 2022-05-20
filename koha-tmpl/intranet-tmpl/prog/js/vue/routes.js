import ERMHome from "./components/ERM/ERMHome.vue";
import AgreementsList from "./components/ERM/AgreementsList.vue";
import AgreementsShow from "./components/ERM/AgreementsShow.vue";
import AgreementsFormAdd from "./components/ERM/AgreementsFormAdd.vue";
import AgreementsFormConfirmDelete from "./components/ERM/AgreementsFormConfirmDelete.vue";
import PackagesList from "./components/ERM/PackagesList.vue";
import PackagesShow from "./components/ERM/PackagesShow.vue";
import PackagesFormAdd from "./components/ERM/PackagesFormAdd.vue";
import PackagesFormConfirmDelete from "./components/ERM/PackagesFormConfirmDelete.vue";
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
    licenses: { text: "Licenses", path: "/cgi-bin/koha/erm/licenses" },
    packages: { text: "Packages", path: "/cgi-bin/koha/erm/packages" },
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
        path: "/cgi-bin/koha/erm/packages",
        component: PackagesList,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.packages,
            ],
            view: "list",
        },
    },
    {
        path: "/cgi-bin/koha/erm/packages/:package_id",
        component: PackagesShow,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.packages,
            ],
            view: "show",
        },
    },
    {
        path: "/cgi-bin/koha/erm/packages/delete/:package_id",
        component: PackagesFormConfirmDelete,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.packages,
            ],
            view: "confirm-delete-form",
        },
    },
    {
        path: "/cgi-bin/koha/erm/packages/add",
        component: PackagesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.packages,
            ],
            view: "add",
        },
    },
    {
        path: "/cgi-bin/koha/erm/packages/edit/:package_id",
        component: PackagesFormAdd,
        meta: {
            breadcrumb: [
                breadcrumbs.home,
                breadcrumbs.erm_home,
                breadcrumbs.packages,
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
