<template>
    <fieldset class="rows" v-if="display">
        <h2>
            {{ $__("Vendor details") }}
        </h2>
        <ol>
            <li>
                <label>{{ $__("Type") }}:</label>
                <span>
                    {{ get_lib_from_av("av_vendor_types", vendor.type) }}
                </span>
            </li>
            <li>
                <label>{{ $__("Company name") }}:</label>
                <span>
                    {{ vendor.name }}
                </span>
            </li>
            <li>
                <label>{{ $__("Postal address") }}:</label>
                <span>
                    {{ vendor.postal }}
                </span>
            </li>
            <li>
                <label>{{ $__("Physical address") }}:</label>
                <span>
                    {{ vendor.address1 }}
                    {{ vendor.address2 }}
                    {{ vendor.address3 }}
                    {{ vendor.address4 }}
                </span>
            </li>
            <li>
                <label>{{ $__("Phone") }}:</label>
                <span>
                    {{ vendor.phone }}
                </span>
            </li>
            <li>
                <label>{{ $__("Fax") }}:</label>
                <span>
                    {{ vendor.fax }}
                </span>
            </li>
            <li v-if="vendor.url" id="vendorWebsite">
                <label>{{ $__("Website") }}:</label>
                <Link
                    :to="{
                        path: vendor.url,
                    }"
                    :cssClass="''"
                    :title="vendor.url"
                    callback="redirect"
                />
            </li>
            <li v-if="vendor.accountnumber">
                <label>{{ $__("Account number") }}:</label>
                <span>
                    {{ vendor.accountnumber }}
                </span>
            </li>
            <li v-if="vendor.aliases.length">
                <label>{{ $__("Aliases") }}:</label>
                <ul style="margin-left: 8rem">
                    <li
                        v-for="(alias, i) in vendor.aliases"
                        :key="alias.vendor_alias_id"
                    >
                        {{ $__("Alias") + " " + (i + 1) }}: {{ alias.alias }}
                    </li>
                </ul>
            </li>
        </ol>
    </fieldset>
    <fieldset class="rows" v-else>
        <legend>{{ $__("Company details") }}</legend>
        <ol>
            <li>
                <label for="vendor_name" class="required"
                    >{{ $__("Name") }}:</label
                >
                <input
                    id="vendor_name"
                    v-model="vendor.name"
                    :placeholder="$__('Vendor name')"
                    required
                />
                <span class="required">{{ $__("Required") }}</span>
            </li>
            <li>
                <label for="vendor_postal">{{ $__("Postal address") }}:</label>
                <textarea
                    id="vendor_postal"
                    v-model="vendor.postal"
                    cols="40"
                    rows="3"
                />
            </li>
            <li>
                <label for="vendor_physical"
                    >{{ $__("Physical address") }}:</label
                >
                <textarea
                    id="vendor_physical"
                    v-model="vendor.physical"
                    cols="40"
                    rows="3"
                />
            </li>
            <li>
                <label for="vendor_phone">{{ $__("Phone") }}:</label>
                <input id="vendor_phone" v-model="vendor.phone" />
            </li>
            <li>
                <label for="vendor_fax">{{ $__("Fax") }}:</label>
                <input id="vendor_fax" v-model="vendor.fax" />
            </li>
            <li>
                <label for="vendor_website">{{ $__("Website") }}:</label>
                <input id="vendor_website" v-model="vendor.url" />
            </li>
            <li>
                <label for="vendor_accountnumber"
                    >{{ $__("Account number") }}:</label
                >
                <input
                    id="vendor_accountnumber"
                    v-model="vendor.accountnumber"
                />
            </li>
            <li>
                <label for="vendor_type">{{ $__("Vendor type") }}:</label>
                <v-select
                    v-if="authorisedValues['av_vendor_types'].length"
                    id="vendor_type"
                    v-model="vendor.type"
                    label="description"
                    :reduce="av => av.value"
                    :options="authorisedValues['av_vendor_types']"
                />
                <input v-else id="vendor_type" v-model="vendor.type" />
            </li>
            <li>
                <label for="vendor_aliases">{{ $__("Aliases") }}:</label>
                <input
                    id="vendor_aliases"
                    class="noEnterSubmit"
                    v-model="newAlias"
                />
                <span class="aliasAction" @click="addAlias()"
                    ><i class="fa fa-plus"></i> {{ $__("Add") }}</span
                >
                <ol id="aliasList">
                    <li
                        v-for="(item, i) in vendor.aliases"
                        :key="`${item}${i}`"
                        style="display: flex"
                    >
                        <label :for="`alias${i}`"
                            >{{ $__("Alias") + " " + (i + 1) }}:</label
                        >
                        <span :id="`alias${i}`">{{ item.alias }}</span>
                        <span class="aliasAction" @click="removeAlias(item)"
                            ><i class="fa fa-trash"></i>
                            {{ $__("Remove") }}</span
                        >
                    </li>
                </ol>
            </li>
        </ol>
    </fieldset>
</template>

<script>
import { inject } from "vue";
import Link from "../Link.vue";

export default {
    props: {
        vendor: Object,
        display: Boolean,
    },
    setup() {
        const vendorStore = inject("vendorStore");
        const { get_lib_from_av, authorisedValues } = vendorStore;
        return {
            get_lib_from_av,
            authorisedValues,
        };
    },
    data() {
        return {
            newAlias: "",
        };
    },
    methods: {
        addAlias() {
            if (!this.vendor.aliases) {
                this.vendor.aliases = [];
            }
            if (!this.newAlias) return;
            this.vendor.aliases.push({ alias: this.newAlias });
            this.newAlias = "";
        },
        removeAlias(e) {
            const aliasIndex = this.vendor.aliases
                .map(a => a.alias)
                .indexOf(e.alias);
            this.vendor.aliases.splice(aliasIndex, 1);
        },
    },
    components: {
        Link,
    },
};
</script>

<style scoped>
.aliasAction {
    cursor: pointer;
    margin-left: 5px;
    color: #006100;
}
#aliasList {
    padding-left: 5em;
}
</style>
