const businessContext = require.context("@koha-vue", true, /\.vue$/);
const cypressContext = require.context("@cypress", true, /\.vue$/);

export function loadComponent(path) {
    if (path.startsWith("@koha-vue/")) {
        return () => Promise.resolve(businessContext("." + path.slice(9)));
    } else if (path.startsWith("@cypress/")) {
        // FIXME should only be imported if we are not in production
        return () => Promise.resolve(cypressContext("." + path.slice(8)));
    } else {
        return () => import(`${path}`);
    }
}
