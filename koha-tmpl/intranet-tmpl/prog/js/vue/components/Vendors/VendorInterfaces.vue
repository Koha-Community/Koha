<template>
    <fieldset class="rows" v-if="display">
        <h2>
            {{ $__("Interfaces") }}
        </h2>
        <ol v-for="vi in vendor.interfaces" :key="vi.id">
            <h3>{{ vi.name }}</h3>
            <li v-if="vi.type">
                <label>{{ $__("Type") }}:</label>
                <span>
                    {{ get_lib_from_av("av_vendor_interface_types", vi.type) }}
                </span>
            </li>
            <li v-if="vi.uri">
                <label>{{ $__("URI") }}:</label>
                <ToolbarButton
                    :to="{
                        path: vi.uri,
                    }"
                    class=""
                    :title="vi.uri"
                    callback="redirect"
                />
            </li>
            <li v-if="vi.login">
                <label>{{ $__("Login") }}:</label>
                <span>
                    {{ vi.login }}
                </span>
            </li>
            <li v-if="vi.password">
                <label>{{ $__("Password") }}:</label>
                <span>
                    {{ vi.password }}
                </span>
            </li>
            <li v-if="vi.account_email">
                <label>{{ $__("Account email") }}:</label>
                <span>
                    {{ vi.account_email }}
                </span>
            </li>
            <li v-if="vi.notes">
                <label>{{ $__("Notes") }}:</label>
                <span>
                    {{ vi.notes }}
                </span>
            </li>
        </ol>
    </fieldset>
    <fieldset class="rows" v-else>
        <legend>{{ $__("Interfaces") }}</legend>
        <fieldset
            v-for="(vendorInterface, i) in vendor.interfaces"
            v-bind:key="i"
            class="rows"
            :id="`vendor_interface_${i}`"
        >
            <legend>
                {{ $__("Interface details") }}
            </legend>
            <ol>
                <li>
                    <label :for="`vendorInterface_${i}_name`"
                        >{{ $__("Name") }}:</label
                    >
                    <input
                        :id="`vendorInterface_${i}_name`"
                        v-model="vendorInterface.name"
                    />
                </li>
                <li>
                    <label for="vendorInterface_type">{{ $__("Type") }}:</label>
                    <v-select
                        id="vendorInterface_type"
                        v-model="vendorInterface.type"
                        label="description"
                        :reduce="av => av.value"
                        :options="av_vendor_interface_types"
                    />
                </li>
                <li>
                    <label :for="`vendorInterface_${i}_uri`"
                        >{{ $__("URI") }}:</label
                    >
                    <input
                        :id="`vendorInterface_${i}_uri`"
                        v-model="vendorInterface.uri"
                    />
                </li>
                <li>
                    <label :for="`vendorInterface_${i}_login`"
                        >{{ $__("Login") }}:</label
                    >
                    <input
                        :id="`vendorInterface_${i}_login`"
                        v-model="vendorInterface.login"
                    />
                </li>
                <li>
                    <label :for="`vendorInterface_${i}_password`"
                        >{{ $__("Password") }}:</label
                    >
                    <input
                        :id="`vendorInterface_${i}_password`"
                        v-model="vendorInterface.password"
                    />
                </li>
                <li>
                    <label :for="`vendorInterface_${i}_accountemail`"
                        >{{ $__("Account email") }}:</label
                    >
                    <input
                        :id="`vendorInterface_${i}_accountemail`"
                        v-model="vendorInterface.account_email"
                    />
                </li>
                <li>
                    <label :for="`vendorInterface_${i}_notes`"
                        >{{ $__("Notes") }}:</label
                    >
                    <textarea
                        :id="`vendorInterface_${i}_notes`"
                        v-model="vendorInterface.notes"
                        cols="40"
                        rows="3"
                    />
                </li>
            </ol>
            <span class="btn btn-default" @click.prevent="deleteContact(i)"
                ><font-awesome-icon icon="trash" />
                {{ $__("Delete interface") }}</span
            >
        </fieldset>
        <span class="btn btn-default" @click="addInterface"
            ><font-awesome-icon icon="plus" />
            {{ $__("Add new interface") }}</span
        >
    </fieldset>
</template>

<script>
import { inject } from "vue";
import { storeToRefs } from "pinia";
import ToolbarButton from "../ToolbarButton.vue";

export default {
    props: {
        vendor: Object,
        display: Boolean,
    },
    setup() {
        const AVStore = inject("AVStore");
        const { get_lib_from_av, av_vendor_interface_types } = AVStore;
        return {
            get_lib_from_av,
            av_vendor_interface_types,
        };
    },
    methods: {
        addInterface() {
            this.vendor.interfaces.push({
                type: "",
                name: "",
                uri: "",
                login: "",
                password: "",
                account_email: "",
                notes: "",
            });
        },
        deleteInterface(interfaceIndex) {
            this.vendor.interfaces.splice(interfaceIndex, 1);
        },
    },
    components: {
        ToolbarButton,
    },
};
</script>

<style></style>
