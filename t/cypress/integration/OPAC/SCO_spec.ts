describe("SCO", () => {
    // Sets a system preference via the intranet svc endpoint using only
    // cy.request() — no browser navigation, so no cross-origin issues.
    function setSyspref(variable: string, value: string) {
        // Step 1: GET the login page to get an anonymous session + its CSRF token
        cy.env(["apiUsername", "apiPassword"]).then(
            ({ apiUsername, apiPassword }) => {
                cy.request("/cgi-bin/koha/mainpage.pl?logout.x=1").then(
                    loginPage => {
                        const csrfForLogin = (loginPage.body as string).match(
                            /<meta name="csrf-token" content="([^"]+)"/
                        )?.[1];
                        if (!csrfForLogin)
                            throw new Error(
                                "CSRF token not found on login page"
                            );

                        // Step 2: POST credentials — Koha authenticates and redirects to the
                        // logged-in mainpage whose body contains the new session's CSRF token
                        cy.request({
                            method: "POST",
                            url: "/cgi-bin/koha/mainpage.pl",
                            headers: {
                                "Content-Type":
                                    "application/x-www-form-urlencoded",
                            },
                            body: [
                                `login_userid=${encodeURIComponent(apiUsername)}`,
                                `login_password=${encodeURIComponent(apiPassword)}`,
                                `csrf_token=${encodeURIComponent(csrfForLogin)}`,
                                `login_op=cud-login`,
                            ].join("&"),
                        }).then(mainPage => {
                            const csrfForSvc = (mainPage.body as string).match(
                                /<meta name="csrf-token" content="([^"]+)"/
                            )?.[1];
                            if (!csrfForSvc)
                                throw new Error(
                                    "CSRF token not found on main page"
                                );

                            // Step 3: POST to svc endpoint — session cookie sent automatically
                            cy.request({
                                method: "POST",
                                url: "/cgi-bin/koha/svc/config/systempreferences",
                                headers: {
                                    "Content-Type":
                                        "application/x-www-form-urlencoded",
                                    "CSRF-TOKEN": csrfForSvc,
                                },
                                body: `pref_${encodeURIComponent(variable)}=${encodeURIComponent(value)}`,
                            });
                        });
                    }
                );
            }
        );
    }

    beforeEach(() => {
        cy.task("insertSampleBiblio", { item_count: 1 }).then(objects => {
            cy.wrap(objects).as("objects");
            cy.task("query", {
                sql: "UPDATE items SET barcode=CONCAT('+', itemnumber, '+') WHERE itemnumber=?",
                values: [objects.items[0].item_id],
            });
        });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='WebBasedSelfCheck'",
        }).then(rows => {
            cy.wrap(rows[0].value).as("syspref_WebBasedSelfCheck");
        });
        setSyspref("WebBasedSelfCheck", "1");
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", this.objects);
        setSyspref("WebBasedSelfCheck", this.syspref_WebBasedSelfCheck);
    });

    it("Should not crash if barcode contains '+'", function () {
        const barcode = `+${this.objects.items[0].item_id}+`;
        cy.visitOpac("/cgi-bin/koha/sco/sco-main.pl?op=logout");
        cy.get("#patronlogin").should("be.visible").type("kkoha"); // FIXME Why is the first character not displayed??
        cy.get("#patronpw").type("koha");
        cy.get("#mainform button").click();
        cy.get("#barcode").should("be.visible").type(barcode);
        cy.get("#scan_form button[type='submit']").click();
        cy.get("div.alert-info")
            .contains(`Item checked out (${barcode})`)
            .should("be.visible");
        cy.task("query", {
            sql: "DELETE FROM issues WHERE itemnumber=?",
            values: [this.objects.items[0].item_id],
        });
    });
});
