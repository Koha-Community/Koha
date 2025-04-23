import { markRaw } from "vue";

import Home from "../components/Vendors/Home.vue";
import VendorList from "../components/Vendors/VendorList.vue";
import VendorShow from "../components/Vendors/VendorShow.vue";
import VendorFormAdd from "../components/Vendors/VendorFormAdd.vue";

import { $__ } from "../i18n";

const vendorSearchBreadcrumb = ({ match, query }) => {
    if (!query || !query.supplier) return match.meta.self;
    match.meta.self.title = $__("Search for vendor: %s").format(query.supplier);
    match.meta.self.disabled = true;
    return match.meta.self;
};

export const routes = [
    {
        path: "/cgi-bin/koha/acqui/acqui-home.pl",
        is_default: true,
        is_base: true,
        title: $__("Acquisitions"),
        children: [
            {
                path: "",
                name: "Home",
                component: markRaw(Home),
                is_navigation_item: false,
            },
            {
                path: "/cgi-bin/koha/acquisition/vendors",
                title: $__("Vendors"),
                icon: "fa fa-shopping-cart",
                is_end_node: true,
                breadcrumbFormat: vendorSearchBreadcrumb,
                children: [
                    {
                        path: "",
                        name: "VendorList",
                        component: markRaw(VendorList),
                        alternateLeftMenu: "AcquisitionsMenu",
                    },
                    {
                        path: ":id",
                        name: "VendorShow",
                        component: markRaw(VendorShow),
                        title: $__("Show vendor"),
                        alternateLeftMenu: "VendorMenu",
                    },
                    {
                        path: "add",
                        name: "VendorFormAdd",
                        component: markRaw(VendorFormAdd),
                        title: $__("Add vendor"),
                        alternateLeftMenu: "none",
                    },
                    {
                        path: "edit/:id",
                        name: "VendorFormAddEdit",
                        component: markRaw(VendorFormAdd),
                        title: $__("Edit vendor"),
                        alternateLeftMenu: "VendorMenu",
                    },
                ],
            },
        ],
    },
];
