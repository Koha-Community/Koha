describe("Vendor CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("should list vendors", () => {
        cy.visit("/cgi-bin/koha/acqui/acqui-home.pl");

        cy.intercept("GET", "/api/v1/acquisitions/vendors\?*", []);
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.get("#vendors_list").contains("There are no vendors defined");

        const vendor = cy.getVendor();
        cy.intercept("GET", "/api/v1/acquisitions/vendors\?*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.get("#vendors_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("should add a vendor", () => {
        const vendor = cy.getVendor();

        cy.intercept("GET", "/api/v1/acquisitions/vendors\?*", {
            statusCode: 200,
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.contains("New vendor").click();
        cy.get("h2").contains("New vendor");

        // Fill in the form for normal attributes
        cy.get("#toolbar").contains("Save").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );

        // Vendor details
        cy.get("#name").type(vendor.name);
        cy.get("#postal").type(vendor.postal);
        cy.get("#physical").type(`${vendor.address1}\n${vendor.address2}`);
        cy.get("#fax").type(vendor.fax);
        cy.get("#phone").type(vendor.phone);
        cy.get("#url").type(vendor.url);
        cy.get("#type").type(vendor.type);
        cy.get("#accountnumber").type(vendor.accountnumber);
        cy.contains("Add new alias").click();
        cy.get("#aliases_alias_0").type(vendor.aliases[0].alias);

        // Vendor ordering information
        cy.get("#active_true").check();
        cy.get("#list_currency .vs__search").type(
            vendor.list_currency + "{enter}",
            {
                force: true,
            }
        );
        cy.get("#invoice_currency .vs__search").type(
            vendor.invoice_currency + "{enter}",
            {
                force: true,
            }
        );
        cy.get("#gst_true").check();
        cy.get("#tax_rate .vs__search").type(
            `${(vendor.tax_rate * 100).toFixed(2)}` + "{enter}",
            {
                force: true,
            }
        );
        cy.get("#invoice_includes_gst_true").check();
        cy.get("#list_includes_gst_true").check();
        cy.get("#discount").type(vendor.discount.toString());
        cy.get("#deliverytime").type(vendor.deliverytime.toString());
        cy.get("#notes").type(vendor.notes);

        // Vendor contacts
        cy.contains("Add new contact").click();
        cy.get("#contacts_name_0").type(vendor.contacts[0].name);
        cy.get("#contacts_email_0").type(vendor.contacts[0].email);
        cy.get("#contacts_fax_0").type(vendor.contacts[0].fax);
        cy.get("#contacts_altphone_0").type(vendor.contacts[0].altphone);
        cy.get("#contacts_phone_0").type(vendor.contacts[0].phone);
        cy.get("#contacts_position_0").type(vendor.contacts[0].position);
        cy.get("#contacts_notes_0").type(vendor.contacts[0].notes);
        cy.get("#contact_acqprimary_0").check();
        cy.get("#contact_serialsprimary_0").check();

        // Vendor interfaces
        cy.contains("Add new interface").click();
        cy.get("#interfaces_name_0").type(vendor.interfaces[0].name);
        cy.get("#interfaces_uri_0").type(vendor.interfaces[0].uri);
        cy.get("#interfaces_login_0").type(vendor.interfaces[0].login);
        cy.get("#interfaces_password_0").type(vendor.interfaces[0].password);
        cy.get("#interfaces_account_email_0").type(
            vendor.interfaces[0].account_email
        );
        cy.get("#interfaces_notes_0").type(vendor.interfaces[0].notes);

        cy.intercept("POST", "/api/v1/acquisitions/vendors", {
            statusCode: 201,
            body: vendor,
        });
        cy.get("#toolbar").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains("Vendor created");
    });

    it("should edit a vendor", () => {
        const vendor = cy.getVendor();

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
        cy.intercept(
            "GET",
            "/api/v1/acquisitions/vendors/extended_attribute_types*",
            {
                body: [],
                statusCode: 200,
            }
        );

        // Click the 'Edit' button from the list
        cy.get("#vendors_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-vendor");
        cy.get("h2").contains("Edit vendor");

        // Form has been correctly filled in
        cy.get("#name").should("have.value", vendor.name);
        cy.get("#phone").should("have.value", vendor.phone);
        cy.get("#aliases_alias_0").should(
            "have.value",
            vendor.aliases[0].alias
        );
        cy.get("#active_true").should("be.checked");

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/acquisitions/vendors/*", {
            statusCode: 200,
            body: vendor,
        });
        cy.get("#toolbar").contains("Save").click();
        cy.get("main div[class='alert alert-info']").contains("Vendor updated");
    });

    it("should show a vendor", () => {
        const vendor = cy.getVendor();

        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/acquisitions/vendors\?*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-vendors");
        cy.visit("/cgi-bin/koha/acquisition/vendors");
        cy.wait("@get-vendors");
        cy.intercept(
            "GET",
            new RegExp("/api/v1/acquisitions/vendors/(?!config$).+"),
            vendor
        ).as("get-vendor");

        const name_link = cy.get(
            "#vendors_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", vendor.id);
        name_link.click();
        cy.get("#vendors_show h2").contains("Vendor #" + vendor.id);

        // TODO Test contracts table
    });

    it("should delete a vendor", () => {
        const vendor = cy.getVendor();

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/acquisitions/vendors\?*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept(
            "GET",
            new RegExp("/api/v1/acquisitions/vendors/(?!config$).+"),
            vendor
        );
        cy.intercept(
            "GET",
            "/api/v1/acquisitions/vendors/extended_attribute_types*",
            {
                body: [],
                statusCode: 200,
            }
        );
        cy.visit("/cgi-bin/koha/acquisition/vendors");

        cy.get("#vendors_list table tbody tr:first").contains("Delete").click();
        cy.get(".alert-warning.confirmation h1").contains("remove this vendor");
        cy.contains(vendor.name);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/acquisitions/vendors/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/acquisitions/vendors/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#vendors_list table tbody tr:first").contains("Delete").click();
        cy.get(".alert-warning.confirmation h1").contains("remove this vendor");
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Vendor")
            .contains("deleted");
    });
});

describe("Vendor module", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("buildSampleObject", {
            object: "vendor",
            values: { active: 1 },
        })
            .then(generatedVendor => {
                delete generatedVendor.list_currency;
                delete generatedVendor.invoice_currency;
                return cy.task("insertObject", {
                    type: "vendor",
                    object: generatedVendor,
                });
            })
            .then(vendor => {
                cy.wrap(vendor).as("vendor");
                return cy.task("buildSampleObject", {
                    object: "basket",
                    values: { vendor_id: vendor.id },
                });
            })
            .then(generatedBasket => {
                return cy.task("insertObject", {
                    type: "basket",
                    object: generatedBasket,
                });
            })
            .then(basket => {
                cy.wrap(basket).as("basket");
            });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [
            { vendor: this.vendor, basket: this.basket },
        ]);
    });

    it("receive should open in the same tab", function () {
        cy.visit("/cgi-bin/koha/acquisition/vendors");

        // table_id is currently 'DataTables_Table_0', and it should be fixed
        cy.get("#vendors_list table.dataTable")
            .invoke("attr", "id")
            .then(table_id => {
                cy.intercept("GET", "/api/v1/acquisitions/vendors*").as(
                    "get-vendors"
                );
                cy.get(`#${table_id}_wrapper input.dt-input`).type(
                    this.vendor.name
                );
                cy.wait("@get-vendors");
                cy.get(`#${table_id} tbody tr:first`)
                    .contains("Receive shipments")
                    .click();
                cy.url().should(
                    "contain",
                    `/cgi-bin/koha/acqui/parcels.pl?booksellerid=${this.vendor.id}`
                );
            });
    });
});
