import { inject, nextTick, ref } from "vue";

export function useVueModule(moduleName) {
    const mainStore = inject("mainStore");
    const { loading, loaded, setError } = mainStore;
    const initialized = ref(false);

    function onModuleReady() {
        loaded();
        initialized.value = true;
        nextTick(() => {
            document.dispatchEvent(
                new CustomEvent("koha:vue-loaded", {
                    detail: { module: moduleName },
                })
            );
        });
    }

    return { loading, loaded, setError, initialized, onModuleReady };
}
