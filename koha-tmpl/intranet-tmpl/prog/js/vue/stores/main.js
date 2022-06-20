import { defineStore } from "pinia";

export const useMainStore = defineStore("main", {
    state: () => ({
        message: null,
        error: null,
        previousMessage: null,
        previousError: null,
        displayed_already: false,
    }),
    actions: {
        setMessage(message) {
            this.error = null;
            this.message = message;
            this.displayed_already = false; /* Will be displayed on the next view */
        },
        setError(error) {
            this.error = error;
            this.message = null;
            this.displayed_already = true; /* Is displayed on the current view */
        },
        removeMessages() {
            if (this.displayed_already) {
                this.error = null;
                this.message = null;
            }
            this.displayed_already = true;
        },
    },
});
