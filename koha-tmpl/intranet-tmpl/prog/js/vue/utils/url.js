/**
 * Pages served through a rewrite rule, such as /cgi-bin/koha/admin/record_sources, can
 * also be reached on the URL of their script, with the route as path info (for example
 * /cgi-bin/koha/admin/record_sources.pl/edit/3). That is where the login form takes the
 * user back to after a session timeout.
 *
 * The router only knows the URLs of the pages, so put the address back to it before the
 * router reads it, keeping the route, the query string and the hash.
 *
 * By default the extension of the script is taken out. A page that is served by a script
 * that does not have the path of the page, such as the vendors (/cgi-bin/koha/acquisition/vendors,
 * served by /cgi-bin/koha/acqui/vendors.pl), gives the path of its script and of its route:
 *
 *     removeScriptExtension({ script: "/acqui/vendors.pl", route: "/acquisition/vendors" });
 *
 * @param {Object} [options]
 * @param {string} [options.script] Path of the script, with its extension, when it is not the path of the page with it
 * @param {string} [options.route]  Path of the page, the one the router is based on, that replaces the one of the script
 */
export function removeScriptExtension({ script, route } = {}) {
    const { pathname, search, hash } = window.location;

    let path = pathname;
    if (script) {
        const start = pathname.indexOf(script);
        const end = start + script.length;
        if (
            start !== -1 &&
            (end === pathname.length || pathname[end] === "/")
        ) {
            path = pathname.slice(0, start) + route + pathname.slice(end);
        }
    } else {
        path = pathname.replace(/\.pl(?=\/|$)/, "");
    }

    if (path !== pathname) {
        window.history.replaceState(
            window.history.state,
            "",
            path + search + hash
        );
    }
}
