import { useMainStore } from "./stores/main";

export const setError = function (new_error) {
    const mainStore = useMainStore();
    const { setError } = mainStore;
    setError("Something went wrong: " + new_error);
};

export const setWarning = function (new_warning) {
    const mainStore = useMainStore();
    const { setWarning } = mainStore;
    setWarning(new_warning);
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
export const isSubmitting = function () {
    const mainStore = useMainStore();
    const { isSubmitting } = mainStore;
    isSubmitting();
};
export const submitted = function () {
    const mainStore = useMainStore();
    const { submitted } = mainStore;
    submitted();
};