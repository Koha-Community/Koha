const getVendor = () => {
    return {
        accountnumber: "69823",
        active: true,
        address1: "6897 Library Rd",
        address2: "Springfield, MA 44224",
        address3: null,
        address4: null,
        aliases: [{ alias: "Test alias" }],
        baskets: [],
        contacts: [
            {
                name: "Test contact",
                position: "Test",
                email: "test@email.com",
                phone: "0123456789",
                notes: "Some interesting notes",
                altphone: "9876543210",
                fax: "Who uses fax these days?",
                acqprimary: false,
                orderacquisition: false,
                claimacquisition: false,
                serialsprimary: false,
                claimissues: false,
            },
        ],
        deliverytime: 3,
        discount: 10,
        external_id: "test1234",
        fax: "555-555-9999",
        gst: false,
        id: 1,
        interfaces: [
            {
                type: "interface",
                name: "fancy website",
                uri: "www.uri.com",
                login: "login",
                password: "password",
                account_email: "email@email.com",
                notes: "This is a website",
            },
        ],
        invoice_currency: "USD",
        invoice_includes_gst: false,
        list_currency: "USD",
        list_includes_gst: false,
        name: "My Vendor",
        notes: "Sample vendor",
        phone: "555-555-5555",
        postal: "567 Main St. PO Box 25 Springfield, MA 44224",
        subscriptions: [],
        tax_rate: 0.1965,
        type: "Print books",
        url: "https://koha-community.org/",
    };
};

describe("Vendor CRUD operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("should list vendors", () => {
        cy.visit("/cgi-bin/koha/acqui/acqui-home.pl");

        cy.intercept("GET", "/api/v1/acquisitions/vendors*", []);
        cy.visit("/cgi-bin/koha/vendors");
        cy.get("#vendors_list").contains("There are no vendors defined");

        const vendor = getVendor();
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/acquisitions/vendors/*", vendor);
        cy.visit("/cgi-bin/koha/vendors");
        cy.get("#vendors_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("should add a vendor", () => {
        const vendor = getVendor();

        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: [],
        });

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/vendors");
        cy.contains("New vendor").click();
        cy.get("#vendor_add h2").contains("New vendor");

        // Fill in the form for normal attributes
        cy.get("#vendor_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        );

        // Vendor details
        cy.get("#vendor_name").type(vendor.name);
        cy.get("#vendor_postal").type(vendor.postal);
        cy.get("#vendor_physical").type(
            `${vendor.address1}\n${vendor.address2}`
        );
        cy.get("#vendor_fax").type(vendor.fax);
        cy.get("#vendor_phone").type(vendor.phone);
        cy.get("#vendor_website").type(vendor.url);
        cy.get("#vendor_type").type(vendor.type);
        cy.get("#vendor_accountnumber").type(vendor.accountnumber);
        cy.get("#vendor_aliases").type(vendor.aliases[0].alias);
        cy.get(".aliasAction").click();

        // Vendor ordering information
        cy.get("#activestatus_active").check();
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
        cy.get("#gst_yes").check();
        cy.get("#tax_rate .vs__search").type(
            `${(vendor.tax_rate * 100).toFixed(2)}` + "{enter}",
            {
                force: true,
            }
        );
        cy.get("#invoice_gst_yes").check();
        cy.get("#list_gst_yes").check();
        cy.get("#discount").type(vendor.discount.toString());
        cy.get("#deliverytime").type(vendor.deliverytime.toString());
        cy.get("#notes").type(vendor.notes);

        // Vendor contacts
        cy.contains("Add new contact").click();
        cy.get("#contact_0_name").type(vendor.contacts[0].name);
        cy.get("#contact_0_email").type(vendor.contacts[0].email);
        cy.get("#contact_0_fax").type(vendor.contacts[0].fax);
        cy.get("#contact_0_altphone").type(vendor.contacts[0].altphone);
        cy.get("#contact_0_phone").type(vendor.contacts[0].phone);
        cy.get("#contact_0_position").type(vendor.contacts[0].position);
        cy.get("#contact_0_notes").type(vendor.contacts[0].notes);
        cy.get("#contact_acqprimary_0").check();
        cy.get("#contact_serialsprimary_0").check();

        // Vendor interfaces
        cy.contains("Add new interface").click();
        cy.get("#vendorInterface_0_name").type(vendor.interfaces[0].name);
        cy.get("#vendorInterface_0_uri").type(vendor.interfaces[0].uri);
        cy.get("#vendorInterface_0_login").type(vendor.interfaces[0].login);
        cy.get("#vendorInterface_0_password").type(
            vendor.interfaces[0].password
        );
        cy.get("#vendorInterface_0_accountemail").type(
            vendor.interfaces[0].account_email
        );
        cy.get("#vendorInterface_0_notes").type(vendor.interfaces[0].notes);

        cy.intercept("POST", "/api/v1/acquisitions/vendors", {
            statusCode: 201,
            body: vendor,
        });
        cy.get("#vendor_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains("Vendor created");
    });

    it("should edit a vendor", () => {
        const vendor = getVendor();

        cy.visit("/cgi-bin/koha/vendors");
        cy.intercept("GET", "/api/v1/acquisitions/vendors/*", vendor).as(
            "get-vendor"
        );

        // Click the 'Edit' button from the list
        cy.get("#vendors_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-vendor");
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#vendor_add h2").contains("Edit vendor");

        // Form has been correctly filled in
        cy.get("#vendor_name").should("have.value", vendor.name);
        cy.get("#vendor_phone").should("have.value", vendor.phone);
        cy.get("#alias0").should("have.text", vendor.aliases[0].alias);
        cy.get("#activestatus_active").should("be.checked");

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/acquisitions/vendors/*", {
            statusCode: 200,
            body: vendor,
        });
        cy.get("#vendor_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains("Vendor updated");
    });

    it("should show a vendor", () => {
        const vendor = getVendor();

        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/vendors");
        const name_link = cy.get(
            "#vendors_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", vendor.name + " (#" + vendor.id + ")");
        name_link.click();
        cy.wait(500); // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#vendors_show h1").contains(vendor.name);

        // TODO Test contracts table
    });

    it("should delete a vendor", () => {
        const vendor = getVendor();

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/acquisitions/vendors*", {
            statusCode: 200,
            body: [vendor],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/acquisitions/vendors/*", vendor);
        cy.visit("/cgi-bin/koha/vendors");

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
