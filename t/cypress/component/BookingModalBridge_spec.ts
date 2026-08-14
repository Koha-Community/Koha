// modals/booking.js bridges the legacy page (DataTables, trigger buttons
// carrying data-* prefill values) to the <booking-modal> Vue island. It has
// no exports - openBookingModal is only reachable once the module's IIFE has
// run against a real <booking-modal> element in the document, so this spec
// sets that element up first and imports the module for its side effects.
describe("modals/booking.js bridge", () => {
    it("normalizes trigger data onto the island, preserving biblionumber when a later call omits it", () => {
        if (!customElements.get("booking-modal")) {
            customElements.define(
                "booking-modal",
                class extends HTMLElement {}
            );
        }
        const island = document.createElement("booking-modal");
        document.body.appendChild(island);

        const resultContainer = document.createElement("div");
        resultContainer.id = "transient_result";
        document.body.appendChild(resultContainer);

        // The page-level translation global the module expects (see its
        // `/* global __ */` pragma); real Koha pages provide this via
        // i18n.inc, the component-testing harness does not.
        window["__"] = s => s;

        return cy
            .wrap(
                import("../../../koha-tmpl/intranet-tmpl/prog/js/modals/booking.js")
            )
            .then(() =>
                cy.wrap(
                    window.openBookingModal({
                        booking: 5,
                        itemnumber: 10,
                        patron: 3,
                        pickup_library: "CPL",
                        start_date: "2026-03-10T00:00:00.000Z",
                        end_date: "2026-03-12T23:59:59.999Z",
                        item_type_id: "BK",
                        biblionumber: 7,
                    })
                )
            )
            .then(() => {
                expect(island).to.include({
                    bookingId: 5,
                    itemId: 10,
                    patronId: 3,
                    pickupLibraryId: "CPL",
                    startDate: "2026-03-10T00:00:00.000Z",
                    endDate: "2026-03-12T23:59:59.999Z",
                    itemtypeId: "BK",
                    biblionumber: 7,
                    open: true,
                });

                island.open = false;
                // A later trigger without biblionumber (e.g. the timeline's
                // onMove handler always supplies one, but callers outside
                // the page's own bookings list may not) must not clear the
                // island's existing biblionumber - see normalizeProps.
                return window.openBookingModal({
                    bookingId: 9,
                    itemId: 11,
                    patronId: 4,
                    pickupLibraryId: "CPL2",
                });
            })
            .then(() => {
                expect(island).to.include({
                    bookingId: 9,
                    itemId: 11,
                    patronId: 4,
                    pickupLibraryId: "CPL2",
                    biblionumber: 7,
                    open: true,
                });

                island.dispatchEvent(
                    new CustomEvent("booking-saved", {
                        detail: [
                            {
                                booking: { booking_id: 9 },
                                bookingPatron: null,
                                isUpdate: true,
                            },
                        ],
                    })
                );
            })
            .then(() => {
                cy.get("#transient_result .alert-success").should(
                    "contain.text",
                    "Booking successfully updated"
                );
            });
    });
});
