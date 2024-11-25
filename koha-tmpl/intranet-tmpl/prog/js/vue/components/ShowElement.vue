<template>
    <div v-if="attr.type == 'text' || attr.type == 'textarea'">
        <label>{{ attr.label }}:</label>
        <span>
            {{ resource[attr.name] }}
        </span>
    </div>
    <div v-else-if="attr.type == 'av'">
        <label>{{ attr.label }}:</label>
        <span>{{ get_lib_from_av(attr.av_cat, resource[attr.name]) }}</span>
    </div>
    <div
        v-else-if="
            attr.type == 'component' && attr.component == 'FormSelectVendors'
        "
    >
        <label>{{ attr.label }}:</label>
        <span v-if="resource[attr.name]">
            <a
                :href="`/cgi-bin/koha/acqui/booksellers.pl?booksellerid=${resource['vendor_id']}`"
            >
                {{ resource["vendor"]["name"] }}
            </a>
        </span>
    </div>
    <div
        v-else-if="
            attr.type == 'relationship' && attr.showElement.type === 'table'
        "
    >
        <template v-if="attr.showElement.hidden(resource)">
            <label>{{ attr.label }}</label>
            <table>
                <thead>
                    <th
                        v-for="column in attr.showElement.columns"
                        :key="column.name + 'head'"
                    >
                        {{ column.name }}
                    </th>
                </thead>
                <tbody>
                    <tr
                        v-for="(row, counter) in resource[
                            attr.showElement.columnData
                        ]"
                        v-bind:key="counter"
                    >
                        <td
                            v-for="dataColumn in attr.showElement.columns"
                            :key="dataColumn.name + 'data'"
                        >
                            <template v-if="dataColumn.format">
                                {{
                                    dataColumn.format(
                                        row[dataColumn.value]
                                            ? row[dataColumn.value]
                                            : dataColumn.value,
                                        row
                                    )
                                }}
                            </template>
                            <template v-else-if="dataColumn.av">
                                {{
                                    get_lib_from_av(
                                        dataColumn.av,
                                        row[dataColumn.value]
                                    )
                                }}
                            </template>
                            <template v-else>
                                {{ row[dataColumn.value] }}
                            </template>
                        </td>
                    </tr>
                </tbody>
            </table>
        </template>
    </div>
</template>

<script>
import { inject } from "vue";

export default {
    setup() {
        const AVStore = inject("AVStore");
        const { get_lib_from_av } = AVStore;

        return {
            get_lib_from_av,
        };
    },
    props: {
        resource: null,
        attr: null,
    },
    name: "ShowElement",
};
</script>
