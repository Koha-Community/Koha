<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import { inject } from "vue";
import BaseResource from "./BaseResource.vue";
import { useBaseResource } from "../composables/base-resource.js";
import { storeToRefs } from "pinia";
import { APIClient } from "../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
        embedded: { type: Boolean, default: false },
        embedEvent: Function,
    },

    setup(props) {
        /* Import any global window methods here */
        const format_date = $date;
        const patron_to_html = $patron_to_html;

        /* Import any stores */
        const exampleStore = inject("exampleStore");
        const { examples } = storeToRefs(exampleStore);

        /*
         * If your resource has additional fields, simply add this line with the name of
         * your resource as it appears for additional fields
         */
        const extendedAttributesResourceType = "example";

        /*
         * If you need to include filters in your List component, add them as an array here.
         * The filters follow the format of resourceAttrs and are passed into the useBaseResource method
         */
        const additionalFilters = [];

        /*
         * If you want to amend the default buttons in the toolbar, include this method and pass it into the useBaseResource method
         * @param {array} defaultButtons - the default buttons from the useBaseResource method
         * @param {object} resource - the resource object
         */
        const defaultToolbarButtons = (defaultButtons, resource) => {
            return {
                list: [],
                show: [],
            };
        };

        /*
         * If you want to include additional buttons in the toolbar, include this method and pass it into the useBaseResource method
         * @param {object} resource - the resource object
         * @param {object} componentData - the prop data from the component rendering the toolbar
         */
        const additionalToolbarButtons = (resource, componentData) => {
            return {
                list: [
                    {
                        to: { name: "SkeletonList" },
                        icon: "plus",
                        title: $__("Import new skeleton"),
                    },
                ],
                show: [],
            };
        };

        /*
         * The arguments for the useBaseResource method are documented in base-resource.js
         */
        const baseResource = useBaseResource({
            resourceName: "skeleton",
            nameAttr: "name",
            idAttr: "skeleton_id",
            components: {
                show: "SkeletonsShow",
                list: "SkeletonsList",
                add: "SkeletonsFormAdd",
                edit: "SkeletonsFormAddEdit",
            },
            apiClient: APIClient.skel.skeletons,
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this skeleton?"
                ),
                deleteSuccessMessage: $__("Skeleton %s deleted"),
                displayName: $__("Skeleton"),
                editLabel: $__("Edit skeleton #%s"),
                emptyListMessage: $__("There are no skeletons defined"),
                newLabel: $__("New skeleton"),
            },
            table: {
                resourceTableUrl:
                    APIClient.skel.httpClient._baseURL + "skeletons",
                addAdditionalFilters: true,
                additionalFilters,
            },
            embedded: props.embedded,
            extendedAttributesResourceType,
            resourceAttrs: [],
            moduleStore: "examplesStore",
            examples,
            props: props,
            additionalToolbarButtons,
            defaultToolbarButtons,
            // The default behaviour for the below is the "show" component so is not necessary if this is the desired behaviour
            navigationOnFormSave: "SkeletonsList",
        });

        /*
         * If your resource has filters on the table, you need to include this method
         * to retrieve the default values for the filters from the url.
         * You can then use these values to set the default values for the filters in tableOptions
         * or pass them into a tableUrl method
         */
        const defaults = baseResource.getFilterValues(
            baseResource.route.query,
            additionalFilters
        );

        /*
         * These are the datatables options that will pass to the table
         * Notice that you don't need to include columns as these are generated automatically
         */
        const tableOptions = {
            options: {
                embed: "skeleton_embed",
            },
            url: baseResource.getResourceTableUrl(),
            table_settings: baseResource.skeleton_table_settings,
            add_filters: true,
            filters_options: {},
            actions: {
                "-1": ["edit", "delete"],
            },
            default_filters: {
                // use 'defaults' from above here to access any filters
            },
        };

        /*
         * If your resource has a form, you need to include this method
         * to handle the form submit
         */
        const onFormSave = (e, skeletonToSave) => {
            e.preventDefault();

            let skeleton = JSON.parse(JSON.stringify(skeletonToSave)); // copy
            let skeleton_id = skeleton.skeleton_id;

            delete skeleton.skeleton_id;

            if (skeleton_id) {
                return baseResource.apiClient
                    .update(skeleton, skeleton_id)
                    .then(
                        skeleton => {
                            baseResource.setMessage($__("Skeleton updated"));
                            return skeleton;
                        },
                        error => {}
                    );
            } else {
                return baseResource.apiClient.create(skeleton).then(
                    skeleton => {
                        baseResource.setMessage($__("Skeleton created"));
                        return skeleton;
                    },
                    error => {}
                );
            }
        };

        /*
         * If you want to edit the default table url, include this method and add it into your tableOptions on the url property
         */
        const tableUrl = filters => {
            let url = baseResource.getResourceTableUrl();
            url += "hello_world";
            return url;
        };

        /*
         * If your resource has filters on the table, you need to include this method
         * to filter the table
         */
        const filterTable = async (filters, table, embedded = false) => {
            table.redraw(tableUrl(filters));
        };

        /*
         * If you want to append data to the show view, include this method
         * The format of the array values is the same as resourceAttrs
         * @param {object} componentData - contains all props passed to ResourceShow,
         *   the resource object, and any further props coming from this resource component
         */
        const appendToShow = componentData => {
            return [];
        };

        /*
         * If you want to run some logic after the resource has been fetched when editing or displaying it, you can add this hook which will be called automatically
         * @param {object} componentData - contains all props passed to ResourceShow/ResourceFormSave,
         *   the resource object, and any further props coming from this resource component
         * @param {object} resource - the newly fetched resource object
         * @param {string} caller - the component that called this hook - either "show" or "form"
         */
        const afterResourceFetch = (componentData, resource, caller) => {
            if (caller === "show") {
            }
            if (caller === "form") {
            }
        };

        return {
            ...baseResource,
            tableOptions,
            checkForm,
            onFormSave,
            tableUrl,
            filterTable,
            appendToShow,
            afterResourceFetch,
        };
    },
    /*
     * Emits the select-resource event in case this resource is embedded into another component
     */
    emits: ["select-resource"],
    name: "SkeletonResource",
    components: {
        BaseResource,
    },
};
</script>
