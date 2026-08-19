const item = {
    item_id: 1,
    biblio_id: 1,
    external_id: "BUG42605",
    home_library_id: "CPL",
    holding_library_id: "CPL",
    not_for_loan_status: 0,
    restricted_status: 0,
    location: null,
    callnumber: null,
    copy_number: null,
    inventory_number: null,
    collection: null,
    item_type: null,
    materials_notes: null,
    public_notes: null,
    _strings: {},
};

const buildOrder = (create_items: string | null, items = [item]) => ({
    order_id: 999999999,
    biblio_id: 1,
    basket_id: 1,
    basket: {
        basket_id: 1,
        vendor_id: 1,
        create_items,
        standing: false,
    },
    biblio: {
        title: "Bug 42605 test record",
        author: null,
        copyright_date: null,
        isbn: null,
        series_title: null,
        suggestions: [],
    },
    fund_id: 1,
    fund: {
        fund_id: 1,
        name: "Bug 42605 test fund",
        budget: { budget_period_description: "Bug 42605 test budget" },
    },
    items,
    creator: null,
    subscription_id: null,
    quantity: 1,
    quantity_received: 0,
    date_received: null,
    tax_rate_on_receiving: 0,
    tax_rate_on_ordering: 0,
    replacement_price: 10,
    rrp_tax_included: 10,
    rrp_tax_excluded: 10,
    ecost_tax_included: 10,
    ecost_tax_excluded: 10,
    unit_price_tax_included: null,
    unit_price_tax_excluded: null,
    internal_note: null,
    vendor_note: null,
    invoice_currency: null,
    invoice_unit_price: null,
});

const interceptOrder = order => {
    cy.intercept("GET", /\/api\/v1\/acquisitions\/orders\?only_active=1/, {
        statusCode: 200,
        headers: { "x-total-count": "1" },
        body: [order],
    }).as("getOrder");
};

describe("Order receive preferences", () => {
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
                    object: "invoice",
                    values: { vendor_id: vendor.id },
                });
            })
            .then(generatedInvoice => {
                return cy.task("insertObject", {
                    type: "invoice",
                    object: generatedInvoice,
                });
            })
            .then(invoice => {
                cy.wrap(invoice).as("invoice");
            });

        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AcqCreateItem'",
        }).then(rows => {
            cy.wrap(rows[0].value).as("syspref_AcqCreateItem");
        });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='UniqueItemFields'",
        }).then(rows => {
            cy.wrap(rows[0].value).as("syspref_UniqueItemFields");
        });
    });

    afterEach(function () {
        cy.task("query", {
            sql: "DELETE FROM aqinvoices WHERE invoiceid = ?",
            values: [this.invoice.invoice_id],
        });
        cy.task("deleteSampleObjects", [{ vendor: this.vendor }]);
        cy.set_syspref("AcqCreateItem", this.syspref_AcqCreateItem);
        cy.set_syspref("UniqueItemFields", this.syspref_UniqueItemFields);
    });

    const visitOrder = function (order) {
        interceptOrder(order);
        cy.visit(
            `/cgi-bin/koha/acqui/orderreceive.pl?invoiceid=${this.invoice.invoice_id}&multiple_orders=${order.order_id}`
        );
        cy.wait("@getOrder");
    };

    it("shows ordered items when the basket inherits AcqCreateItem", function () {
        cy.set_syspref("AcqCreateItem", "ordering");
        cy.set_syspref("UniqueItemFields", "barcode");
        visitOrder.call(this, buildOrder(null));

        cy.get("#order_edit").should("have.class", "show");
        cy.get("#modal-order-main #items-panel").should("have.class", "show");
        cy.get("#acq-create-ordering tbody tr").should("have.length", 1);
        cy.get('input[name="items_to_receive"]').should("have.length", 1);
    });

    it("shows ordered items when the basket overrides AcqCreateItem", function () {
        cy.set_syspref("AcqCreateItem", "ordering");
        cy.set_syspref("UniqueItemFields", "barcode");
        visitOrder.call(this, buildOrder("ordering"));

        cy.get("#order_edit").should("have.class", "show");
        cy.get("#modal-order-main #items-panel").should("have.class", "show");
        cy.get("#acq-create-ordering tbody tr").should("have.length", 1);
        cy.get('input[name="items_to_receive"]').should("have.length", 1);
    });

    it("opens the item form when the basket creates items on receiving", function () {
        cy.set_syspref("UniqueItemFields", "barcode");
        visitOrder.call(this, buildOrder("receiving", []));

        cy.get("#order_edit").should("have.class", "show");
        cy.get("#modal-order-main #items-panel").should("have.class", "show");
        cy.get("#outeritemblock").children().should("have.length", 1);
        cy.get('input[name="buttonPlus"]').should("have.length", 1);
    });
});
