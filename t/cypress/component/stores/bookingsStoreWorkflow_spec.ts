import { createPinia, setActivePinia } from "pinia";
import { useBookingStore } from "@koha-vue/stores/bookings";

const ITEM = {
    item_id: 101,
    external_id: "ITEM101",
    home_library_id: "CPL",
    effective_item_type_id: "BK",
};
const PATRON = {
    patron_id: 42,
    category_id: "ST",
    library_id: "CPL",
    surname: "Reader",
};
const LOCATION = {
    library_id: "CPL",
    name: "Centerville",
    pickup_items: [101],
};
const RULES = {
    bookings_lead_period: 0,
    bookings_trail_period: 0,
    issuelength: 14,
};

function makeStore() {
    setActivePinia(createPinia());
    return useBookingStore();
}

function interceptWorkflowResources() {
    cy.intercept("GET", "**/api/v1/biblios/*/items*", {
        body: [ITEM],
    }).as("bookableItems");
    cy.intercept("GET", "**/api/v1/patrons/*", { body: PATRON }).as("patron");
    cy.intercept("GET", "**/api/v1/biblios/*/pickup_locations*", {
        body: [LOCATION],
    }).as("pickupLocations");
    cy.intercept("GET", "**/api/v1/circulation_rules*", {
        body: [RULES],
    }).as("circulationRules");
    cy.intercept("GET", "**/api/v1/biblios/*/booking_availability*", {
        body: { item_ids: [101], availability: {} },
    }).as("bookingAvailability");
    cy.intercept("GET", "**/api/v1/libraries/*/closed_dates*", {
        body: [],
    }).as("holidays");
}

function expectRequestCount(alias, count) {
    cy.get(`@${alias}.all`).should("have.length", count);
}

function deferred() {
    let resolve = () => {};
    const promise = new Promise(done => {
        resolve = done;
    });
    return { promise, resolve };
}

describe("bookings store workflow", () => {
    beforeEach(() => {
        cy.intercept("GET", "**/api/v1/**", { body: [] }).as("allApi");
        interceptWorkflowResources();
    });

    it("opens create mode with one request per required resource", () => {
        const store = makeStore();
        cy.wrap(
            store.openForCreate({
                biblionumber: 1,
                patronId: 42,
                itemtypeId: "BK",
                pickupLibraryId: "CPL",
            })
        ).then(() => {
            expect(store.bookingId).to.equal(null);
            expect(store.bookingPatron.patron_id).to.equal(42);
            expect(store.readiness.dataReady).to.equal(true);
            expectRequestCount("bookableItems", 1);
            expectRequestCount("patron", 1);
            expectRequestCount("pickupLocations", 1);
            expectRequestCount("circulationRules", 1);
            expectRequestCount("bookingAvailability", 1);
            expectRequestCount("holidays", 1);
        });
    });

    it("opens edit mode with one request per required resource", () => {
        const store = makeStore();
        cy.wrap(
            store.openForEdit({
                booking: {
                    booking_id: 12,
                    biblio_id: 1,
                    item_id: 101,
                    patron_id: 42,
                    pickup_library_id: "CPL",
                    item_type_id: "BK",
                    selectedDateRange: ["2026-03-10", "2026-03-12"],
                },
            })
        ).then(() => {
            expect(store.bookingId).to.equal(12);
            expect(store.bookingItemId).to.equal(101);
            expect(store.selectedDateRange).to.deep.equal([
                "2026-03-10",
                "2026-03-12",
            ]);
            expectRequestCount("bookableItems", 1);
            expectRequestCount("patron", 1);
            expectRequestCount("pickupLocations", 1);
            expectRequestCount("circulationRules", 1);
            expectRequestCount("bookingAvailability", 1);
            expectRequestCount("holidays", 1);
        });
    });

    it("does not fetch contextual data merely because the store is mounted", () => {
        makeStore();

        cy.wait(100);
        expectRequestCount("allApi", 0);
    });

    it("owns and resets modal-session configuration", () => {
        const store = makeStore();
        cy.wrap(
            store.openForCreate({
                biblionumber: 1,
                patron: PATRON,
                itemtypeId: "BK",
                pickupLibraryId: "CPL",
                dateRangeConstraint: "issuelength_with_renewals",
                showPatronSelect: true,
                showItemDetailsSelects: true,
                showPickupLocationSelect: true,
            })
        ).then(() => {
            expect(store.dateRangeConstraint).to.equal(
                "issuelength_with_renewals"
            );
            expect(store.readiness.formPrefilterValid).to.equal(true);

            store.closeSession();

            expect(store.dateRangeConstraint).to.equal(null);
            expect(store.readiness.formPrefilterValid).to.equal(true);
            expect(store.bookingPatron).to.equal(null);
        });
    });

    it("fetches an Any item context without requiring an item type", () => {
        cy.intercept("GET", "**/api/v1/biblios/*/items*", {
            body: [
                ITEM,
                {
                    ...ITEM,
                    item_id: 102,
                    external_id: "ITEM102",
                    effective_item_type_id: "DVD",
                },
            ],
        });
        cy.intercept("GET", "**/api/v1/biblios/*/pickup_locations*", {
            body: [{ ...LOCATION, pickup_items: [101, 102] }],
        });
        const store = makeStore();

        cy.then(() =>
            store.openForCreate({
                biblionumber: 1,
                patronId: 42,
                pickupLibraryId: "CPL",
            })
        ).then(() => {
            expect(store.readiness.dataReady).to.equal(true);
            expect(store.readiness.isCalendarReady).to.equal(true);
            expect(store.bookingItemtypeId).to.equal(null);
            expectRequestCount("circulationRules", 1);
            expectRequestCount("bookingAvailability", 1);
        });
    });

    it("ignores a superseded session failure", () => {
        cy.intercept("GET", "**/api/v1/biblios/*/items*", req => {
            if (req.url.includes("/biblios/1/")) {
                req.reply({
                    delay: 250,
                    statusCode: 500,
                    body: { error: "Stale failure" },
                });
                return;
            }
            req.reply({ body: [ITEM] });
        });

        cy.stub(console, "error");
        const store = makeStore();
        let firstSession;
        cy.then(() => {
            firstSession = store.openForCreate({
                biblionumber: 1,
                patron: PATRON,
                itemtypeId: "BK",
                pickupLibraryId: "CPL",
            });
        });

        cy.wait(25)
            .then(() => {
                const currentSession = store.openForCreate({
                    biblionumber: 2,
                    patron: PATRON,
                    itemtypeId: "BK",
                    pickupLibraryId: "CPL",
                });
                return Promise.all([firstSession, currentSession]);
            })
            .then(([firstResult, currentResult]) => {
                expect(firstResult).to.equal(false);
                expect(currentResult).to.equal(true);
                expect(store.bookableItems).to.deep.equal([ITEM]);
                expect(store.error.message).to.equal("");
            });
    });

    it("publishes the latest pickup locations and ignores a stale error", () => {
        const oldPickupStarted = deferred();
        cy.intercept("GET", "**/api/v1/biblios/1/pickup_locations*", req => {
            const patronId = String(req.query.patron_id);
            if (patronId === "old") {
                oldPickupStarted.resolve();
                req.reply({
                    delay: 250,
                    statusCode: 500,
                    body: { error: "Stale failure" },
                });
                return;
            }
            req.reply({
                body: [
                    {
                        library_id: patronId,
                        name: patronId,
                        pickup_items: [101],
                    },
                ],
            });
        });

        cy.stub(console, "error");
        const store = makeStore();
        let oldRequest;
        cy.then(() => {
            oldRequest = store.openForCreate({
                biblionumber: 1,
                patron: { ...PATRON, patron_id: "old", library_id: "old" },
                itemtypeId: "BK",
            });
            return oldPickupStarted.promise;
        })
            .then(() =>
                Promise.all([
                    oldRequest,
                    store.changePatron({
                        ...PATRON,
                        patron_id: "current",
                        library_id: "current",
                    }),
                ])
            )
            .then(() => {
                expect(store.pickupLocations[0].library_id).to.equal("current");
                expect(store.loading.pickupLocations).to.equal(false);
                expect(store.error.message).to.equal("");
            });
    });

    it("publishes only the latest circulation-rules response", () => {
        const oldRulesStarted = deferred();
        cy.intercept("GET", "**/api/v1/biblios/1/pickup_locations*", {
            body: [
                { ...LOCATION, library_id: "OLD" },
                { ...LOCATION, library_id: "CURRENT" },
            ],
        });
        cy.intercept("GET", "**/api/v1/circulation_rules*", req => {
            const libraryId = String(req.query.library_id);
            if (libraryId === "OLD") oldRulesStarted.resolve();
            req.reply({
                delay: libraryId === "OLD" ? 250 : 0,
                body: [{ library_id: libraryId, issuelength: 14 }],
            });
        });

        const store = makeStore();
        let oldRequest;
        cy.then(() => {
            oldRequest = store.openForCreate({
                biblionumber: 1,
                patron: PATRON,
                itemtypeId: "BK",
                pickupLibraryId: "OLD",
            });
            return oldRulesStarted.promise;
        })
            .then(() =>
                Promise.all([
                    oldRequest,
                    store.changeBookingContext({
                        pickupLibraryId: "CURRENT",
                    }),
                ])
            )
            .then(() => {
                expect(store.circulationRules[0].library_id).to.equal(
                    "CURRENT"
                );
            });
    });

    it("publishes only the latest booking-availability response", () => {
        const oldAvailabilityStarted = deferred();
        cy.intercept("GET", "**/api/v1/biblios/1/pickup_locations*", {
            body: [
                { ...LOCATION, library_id: "OLD" },
                { ...LOCATION, library_id: "CURRENT" },
            ],
        });
        cy.intercept(
            "GET",
            "**/api/v1/biblios/1/booking_availability*",
            req => {
                const libraryId = String(req.query.pickup_library_id);
                if (libraryId === "OLD") oldAvailabilityStarted.resolve();
                req.reply({
                    delay: libraryId === "OLD" ? 250 : 0,
                    body: {
                        item_ids: [101],
                        availability:
                            libraryId === "OLD"
                                ? {
                                      "2026-01-10": {
                                          101: {
                                              blockers: { booking: 1 },
                                              confirms: {},
                                              warnings: {},
                                          },
                                      },
                                  }
                                : {},
                    },
                });
            }
        );

        const store = makeStore();
        let oldRequest;
        cy.then(() => {
            oldRequest = store.openForCreate({
                biblionumber: 1,
                patron: PATRON,
                itemtypeId: "BK",
                pickupLibraryId: "OLD",
            });
            return oldAvailabilityStarted.promise;
        })
            .then(() =>
                Promise.all([
                    oldRequest,
                    store.changeBookingContext({
                        pickupLibraryId: "CURRENT",
                    }),
                ])
            )
            .then(() => {
                expect(store.readiness.isCalendarReady).to.equal(true);
                expect(store.unavailableByDate).to.deep.equal({});
            });
    });

    it("publishes holidays only for the latest pickup library", () => {
        const oldHolidaysStarted = deferred();
        cy.intercept("GET", "**/api/v1/biblios/1/pickup_locations*", {
            body: [
                { ...LOCATION, library_id: "OLD" },
                { ...LOCATION, library_id: "CURRENT" },
            ],
        });
        cy.intercept("GET", "**/api/v1/libraries/*/closed_dates*", req => {
            const libraryId = req.url.includes("/OLD/") ? "OLD" : "CURRENT";
            if (libraryId === "OLD") oldHolidaysStarted.resolve();
            req.reply({
                delay: libraryId === "OLD" ? 250 : 0,
                body: [libraryId === "OLD" ? "2026-01-05" : "2026-01-06"],
            });
        });

        const store = makeStore();
        let oldRequest;
        cy.then(() => {
            oldRequest = store.openForCreate({
                biblionumber: 1,
                patron: PATRON,
                itemtypeId: "BK",
                pickupLibraryId: "OLD",
            });
            return oldHolidaysStarted.promise;
        })
            .then(() =>
                Promise.all([
                    oldRequest,
                    store.changeBookingContext({
                        pickupLibraryId: "CURRENT",
                    }),
                ])
            )
            .then(() => {
                expect(store.holidays).to.deep.equal(["2026-01-06"]);
            });
    });

    it("uses the selected item's home library as the pickup default", () => {
        const selectedItem = {
            ...ITEM,
            item_id: 102,
            external_id: "ITEM102",
            home_library_id: "BR2",
        };
        cy.intercept("GET", "**/api/v1/biblios/1/items*", {
            body: [ITEM, selectedItem],
        });
        cy.intercept("GET", "**/api/v1/biblios/1/pickup_locations*", {
            body: [
                LOCATION,
                {
                    library_id: "BR2",
                    name: "Branch 2",
                    pickup_items: [102],
                },
            ],
        });

        const store = makeStore();
        cy.then(() =>
            store.openForCreate({
                biblionumber: 1,
                itemId: "102",
                patron: { ...PATRON, library_id: "UNKNOWN" },
                itemtypeId: "BK",
            })
        ).then(() => {
            expect(store.bookingItemId).to.equal(102);
            expect(store.pickupLibraryId).to.equal("BR2");
        });
    });

    it("retains an edited booking's assigned item when it is no longer bookable", () => {
        cy.intercept("GET", "**/api/v1/biblios/1/items*", req => {
            if (req.query.bookable === "1") {
                req.reply({ body: [] });
                return;
            }
            req.reply({
                body: [
                    {
                        ...ITEM,
                        item_id: 99,
                        external_id: "NONBOOKABLE",
                    },
                ],
            });
        });

        const store = makeStore();
        cy.then(() =>
            store.openForEdit({
                booking: {
                    booking_id: 12,
                    biblio_id: 1,
                    item_id: 99,
                    patron_id: 42,
                    pickup_library_id: "CPL",
                    item_type_id: "BK",
                },
            })
        ).then(() => {
            expect(store.bookableItems.map(item => item.item_id)).to.deep.equal(
                [99]
            );
            expect(store.readiness.dataReady).to.equal(true);
            expect(store.readiness.hasAvailableItems).to.equal(true);
        });
    });

    it("resets session state and reopens for the same or another biblio", () => {
        const store = makeStore();
        const open = biblionumber =>
            store.openForCreate({
                biblionumber,
                patronId: 42,
                itemtypeId: "BK",
                pickupLibraryId: "CPL",
            });

        cy.wrap(open(1))
            .then(() => {
                store.closeSession();
                expect(store.bookableItems).to.deep.equal([]);
                expect(store.bookingPatron).to.equal(null);
                return open(1);
            })
            .then(() => {
                expect(store.bookableItems).to.deep.equal([ITEM]);
                store.closeSession();
                return open(2);
            })
            .then(() => {
                expect(store.bookableItems).to.deep.equal([ITEM]);
                expectRequestCount("bookableItems", 3);
                expectRequestCount("pickupLocations", 3);
            });
    });

    it("does not restore stale availability after a write", () => {
        const staleAvailabilityStarted = deferred();
        let availabilityRequests = 0;
        cy.intercept(
            "GET",
            "**/api/v1/biblios/1/booking_availability*",
            req => {
                availabilityRequests++;
                if (availabilityRequests === 1) {
                    staleAvailabilityStarted.resolve();
                }
                req.reply({
                    delay: availabilityRequests === 1 ? 250 : 0,
                    body: {
                        item_ids: [101],
                        availability:
                            availabilityRequests === 1
                                ? {
                                      "2026-01-10": {
                                          101: {
                                              blockers: { booking: 1 },
                                              confirms: {},
                                              warnings: {},
                                          },
                                      },
                                  }
                                : {},
                    },
                });
            }
        );
        cy.intercept("POST", "/api/v1/bookings", {
            statusCode: 201,
            body: { booking_id: 55 },
        });

        const store = makeStore();
        let staleSession;
        cy.then(() => {
            staleSession = store.openForCreate({
                biblionumber: 1,
                patron: PATRON,
                itemtypeId: "BK",
                pickupLibraryId: "CPL",
            });
            return staleAvailabilityStarted.promise;
        })
            .then(() =>
                store.saveOrUpdateBooking({
                    start_date: "2026-01-05T00:00:00Z",
                    end_date: "2026-01-06T23:59:59Z",
                    biblio_id: 1,
                    item_id: 101,
                    patron_id: 42,
                    pickup_library_id: "CPL",
                })
            )
            .then(() => store.refreshContext())
            .then(current => {
                expect(current).to.equal(true);
                expect(store.readiness.isCalendarReady).to.equal(true);
                expect(store.unavailableByDate).to.deep.equal({});
                return Promise.all([staleSession, store.refreshContext()]);
            })
            .then(() => {
                expect(store.readiness.isCalendarReady).to.equal(true);
                expect(store.unavailableByDate).to.deep.equal({});
                expect(availabilityRequests).to.equal(2);
            });
    });

    it("retries a failed request for the same context", () => {
        let rulesRequests = 0;
        cy.intercept("GET", "**/api/v1/circulation_rules*", req => {
            rulesRequests++;
            if (rulesRequests === 1) {
                req.reply({ statusCode: 500, body: { error: "Try again" } });
                return;
            }
            req.reply({ body: [RULES] });
        });
        cy.stub(console, "error");

        const store = makeStore();
        cy.wrap(
            store
                .openForCreate({
                    biblionumber: 1,
                    patronId: 42,
                    itemtypeId: "BK",
                    pickupLibraryId: "CPL",
                })
                .catch(() => false)
        )
            .then(result => {
                expect(result).to.equal(false);
                return store.refreshContext();
            })
            .then(result => {
                expect(result).to.equal(true);
                expect(rulesRequests).to.equal(2);
                expect(store.circulationRules[0].issuelength).to.equal(14);
            });
    });
});
