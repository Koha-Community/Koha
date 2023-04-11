<template>
    <v-select
        label="name"
        :reduce="vendor => vendor.id"
        :options="vendorOptions"
        :filter-by="filterVendors"
    >
        <template v-slot:option="v">
            {{ v.name }}
            <br />
            <cite>{{ v.aliases.map(a => a.alias).join(", ") }}</cite>
        </template>
    </v-select>
</template>

<script>
import { inject } from "vue"
import { storeToRefs } from "pinia"
export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)
        return { vendors }
    },
    computed: {
        vendorOptions() {
            return this.vendors.map(v => ({
                ...v,
                full_search:
                    v.name +
                    (v.aliases.length > 0
                        ? " (" + v.aliases.map(a => a.alias).join(", ") + ")"
                        : ""),
            }))
        },
    },
    methods: {
        filterVendors(vendor, label, search) {
            return (
                (vendor.full_search || "")
                    .toLocaleLowerCase()
                    .indexOf(search.toLocaleLowerCase()) > -1
            )
        },
    },
}
</script>
