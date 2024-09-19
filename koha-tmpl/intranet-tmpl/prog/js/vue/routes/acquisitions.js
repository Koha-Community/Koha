import { markRaw } from "vue";

import Home from "../components/Vendors/Home.vue";
import VendorList from "../components/Vendors/VendorList.vue";
import VendorShow from "../components/Vendors/VendorShow.vue";

import { $__ } from "../i18n";

export const routes = [
    {
        path: "/cgi-bin/koha/acqui/booksellers.pl",
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
                path: "/cgi-bin/koha/vendors",
                title: $__("Vendors"),
                icon: "fa fa-shopping-cart",
                is_end_node: true,
                children: [
                    {
                        path: "",
                        name: "VendorList",
                        component: markRaw(VendorList),
                    },
                    {
                        path: ":vendor_id",
                        name: "VendorShow",
                        component: markRaw(VendorShow),
                        title: $__("Show vendor"),
                    },
                ],
            },
        ],
    },
];
