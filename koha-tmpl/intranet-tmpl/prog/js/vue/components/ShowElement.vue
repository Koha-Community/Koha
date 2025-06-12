<template>
    <template
        v-if="
            (attribute.type == 'text' ||
                attribute.type == 'textarea' ||
                (attribute.type == 'select' && !attribute.avCat) ||
                attribute?.type == 'date') &&
            (!attribute.hidden ||
                (attribute.hidden && attribute.hidden(resource)))
        "
    >
        <label>{{ attribute.label }}:</label>
        <LinkWrapper :linkData="attribute?.link" :resource="resource">
            <span>
                {{
                    attribute?.format ||
                    (attribute.value && attribute?.value.includes("."))
                        ? formatValue(attribute, resource)
                        : resource[attribute.name]
                }}
            </span>
        </LinkWrapper>
    </template>
    <template
        v-else-if="
            attribute.type == 'av' ||
            (attribute.type == 'select' && attribute.avCat)
        "
    >
        <label>{{ attribute.label }}:</label>
        <LinkWrapper :linkData="attribute?.link" :resource="resource">
            <span>{{
                instancedResource.get_lib_from_av(
                    attribute.avCat,
                    resource[attribute.name]
                )
            }}</span>
        </LinkWrapper>
    </template>
    <template
        v-else-if="attribute.type == 'boolean' || attribute.type == 'checkbox'"
    >
        <label>{{ attribute.label }}:</label>
        <span v-if="resource[attribute.name]">{{ $__("Yes") }}</span>
        <span v-else>{{ $__("No") }}</span>
    </template>
    <template v-else-if="attribute.type === 'table'">
        <template v-if="attribute.hidden && attribute.hidden(resource)">
            <label>{{ attribute.label }}</label>
            <table>
                <thead>
                    <th
                        v-for="column in attribute.columns"
                        :key="column.name + 'head'"
                    >
                        {{ column.name }}
                    </th>
                </thead>
                <tbody>
                    <tr
                        v-for="(row, counter) in resource[attribute.columnData]"
                        v-bind:key="counter"
                    >
                        <td
                            v-for="dataColumn in attribute.columns"
                            :key="dataColumn.name + 'data'"
                        >
                            <template
                                v-if="
                                    dataColumn.format ||
                                    dataColumn.value.includes('.')
                                "
                            >
                                <LinkWrapper
                                    :linkData="dataColumn.link"
                                    :resource="row"
                                >
                                    {{ formatValue(dataColumn, row) }}
                                </LinkWrapper>
                            </template>
                            <template v-else-if="dataColumn.av">
                                <LinkWrapper
                                    :linkData="dataColumn.link"
                                    :resource="row"
                                >
                                    {{
                                        instancedResource.get_lib_from_av(
                                            dataColumn.av,
                                            row[dataColumn.value]
                                        )
                                    }}
                                </LinkWrapper>
                            </template>
                            <template v-else>
                                <LinkWrapper
                                    :linkData="dataColumn.link"
                                    :resource="row"
                                >
                                    {{ row[dataColumn.value] }}
                                </LinkWrapper>
                            </template>
                        </td>
                    </tr>
                </tbody>
            </table>
        </template>
    </template>
    <template v-else-if="attribute?.type === 'component'">
        <template v-if="attribute.hidden && attribute.hidden(resource)">
            <label v-if="attribute.label">{{ attribute.label }}:</label>
            <component
                :is="requiredComponent"
                v-bind="getComponentProps(true)"
            ></component>
        </template>
    </template>
    <template
        v-else-if="attribute.type == 'relationship' && attribute.componentPath"
    >
        <template v-if="attribute.hidden && attribute.hidden(resource)">
            <component
                :is="requiredComponent"
                v-bind="getComponentProps(true)"
            ></component>
        </template>
    </template>
    <template
        v-else-if="
            attr.type == 'additional_fields' &&
            resource._strings?.additional_field_values.length > 0
        "
    >
        <AdditionalFieldsDisplay
            :additional_field_values="resource._strings.additional_field_values"
            :extended_attributes_resource_type="
                attr.extended_attributes_resource_type
            "
        ></AdditionalFieldsDisplay>
    </template>
</template>

<script>
import LinkWrapper from "./LinkWrapper.vue";
import AdditionalFieldsDisplay from "./AdditionalFieldsDisplay.vue";
import { useBaseElement } from "../composables/base-element.js";
import { computed, defineAsyncComponent } from "vue";

export default {
    components: { LinkWrapper, AdditionalFieldsDisplay },
    setup(props) {
        const baseElement = useBaseElement({ ...props });

        const requiredComponent = computed(() => {
            const importPath = baseElement.identifyAndImportComponent(
                props.attr,
                true
            );
            return defineAsyncComponent(() => import(`${importPath}`));
        });
        const attribute = computed(() => {
            if (props.attr.showElement) {
                return { ...props.attr, ...props.attr.showElement };
            }
            return props.attr;
        });
        const formatValue = (attr, resource) => {
            const valueKey = attr.hasOwnProperty("value")
                ? attr.value
                : attr.name;
            if (valueKey?.includes(".")) {
                return baseElement.accessNestedProperty(valueKey, resource);
            }
            const displayValue = attr.format(
                resource[valueKey] ? resource[valueKey] : valueKey,
                resource
            );
            if (displayValue == "Invalid Date") {
                return "";
            }
            return displayValue || "";
        };

        return {
            ...baseElement,
            requiredComponent,
            attribute,
            formatValue,
        };
    },
    props: {
        resource: Object | null,
        attr: Object | null,
        instancedResource: Object | null,
    },
    name: "ShowElement",
};
</script>
