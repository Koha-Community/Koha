import { createPinia, setActivePinia } from "pinia";
import BookingPatronStep from "@koha-vue/components/Bookings/BookingPatronStep.vue";
import { useBookingStore } from "@koha-vue/stores/bookings";

function deferred() {
    let resolve;
    const promise = new Promise(resolver => {
        resolve = resolver;
    });
    return { promise, resolve };
}

describe("BookingPatronStep", () => {
    it("formats patron ages with plural-aware translations", () => {
        cy.clock();
        const pinia = createPinia();
        setActivePinia(pinia);
        const store = useBookingStore();
        cy.stub(store, "fetchPatrons").resolves([
            { patron_id: 1, label: "One year old", _age: 1 },
            { patron_id: 2, label: "Two years old", _age: 2 },
        ]);
        cy.window().then(win => {
            win.__nx = (singular, plural, count, variables) =>
                (count === 1 ? singular : plural).replace(
                    "{count}",
                    variables.count
                );
        });

        cy.mount(BookingPatronStep, {
            props: {
                stepNumber: 1,
                modelValue: null,
            },
            global: {
                plugins: [pinia],
                provide: { bookingStore: store },
            },
        });

        cy.get("#booking_patron").type("patron age");
        cy.tick(250);
        cy.contains(".vs__dropdown-option", "1 year").should("be.visible");
        cy.contains(".vs__dropdown-option", "2 years").should("be.visible");
    });

    it("cancels a scheduled search when the form becomes inactive", () => {
        cy.clock();
        const pinia = createPinia();
        setActivePinia(pinia);
        const store = useBookingStore();
        const fetchPatrons = cy.stub(store, "fetchPatrons").resolves([]);

        let wrapper;
        cy.mount(BookingPatronStep, {
            props: {
                active: true,
                stepNumber: 1,
                modelValue: null,
            },
            global: {
                plugins: [pinia],
                provide: { bookingStore: store },
            },
        }).then(mounted => {
            wrapper = mounted.wrapper;
        });
        cy.get("#booking_patron").type("first patron");
        cy.then(() => wrapper.setProps({ active: false }));
        cy.tick(250);
        cy.then(() => {
            expect(fetchPatrons.called).to.equal(false);
        });
    });

    it("does not publish stale patron search results", () => {
        cy.clock();
        const pinia = createPinia();
        setActivePinia(pinia);
        const store = useBookingStore();
        const first = deferred();
        const second = deferred();
        const fetchPatrons = cy.stub(store, "fetchPatrons");
        fetchPatrons.onFirstCall().returns(first.promise);
        fetchPatrons.onSecondCall().returns(second.promise);

        cy.mount(BookingPatronStep, {
            props: {
                stepNumber: 1,
                modelValue: null,
            },
            global: {
                plugins: [pinia],
                provide: { bookingStore: store },
            },
        });

        cy.get("#booking_patron").type("first patron");
        cy.tick(250);
        cy.get("#booking_patron").clear().type("second patron");

        cy.then(() => {
            first.resolve([{ patron_id: 1, label: "First patron" }]);
        });
        cy.contains(".vs__dropdown-option", "First patron").should("not.exist");

        cy.tick(250);
        cy.then(() => {
            second.resolve([{ patron_id: 2, label: "Second patron" }]);
        });
        cy.contains(".vs__dropdown-option", "Second patron").should(
            "be.visible"
        );
        cy.contains(".vs__dropdown-option", "First patron").should("not.exist");
    });
});
