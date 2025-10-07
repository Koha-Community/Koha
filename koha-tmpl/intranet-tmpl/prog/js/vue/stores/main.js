import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";

export const useMainStore = defineStore("main", () => {
    const store = reactive({
        message: null,
        error: null,
        warning: null,
        confirmation: null,
        accept_callback: null,
        previousMessage: null,
        previousError: null,
        componentDialog: null,
        displayed_already: false,
        is_submitting: false,
        is_loading: false,
    });

    const actions = {
        setMessage(message, displayed = false) {
            this.error = null;
            this.warning = null;
            this.message = message;
            this.confirmation = null;
            this.displayed_already =
                displayed; /* Will be displayed on the next view */
        },
        setError(error, displayed = true) {
            this.error = error;
            this.warning = null;
            this.message = null;
            this.confirmation = null;
            this.displayed_already =
                displayed; /* Is displayed on the current view */
        },
        setWarning(warning, displayed = true) {
            this.error = null;
            this.warning = warning;
            this.message = null;
            this.confirmation = null;
            this.displayed_already =
                displayed; /* Is displayed on the current view */
        },
        /**
         * Sets a confirmation dialog pop-up modal
         * @param  {Object} confirmation Confirmation details
         * @param  {string} confirmation.title Shows at the top of the dialog
         * @param  {string} confirmation.message Shows under the title
         * @param  {string} confirmation.accept_label Label for the 'accept' button
         * @param  {string} confirmation.cancel_label Label for the 'cancel' button
         * @param  {Array}  confirmation.inputs Optional inputs details
         * @param  {string} confirmation.inputs.id Key code of the input, used for HTML elements id
         * @param  {string} confirmation.inputs.type Type of the input, 'Date' or 'Text'
         * @param  {string} confirmation.inputs.value Initial/default value
         * @param  {string} confirmation.inputs.required Sets the input required or not
         * @param  {string} confirmation.inputs.label Label that sits next to the input
         * @callback accept_callback Callback function called after the user accepts the dialog. Carries over the user input if inputs exist.
         */
        setConfirmationDialog(confirmation, accept_callback, displayed = true) {
            if (accept_callback) {
                this.accept_callback = async inputFields => {
                    await accept_callback(confirmation, inputFields);
                    this.removeConfirmationMessages();
                };
            }
            this.confirmation = confirmation;
            this.displayed_already =
                displayed; /* Is displayed on the current view */
        },
        setComponentDialog(componentDialog, displayed = true) {
            this.componentDialog = componentDialog;
            this.displayed_already =
                displayed; /* Is displayed on the current view */
        },
        removeMessages() {
            if (this.displayed_already) {
                this.error = null;
                this.warning = null;
                this.message = null;
                this.confirmation = null;
                this.accept_callback = null;
            }
            this.displayed_already = true;
        },
        removeConfirmationMessages() {
            this.confirmation = null;
            this.accept_callback = null;
        },
        submitting() {
            this.is_submitting = true;
        },
        submitted() {
            this.is_submitting = false;
        },
        loading() {
            this.is_loading = true;
        },
        loaded() {
            this.is_loading = false;
        },
    };

    return {
        ...toRefs(store),
        ...actions,
    };
});
