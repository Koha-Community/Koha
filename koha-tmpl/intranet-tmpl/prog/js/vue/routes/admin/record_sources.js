import { markRaw } from "vue";
import RecordSourcesFormAdd from "../../components/Admin/RecordSources/FormAdd.vue";
import RecordSourcesList from "../../components/Admin/RecordSources/List.vue";
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
            children: [
                {
                    path: "",
                    name: "RecordSourcesList",
                    component: markRaw(RecordSourcesList),
                },
                {
                    component: markRaw(RecordSourcesFormAdd),
                    name: "RecordSourcesFormAdd",
                    path: "add",
                    title: $__("Add record source"),
                },
                {
                    component: markRaw(RecordSourcesFormAdd),
                    name: "RecordSourcesFormAddEdit",
                    path: "edit/:record_source_id",
                    title: $__("Edit record source"),
                },
            ],
        },
    ],
};
