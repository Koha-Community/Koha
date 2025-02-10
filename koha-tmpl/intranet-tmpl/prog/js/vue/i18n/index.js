const methods = ["__", "__x", "__n", "__nx", "__p", "__px", "__np", "__npx"];

const translators = Object.fromEntries(
    methods.map(method => [method, (...args) => window[method](...args)])
);

export const {
    __: $__,
    __x: $__x,
    __n: $__n,
    __nx: $__nx,
    __p: $__p,
    __px: $__px,
    __np: $__np,
    __npx: $__npx,
} = translators;

export default {
    install: app => {
        Object.entries(translators).forEach(([key, func]) => {
            app.config.globalProperties[`$${key}`] = func;
        });
    },
};
