export const $__ = key => {
    return window["__"](key);
};

export default {
    install: (app, options) => {
        app.config.globalProperties.$__ = $__;
    },
};
