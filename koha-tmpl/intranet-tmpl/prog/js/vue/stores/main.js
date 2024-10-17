import { defineStore } from "pinia";
import { APIClient } from "../fetch/api-client.js";

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
        authorisedValues: {},
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
        get_lib_from_av(arr_name, av) {
            if (this.authorisedValues[arr_name] === undefined) {
                console.warn(
                    "The authorised value category for '%s' is not defined.".format(
                        arr_name
                    )
                );
                return;
            }
            let o = this.authorisedValues[arr_name].find(e => e.value == av);
            return o ? o.description : av;
        },
        map_av_dt_filter(arr_name) {
            return this.authorisedValues[arr_name].map(e => {
                e["_id"] = e["value"];
                e["_str"] = e["description"];
                return e;
            });
        },
        async loadAuthorisedValues(authorisedValues) {
            const AVsToFetch = Object.keys(authorisedValues).reduce(
                (acc, avKey) => {
                    if (Array.isArray(authorisedValues[avKey])) return acc;
                    acc[avKey] = authorisedValues[avKey];
                    return acc;
                },
                {}
            );

            const AVCatArray = Object.keys(AVsToFetch).map(avCat => {
                return '"' + AVsToFetch[avCat] + '"';
            });

            const promises = [];
            const AVClient = APIClient.authorised_values;
            promises.push(
                AVClient.values
                    .getCategoriesWithValues(AVCatArray)
                    .then(AVCategories => {
                        Object.entries(AVsToFetch).forEach(
                            ([AVName, AVCat]) => {
                                const AVMatch = AVCategories.find(
                                    element => element.category_name == AVCat
                                );
                                this.authorisedValues[AVName] =
                                    AVMatch.authorised_values;
                            }
                        );
                    })
            );

            return Promise.all(promises);
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
