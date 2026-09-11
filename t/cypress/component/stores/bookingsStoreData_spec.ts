import { createPinia, setActivePinia } from "pinia";
import { useBookingStore } from "@koha-vue/stores/bookings";

function makeStore() {
    setActivePinia(createPinia());
    return useBookingStore();
}

describe("bookings store patron search formatting", () => {
    beforeEach(() => {
        cy.window().then(win => {
            win.buildPatronSearchQuery = term => [{ me: { like: term } }];
        });
    });

    it("formats a searched patron's label using the shared patron formatter", () => {
        cy.intercept("GET", "**/api/v1/patrons*", {
            body: {
                results: [
                    {
                        patron_id: 1,
                        surname: "Doe",
                        preferred_name: "Jane",
                        cardnumber: "12345",
                    },
                ],
            },
        }).as("patronSearch");

        const store = makeStore();
        cy.wrap(null)
            .then(() => store.fetchPatrons("doe"))
            .then(patrons => {
                expect(patrons[0].label).to.equal("Doe, Jane (12345)");
            });
    });
});
