<template>
    <fieldset class="rows">
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
                <Link
                    :to="{
                        path: vi.uri,
                    }"
                    :cssClass="''"
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
                <span v-if="showPassword">
                    {{ vi.password }}
                </span>

                <a
                    @click="showPassword = !showPassword"
                    style="cursor: pointer"
                    v-if="!showPassword"
                >
                    <font-awesome-icon icon="eye" />
                    {{ $__("Show password") }}
                </a>
                <a
                    @click="showPassword = !showPassword"
                    v-else
                    style="cursor: pointer"
                >
                    <font-awesome-icon icon="eye-slash" />
                    {{ $__("Hide password") }}
                </a>
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
</template>

<script>
import { inject, ref } from "vue";
import Link from "../Link.vue";

export default {
    props: {
        vendor: Object,
    },
    setup() {
        const vendorStore = inject("vendorStore");
        const { get_lib_from_av } = vendorStore;

        const showPassword = ref(false);
        return {
            get_lib_from_av,
            showPassword,
        };
    },
    data() {
        return {
            showPassword: false,
        };
    },
    components: {
        Link,
    },
};
</script>

<style></style>
