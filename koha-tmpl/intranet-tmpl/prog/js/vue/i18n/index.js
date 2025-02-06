export const $__ = key => {
    return window["__"](key);
};

export const $__p = (ctx, key) => {
    return window["__p"](ctx, key);
};

export default {
    install: (app, options) => {
        app.config.globalProperties.$__ = $__;
        app.config.globalProperties.$__p = $__p;
    },
};
