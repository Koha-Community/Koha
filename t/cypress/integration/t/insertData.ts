const { query } = require("./../../plugins/db.js");
const { getBasicAuthHeader } = require("./../../plugins/auth.js");

describe("insertData", () => {
    let tablesToCheck = [
        "borrowers",
        "branches",
        "items",
        "biblio",
        "reserves",
        "issues",
    ];
    beforeEach(() => {
        const counts = {};

        const queries = tablesToCheck.map(table => {
            return cy
                .task("query", {
                    sql: `SELECT COUNT(*) as count FROM ${table}`,
                })
                .then(result => {
                    counts[table] = result[0].count;
                });
        });

        cy.wrap(Promise.all(queries)).then(() => {
            cy.wrap(counts).as("initialCounts");
        });
    });

    describe("deleteSampleObjects", () => {
        it("should delete everything from Object", () => {
            cy.task("insertSampleBiblio", { item_count: 2 }).then(objects => {
                cy.task("deleteSampleObjects", objects);
            });
        });
        it("should delete everything from Array", () => {
            cy.task("insertSampleBiblio", { item_count: 2 }).then(objects => {
                cy.task("deleteSampleObjects", [
                    { biblio: objects.biblio },
                    { item_type: objects.item_type },
                    { item: objects.items[0] },
                    { item: objects.items[1] },
                    { library: objects.libraries[0] },
                ]);
            });
        });
    });

    describe("insertSampleBiblio", () => {
        it("should generate library and item type", () => {
            cy.task("insertSampleBiblio", { item_count: 3 }).then(objects => {
                expect(typeof objects.biblio.biblio_id).to.be.equal("number");
                expect(typeof objects.biblio.title).to.be.equal("string");
                expect(typeof objects.biblio.author).to.be.equal("string");

                const biblio_id = objects.biblio.biblio_id;

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM biblio WHERE biblionumber=?",
                    values: [biblio_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(1);
                });

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM items WHERE biblionumber=?",
                    values: [biblio_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(3);
                });

                cy.task("query", {
                    sql: "SELECT DISTINCT(itype) as count FROM items WHERE biblionumber=?",
                    values: [biblio_id],
                }).then(result => {
                    expect(result.length).to.be.equal(1);
                });

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
                    values: [objects.libraries[0].library_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(1);
                });

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM itemtypes WHERE itemtype=?",
                    values: [objects.item_type.item_type_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(1);
                });

                cy.task("deleteSampleObjects", objects);

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM biblio WHERE biblionumber=?",
                    values: [biblio_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(0);
                });

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM items WHERE biblionumber=?",
                    values: [biblio_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(0);
                });

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
                    values: [objects.libraries[0].library_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(0);
                });

                cy.task("query", {
                    sql: "SELECT COUNT(*) as count FROM itemtypes WHERE itemtype=?",
                    values: [objects.item_type.item_type_id],
                }).then(result => {
                    expect(result[0].count).to.be.equal(0);
                });
            });
        });

        it("insertSampleBiblio - options.different_libraries", () => {
            cy.task("insertSampleBiblio", {
                item_count: 3,
                options: { different_libraries: true },
            }).then(objects => {
                expect(objects.libraries.length).to.be.equal(3);
                let libraries = objects.libraries
                    .map(library => library.library_id)
                    .sort();
                let itemsLibraries = objects.items
                    .map(item => item.home_library_id)
                    .sort();
                expect(libraries).deep.to.equal(itemsLibraries);

                cy.task("deleteSampleObjects", objects);
            });
        });
    });

    describe("insertSampleHold", () => {
        it("insertSampleHold - item/biblio", () => {
            cy.task("insertSampleBiblio", { item_count: 2 }).then(
                objects_biblio => {
                    cy.task("insertSampleHold", {
                        item: objects_biblio.items[0],
                    }).then(objects_hold_1 => {
                        cy.task("insertSampleHold", {
                            biblio: objects_biblio.biblio,
                            library_id: objects_biblio.items[0].home_library_id,
                        }).then(objects_hold_2 => {
                            cy.task("apiGet", {
                                // No /holds/:hold_id (yet)
                                // No q={} (yet)
                                endpoint: `/api/v1/holds?hold_id=${objects_hold_1.hold.hold_id}`,
                                headers: {
                                    "Content-Type": "application/json",
                                },
                            }).then(holds => {
                                expect(holds.length).to.be.equal(1);
                                expect(holds[0].biblio_id).to.be.equal(
                                    objects_biblio.biblio.biblio_id
                                );
                                expect(holds[0].item_id).to.be.equal(
                                    objects_biblio.items[0].item_id
                                );
                            });
                            cy.task("apiGet", {
                                // No /holds/:hold_id (yet)
                                // No q={} (yet)
                                endpoint: `/api/v1/holds?hold_id=${objects_hold_2.hold.hold_id}`,
                                headers: {
                                    "Content-Type": "application/json",
                                },
                            }).then(holds => {
                                expect(holds.length).to.be.equal(1);
                                expect(holds[0].biblio_id).to.be.equal(
                                    objects_biblio.biblio.biblio_id
                                );
                                expect(holds[0].item_id).to.be.equal(null);
                            });

                            cy.task("deleteSampleObjects", [
                                objects_biblio,
                                objects_hold_1,
                                objects_hold_2,
                            ]);
                        });
                    });
                }
            );
        });

        // How to properly test for Error?
        it.skip("insertSampleHold - missing library_id", () => {
            cy.task("insertSampleBiblio", { item_count: 2 }).then(
                objects_biblio => {
                    cy.task("insertSampleHold", {
                        biblio: objects_biblio.biblio,
                    }).then(
                        () => {
                            throw new Error("Task should have failed");
                        },
                        err => {
                            expect(err.message).to.include(
                                "Could not generate sample hold without library_id or item"
                            );
                        }
                    );
                }
            );
        });
    });

    describe("insertSampleCheckout", () => {
        it("insertSampleCheckout - without parameter", () => {
            cy.task("insertSampleCheckout").then(objects_checkout => {
                cy.task("apiGet", {
                    endpoint: `/api/v1/checkouts/${objects_checkout.checkout.checkout_id}`,
                }).then(checkout => {
                    expect(checkout.item_id).to.be.equal(
                        objects_checkout.items[0].item_id
                    );
                });

                cy.task("deleteSampleObjects", objects_checkout);
            });
        });

        it("insertSampleCheckout - pass an already generated patron", () => {
            cy.task("insertSamplePatron").then(objects_patron => {
                cy.task("insertSampleCheckout", {
                    patron: objects_patron.patron,
                }).then(objects_checkout => {
                    expect(objects_checkout.patron).to.not.exist;
                    cy.task("apiGet", {
                        endpoint: `/api/v1/checkouts/${objects_checkout.checkout.checkout_id}`,
                    }).then(checkout => {
                        expect(checkout.item_id).to.be.equal(
                            objects_checkout.items[0].item_id
                        );
                        expect(checkout.patron_id).to.be.equal(
                            objects_patron.patron.patron_id
                        );
                    });
                    cy.task("deleteSampleObjects", [
                        objects_checkout,
                        objects_patron,
                    ]);
                });
            });
        });
    });

    afterEach(function () {
        cy.get("@initialCounts").then(initialCounts => {
            const queries = tablesToCheck.map(table => {
                return cy
                    .task("query", {
                        sql: `SELECT COUNT(*) as count FROM ${table}`,
                    })
                    .then(result => {
                        const finalCount = result[0].count;
                        expect(
                            finalCount,
                            `Row count for ${table} should match`
                        ).to.eq(initialCounts[table]);
                    });
            });

            return Promise.all(queries);
        });
    });
});
