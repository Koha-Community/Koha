// Vue pages served through a RewriteRule must keep working when the .pl script is
// requested, as happens when logging back in after the session timed out: the login
// form posts to the script, with the route of the page the user was on as path info

// path is the URL of the page, script the one of the script it is served by when they differ
const pages: Array<{
    name: string;
    path: string;
    script?: string;
    route: string;
    title: string;
}> = [
    {
        name: "Record sources",
        path: "/cgi-bin/koha/admin/record_sources",
        route: "/add",
        title: "Record sources",
    },
    {
        name: "Circulation triggers",
        path: "/cgi-bin/koha/admin/circulation_triggers",
        route: "/add",
        title: "Circulation triggers",
    },
    {
        name: "Vendors",
        path: "/cgi-bin/koha/acquisition/vendors",
        script: "/cgi-bin/koha/acqui/vendors",
        route: "/add",
        title: "Vendors",
    },
    {
        name: "Item lists",
        path: "/cgi-bin/koha/lists/items",
        route: "/add",
        title: "Item Lists",
    },
];

describe("Vue pages served through a rewrite rule", () => {
    pages.forEach(page => {
        describe(page.name, () => {
            it("should show the page when the .pl script is requested", () => {
                cy.login();
                cy.visit(`${page.script ?? page.path}.pl`);
                cy.get("#breadcrumbs").contains(page.title);
                cy.location("pathname").should("eq", page.path);
            });

            it("should keep the route when the .pl script is requested with it", () => {
                cy.login();
                cy.visit(`${page.script ?? page.path}.pl${page.route}?test=1`);
                cy.get("#breadcrumbs").contains(page.title);
                cy.location("pathname").should("eq", page.path + page.route);
                cy.location("search").should("eq", "?test=1");
            });

            it("should show the page the user was on after logging back in", () => {
                cy.env(["kohaUsername", "kohaPassword"]).then(
                    ({ kohaUsername, kohaPassword }) => {
                        cy.visit("/cgi-bin/koha/mainpage.pl?logout.x=1");
                        cy.visit(page.path + page.route);
                        cy.get("#userid").type(kohaUsername);
                        cy.get("#password").type(kohaPassword);
                        cy.get("#submit-button").click();
                        cy.get("#breadcrumbs").contains(page.title);
                        cy.location("pathname").should(
                            "eq",
                            page.path + page.route
                        );
                    }
                );
            });
        });
    });
});
