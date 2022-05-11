import { useMainStore } from "./stores/main";
import { storeToRefs } from "pinia";

export const setError = function (new_error) {
    const mainStore = useMainStore();
    const { setError } = mainStore;
    setError("Something went wrong: " + new_error);
};

export const setMessage = function (message) {
    const mainStore = useMainStore();
    const { setMessage } = mainStore;
    setMessage(message);
};
export const removeMessages = function () {
    const mainStore = useMainStore();
    const { removeMessages } = mainStore;
    removeMessages();
};
