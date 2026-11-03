/**
 * Pages served through a rewrite rule, such as /cgi-bin/koha/admin/record_sources, can
 * also be reached on the URL of their script, with the route as path info (for example
 * /cgi-bin/koha/admin/record_sources.pl/edit/3). That is where the login form takes the
 * user back to after a session timeout.
 *
 * The router only knows the URLs without the extension, so take it out of the address
 * before the router reads it, keeping the route, the query string and the hash.
 */
export function removeScriptExtension() {
    const { pathname, search, hash } = window.location;
    const path = pathname.replace(/\.pl(?=\/|$)/, "");
    if (path !== pathname) {
        window.history.replaceState(
            window.history.state,
            "",
            path + search + hash
        );
    }
}
