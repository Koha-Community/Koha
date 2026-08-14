import { createPinia, setActivePinia } from "pinia";
import { useBookingStore } from "@koha-vue/stores/bookings";

/**
 * Store-level regression tests for resolveItemForPeriod's multi-item
 * fallback. POST /bookings requires exactly one of item_id/itemtype_id,
 * so the fallback must never hand the modal a null itemtype_id — the
 * server rejects such a payload with a 400.
 */
describe("bookings store validation", () => {
    const START = "2026-08-10T00:00:00.000Z";
    const END = "2026-08-12T23:59:59.999Z";

    function makeStore(bookableItems) {
        setActivePinia(createPinia());
        const store = useBookingStore();
        store.bookableItems = bookableItems;
        return store;
    }

    beforeEach(() => {
        cy.intercept("GET", "**/api/v1/**", { body: [] });
    });

    it("blocks submission when available items span several item types and none is selected", () => {
        const store = makeStore([
            { item_id: 101, item_type_id: "BK" },
            { item_id: 102, item_type_id: "DVD" },
        ]);

        const result = store.resolveItemForPeriod({
            start: START,
            end: END,
        });
        expect(result.ok).to.equal(false);
        expect(store.error?.code).to.equal("item_type_required");
    });

    it("narrows to the shared effective item type when all available items agree", () => {
        const store = makeStore([
            { item_id: 101, item_type_id: "BK" },
            { item_id: 102, item_type_id: null, effective_item_type_id: "BK" },
        ]);

        const result = store.resolveItemForPeriod({
            start: START,
            end: END,
        });
        expect(result).to.deep.equal({
            ok: true,
            item_id: null,
            itemtype_id: "BK",
        });
    });

    it("keeps the explicitly selected item type", () => {
        const store = makeStore([
            { item_id: 101, item_type_id: "BK" },
            { item_id: 102, item_type_id: "DVD" },
            { item_id: 103, item_type_id: "DVD" },
        ]);
        store.bookingItemtypeId = "DVD";

        const result = store.resolveItemForPeriod({
            start: START,
            end: END,
        });
        expect(result).to.deep.equal({
            ok: true,
            item_id: null,
            itemtype_id: "DVD",
        });
    });
});
