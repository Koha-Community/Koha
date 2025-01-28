import { markRaw } from "vue";

import ResourceWrapper from "../../components/ResourceWrapper.vue";

import { $__ } from "../../i18n";

export default {
    title: $__("Administration"),
    path: "",
    href: "/cgi-bin/koha/admin/admin-home.pl",
    is_base: true,
    is_default: true,
    children: [
        {
            title: $__("Record sources"),
            path: "/cgi-bin/koha/admin/record_sources",
            is_end_node: true,
            resource: "Admin/RecordSources/RecordSourcesResource.vue",
            children: [
                {
                    path: "",
                    name: "RecordSourcesList",
                    component: markRaw(ResourceWrapper),
                },
                {
                    component: markRaw(ResourceWrapper),
                    name: "RecordSourcesFormAdd",
                    path: "add",
                    title: $__("Add record source"),
                },
                {
                    component: markRaw(ResourceWrapper),
                    name: "RecordSourcesFormAddEdit",
                    path: "edit/:record_source_id",
                    title: $__("Edit record source"),
                },
            ],
        },
    ],
};
