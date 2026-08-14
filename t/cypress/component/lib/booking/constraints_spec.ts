// Pure-function tests for the constraint cross-filters.
//
// Items on biblio-level itype systems (item-level_itypes = 0) or with a
// NULL itype carry their type in effective_item_type_id; the itemtype
// options and auto-derived selection are built from that value, so the
// constraint predicates must match against it too. A regression here
// empties constrainedBookableItems and disables the whole calendar.

import {
    constrainPickupLocations,
    constrainBookableItems,
    constrainItemTypes,
} from "@koha-vue/lib/booking/constraints.js";

const LOCATIONS = [
    { library_id: "CPL", pickup_items: [1, 2] },
    { library_id: "MPL", pickup_items: [3] },
];

// Item 1 carries its own itype; items 2 and 3 inherit from the biblio
// level (item_type_id null, effective_item_type_id set).
const ITEMS = [
    { item_id: 1, item_type_id: "BK", effective_item_type_id: null },
    { item_id: 2, item_type_id: null, effective_item_type_id: "DVD" },
    { item_id: 3, item_type_id: null, effective_item_type_id: "BK" },
];

const TYPES = [
    { item_type_id: "BK", description: "Books" },
    { item_type_id: "DVD", description: "DVDs" },
];

describe("constrainBookableItems", () => {
    it("matches items whose type comes from the biblio level", () => {
        const result = constrainBookableItems(ITEMS, LOCATIONS, null, "DVD");
        expect(result.filtered.map(i => i.item_id)).to.deep.equal([2]);
    });

    it("matches item-level and effective types under the same selection", () => {
        const result = constrainBookableItems(ITEMS, LOCATIONS, null, "BK");
        expect(result.filtered.map(i => i.item_id)).to.deep.equal([1, 3]);
    });

    it("combines pickup location and effective type constraints", () => {
        const result = constrainBookableItems(ITEMS, LOCATIONS, "MPL", "BK");
        expect(result.filtered.map(i => i.item_id)).to.deep.equal([3]);
    });
});

describe("constrainPickupLocations", () => {
    it("keeps locations holding an item of the selected effective type", () => {
        const result = constrainPickupLocations(LOCATIONS, ITEMS, "DVD", null);
        expect(result.filtered.map(l => l.library_id)).to.deep.equal(["CPL"]);
    });

    it("keeps only locations that can pick up the selected item", () => {
        const result = constrainPickupLocations(LOCATIONS, ITEMS, null, 3);
        expect(result.filtered.map(l => l.library_id)).to.deep.equal(["MPL"]);
    });
});

describe("constrainItemTypes", () => {
    it("resolves the selected item's type via effective_item_type_id", () => {
        const result = constrainItemTypes(TYPES, ITEMS, LOCATIONS, null, 2);
        expect(result.filtered.map(t => t.item_type_id)).to.deep.equal(["DVD"]);
    });

    it("keeps types with items pickable at the selected location", () => {
        const result = constrainItemTypes(TYPES, ITEMS, LOCATIONS, "MPL", null);
        expect(result.filtered.map(t => t.item_type_id)).to.deep.equal(["BK"]);
    });
});
