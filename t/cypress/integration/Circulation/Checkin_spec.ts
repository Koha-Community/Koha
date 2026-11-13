// End-to-end tests for the Vue check-in page (circ/checkin.pl).
//
// The data is created in the database through the plugin tasks and the
// outcome of each action is checked in the database too, so these tests
// exercise the page, the REST API and the circulation code together.

// The library the 'koha' user is logged in at
const LOGGED_IN_LIBRARY = "CPL";

// System preferences these tests depend on, and the value each test starts
// with. The original values are restored after each test.
const PREFS = {
    AutomaticItemReturn: "1",
    AutomaticConfirmTransfer: "0",
    RecordLocalUseOnReturn: "0",
    BlockReturnOfLostItems: "0",
    BlockReturnOfWithdrawnItems: "1",
    CircConfirmItemParts: "0",
    ClaimReturnedLostValue: "",
    AutoClaimReturnStatusOnCheckin: "",
    HoldsAutoFill: "0",
    SpecifyReturnDate: "1",
    TransfersBlockCirc: "0",
    UseRecalls: "off",
};

const originalPrefs = {};

// Objects to remove after each test, and SQL statements to run before
// they are removed
let cleanupObjects = [];
let cleanupQueries = [];

function cleanupLater(objects) {
    cleanupObjects.push(objects);
}

function cleanupQueryLater(sql, values) {
    cleanupQueries.push({ sql, values });
}

function dbQuery(sql, values = []) {
    return cy.task("query", { sql, values });
}

// Move an item to a library, so it does not need to be transferred when
// it is checked in there
function moveItemTo(item, library_id) {
    return dbQuery(
        "UPDATE items SET homebranch=?, holdingbranch=? WHERE itemnumber=?",
        [library_id, library_id, item.item_id]
    );
}

// Create a checked out item. Its home library is LOGGED_IN_LIBRARY unless
// stay_home is set, in which case it stays at a newly created library.
function createCheckout({ stay_home = false } = {}) {
    return cy.task("insertSampleCheckout").then(objects => {
        cleanupLater(objects);
        cleanupLater({
            category: { patron_category_id: objects.patron.category_id },
        });
        const item = objects.items[0];
        cleanupItemHistory(item);
        if (stay_home) {
            return cy.wrap(objects);
        }
        return moveItemTo(item, LOGGED_IN_LIBRARY).then(() => objects);
    });
}

// Place a hold on an item for a new patron
function createHold(item, pickup_library_id) {
    return cy
        .task("insertSampleHold", { item, library_id: pickup_library_id })
        .then(objects => {
            cleanupLater(objects);
            cleanupLater({ category: objects.patron_category });
            cleanupQueryLater("DELETE FROM old_reserves WHERE reserve_id=?", [
                objects.hold.hold_id,
            ]);
            return objects;
        });
}

// Rows the check-in leaves behind for the item, which do not belong to any
// of the objects created by the tasks
function cleanupItemHistory(item) {
    cleanupQueryLater("DELETE FROM old_issues WHERE itemnumber=?", [
        item.item_id,
    ]);
    cleanupQueryLater("DELETE FROM statistics WHERE itemnumber=?", [
        item.item_id,
    ]);
}

function visitCheckin(params = "") {
    cy.visit(`/cgi-bin/koha/circ/checkin.pl${params}`);
    // The Vue app is mounted
    cy.get("#checkin-app #barcode-input").should("be.visible");
    // The page focuses the barcode box a moment after it is mounted: wait for
    // it, so it does not take the focus from what a test does next (it
    // closes an open date picker, for example)
    cy.get("#checkin-app #barcode-input").should("have.focus");
}

function checkin(barcode) {
    cy.get("#barcode-input").should("not.be.disabled").clear().type(barcode);
    cy.get("#checkin-app form.checkin-form button[type='submit']").click();
    return cy.wait("@checkin");
}

// Set the return date override through the flatpickr instance: the
// picker also takes a time, so its calendar does not close on a click.
// The date is passed as a timestamp, a Date from the spec is not an
// instance of the Date of the application window
function setReturnDate(date) {
    return cy
        .get("#return-date-override")
        .should($el => expect($el[0]).to.have.property("_flatpickr"))
        .then($el => $el[0]._flatpickr.setDate(date.getTime(), true));
}

function checkoutCount(item) {
    return dbQuery("SELECT COUNT(*) AS count FROM issues WHERE itemnumber=?", [
        item.item_id,
    ]).then(rows => rows[0].count);
}

function checkinModal() {
    return cy.get(
        "#checkin-app .modal.non-blocking .modal-content, #checkin-app .modal.blocking .modal-content"
    );
}

describe("Circulation - Check in", () => {
    before(() => {
        const names = Object.keys(PREFS);
        dbQuery(
            `SELECT variable, value FROM systempreferences WHERE variable IN (${names.map(() => "?").join(",")})`,
            names
        ).then(rows => {
            for (const row of rows) {
                originalPrefs[row.variable] = row.value;
            }
        });
    });

    beforeEach(() => {
        cleanupObjects = [];
        cleanupQueries = [];
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        for (const [name, value] of Object.entries(PREFS)) {
            cy.set_syspref(name, value);
        }
        cy.intercept("POST", "/api/v1/checkins*").as("checkin");
    });

    afterEach(() => {
        cy.then(() => {
            for (const { sql, values } of cleanupQueries) {
                dbQuery(sql, values);
            }
        });
        cy.then(() => cy.task("deleteSampleObjects", cleanupObjects));
        cy.visit("/cgi-bin/koha/mainpage.pl");
        for (const [name, value] of Object.entries(originalPrefs)) {
            cy.set_syspref(name, value);
        }
    });

    describe("Simple check-in", () => {
        it("checks in a checked out item", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];

                visitCheckin();
                cy.get("#checkin-app").should(
                    "contain",
                    "No items have been checked in yet."
                );

                checkin(item.external_id)
                    .its("response.statusCode")
                    .should("eq", 200);

                cy.get("#checkins-table tbody tr")
                    .should("have.length", 1)
                    .first()
                    .should("contain", item.external_id)
                    .and("contain", objects.biblio.title)
                    .and("not.have.class", "table-warning");
                checkinModal().should("not.exist");
                cy.get("#checkin-app .alert-danger").should("not.exist");

                checkoutCount(item).should("eq", 0);
                dbQuery(
                    "SELECT COUNT(*) AS count FROM old_issues WHERE issue_id=?",
                    [objects.checkout.checkout_id]
                )
                    .its("0.count")
                    .should("eq", 1);

                // The input is ready for the next barcode
                cy.get("#barcode-input")
                    .should("have.value", "")
                    .and("have.focus");
            });
        });

        it("lets the librarian show, hide, export and configure the columns", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];

                visitCheckin();
                cy.clearLocalStorage();
                checkin(item.external_id);
                cy.get("#checkins-table tbody tr").should("have.length", 1);

                // Shown by default, and hidden by the table settings
                cy.get("#checkins-table thead").should(
                    "contain",
                    "Call number"
                );
                cy.get("#checkins-table thead").should(
                    "not.contain",
                    "Date acquired"
                );

                cy.get(".koha-table-controls .columns_controls").click();
                cy.get(".columns-menu").should("be.visible");
                cy.get(".column-toggle[data-colname='itemcallnumber']").click();
                cy.get(
                    ".column-toggle[data-colname='dateaccessioned']"
                ).click();
                cy.get("#checkins-table thead")
                    .should("not.contain", "Call number")
                    .and("contain", "Date acquired");
                // The cells follow the headings
                cy.get("#checkins-table thead th").then($th => {
                    cy.get("#checkins-table tbody tr td").should(
                        "have.length",
                        $th.length
                    );
                });

                // Remembered when the page is loaded again
                visitCheckin();
                checkin(item.external_id);
                cy.get("#checkins-table thead")
                    .should("not.contain", "Call number")
                    .and("contain", "Date acquired");

                cy.get(".koha-table-controls .export_controls").click();
                cy.get(".export-csv").should("be.visible");
                cy.get(".export-copy").should("be.visible");
                cy.get(".export-print").should("be.visible");

                cy.get(".dt_button_configure_table")
                    .should("have.attr", "href")
                    .and(
                        "contain",
                        "columns_settings.pl?module=circ&page=returns&table=checkedintable"
                    );
                cy.clearLocalStorage();
            });
        });

        it("keeps the form, its settings and the results in white cards", () => {
            createCheckout({ stay_home: true }).then(objects => {
                visitCheckin();

                // The settings expand inside the card of the form
                // Password managers must not offer to fill the barcode box:
                // their icon covers the settings icon
                cy.get("#barcode-input").should($input => {
                    expect($input).to.have.attr("autocomplete", "off");
                    expect($input).to.have.attr("data-1p-ignore");
                    expect($input).to.have.attr("data-lpignore", "true");
                    expect($input).to.have.attr("data-bwignore", "true");
                    expect($input).to.have.attr("data-form-type", "other");
                });

                cy.get("#checkin-app .page-section.checkin-card")
                    .should(
                        "have.css",
                        "background-color",
                        "rgb(255, 255, 255)"
                    )
                    .within(() => {
                        cy.get("#barcode-input").should("be.visible");
                        cy.get(".circ-settings").should("not.be.visible");
                        cy.get("[aria-label='Checkin settings']").click();
                        cy.get(".circ-settings").should("be.visible");
                    });

                checkin(objects.items[0].external_id);

                // The checked-in items have a card and a heading
                cy.get("#checkin-app .page-section")
                    .contains("h2", "Checked-in items")
                    .parent()
                    .find("table#checkins-table")
                    .should("be.visible");
            });
        });

        it("shows an error for an unknown barcode", () => {
            const barcode = `UNKNOWN-${Date.now()}`;

            visitCheckin();
            checkin(barcode).its("response.statusCode").should("eq", 404);

            cy.get("#checkin-app .alert-danger")
                .should("be.visible")
                .and("contain", `No item with barcode: ${barcode}`);
            cy.get("#checkins-table").should("not.exist");
            checkinModal().should("not.exist");
        });

        it("prefills the barcode from the URL without checking the item in", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];

                visitCheckin(
                    `?barcode=${encodeURIComponent(item.external_id)}`
                );

                cy.get("#barcode-input").should("have.value", item.external_id);
                // Give the page time to (wrongly) submit the barcode
                cy.wait(1000);
                cy.get("@checkin.all").should("have.length", 0);
                cy.get("#checkins-table").should("not.exist");
                checkoutCount(item).should("eq", 1);

                // Staff confirm the check-in explicitly
                cy.get(
                    "#checkin-app form.checkin-form button[type='submit']"
                ).click();
                cy.wait("@checkin")
                    .its("response.statusCode")
                    .should("eq", 200);
                cy.get("#checkins-table tbody tr")
                    .first()
                    .should("contain", item.external_id);
                checkoutCount(item).should("eq", 0);
            });
        });

        it("checks in the item from the header search box", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];

                // The header search box posts the barcode to the check-in page,
                // which checks the item in once it is loaded. Its tab may not be
                // the active one, so the form is filled and submitted directly
                cy.visit("/cgi-bin/koha/mainpage.pl");
                cy.get("#ret_barcode").invoke("val", item.external_id);
                cy.get("#ret_barcode").closest("form").submit();

                cy.wait("@checkin")
                    .its("response.statusCode")
                    .should("eq", 200);
                cy.get("#checkins-table tbody tr")
                    .first()
                    .should("contain", item.external_id);
                checkoutCount(item).should("eq", 0);
            });
        });

        it("shows the item type check-in message as text", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery(
                    "UPDATE itemtypes SET checkinmsg=?, checkinmsgtype='message' WHERE itemtype=?",
                    [
                        "Handle <b>with</b> care <img src=x onerror=alert(1)>",
                        objects.item_type.item_type_id,
                    ]
                );

                visitCheckin();
                checkin(item.external_id);

                cy.get("#checkins-table tbody tr")
                    .first()
                    .should("contain", item.external_id);
                cy.contains(
                    "#checkin-app .alert",
                    "Handle <b>with</b> care <img src=x onerror=alert(1)>"
                )
                    .should("be.visible")
                    .within(() => {
                        cy.get("b").should("not.exist");
                        cy.get("img").should("not.exist");
                    });
                checkoutCount(item).should("eq", 0);
            });
        });
    });

    describe("Blocked check-in", () => {
        it("does not check in a withdrawn item with BlockReturnOfWithdrawnItems", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery(
                    "UPDATE items SET withdrawn=1, withdrawn_on=NOW() WHERE itemnumber=?",
                    [item.item_id]
                );

                visitCheckin();
                checkin(item.external_id)
                    .its("response.statusCode")
                    .should("eq", 403);

                // The refusal is a red alert under the form, not a modal
                cy.get("#checkin-app .modal.show").should("not.exist");
                cy.get("#checkin-app .alert-danger")
                    .should("be.visible")
                    .and("have.attr", "role", "alert")
                    .and("contain", "NOT CHECKED IN")
                    .and(
                        "contain",
                        "This item is withdrawn and cannot be checked in."
                    );
                cy.get("#checkin-app .checkin-card")
                    .nextAll()
                    .find(".alert-danger")
                    .should("exist");
                cy.get("#checkins-table tbody tr")
                    .first()
                    .should("have.class", "table-danger")
                    .and("contain", "Blocked");

                // Nothing to acknowledge: the next item can be scanned
                cy.get("#barcode-input").should("not.be.disabled");

                checkoutCount(item).should("eq", 1);
            });
        });

        it("does not check in a lost item with BlockReturnOfLostItems", () => {
            cy.set_syspref("BlockReturnOfLostItems", "1");
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery(
                    "UPDATE items SET itemlost=1, itemlost_on=NOW() WHERE itemnumber=?",
                    [item.item_id]
                );

                visitCheckin();
                checkin(item.external_id)
                    .its("response.statusCode")
                    .should("eq", 403);

                cy.get("#checkin-app .modal.show").should("not.exist");
                cy.get("#checkin-app .alert-danger")
                    .should("be.visible")
                    .and("contain", "NOT CHECKED IN")
                    .and(
                        "contain",
                        "This item is lost and cannot be checked in."
                    );
                checkoutCount(item).should("eq", 1);
            });
        });
    });

    describe("Results of the check-in", () => {
        // An item that is on the shelf, as if its checkout had ended
        function createItemOnShelf() {
            return createCheckout().then(objects =>
                dbQuery("DELETE FROM issues WHERE itemnumber=?", [
                    objects.items[0].item_id,
                ]).then(() => objects)
            );
        }

        it("makes the librarian read the note the patron left on the checkout", () => {
            createCheckout().then(objects => {
                const note = `Please renew it for me, ${Date.now()}`;
                dbQuery(
                    "UPDATE issues SET note=?, notedate=NOW() WHERE issue_id=?",
                    [note, objects.checkout.checkout_id]
                ).then(() => {
                    visitCheckin();
                    checkin(objects.items[0].external_id);

                    // The page waits until the note is read
                    checkinModal()
                        .should("be.visible")
                        .and("contain", "Note from the patron")
                        .and("contain", note);
                    cy.get("#checkin-app .modal.show.blocking").should("exist");
                    cy.get("#barcode-input").should("be.disabled");

                    checkinModal()
                        .contains("button", "Acknowledge (Y)")
                        .click();
                    checkinModal().should("not.exist");
                    cy.get("#barcode-input").should("not.be.disabled");
                    // The row keeps the note
                    cy.get("#checkins-table tbody tr")
                        .first()
                        .should("contain", note)
                        .and("not.have.class", "table-warning");
                });
            });
        });

        it("says in a yellow alert that the item was not checked out", () => {
            cy.set_syspref("RecordLocalUseOnReturn", "0");
            createItemOnShelf().then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);

                cy.get("#checkin-app .alert-warning")
                    .should("be.visible")
                    .and("contain", "Not checked out.");
                cy.get("#checkin-app").should(
                    "not.contain",
                    "Local use recorded."
                );
            });
        });

        it("says in a blue alert that a local use was recorded", () => {
            cy.set_syspref("RecordLocalUseOnReturn", "1");
            createItemOnShelf().then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);

                cy.get("#checkin-app .alert-info")
                    .should("be.visible")
                    .and("contain", "Local use recorded.");
            });
        });

        it("says that the waiting hold with a cancellation request was cancelled", () => {
            createItemOnShelf().then(objects => {
                const item = objects.items[0];
                createHold(item, LOGGED_IN_LIBRARY).then(({ hold }) => {
                    dbQuery(
                        "UPDATE reserves SET found='W', priority=0, itemnumber=? WHERE reserve_id=?",
                        [item.item_id, hold.hold_id]
                    );
                    dbQuery(
                        "INSERT INTO hold_cancellation_requests (hold_id) VALUES (?)",
                        [hold.hold_id]
                    );
                    cleanupQueryLater(
                        "DELETE FROM hold_cancellation_requests WHERE hold_id=?",
                        [hold.hold_id]
                    );

                    visitCheckin();
                    checkin(item.external_id);

                    cy.get("#checkin-app .alert-info")
                        .should("be.visible")
                        .and(
                            "contain",
                            "The hold waiting for this item was cancelled"
                        );
                    cy.get("#checkins-table tbody tr")
                        .first()
                        .should("contain", "Hold cancelled");
                    dbQuery(
                        "SELECT COUNT(*) AS count FROM reserves WHERE reserve_id=?",
                        [hold.hold_id]
                    )
                        .its("0.count")
                        .should("eq", 0);
                });
            });
        });
    });

    describe("Confirmations", () => {
        it("checks the item in only once the confirmation is accepted", () => {
            cy.set_syspref("CircConfirmItemParts", "1");
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery("UPDATE items SET materials=? WHERE itemnumber=?", [
                    "Two discs",
                    item.item_id,
                ]);

                visitCheckin();
                checkin(item.external_id)
                    .its("response.statusCode")
                    .should("eq", 412);

                checkinModal().should("be.visible").and("contain", "Two discs");
                checkoutCount(item).should("eq", 1);

                // The check-in is sent again, with the confirmation token
                checkinModal().contains("button", "Yes, check in").click();
                cy.wait("@checkin").then(({ request, response }) => {
                    expect(request.url).to.contain("confirmation=");
                    expect(response.statusCode).to.eq(200);
                });

                checkinModal().should("not.exist");
                checkoutCount(item).should("eq", 0);
            });
        });

        it("does not check the item in when the confirmation is declined", () => {
            cy.set_syspref("CircConfirmItemParts", "1");
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery("UPDATE items SET materials=? WHERE itemnumber=?", [
                    "Two discs",
                    item.item_id,
                ]);

                visitCheckin();
                checkin(item.external_id)
                    .its("response.statusCode")
                    .should("eq", 412);

                checkinModal().contains("button", "No, don't check in").click();
                checkinModal().should("not.exist");
                checkoutCount(item).should("eq", 1);
            });
        });
    });

    describe("Module policy", () => {
        it("refreshes the policy when the server refuses a return date", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];

                visitCheckin();
                cy.get("#show-circ-settings a").click();
                cy.get("#return_date_override_fields").should("be.visible");

                // The return date override is disabled after the page was
                // loaded: the page still offers it
                cy.set_syspref("SpecifyReturnDate", "0");

                const yesterday = new Date();
                yesterday.setDate(yesterday.getDate() - 1);
                setReturnDate(yesterday);
                cy.get("#show-circ-settings a").click();
                cy.get("#checkin-app .checkin-active-settings").should(
                    "contain",
                    "Return date:"
                );

                checkin(item.external_id).then(({ response }) => {
                    expect(response.statusCode).to.eq(403);
                    expect(response.body.error_code).to.eq(
                        "return_date_not_allowed"
                    );
                    expect(response.body.policy.module).to.eq("checkin");
                    expect(
                        response.body.policy.checkin.specify_return_date
                    ).to.eq(false);
                });

                cy.get("#checkin-app .alert-danger")
                    .should("be.visible")
                    .and(
                        "contain",
                        "Specifying a return date is not allowed. The item was not checked in."
                    );
                // The page no longer offers the return date
                cy.get("#checkin-app .checkin-active-settings").should(
                    "not.exist"
                );
                cy.get("#show-circ-settings a").click();
                cy.get("#return_date_override_fields").should("not.exist");
                checkinModal().should("not.exist");

                checkoutCount(item).should("eq", 1);
            });
        });
    });

    describe("Holds", () => {
        it("sets the hold waiting when it is confirmed", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];
                createHold(item, LOGGED_IN_LIBRARY).then(({ hold }) => {
                    cy.intercept(
                        "POST",
                        "/api/v1/checkins/*/hold_confirmation*"
                    ).as("holdConfirmation");

                    visitCheckin();
                    checkin(item.external_id);

                    checkinModal()
                        .should("be.visible")
                        .and("contain", "Hold found")
                        .and("contain", objects.biblio.title);
                    cy.get("#checkins-table tbody tr")
                        .first()
                        .should("have.class", "table-warning");
                    checkoutCount(item).should("eq", 0);

                    checkinModal()
                        .contains("button", "Confirm hold (Y)")
                        .click();
                    cy.wait("@holdConfirmation")
                        .its("response.statusCode")
                        .should("eq", 201);

                    checkinModal().should("not.exist");
                    cy.get("#checkins-table tbody tr")
                        .first()
                        .should("not.have.class", "table-warning");
                    dbQuery(
                        "SELECT found, itemnumber, branchcode FROM reserves WHERE reserve_id=?",
                        [hold.hold_id]
                    ).then(rows => {
                        expect(rows).to.have.length(1);
                        expect(rows[0].found).to.eq("W");
                        expect(rows[0].itemnumber).to.eq(item.item_id);
                        expect(rows[0].branchcode).to.eq(LOGGED_IN_LIBRARY);
                    });
                });
            });
        });

        it("transfers the item when the hold is for another library", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];
                const pickup_library = objects.libraries[0];
                createHold(item, pickup_library.library_id).then(({ hold }) => {
                    cy.intercept(
                        "POST",
                        "/api/v1/checkins/*/hold_confirmation*"
                    ).as("holdConfirmation");

                    visitCheckin();
                    checkin(item.external_id);

                    checkinModal()
                        .should("be.visible")
                        .and("contain", "Hold found");
                    checkinModal()
                        .contains("button", "Confirm hold and transfer (Y)")
                        .click();
                    cy.wait("@holdConfirmation")
                        .its("response.statusCode")
                        .should("eq", 201);
                    checkinModal().should("not.exist");

                    dbQuery("SELECT found FROM reserves WHERE reserve_id=?", [
                        hold.hold_id,
                    ])
                        .its("0.found")
                        .should("eq", "T");
                    dbQuery(
                        "SELECT frombranch, tobranch, datesent, reason FROM branchtransfers WHERE itemnumber=? AND datearrived IS NULL AND datecancelled IS NULL",
                        [item.item_id]
                    ).then(rows => {
                        expect(rows).to.have.length(1);
                        expect(rows[0].frombranch).to.eq(LOGGED_IN_LIBRARY);
                        expect(rows[0].tobranch).to.eq(
                            pickup_library.library_id
                        );
                        expect(rows[0].datesent).to.not.eq(null);
                        expect(rows[0].reason).to.eq("Reserve");
                    });
                });
            });
        });

        it("cancels a waiting hold from the hold modal", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];
                createHold(item, LOGGED_IN_LIBRARY).then(({ hold }) => {
                    // The item was returned and set waiting before
                    dbQuery("DELETE FROM issues WHERE itemnumber=?", [
                        item.item_id,
                    ]);
                    dbQuery(
                        "UPDATE reserves SET found='W', priority=0, waitingdate=CURDATE(), itemnumber=?, branchcode=? WHERE reserve_id=?",
                        [item.item_id, LOGGED_IN_LIBRARY, hold.hold_id]
                    );
                    cy.intercept(
                        "POST",
                        "/api/v1/checkins/*/hold_cancellation*"
                    ).as("holdCancellation");

                    visitCheckin();
                    checkin(item.external_id);

                    checkinModal()
                        .should("be.visible")
                        .and("contain", "Hold found (item is already waiting)");
                    checkinModal()
                        .contains("button", "Cancel hold (X)")
                        .click();

                    // Secondary pop-up asking for a cancellation reason
                    cy.get("#checkin-app .modal-dialog.modal-sm")
                        .should("be.visible")
                        .and("contain", "Cancellation reason:")
                        .contains("button", "Cancel hold")
                        .click();
                    cy.wait("@holdCancellation")
                        .its("response.statusCode")
                        .should("eq", 201);

                    cy.get("#checkin-app .modal").should("not.exist");
                    dbQuery(
                        "SELECT COUNT(*) AS count FROM reserves WHERE reserve_id=?",
                        [hold.hold_id]
                    )
                        .its("0.count")
                        .should("eq", 0);
                    dbQuery(
                        "SELECT cancellationdate FROM old_reserves WHERE reserve_id=?",
                        [hold.hold_id]
                    ).then(rows => {
                        expect(rows).to.have.length(1);
                        expect(rows[0].cancellationdate).to.not.eq(null);
                    });
                });
            });
        });
    });

    describe("Transfers", () => {
        it("sends the item back to its home library when confirmed", () => {
            cy.set_syspref("TransfersBlockCirc", "1");
            createCheckout({ stay_home: true }).then(objects => {
                const item = objects.items[0];
                const home_library = objects.libraries[0];
                cy.intercept(
                    "POST",
                    "/api/v1/checkins/*/transfer_confirmation*"
                ).as("transferConfirmation");

                visitCheckin();
                checkin(item.external_id);

                checkinModal()
                    .should("be.visible")
                    .and(
                        "contain",
                        `Please return this item to: ${home_library.name}`
                    );
                checkoutCount(item).should("eq", 0);
                // TransfersBlockCirc: the transfer must be acted on first
                cy.get("#barcode-input").should("be.disabled");

                // The transfer already exists (AutomaticItemReturn): the
                // dialog only asks to acknowledge it
                checkinModal().contains("button", "OK (Y)").click();
                cy.wait("@transferConfirmation")
                    .its("response.statusCode")
                    .should("eq", 201);
                checkinModal().should("not.exist");
                cy.get("#barcode-input").should("not.be.disabled");

                dbQuery(
                    "SELECT frombranch, tobranch, datesent FROM branchtransfers WHERE itemnumber=? AND datearrived IS NULL AND datecancelled IS NULL",
                    [item.item_id]
                ).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].frombranch).to.eq(LOGGED_IN_LIBRARY);
                    expect(rows[0].tobranch).to.eq(home_library.library_id);
                    expect(rows[0].datesent).to.not.eq(null);
                });
            });
        });
    });

    describe("Transfers: what closing the dialog does", () => {
        const hint = () => checkinModal().find(".dismiss-hint");

        it("says that closing leaves an existing transfer as it is", () => {
            createCheckout({ stay_home: true }).then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);
                hint()
                    .should("be.visible")
                    .and("contain", "leaves the transfer as it is");
            });
        });

        it("says that closing confirms the transfer with AutomaticConfirmTransfer", () => {
            cy.set_syspref("AutomaticConfirmTransfer", "1");
            createCheckout({ stay_home: true }).then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);
                hint()
                    .should("be.visible")
                    .and("contain", "confirms the transfer");
            });
        });

        it("says that closing does not transfer the item when none was created", () => {
            cy.set_syspref("AutomaticItemReturn", "0");
            createCheckout({ stay_home: true }).then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);
                hint()
                    .should("be.visible")
                    .and("contain", "does not transfer the item");
            });
        });

        it("has no hint when the dialog blocks the page", () => {
            cy.set_syspref("TransfersBlockCirc", "1");
            createCheckout({ stay_home: true }).then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);
                checkinModal().should("be.visible");
                hint().should("not.exist");
            });
        });
    });

    describe("Transfers: blocking and cancelling", () => {
        it("dims the page and blocks everything outside the dialog when blocking", () => {
            cy.set_syspref("TransfersBlockCirc", "1");
            createCheckout({ stay_home: true }).then(objects => {
                visitCheckin();
                checkin(objects.items[0].external_id);

                checkinModal().should("be.visible");
                cy.get("#checkin-app .modal.blocking")
                    .should("have.attr", "aria-modal", "true")
                    .and("have.css", "background-color", "rgba(0, 0, 0, 0.5)");

                // The dialog covers the menu: a click outside it cannot
                // reach a link
                cy.get("#sidebar-container a")
                    .first()
                    .then($link => {
                        const rect = $link[0].getBoundingClientRect();
                        const top = $link[0].ownerDocument.elementFromPoint(
                            rect.left + 4,
                            rect.top + 4
                        );
                        expect(top.closest(".modal.blocking")).to.not.eq(null);
                    });

                // Escape does not dismiss it either
                cy.get("body").type("{esc}");
                checkinModal().should("be.visible");

                // Ignoring is not possible either: a choice must be made
                checkinModal().should("not.contain", "Ignore (I)");

                checkinModal().contains("button", "OK (Y)").click();
                checkinModal().should("not.exist");
            });
        });

        it("cancels the transfer created by AutomaticItemReturn, leaving a trace in the transfer history", () => {
            createCheckout({ stay_home: true }).then(objects => {
                const item = objects.items[0];
                visitCheckin();
                checkin(item.external_id);

                checkinModal()
                    .should("be.visible")
                    .and("contain", "The transfer has already been created");
                checkinModal()
                    .contains("button", "Cancel transfer (X)")
                    .should("have.attr", "accesskey", "x")
                    .click();
                checkinModal().should("not.exist");

                // The transfer is kept, as cancelled
                dbQuery(
                    "SELECT datecancelled, cancellation_reason FROM branchtransfers WHERE itemnumber=?",
                    [item.item_id]
                ).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].datecancelled).to.not.eq(null);
                    expect(rows[0].cancellation_reason).to.eq("Manual");
                });
            });
        });

        it("leaves the existing transfer as it is when ignored", () => {
            createCheckout({ stay_home: true }).then(objects => {
                const item = objects.items[0];
                visitCheckin();
                checkin(item.external_id);

                checkinModal()
                    .contains("button", "Ignore (I)")
                    .should("have.attr", "accesskey", "i")
                    .click();
                checkinModal().should("not.exist");

                // Neither confirmed nor cancelled: the transfer is untouched
                dbQuery(
                    "SELECT datesent, datecancelled FROM branchtransfers WHERE itemnumber=?",
                    [item.item_id]
                ).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].datecancelled).to.eq(null);
                });
            });
        });

        it("only offers to not create the transfer when none exists yet", () => {
            cy.set_syspref("AutomaticItemReturn", "0");
            createCheckout({ stay_home: true }).then(objects => {
                const item = objects.items[0];
                visitCheckin();
                checkin(item.external_id);

                checkinModal().should("contain", "Transfer now?");
                checkinModal().contains("button", "Yes, transfer (Y)");
                checkinModal()
                    .contains("button", "No, don't transfer (N)")
                    .should("have.attr", "accesskey", "n")
                    .click();
                checkinModal().should("not.exist");

                // Nothing was created
                dbQuery(
                    "SELECT COUNT(*) AS count FROM branchtransfers WHERE itemnumber=?",
                    [item.item_id]
                ).then(rows => expect(rows[0].count).to.eq(0));
            });
        });
    });

    describe("Recalls", () => {
        it("sets the recall waiting when it is confirmed", () => {
            cy.set_syspref("UseRecalls", "staff");
            createCheckout().then(objects => {
                const item = objects.items[0];
                // Recalls need to be allowed for the item type
                dbQuery(
                    "INSERT INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value) VALUES (NULL, NULL, ?, 'recalls_allowed', '1')",
                    [objects.item_type.item_type_id]
                );
                cleanupQueryLater(
                    "DELETE FROM circulation_rules WHERE itemtype=?",
                    [objects.item_type.item_type_id]
                );
                cy.task("insertSamplePatron", {
                    library: { library_id: LOGGED_IN_LIBRARY },
                }).then(({ patron, patron_category }) => {
                    cleanupLater({ patron, category: patron_category });
                    dbQuery(
                        "INSERT INTO recalls (patron_id, created_date, biblio_id, pickup_library_id, priority, status, item_id, item_level) VALUES (?, NOW(), ?, ?, 1, 'requested', ?, 1)",
                        [
                            patron.patron_id,
                            objects.biblio.biblio_id,
                            LOGGED_IN_LIBRARY,
                            item.item_id,
                        ]
                    ).then(result => {
                        const recall_id = result.insertId;
                        cleanupQueryLater(
                            "DELETE FROM recalls WHERE recall_id=?",
                            [recall_id]
                        );
                        cy.intercept(
                            "POST",
                            "/api/v1/checkins/*/recall_confirmation*"
                        ).as("recallConfirmation");

                        visitCheckin();
                        checkin(item.external_id);

                        checkinModal()
                            .should("be.visible")
                            .and("contain", "Recall found")
                            .and("contain", patron.surname);
                        checkoutCount(item).should("eq", 0);

                        checkinModal()
                            .contains("button", "Confirm recall (Y)")
                            .click();
                        cy.wait("@recallConfirmation")
                            .its("response.statusCode")
                            .should("eq", 201);
                        checkinModal().should("not.exist");

                        dbQuery(
                            "SELECT status, item_id FROM recalls WHERE recall_id=?",
                            [recall_id]
                        ).then(rows => {
                            expect(rows[0].status).to.eq("waiting");
                            expect(rows[0].item_id).to.eq(item.item_id);
                        });
                    });
                });
            });
        });
    });
    describe("Bundles", () => {
        // A checked out bundle with two parts
        function createBundle() {
            return createCheckout().then(objects => {
                const host = objects.items[0];
                return cy
                    .task("insertSampleBiblio", { item_count: 2 })
                    .then(parts => {
                        cleanupLater(parts);
                        cleanupQueryLater(
                            "DELETE FROM item_bundles WHERE host=?",
                            [host.item_id]
                        );
                        const queries = parts.items.map(part =>
                            dbQuery(
                                "INSERT INTO item_bundles (item, host) VALUES (?, ?)",
                                [part.item_id, host.item_id]
                            )
                        );
                        return cy
                            .wrap(queries)
                            .then(() => ({ host, parts: parts.items }));
                    });
            });
        }

        const bundleModal = () => cy.get("#checkin-app .modal.show");

        it("is confirmed in a single modal that asks for the contents", () => {
            createBundle().then(({ host, parts }) => {
                visitCheckin();
                checkin(host.external_id);

                // No confirmation before the contents are asked for
                bundleModal()
                    .should("be.visible")
                    .and("contain", "Please confirm bundle contents")
                    .and("not.contain", "Please confirm check in");
                bundleModal()
                    .find("p.bundle-host")
                    .should("contain", host.external_id);

                // The explanation is above the table of the expected items
                bundleModal()
                    .contains(".alert", "Missing items will be marked as lost")
                    .should("be.visible");
                bundleModal()
                    .find("table tbody tr")
                    .should("have.length", parts.length);
                cy.focused().should("have.id", "bundle-barcodes");

                // The table can be exported, without its status column
                bundleModal().contains("button", "Export").click();
                bundleModal()
                    .find(
                        ".bundle-export-copy, .bundle-export-csv, .bundle-export-print"
                    )
                    .should("have.length", 3)
                    .and("be.visible");

                // The actions are named for what they do, with shortcuts
                bundleModal()
                    .contains("button", "Check in, mark missing lost (Y)")
                    .should("have.attr", "accesskey", "y");
                bundleModal()
                    .contains("button", "Check in, verify later (L)")
                    .should("have.attr", "accesskey", "l");
                bundleModal()
                    .contains("button", "Cancel (X)")
                    .should("have.attr", "accesskey", "x");
            });
        });

        it("is not checked in when cancelled", () => {
            createBundle().then(({ host }) => {
                visitCheckin();
                checkin(host.external_id);
                bundleModal().contains("button", "Cancel (X)").click();
                bundleModal().should("not.exist");
                checkoutCount(host).should("eq", 1);
            });
        });

        it("marks the missing parts as lost and offers to print their list", () => {
            createBundle().then(({ host, parts }) => {
                visitCheckin();
                checkin(host.external_id);

                bundleModal()
                    .find("#bundle-barcodes")
                    .type(parts[0].external_id);
                bundleModal()
                    .find("#verify-progress")
                    .should("contain", "1 of 2 verified");
                bundleModal()
                    .contains("button", "Check in, mark missing lost (Y)")
                    .click();
                cy.wait("@checkin")
                    .its("response.statusCode")
                    .should("eq", 200);

                // The part that was not scanned is lost, the other one is not
                dbQuery(
                    "SELECT itemnumber, itemlost FROM items WHERE itemnumber IN (?, ?)",
                    [parts[0].item_id, parts[1].item_id]
                ).then(rows => {
                    const lost = Object.fromEntries(
                        rows.map(r => [r.itemnumber, r.itemlost])
                    );
                    expect(lost[parts[0].item_id]).to.eq(0);
                    expect(lost[parts[1].item_id]).to.not.eq(0);
                });

                // The alert lists the missing part, and its list can be printed
                cy.get("#checkin-app .alert-warning")
                    .contains("Bundle had missing items")
                    .parents(".alert")
                    .within(() => {
                        cy.contains(parts[1].external_id);
                        cy.contains("button", "Print list").should(
                            "be.visible"
                        );
                    });
            });
        });
    });

    describe("Return claims", () => {
        it("marks the row of the resolved claim as resolved", () => {
            cy.set_syspref("ClaimReturnedLostValue", "1");
            cy.intercept("PUT", "/api/v1/return_claims/*/resolve").as(
                "resolveClaim"
            );

            // An item claimed returned by the patron it is checked out to
            const createClaimedCheckout = () =>
                createCheckout().then(objects => {
                    const item = objects.items[0];
                    return dbQuery(
                        "INSERT INTO return_claims (itemnumber, borrowernumber, created_on) VALUES (?, ?, NOW())",
                        [item.item_id, objects.patron.patron_id]
                    ).then(result => ({ item, claim_id: result.insertId }));
                });

            const row = barcode =>
                cy
                    .get("#checkins-table tbody tr")
                    .filter(`:contains("${barcode}")`);

            createClaimedCheckout().then(first => {
                createClaimedCheckout().then(second => {
                    visitCheckin();
                    checkin(first.item.external_id);
                    checkin(second.item.external_id);

                    row(first.item.external_id)
                        .contains("button", "Resolve claim")
                        .should("be.visible");
                    row(second.item.external_id)
                        .contains("button", "Resolve claim")
                        .should("be.visible");

                    // Resolve the claim of the first item, which is not the
                    // first row of the table
                    checkinModal().should(
                        "contain",
                        "Item was claimed returned"
                    );
                    row(first.item.external_id)
                        .contains("button", "Resolve claim")
                        .click();
                    // The claim is resolved in this same modal: the
                    // resolution is chosen in it, and is required
                    checkinModal()
                        .should("contain", "Item was claimed returned")
                        .and("contain", first.item.external_id);
                    checkinModal()
                        .contains("button", "Resolve claim (Y)")
                        .should("be.disabled");
                    cy.get("#claim-resolution").select("FOUND_IN_LIB");
                    checkinModal()
                        .contains("button", "Resolve claim (Y)")
                        .should("be.enabled")
                        .click();
                    cy.wait("@resolveClaim")
                        .its("response.statusCode")
                        .should("eq", 200);

                    row(first.item.external_id)
                        .contains("button", "Resolve claim")
                        .should("not.exist");
                    row(second.item.external_id)
                        .contains("button", "Resolve claim")
                        .should("be.visible");
                    // and comes back for the claim still pending
                    checkinModal()
                        .should("contain", "Item was claimed returned")
                        .and("contain", second.item.external_id);

                    dbQuery(
                        "SELECT id, resolution FROM return_claims WHERE id IN (?, ?) ORDER BY id",
                        [first.claim_id, second.claim_id]
                    ).then(rows => {
                        expect(rows[0].resolution).to.eq("FOUND_IN_LIB");
                        expect(rows[1].resolution).to.eq(null);
                    });
                });
            });
        });
    });
    describe("Declined actions", () => {
        // The row of the item says what was declined, and the action can be
        // reopened to decide again
        const firstRow = () => cy.get("#checkins-table tbody tr").first();
        const transfers = item =>
            dbQuery(
                "SELECT datesent, datecancelled FROM branchtransfers WHERE itemnumber=? ORDER BY branchtransfer_id",
                [item.item_id]
            );

        it("lets a declined transfer be requested after all", () => {
            cy.set_syspref("AutomaticItemReturn", "0");
            createCheckout({ stay_home: true }).then(objects => {
                const item = objects.items[0];
                visitCheckin();
                checkin(item.external_id);

                checkinModal()
                    .contains("button", "No, don't transfer (N)")
                    .click();
                checkinModal().should("not.exist");
                firstRow()
                    .should("contain", "Transfer declined")
                    .find("button.reopen-action")
                    .click();
                transfers(item).should("have.length", 0);

                // The question is asked again
                checkinModal()
                    .should("contain", "Transfer now?")
                    .contains("button", "Yes, transfer (Y)")
                    .click();
                checkinModal().should("not.exist");
                firstRow().should("not.contain", "Transfer declined");
                transfers(item).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].datesent).to.not.eq(null);
                });
            });
        });

        it("lets a cancelled transfer be requested again", () => {
            createCheckout({ stay_home: true }).then(objects => {
                const item = objects.items[0];
                visitCheckin();
                checkin(item.external_id);

                checkinModal()
                    .contains("button", "Cancel transfer (X)")
                    .click();
                checkinModal().should("not.exist");
                firstRow()
                    .should("contain", "Transfer cancelled")
                    .find("button.reopen-action")
                    .click();
                transfers(item).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].datecancelled).to.not.eq(null);
                });

                checkinModal()
                    .should("contain", "Transfer now?")
                    .contains("button", "Yes, transfer (Y)")
                    .click();
                checkinModal().should("not.exist");
                // The cancelled transfer is kept, and a new one was sent
                transfers(item).then(rows => {
                    expect(rows).to.have.length(2);
                    expect(rows[1].datesent).to.not.eq(null);
                    expect(rows[1].datecancelled).to.eq(null);
                });
            });
        });

        it("lets an ignored hold be confirmed after all", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];
                createHold(item, LOGGED_IN_LIBRARY).then(({ hold }) => {
                    visitCheckin();
                    checkin(item.external_id);

                    checkinModal().contains("button", "Ignore (I)").click();
                    checkinModal().should("not.exist");
                    firstRow()
                        .should("contain", "Hold ignored")
                        .find("button.reopen-action")
                        .click();

                    checkinModal()
                        .should("contain", "Hold found")
                        .contains("button", "Confirm hold (Y)")
                        .click();
                    checkinModal().should("not.exist");
                    dbQuery("SELECT found FROM reserves WHERE reserve_id=?", [
                        hold.hold_id,
                    ]).then(rows => expect(rows[0].found).to.eq("W"));
                });
            });
        });

        it("lets an ignored recall be confirmed after all", () => {
            cy.set_syspref("UseRecalls", "staff");
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery(
                    "INSERT INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value) VALUES (NULL, NULL, ?, 'recalls_allowed', '1')",
                    [objects.item_type.item_type_id]
                );
                cleanupQueryLater(
                    "DELETE FROM circulation_rules WHERE itemtype=?",
                    [objects.item_type.item_type_id]
                );
                cy.task("insertSamplePatron", {
                    library: { library_id: LOGGED_IN_LIBRARY },
                }).then(({ patron, patron_category }) => {
                    cleanupLater({ patron, category: patron_category });
                    dbQuery(
                        "INSERT INTO recalls (patron_id, created_date, biblio_id, pickup_library_id, priority, status, item_id, item_level) VALUES (?, NOW(), ?, ?, 1, 'requested', ?, 1)",
                        [
                            patron.patron_id,
                            objects.biblio.biblio_id,
                            LOGGED_IN_LIBRARY,
                            item.item_id,
                        ]
                    ).then(result => {
                        const recall_id = result.insertId;
                        cleanupQueryLater(
                            "DELETE FROM recalls WHERE recall_id=?",
                            [recall_id]
                        );
                        visitCheckin();
                        checkin(item.external_id);

                        checkinModal().contains("button", "Ignore (I)").click();
                        checkinModal().should("not.exist");
                        firstRow()
                            .should("contain", "Recall ignored")
                            .find("button.reopen-action")
                            .click();

                        checkinModal()
                            .should("contain", "Recall found")
                            .contains("button", "Confirm recall (Y)")
                            .click();
                        checkinModal().should("not.exist");
                        dbQuery(
                            "SELECT status FROM recalls WHERE recall_id=?",
                            [recall_id]
                        ).then(rows => expect(rows[0].status).to.eq("waiting"));
                    });
                });
            });
        });

        it("leaves a return claim open when it is resolved later, and can be reopened", () => {
            cy.set_syspref("ClaimReturnedLostValue", "1");
            createCheckout().then(objects => {
                const item = objects.items[0];
                dbQuery(
                    "INSERT INTO return_claims (itemnumber, borrowernumber, created_on) VALUES (?, ?, NOW())",
                    [item.item_id, objects.patron.patron_id]
                ).then(result => {
                    visitCheckin();
                    checkin(item.external_id);

                    checkinModal()
                        .contains("button", "Resolve later (L)")
                        .should("have.attr", "accesskey", "l")
                        .click();
                    checkinModal().should("not.exist");
                    dbQuery("SELECT resolution FROM return_claims WHERE id=?", [
                        result.insertId,
                    ]).then(rows => expect(rows[0].resolution).to.eq(null));

                    firstRow()
                        .should("contain", "Claim not resolved")
                        .find("button.reopen-action")
                        .click();
                    checkinModal().should(
                        "contain",
                        "Item was claimed returned"
                    );
                });
            });
        });
    });

    describe("Return date", () => {
        it("can be cleared with the clear control of the date field", () => {
            createCheckout().then(() => {
                visitCheckin();
                cy.get("#show-circ-settings a").click();

                const twoDaysAgo = new Date();
                twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
                setReturnDate(twoDaysAgo);
                cy.get("#return_date_override_fields input[type='text']")
                    .invoke("val")
                    .should("not.be.empty");

                cy.get(
                    "#return_date_override_fields button.koha-datepicker-clear"
                )
                    .should("have.attr", "aria-label", "Clear date")
                    .click();
                cy.get("#return_date_override_fields input[type='text']")
                    .invoke("val")
                    .should("be.empty");

                // No return date is active any more
                cy.get("#show-circ-settings a").click();
                cy.get("#checkin-app").should("not.contain", "Return date:");
            });
        });

        it("takes a time and does not allow a future date", () => {
            createCheckout().then(objects => {
                const item = objects.items[0];

                visitCheckin();
                cy.get("#show-circ-settings a").click();
                cy.get("#return_date_override_fields").should("be.visible");

                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                cy.get("#return-date-override")
                    .getFlatpickrDate(tomorrow)
                    .should("have.class", "flatpickr-disabled");
                cy.get(".flatpickr-calendar.open .flatpickr-time").should(
                    "be.visible"
                );
                cy.get("#return-date-override").then($el =>
                    $el[0]._flatpickr.close()
                );

                const yesterday = new Date();
                yesterday.setDate(yesterday.getDate() - 1);
                yesterday.setHours(10, 30, 0, 0);
                const pad = n => String(n).padStart(2, "0");
                const ymd = `${yesterday.getFullYear()}-${pad(yesterday.getMonth() + 1)}-${pad(yesterday.getDate())}`;
                setReturnDate(yesterday);

                checkin(item.external_id).then(({ request, response }) => {
                    expect(request.body.return_date).to.eq(`${ymd}T10:30:00`);
                    expect(response.statusCode).to.eq(200);
                });

                dbQuery(
                    "SELECT DATE_FORMAT(returndate, '%Y-%m-%d %H:%i:%s') AS returndate FROM old_issues WHERE itemnumber=?",
                    [item.item_id]
                ).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].returndate).to.eq(`${ymd} 10:30:00`);
                });
            });
        });
    });
});
