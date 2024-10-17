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
