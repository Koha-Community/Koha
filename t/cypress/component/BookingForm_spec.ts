import { createPinia, setActivePinia } from "pinia";
import BookingForm from "@koha-vue/components/Bookings/BookingForm.vue";
import { useBookingStore } from "@koha-vue/stores/bookings";

const componentStubs = {
    Alert: true,
    BookingDetailsStep: true,
    BookingPatronStep: true,
    BookingPeriodStep: true,
};

function makeStore() {
    const pinia = createPinia();
    setActivePinia(pinia);
    return { pinia, store: useBookingStore() };
}

function mountForm(pinia, store, props = {}) {
    return cy.mount(BookingForm, {
        props: {
            biblionumber: 1,
            ...props,
        },
        global: {
            plugins: [pinia],
            provide: { bookingStore: store },
            stubs: componentStubs,
        },
    });
}

function prepareSubmission(store) {
    store.$patch({
        bookingPatron: { patron_id: 42 },
        pickupLibraryId: "CPL",
        selectedDateRange: ["2026-03-10", "2026-03-12"],
    });
    cy.stub(store, "resolveItemForPeriod").returns({
        ok: true,
        item_id: 101,
    });
}

describe("BookingForm", () => {
    it("initializes one create session with normalized initial dates", () => {
        const { pinia, store } = makeStore();
        const openForCreate = cy.stub(store, "openForCreate").resolves();

        mountForm(pinia, store, {
            active: true,
            startDate: "2026-03-10T15:00:00Z",
            endDate: "2026-03-12T15:00:00Z",
        });

        cy.wrap(openForCreate).should("have.been.calledOnce");
        cy.wrap(openForCreate).should(
            "have.been.calledWithMatch",
            Cypress.sinon.match({
                biblionumber: 1,
                selectedDateRange: [
                    "2026-03-10T00:00:00.000Z",
                    "2026-03-12T00:00:00.000Z",
                ],
            })
        );
    });

    it("initializes an edit session through the explicit edit workflow", () => {
        const { pinia, store } = makeStore();
        const openForEdit = cy.stub(store, "openForEdit").resolves();

        mountForm(pinia, store, { active: true, bookingId: 12 });

        cy.wrap(openForEdit).should("have.been.calledOnce");
        cy.wrap(openForEdit).should(
            "have.been.calledWithMatch",
            Cypress.sinon.match({ booking: { bookingId: 12 } })
        );
    });

    it("publishes initialization errors in the form store", () => {
        const { pinia, store } = makeStore();
        cy.stub(console, "error");
        cy.stub(store, "openForCreate").rejects(new Error("Request failed"));

        mountForm(pinia, store, { active: true });

        cy.wrap(null).should(() => {
            expect(store.error.message).to.equal(
                "An error occurred: Request failed"
            );
            expect(store.error.code).to.equal("api");
        });
    });

    it("submits an API payload and emits the saved booking", () => {
        const { pinia, store } = makeStore();
        prepareSubmission(store);
        const result = { booking_id: 22 };
        const save = cy.stub(store, "saveOrUpdateBooking").resolves(result);
        let wrapper;

        mountForm(pinia, store).then(mounted => {
            wrapper = mounted.wrapper;
        });
        cy.get("#form-booking").trigger("submit", { force: true });

        cy.wrap(save).should(stub => {
            expect(stub.calledOnce).to.equal(true);
            expect(stub.firstCall.args[0]).to.include({
                biblio_id: 1,
                patron_id: 42,
                pickup_library_id: "CPL",
                item_id: 101,
                start_date: "2026-03-10T00:00:00.000Z",
                end_date: "2026-03-12T23:59:59.999Z",
            });
        });
        cy.wrap(null).should(() => {
            const submitted = wrapper.emitted("submitted");
            expect(submitted).to.have.length(1);
            expect(submitted[0][0]).to.deep.equal({
                booking: result,
                bookingPatron: { patron_id: 42 },
                isUpdate: false,
            });
        });
    });

    it("keeps API submission errors in the form", () => {
        const { pinia, store } = makeStore();
        prepareSubmission(store);
        cy.stub(store, "saveOrUpdateBooking").rejects(
            new Error("Write failed")
        );

        mountForm(pinia, store);
        cy.get("#form-booking").trigger("submit", { force: true });

        cy.wrap(null).should(() => {
            expect(store.error.message).to.equal(
                "An error occurred: Write failed"
            );
        });
    });

    it("shows a specific message for a booking conflict error_code", () => {
        const { pinia, store } = makeStore();
        prepareSubmission(store);
        const error = new Error("Booking would conflict");
        error.code = "booking_would_conflict";
        cy.stub(store, "saveOrUpdateBooking").rejects(error);

        mountForm(pinia, store);
        cy.get("#form-booking").trigger("submit", { force: true });

        cy.wrap(null).should(() => {
            expect(store.error.message).to.equal(
                "This booking would conflict with an existing booking or checkout."
            );
        });
    });

    it("shows a specific message for a duplicate booking error_code", () => {
        const { pinia, store } = makeStore();
        prepareSubmission(store);
        const error = new Error("Duplicate booking_id");
        error.code = "duplicate_booking_id";
        cy.stub(store, "saveOrUpdateBooking").rejects(error);

        mountForm(pinia, store);
        cy.get("#form-booking").trigger("submit", { force: true });

        cy.wrap(null).should(() => {
            expect(store.error.message).to.equal(
                "This booking has already been saved. Refresh and try again."
            );
        });
    });

    it("retains CSRF-protected legacy form submission", () => {
        const { pinia, store } = makeStore();
        prepareSubmission(store);
        const existingMeta = document.querySelector('meta[name="csrf-token"]');
        const originalToken = existingMeta?.getAttribute("content") ?? null;
        const csrfMeta = existingMeta ?? document.createElement("meta");
        csrfMeta.name = "csrf-token";
        csrfMeta.content = "token-value";
        if (!existingMeta) document.head.appendChild(csrfMeta);
        const nativeSubmit = cy.stub(HTMLFormElement.prototype, "submit");

        mountForm(pinia, store, {
            submitType: "form-submission",
            submitUrl: "/bookings/place",
        });
        cy.get("#form-booking").trigger("submit", { force: true });

        cy.wrap(nativeSubmit).should("have.been.calledOnce");
        cy.get('#form-booking input[name="csrf_token"]')
            .should("have.value", "token-value")
            .and("have.attr", "type", "hidden");
        cy.get('#form-booking input[name="op"]').should(
            "have.value",
            "cud-add"
        );
        cy.get('#form-booking input[name="item_id"]').should(
            "have.value",
            "101"
        );
        cy.then(() => {
            if (!existingMeta) {
                csrfMeta.remove();
            } else if (originalToken === null) {
                existingMeta.removeAttribute("content");
            } else {
                existingMeta.content = originalToken;
            }
        });
    });

    it("does not submit a legacy form without a CSRF token", () => {
        const { pinia, store } = makeStore();
        prepareSubmission(store);
        const csrfMeta = document.querySelector('meta[name="csrf-token"]');
        csrfMeta?.remove();
        document.querySelector('input[name="csrf_token"]')?.remove();
        const nativeSubmit = cy.stub(HTMLFormElement.prototype, "submit");

        mountForm(pinia, store, {
            submitType: "form-submission",
            submitUrl: "/bookings/place",
        });
        cy.get("#form-booking").trigger("submit", { force: true });

        cy.wrap(nativeSubmit).should("not.have.been.called");
        cy.wrap(null).should(() => {
            expect(store.error.code).to.equal("csrf");
        });
        cy.then(() => {
            if (csrfMeta) document.head.appendChild(csrfMeta);
        });
    });

    it("closes an active session exactly once when deactivated and unmounted", () => {
        const { pinia, store } = makeStore();
        cy.stub(store, "openForCreate").resolves();
        const closeSession = cy.stub(store, "closeSession");

        mountForm(pinia, store, { active: true }).then(({ wrapper }) => {
            return wrapper
                .setProps({ active: false })
                .then(() => {
                    expect(closeSession.calledOnce).to.equal(true);
                })
                .then(() => wrapper.unmount())
                .then(() => {
                    expect(closeSession.calledOnce).to.equal(true);
                });
        });
    });
});
