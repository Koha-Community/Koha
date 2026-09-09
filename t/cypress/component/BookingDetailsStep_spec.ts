import { createPinia, setActivePinia } from "pinia";
import BookingDetailsStep from "@koha-vue/components/Bookings/BookingDetailsStep.vue";
import { useBookingStore } from "@koha-vue/stores/bookings";

const PICKUP_LOCATIONS = [
    { library_id: "MAIN", name: "Main Library", pickup_items: ["1", "2"] },
    { library_id: "BRANCH", name: "Branch Library", pickup_items: ["1"] },
];
const BOOKABLE_ITEMS = [
    { item_id: "1", external_id: "BC001", item_type_id: "BOOK" },
    { item_id: "2", external_id: "BC002", item_type_id: "DVD" },
];
const ITEM_TYPES = [
    { item_type_id: "BOOK", description: "Book" },
    { item_type_id: "DVD", description: "DVD" },
];

function mountWithFixtures(props = {}) {
    const pinia = createPinia();
    setActivePinia(pinia);
    const store = useBookingStore();
    store.pickupLocations = PICKUP_LOCATIONS;
    store.bookableItems = BOOKABLE_ITEMS;
    store.itemTypes = ITEM_TYPES;

    let wrapper;
    cy.mount(BookingDetailsStep, {
        props: {
            stepNumber: 1,
            showItemDetailsSelects: true,
            showPickupLocationSelect: true,
            ...props,
        },
        global: {
            plugins: [pinia],
            provide: { bookingStore: store },
        },
    }).then(mounted => {
        wrapper = mounted.wrapper;
    });
    return {
        store,
        getWrapper: () => wrapper,
    };
}

describe("BookingDetailsStep", () => {
    it("renders pickup location, item type, and item selects when both flags are enabled", () => {
        mountWithFixtures();

        cy.get("#pickup_library_id").should("exist");
        cy.get("#booking_itemtype").should("exist");
        cy.get("#booking_item_id").should("exist");
    });

    it("renders only the pickup location select when item details are not shown", () => {
        mountWithFixtures({
            showItemDetailsSelects: false,
            showPickupLocationSelect: true,
        });

        cy.get("#pickup_library_id").should("exist");
        cy.get("#booking_itemtype").should("not.exist");
        cy.get("#booking_item_id").should("not.exist");
    });

    it("renders nothing when neither flag is enabled", () => {
        mountWithFixtures({
            showItemDetailsSelects: false,
            showPickupLocationSelect: false,
        });

        cy.get("#pickup_library_id").should("not.exist");
        cy.get("#booking_itemtype").should("not.exist");
        cy.get("#booking_item_id").should("not.exist");
    });

    it("disables every select when detailsEnabled is false", () => {
        mountWithFixtures({ detailsEnabled: false });

        cy.get("#pickup_library_id")
            .closest(".v-select")
            .should("have.class", "vs--disabled");
        cy.get("#booking_itemtype")
            .closest(".v-select")
            .should("have.class", "vs--disabled");
        cy.get("#booking_item_id")
            .closest(".v-select")
            .should("have.class", "vs--disabled");
    });

    it("disables selects while a required patron is unselected, enables once selected", () => {
        const { getWrapper } = mountWithFixtures({
            patronRequired: true,
            selectedPatron: null,
        });

        cy.get("#pickup_library_id")
            .closest(".v-select")
            .should("have.class", "vs--disabled");

        cy.then(() =>
            getWrapper().setProps({
                selectedPatron: { patron_id: 1, label: "Test Patron" },
            })
        );
        cy.get("#pickup_library_id")
            .closest(".v-select")
            .should("not.have.class", "vs--disabled");
    });

    it("emits update:pickup-library-id when a pickup location is selected", () => {
        const { getWrapper } = mountWithFixtures();

        cy.get("#pickup_library_id")
            .closest(".v-select")
            .find(".vs__open-indicator")
            .click();
        cy.get("#pickup_library_id")
            .closest(".v-select")
            .find(".vs__dropdown-option")
            .contains("Main Library")
            .click();
        cy.then(() => {
            const emitted = getWrapper().emitted("update:pickup-library-id");
            expect(emitted).to.have.length(1);
            expect(emitted[0]).to.deep.equal(["MAIN"]);
        });
    });

    it("emits update:itemtype-id when an item type is selected", () => {
        const { getWrapper } = mountWithFixtures();

        cy.get("#booking_itemtype")
            .closest(".v-select")
            .find(".vs__open-indicator")
            .click();
        cy.get("#booking_itemtype")
            .closest(".v-select")
            .find(".vs__dropdown-option")
            .contains("DVD")
            .click();
        cy.then(() => {
            const emitted = getWrapper().emitted("update:itemtype-id");
            expect(emitted).to.have.length(1);
            expect(emitted[0]).to.deep.equal(["DVD"]);
        });
    });

    it("emits update:item-id when an item is selected", () => {
        const { getWrapper } = mountWithFixtures();

        cy.get("#booking_item_id")
            .closest(".v-select")
            .find(".vs__open-indicator")
            .click();
        cy.get("#booking_item_id")
            .closest(".v-select")
            .find(".vs__dropdown-option")
            .contains("BC001")
            .click();
        cy.then(() => {
            const emitted = getWrapper().emitted("update:item-id");
            expect(emitted).to.have.length(1);
            expect(emitted[0]).to.deep.equal(["1"]);
        });
    });

    it("flags pickup locations as constrained once an itemtype narrows them", () => {
        // constrainedPickupLocations is derived in the store from
        // draft.bookingItemtypeId, not from this component's itemtypeId prop
        // (that prop only drives the select's own displayed value - the
        // store only sees a context change once the parent listens for
        // update:itemtype-id and writes it back). Set the store's draft
        // state directly to exercise the derived constraint.
        const { store } = mountWithFixtures();
        store.bookingItemtypeId = "DVD";

        // Only MAIN carries a DVD-typed item (item 2); BRANCH only pickup_items ["1"]
        // (a BOOK), so selecting the DVD itemtype filters BRANCH out.
        cy.contains(".badge", "Options updated").should("be.visible");
        cy.contains(".badge", "1/2").should("be.visible");
    });
});
