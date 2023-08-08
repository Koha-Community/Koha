import { defineStore } from "pinia";

export const useMainStore = defineStore("main", {
    state: () => ({
        _message: null,
        _error: null,
        _warning: null,
        _confirmation: null,
        _accept_callback: null,
        previousMessage: null,
        previousError: null,
        displayed_already: false,
        _is_submitting: false,
        _is_loading: false,
    }),
    actions: {
        setMessage(message, displayed = false) {
            this._error = null;
            this._warning = null;
            this._message = message;
            this._confirmation = null;
            this.displayed_already =
                displayed; /* Will be displayed on the next view */
        },
        setError(error, displayed = true) {
            this._error = error;
            this._warning = null;
            this._message = null;
            this._confirmation = null;
            this.displayed_already =
                displayed; /* Is displayed on the current view */
        },
        setWarning(warning, displayed = true) {
            this._error = null;
            this._warning = warning;
            this._message = null;
            this._confirmation = null;
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
                this._accept_callback = async () => {
                    await accept_callback(confirmation);
                    this.removeConfirmationMessages();
                };
            }
            this._confirmation = confirmation;
            this.displayed_already =
                displayed; /* Is displayed on the current view */
        },
        removeMessages() {
            if (this.displayed_already) {
                this._error = null;
                this._warning = null;
                this._message = null;
                this._confirmation = null;
                this._accept_callback = null;
            }
            this.displayed_already = true;
        },
        removeConfirmationMessages() {
            this._confirmation = null;
            this._accept_callback = null;
        },
        submitting() {
            this._is_submitting = true;
        },
        submitted() {
            this._is_submitting = false;
        },
        loading() {
            this._is_loading = true;
        },
        loaded() {
            this._is_loading = false;
        },
    },
    getters: {
        error() {
            return this._error;
        },
        warning() {
            return this._warning;
        },
        message() {
            return this._message;
        },
        confirmation() {
            return this._confirmation;
        },
        accept_callback() {
            return this._accept_callback;
        },
        is_submitting() {
            return this._is_submitting;
        },
        is_loading() {
            return this._is_loading;
        },
    },
});
