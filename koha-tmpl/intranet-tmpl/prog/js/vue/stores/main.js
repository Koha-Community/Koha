import { defineStore } from 'pinia'

export const useMainStore = defineStore('main', {
  state: () => ({
        message: null,
        error: null,
    }),
    actions: {
        setMessage(message) {
            this.error = null;
            this.message = message;
        },
        setError(error) {
            this.error = "Something went wrong: " + error;
            this.message = null;
        },
        removeMessages() {
            this.error = null;
            this.message = null;
        },
    },
});