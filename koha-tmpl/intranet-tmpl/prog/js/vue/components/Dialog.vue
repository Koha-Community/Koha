<template>
    <div class="alert alert-info" v-if="message" v-html="message"></div>
    <div class="alert alert-warning" v-if="error" v-html="error"></div>
    <div class="modal" role="dialog" v-if="warning" id="warning">
        <div class="modal-dialog">
            <div class="modal-content modal-lg">
                <div class="modal-header">
                    <h1 class="modal-title" v-html="warning"></h1>
                </div>
                <div class="modal-footer border-top-0">
                    <button
                        id="close_modal"
                        class="btn btn-default deny cancel"
                        type="button"
                        data-bs-dismiss="modal"
                        @click="removeMessages"
                    >
                        <i class="fa fa-fw fa-check"></i>
                        {{ $__("Close") }}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div
        class="confirmation modal"
        role="dialog"
        v-if="confirmation"
        id="confirmation"
    >
        <div class="modal-dialog">
            <div class="modal-content modal-lg">
                <div class="modal-header alert-warning confirmation">
                    <h1 v-html="confirmation.title"></h1>
                </div>
                <div
                    class="modal-body"
                    v-if="confirmation.message || confirmation.inputs"
                >
                    <p v-html="confirmation.message"></p>
                    <div class="inputs" v-if="confirmation.inputs">
                        <form ref="confirmationform">
                            <div
                                class="row"
                                v-for="input in confirmation.inputs"
                                v-bind:key="input.id"
                            >
                                <div class="col-md-6">
                                    <label
                                        :for="`confirmation_input_${input.id}`"
                                        v-bind:class="{
                                            required: input.required,
                                        }"
                                        >{{ input.label }}:</label
                                    >
                                </div>
                                <div class="col-md-6">
                                    <flat-pickr
                                        v-if="input.type == 'Date'"
                                        :id="`confirmation_input_${input.id}`"
                                        v-model="input.value"
                                        :required="input.required"
                                        :config="fp_config"
                                    />
                                    <input
                                        v-if="input.type == 'Text'"
                                        :id="`confirmation_input_${input.id}`"
                                        v-model="input.value"
                                        :required="input.required"
                                    />
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                <div
                    class="modal-footer"
                    :class="{
                        'border-top-0': !(
                            confirmation.message || confirmation.inputs
                        ),
                    }"
                >
                    <button
                        v-if="accept_callback"
                        id="accept_modal"
                        class="btn btn-default approve"
                        @click="submit"
                    >
                        <i class="fa fa-fw fa-check"></i>
                        <span v-html="confirmation.accept_label"></span>
                    </button>
                    <button
                        id="close_modal"
                        class="btn btn-default deny cancel"
                        type="button"
                        data-bs-dismiss="modal"
                        @click="removeConfirmationMessages"
                    >
                        <i class="fa fa-fw fa-remove"></i>
                        <span v-html="confirmation.cancel_label"></span>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal_centered" v-if="is_submitting">
        <div class="spinner alert alert-warning">
            {{ $__("Submitting...") }}
        </div>
    </div>
    <div class="modal_centered" v-if="is_loading">
        <div class="spinner alert alert-info">{{ $__("Loading...") }}</div>
    </div>
</template>

<script>
import { inject, watch, nextTick } from "vue";
import { storeToRefs } from "pinia";
import flatPickr from "vue-flatpickr-component";
export default {
    data() {
        return {
            fp_config: flatpickr_defaults,
        };
    },
    methods: {
        submit: function (e) {
            if (
                this.confirmation.inputs &&
                this.confirmation.inputs.filter(
                    input =>
                        input.required &&
                        (input.value == null || input.value == "")
                ).length
            ) {
                this.$refs.confirmationform.reportValidity();
            } else {
                this.accept_callback().then(() => {
                    nextTick(() => {
                        $("#confirmation.modal").modal("hide");
                    });
                });
            }
        },
    },
    setup() {
        const mainStore = inject("mainStore");
        const {
            message,
            error,
            warning,
            confirmation,
            accept_callback,
            is_submitting,
            is_loading,
        } = storeToRefs(mainStore);
        const { removeMessages, removeConfirmationMessages } = mainStore;

        watch(warning, newWarning => {
            if (!newWarning) {
                $("#warning.modal").modal("hide");
                return;
            }
            nextTick(() => {
                $("#warning.modal").modal("show");
            });
        });

        watch(confirmation, newConfirmation => {
            if (!newConfirmation) {
                $("#confirmation.modal").modal("hide");
                return;
            }
            nextTick(() => {
                $("#confirmation.modal").modal("show");
            });
        });

        return {
            message,
            error,
            warning,
            confirmation,
            accept_callback,
            is_submitting,
            is_loading,
            removeMessages,
            removeConfirmationMessages,
        };
    },
    components: {
        flatPickr,
    },
};
</script>

<style scoped>
.modal {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    margin: auto;
    padding: 20px 30px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
}
#close_modal {
    cursor: pointer;
}

.modal_centered {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    left: 0px;
    top: 0px;
    width: 100%;
    height: 100%;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
}
.spinner {
    position: absolute;
    top: 50%;
    left: 40%;
    width: 10%;
}

.confirmation .inputs {
    margin-top: 0.4em;
}
.confirmation .inputs input,
:deep(.flatpickr-input) {
    width: auto;
    margin: 0px;
    float: left;
}

:deep(.flatpickr-input) {
    padding-left: 20px;
}

.confirmation .inputs label {
    padding: 0.4em;
    float: right;
}
</style>
