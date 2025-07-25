describe("Navigation handling", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("buildSampleObject", {
            object: "vendor",
            values: { active: 1, name: "This should be in the breadcrumb" },
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
    it("Should render a list view", function () {
        cy.task("query", {
            sql: "SELECT count(*) AS count FROM aqbooksellers",
        }).then(result => {
            const vendorCount = result[0].count;
            cy.visit(`/cgi-bin/koha/acquisition/vendors`);

            cy.get("#vendors_list div.datatable").contains(
                `Showing 1 to ${vendorCount} of ${vendorCount} entries`
            );
        });
    });
    it("Should render a show view", function () {
        cy.visit(`/cgi-bin/koha/acquisition/vendors/${this.vendor.id}`);

        cy.get("#vendors_show h2").contains("Vendor #" + this.vendor.id);
        cy.get("#breadcrumbs").contains(this.vendor.name);
    });
    it("Should render a form to create a new resource", function () {
        cy.visit(`/cgi-bin/koha/acquisition/vendors`);

        cy.get("#toolbar").contains("New vendor").click();
        cy.get("h2").contains("New vendor");
    });
    it("Should render a form to edit an existing resource", function () {
        cy.visit(`/cgi-bin/koha/acquisition/vendors/${this.vendor.id}`);
        cy.get("#toolbar").contains("Edit").click();
        cy.get("#breadcrumbs").contains(this.vendor.name);
    });
});

describe("List view features", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });
    it("Should render additional toolbar buttons", function () {
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#toolbar a").should("have.length", 3);

        cy.get("#toolbar a").contains("Import from list").click();
        cy.get("h2").contains("Import from a list");
        cy.visit("/cgi-bin/koha/erm/eholdings/local/titles");
        cy.get("#toolbar a").contains("Import from KBART file").click();
        cy.get("h2").contains("Import from a KBART file");
    });
    it("Should automatically generate the table columns", function () {
        cy.task("buildSampleObject", {
            object: "erm_agreement",
            values: { vendor_id: null },
        })
            .then(agreement => {
                return cy.task("insertObject", {
                    type: "erm_agreement",
                    object: agreement,
                });
            })
            .then(erm_agreement => {
                cy.wrap(erm_agreement).as("erm_agreement");
            });

        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.get("table thead tr:first th").should("have.length", 9);
        cy.get("table thead tr:first th").contains("ID");
        cy.get("table thead tr:first th").contains("Agreement name");
        cy.get("table thead tr:first th").contains("Vendor");
        cy.get("table thead tr:first th").contains("Description");
        cy.get("table thead tr:first th").contains("Status");
        cy.get("table thead tr:first th").contains("Closure reason");
        cy.get("table thead tr:first th").contains("Is perpetual");
        cy.get("table thead tr:first th").contains("Renewal priority");
        cy.get("table thead tr:first th").contains("Actions");

        cy.get("@erm_agreement").then(erm_agreement => {
            cy.task("deleteSampleObjects", [
                { erm_agreement: this.erm_agreement },
            ]);
        });
    });
    it("Should display the table filters if they are enabled", function () {
        cy.task("buildSampleObjects", {
            object: "erm_agreement",
            count: 2,
            values: { vendor_id: null },
        }).then(agreements => {
            agreements[0].periods = [
                {
                    started_on: "2025-01-01",
                    ended_on: "2025-02-01",
                    cancellation_deadline: "2025-02-01",
                    notes: "",
                },
            ];
            agreements[1].periods = [
                {
                    started_on: "2025-01-01",
                    ended_on: null,
                    cancellation_deadline: null,
                    notes: "",
                },
            ];
            cy.task("insertObject", {
                type: "erm_agreement",
                object: agreements[0],
            }).then(agreementOne => {
                cy.wrap(agreementOne).as("agreementOne");
            });
            cy.task("insertObject", {
                type: "erm_agreement",
                object: agreements[1],
            }).then(agreementTwo => {
                cy.wrap(agreementTwo).as("agreementTwo");
            });
        });

        cy.visit("/cgi-bin/koha/erm/agreements");
        cy.get("fieldset.filters").should("be.visible");
        cy.get("fieldset.filters").contains("Filter by expired");
        cy.get("fieldset.filters label").should("have.length", 3);

        cy.get("#by_expired").check();
        cy.get("#filterTable").click();
        cy.get("@agreementOne").then(agreementOne => {
            cy.get("table tbody")
                .contains(agreementOne.name)
                .should("be.visible");
            cy.task("deleteSampleObjects", [
                { erm_agreement: this.agreementOne },
            ]);
        });
        cy.get("@agreementTwo").then(agreementTwo => {
            cy.get("table tbody").should("not.contain", agreementTwo.name);
            cy.task("deleteSampleObjects", [
                { erm_agreement: this.agreementTwo },
            ]);
        });
    });
    it("Should allow custom events to be passed to the table action buttons", function () {
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

        cy.get("@vendor").then(vendor => {
            cy.visit(
                `/cgi-bin/koha/acquisition/vendors?supplier=${vendor.name}`
            );
            cy.get("table tbody tr:first")
                .contains("Receive shipments")
                .click();
            cy.get("h1").contains(
                "Receive shipment from vendor " + vendor.name
            );
            cy.task("deleteSampleObjects", [
                { vendor: this.vendor, basket: this.basket },
            ]);
        });
    });
});

describe("Show view features", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("buildSampleObject", {
            object: "vendor",
            values: { active: 1, name: "This should be in the breadcrumb" },
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
    it("Should allow accordion view", function () {
        cy.get("@vendor").then(vendor => {
            cy.visit(`/cgi-bin/koha/acquisition/vendors/${vendor.id}`);
            cy.get("div.accordion").should("have.length", 2);
            cy.get("div.accordion:first legend").contains("Details");
            cy.get("div.accordion").eq(1).contains("Ordering information");
        });
    });
    it("Should append to show when the method is included in the resource", function () {
        cy.get("@vendor").then(vendor => {
            cy.task("query", {
                sql: "INSERT INTO aqcontract(booksellerid, contractname) VALUES (?, ?)",
                values: [vendor.id, "Test contract"],
            }).then(() => {
                cy.visit(`/cgi-bin/koha/acquisition/vendors/${vendor.id}`);
                cy.get("div.accordion").should("have.length", 3);
                cy.get("div.accordion").eq(2).contains("Contracts");
                cy.get("#contracts_relationship_list").contains(
                    "Test contract"
                );

                cy.task("query", {
                    sql: "DELETE FROM aqcontract where booksellerid=?",
                    values: [vendor.id],
                });
            });
        });
    });
});
