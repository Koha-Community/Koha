<template>
    <div
        v-if="
            attribute.type == 'text' ||
            attribute.type == 'textarea' ||
            (attribute.type == 'select' && !attribute.av_cat) ||
            attribute?.type == 'text'
        "
    >
        <label>{{ attribute.label }}:</label>
        <LinkWrapper :linkData="attribute?.link" :resource="resource">
            <span>
                {{
                    attribute?.format
                        ? attribute?.format(
                              resource[attribute.value]
                                  ? resource[attribute.value]
                                  : attribute.value,
                              resource
                          )
                        : resource[attribute.name]
                }}
            </span>
        </LinkWrapper>
    </div>
    <div
        v-else-if="
            attribute.type == 'av' ||
            (attribute.type == 'select' && attribute.av_cat)
        "
    >
        <label>{{ attribute.label }}:</label>
        <LinkWrapper :linkData="attribute?.link" :resource="resource">
            <span>{{
                get_lib_from_av(attribute.av_cat, resource[attribute.name])
            }}</span>
        </LinkWrapper>
    </div>
    <div v-else-if="attribute.type == 'boolean'">
        <label>{{ attribute.label }}:</label>
        <span v-if="resource[attribute.name]">{{ $__("Yes") }}</span>
        <span v-else>{{ $__("No") }}</span>
    </div>
    <div v-else-if="attribute.type === 'table'">
        <template v-if="attribute.hidden(resource)">
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
                            <template v-if="dataColumn.format">
                                <LinkWrapper
                                    :linkData="dataColumn.link"
                                    :resource="row"
                                >
                                    {{
                                        dataColumn.format(
                                            row[dataColumn.value]
                                                ? row[dataColumn.value]
                                                : dataColumn.value,
                                            row
                                        )
                                    }}
                                </LinkWrapper>
                            </template>
                            <template v-else-if="dataColumn.av">
                                <LinkWrapper
                                    :linkData="dataColumn.link"
                                    :resource="row"
                                >
                                    {{
                                        get_lib_from_av(
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
    </div>
    <div v-else-if="attribute?.type === 'component'">
        <template v-if="attribute.hidden(resource)">
            <component
                :is="requiredComponent"
                v-bind="requiredProps(true)"
            ></component>
        </template>
    </div>
</template>

<script>
import { inject } from "vue";
import LinkWrapper from "./LinkWrapper.vue";
import BaseElement from "./BaseElement.vue";

export default {
    components: { LinkWrapper },
    extends: BaseElement,
    setup() {
        const AVStore = inject("AVStore");
        const { get_lib_from_av } = AVStore;

        return {
            ...BaseElement.setup(),
            get_lib_from_av,
        };
    },
    props: {
        resource: null,
        attr: null,
    },
    computed: {
        requiredComponent() {
            const component = this.identifyAndImportComponent(this.attr, true);
            return component;
        },
        selectOptions() {
            if (this.attr.options) {
                return this.attr.options;
            }
            return this.options;
        },
        attribute() {
            if (this.attr.showElement) {
                return { ...this.attr, ...this.attr.showElement };
            }
            return this.attr;
        },
    },
    name: "ShowElement",
};
</script>
