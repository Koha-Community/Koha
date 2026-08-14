<template>
    <div
        v-if="show"
        :class="computedClass"
        :role="role || undefined"
        :aria-live="live || undefined"
    >
        <slot>{{ message }}</slot>
        <button
            v-if="dismissible"
            type="button"
            class="btn-close"
            :aria-label="$__('Close')"
            @click="$emit('dismiss')"
        ></button>
    </div>
</template>

<script setup>
import { computed } from "vue";
import { $__ } from "@koha-vue/i18n";

defineOptions({ name: "AlertMessage" });

const props = defineProps({
    show: { type: Boolean, default: true },
    variant: {
        type: String,
        default: "info", // info | warning | danger | success | secondary
    },
    message: { type: String, default: "" },
    dismissible: { type: Boolean, default: false },
    extraClass: { type: String, default: "" },
    role: {
        type: String,
        default: null,
        validator: value => ["alert", "status"].includes(value),
    },
    live: {
        type: String,
        default: null,
        validator: value => ["assertive", "polite", "off"].includes(value),
    },
});
defineEmits(["dismiss"]);

/** Build Bootstrap alert classes from presentation props. */
const computedClass = computed(() => {
    const base = ["alert", `alert-${props.variant}`];
    if (props.dismissible) base.push("alert-dismissible");
    if (props.extraClass) base.push(props.extraClass);
    return base.join(" ");
});
</script>
