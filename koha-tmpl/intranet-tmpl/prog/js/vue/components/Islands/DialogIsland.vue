<template>
    <Dialog />
</template>

<script>
import { inject, watch } from "vue";
import Dialog from "../Dialog.vue";

export default {
    props: {
        message: {
            type: String,
            default: null,
        },
        error: {
            type: String,
            default: null,
        },
        warning: {
            type: String,
            default: null,
        },
        confirmation: {
            type: Object,
            default: () => null,
        },
        isSubmitting: {
            type: Boolean,
            default: false,
        },
        isLoading: {
            type: Boolean,
            default: false,
        },
        acceptCallback: {
            type: Function,
            default: null,
        },
    },
    setup(props) {
        const mainStore = inject("mainStore");
        const {
            setMessage,
            setError,
            setWarning,
            setConfirmation,
            setSubmitting,
            setLoading,
            setAcceptCallback,
        } = mainStore;

        watch(
            () => props.message,
            newVal => {
                setMessage(newVal);
            }
        );

        watch(
            () => props.error,
            newVal => {
                setError(newVal);
            }
        );

        watch(
            () => props.warning,
            newVal => {
                setWarning(newVal);
            }
        );

        watch(
            () => props.confirmation,
            newVal => {
                setConfirmation(newVal);
            }
        );

        watch(
            () => props.isSubmitting,
            newVal => {
                setSubmitting(newVal);
            }
        );

        watch(
            () => props.isLoading,
            newVal => {
                setLoading(newVal);
            }
        );

        watch(
            () => props.acceptCallback,
            newVal => {
                setAcceptCallback(newVal);
            }
        );

        return {};
    },
    components: {
        Dialog,
    },
};
</script>
