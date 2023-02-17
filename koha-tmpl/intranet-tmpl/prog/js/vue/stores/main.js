import { defineStore } from "pinia";

export const useMainStore = defineStore("main", {
    state: () => ({
        _message: null,
        _error: null,
        _warning: null,
        _accept: null,
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
            this.displayed_already = displayed; /* Will be displayed on the next view */
        },
        setError(error, displayed = true) {
            this._error = error;
            this._message = null;
            this.displayed_already = displayed; /* Is displayed on the current view */
        },
        setWarning(warning, accept, displayed = true) {
            if(accept) {
                this._accept = async () => {
                    await accept()
                    this.removeMessages()
                }
            }
            this._warning = warning;
            this._message = null;
            this.displayed_already = displayed; /* Is displayed on the current view */
        },
        removeMessages() {
            if (this.displayed_already) {
                this._accept = null;
                this._error = null;
                this._warning = null;
                this._message = null;
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
        accept() {
            return this._accept
        },
        is_submitting(){
            return this._is_submitting
        },
        is_loading(){
            return this._is_loading
        },
    },
});
