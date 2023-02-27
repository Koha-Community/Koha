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
            this.displayed_already = displayed; /* Will be displayed on the next view */
        },
        setError(error, displayed = true) {
            this._error = error;
            this._warning = null;
            this._message = null;
            this._confirmation = null;
            this.displayed_already = displayed; /* Is displayed on the current view */
        },
        setWarning(warning, displayed = true) {
            this._error = null;
            this._warning = warning;
            this._message = null;
            this._confirmation = null;
            this.displayed_already = displayed; /* Is displayed on the current view */
        },
        setConfirmationDialog(confirmation, accept_callback, displayed = true){
            if(accept_callback) {
                this._accept_callback = async () => {
                    await accept_callback()
                    this.removeMessages()
                }
            }
            this._error = null;
            this._warning = null;
            this._message = null;
            this._confirmation = confirmation;
            this.displayed_already = displayed; /* Is displayed on the current view */
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
        submitting(){
            this._is_submitting = true;
        },
        submitted(){
            this._is_submitting = false;
        },
        loading(){
            this._is_loading = true;
        },
        loaded(){
            this._is_loading = false;
        },
    },
    getters: {
        error() {
            return this._error
        },
        warning() {
            return this._warning
        },
        message() {
            return this._message
        },
        confirmation() {
            return this._confirmation
        },
        accept_callback() {
            return this._accept_callback
        },
        is_submitting(){
            return this._is_submitting
        },
        is_loading(){
            return this._is_loading
        },
    },
});
