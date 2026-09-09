// extend_booking_modal.js is a legacy (non-Vue) bridge with no exports: it
// wires itself up against real DOM ids the first time it's imported, driven
// by Bootstrap's show.bs.modal event and a plain <form> submit. Dynamic
// import() is cached per URL, so re-importing it in a second test would be a
// no-op against stale elements - this spec exercises both the success and
// the conflict-error path in a single test against one persistent DOM/module
// instance, mirroring what circulation.tt's Extend button drives.
import dayjs from "dayjs";

const LIBRARY_TZ = "Australia/Brisbane"; // Fixed UTC+10 offset, no DST.

/** Fire show.bs.modal with a synthetic trigger button carrying the same
 * data-* attributes bookings/common.js renders on the Extend button. */
function triggerShowModal(dataset) {
    const button = document.createElement("button");
    Object.entries(dataset).forEach(([key, value]) => {
        button.dataset[key] = value;
    });
    const event = new Event("show.bs.modal");
    event.relatedTarget = button;
    document.getElementById("extendBookingModal").dispatchEvent(event);
}

function submitNewEndDate(localDate) {
    const fp = document.getElementById("extend_new_end_date")._flatpickr;
    fp.setDate(localDate, false);
    document
        .getElementById("extendBookingForm")
        .dispatchEvent(
            new Event("submit", { cancelable: true, bubbles: true })
        );
}

describe("extend_booking_modal.js bridge", () => {
    it("computes the picker's min/max/disable range, submits a chosen end date, and surfaces a conflict without closing", () => {
        // Well before every fixture date below, so the due-date-derived
        // floor is genuinely in the future relative to "today" (see the
        // module's minDate computation) - without this, "today" is the
        // real current date, which can invert against a fixture maxDate
        // derived from a March 2026 "next booking".
        cy.clock(new Date("2026-03-01T00:00:00Z").getTime(), ["Date"]);

        document.body.insertAdjacentHTML(
            "beforeend",
            `
            <div class="modal" id="extendBookingModal">
                <form id="extendBookingForm">
                    <input type="hidden" id="extend_booking_id" />
                    <input type="hidden" id="extend_checkout_id" />
                    <span id="extend_current_end_date"></span>
                    <span id="extend_current_due_date"></span>
                    <input type="text" id="extend_new_end_date" />
                    <div id="extend_booking_result"></div>
                </form>
            </div>
        `
        );

        window["__"] = s => s;
        window["$timezone"] = () => LIBRARY_TZ;
        window["$date"] = d => dayjs(d).tz(LIBRARY_TZ).format("YYYY-MM-DD");
        window["$datetime"] = d =>
            dayjs(d).tz(LIBRARY_TZ).format("YYYY-MM-DD HH:mm");
        window["$toDisplayDate"] = d => d.toDate();
        // Stub flatpickr itself: this spec verifies the bridge's own
        // date-math (minDate/maxDate/disable) and event wiring, not real
        // flatpickr rendering, so a lightweight fake instance is both
        // faster and avoids depending on flatpickr's own internal timing.
        window["flatpickr"] = cy.stub().callsFake((selector, config) => {
            const el = document.querySelector(selector);
            const instance = {
                config,
                selectedDates: [],
                setDate(date) {
                    instance.selectedDates = [date];
                },
                destroy() {},
            };
            el._flatpickr = instance;
            return instance;
        });
        // Fake only the Bootstrap `.modal()` call the source makes on the
        // dialog; delegate everything else to Cypress's own jQuery, since
        // component testing relies on window.$ internally and a blanket
        // stub silently breaks cy.get() on this page.
        const bsModal = cy.stub().as("bsModal");
        window["$"] = selector =>
            selector === "#extendBookingModal"
                ? { modal: bsModal }
                : Cypress.$(selector);
        const reload = cy.stub().as("reload");
        window["bookings_table"] = {
            api: () => ({ ajax: { reload } }),
        };
        const timelineUpdate = cy.stub().as("timelineUpdate");
        window["timeline"] = {
            itemsData: { update: timelineUpdate },
        };

        let bookingsQueryResponse = [];
        let renewalResponse = { ok: true, json: async () => ({}) };
        cy.stub(window, "fetch")
            .as("fetch")
            .callsFake(url => {
                if (url.includes("/api/v1/bookings?")) {
                    return Promise.resolve({
                        ok: true,
                        json: async () => bookingsQueryResponse,
                    });
                }
                if (url.includes("/checkouts/42/renewal")) {
                    return Promise.resolve(renewalResponse);
                }
                return Promise.reject(new Error("Unexpected fetch: " + url));
            });

        cy.wrap(
            import("../../../koha-tmpl/intranet-tmpl/prog/js/extend_booking_modal.js")
        ).then(() => {
            // --- Success path -------------------------------------------
            bookingsQueryResponse = [
                {
                    booking_id: 99,
                    start_date: "2026-03-20T00:00:00.000Z",
                    end_date: "2026-03-22T13:59:59.999Z",
                },
            ];

            triggerShowModal({
                booking: "5",
                checkout_id: "42",
                item_id: "7",
                end_date: "2026-03-12T13:59:59.999Z", // 2026-03-12 23:59:59 Brisbane
                due_date: "2026-03-10T00:00:00.000Z",
            });

            cy.get("#extend_booking_id").should("have.value", "5");
            cy.get("#extend_checkout_id").should("have.value", "42");
            // The (stubbed) async bookings-conflict query settles on the
            // microtask queue well within this; the picker only ever opens
            // once both bounds have been computed.
            cy.wait(300);

            cy.get("#extend_new_end_date").then($input => {
                const fp = $input[0]._flatpickr;
                void expect(fp, "flatpickr instance").to.exist;
                // due_date + 1 day (Brisbane) is later than "today", so
                // it - not today - is the floor.
                expect(
                    dayjs(fp.config.minDate).tz(LIBRARY_TZ).format("YYYY-MM-DD")
                ).to.eq("2026-03-11");
                // Capped the day before the next booking's start.
                expect(
                    dayjs(fp.config.maxDate).tz(LIBRARY_TZ).format("YYYY-MM-DD")
                ).to.eq("2026-03-19");
                expect(fp.config.disable).to.have.length(1);
            });
        });

        cy.then(() => {
            renewalResponse = {
                ok: true,
                json: async () => ({ due_date: "2026-03-15T13:59:59Z" }),
            };
            submitNewEndDate(new Date(2026, 2, 15)); // 2026-03-15, local
        });

        cy.get("@fetch").should(fetchStub => {
            const call = fetchStub
                .getCalls()
                .find(c => String(c.args[0]).includes("/checkouts/42/renewal"));
            void expect(call, "renewal request").to.exist;
            const body = JSON.parse(call.args[1].body);
            // The picked local calendar day, anchored to end-of-day in
            // the library's timezone (see Bug 42868) - not the browser's.
            expect(body.due_date).to.eq("2026-03-15T13:59:59.999Z");
        });
        cy.get("@reload").should("have.been.calledOnce");
        cy.get("@timelineUpdate").should("have.been.calledWithMatch", {
            id: 5,
            end: "2026-03-15T13:59:59Z",
        });
        cy.get("@bsModal").should("have.been.calledOnceWith", "hide");
        cy.get("#extend_booking_result .alert-danger").should("not.exist");

        // --- Conflict path -------------------------------------------------
        cy.then(() => {
            bookingsQueryResponse = [];
            renewalResponse = {
                ok: false,
                json: async () => ({
                    error: "Renewal not authorized (booked)",
                    error_code: "booked",
                }),
            };

            triggerShowModal({
                booking: "5",
                checkout_id: "42",
                item_id: "7",
                end_date: "2026-03-12T13:59:59.999Z",
                due_date: "2026-03-10T00:00:00.000Z",
            });
        });

        // Wait for the fresh instance from this second handleShowBsModal's
        // async bookings query to replace the earlier success path's.
        cy.wait(300);
        cy.get("#extend_new_end_date")
            .then($input => {
                const fp = $input[0]._flatpickr;
                void expect(fp, "flatpickr instance").to.exist;
                expect(fp.config.disable).to.have.length(0);
            })
            .then(() => submitNewEndDate(new Date(2026, 2, 16)));

        cy.get("#extend_booking_result .alert-danger").should(
            "contain.text",
            "conflict with another booking"
        );
        // Only ever called once, by the earlier success path.
        cy.get("@bsModal").should("have.been.calledOnce");
    });
});
