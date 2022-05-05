import { defineStore } from 'pinia'

export const useMainStore = defineStore('main', {
  state: () => ({
        current_view: 'list',
        current_object_id: null,
        message: null,
        error: null,
    }),
    actions: {
        setCurrentView(view) {
            this.current_view = view;
            this.error = null;
            this.message = null;
        },
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