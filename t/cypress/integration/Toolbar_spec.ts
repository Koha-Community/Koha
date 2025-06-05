describe("Sticky toolbar", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Should open non-Vue links correctly in the same tab", () => {
        const vendor = cy.getVendor();
        vendor.baskets_count = 1;
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/acquisitions/vendors\?*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.intercept(
            "GET",
            new RegExp("/api/v1/acquisitions/vendors/(?!config$).+"),
            vendor
        ).as("get-vendor");

        const name_link = cy.get(
            "#vendors_list table tbody tr:first td:first a"
        );
        name_link.click();
        cy.get("#toolbar a").contains("Receive shipments").click();
        cy.get("h1").contains("Receive shipment from vendor " + vendor.name);
    });
});
