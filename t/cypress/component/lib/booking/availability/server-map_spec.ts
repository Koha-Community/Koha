// Tests for the server availability map utilities: payload translation
// and the point/range conflict queries.

import {
    serverMapToUnavailableByDate,
    dateHasConflict,
    rangeHasConflict,
    itemsAvailableForPeriod,
} from "@koha-vue/lib/booking/availability/server-map.js";

const mapOf = entries => {
    const map = {};
    for (const [date, byItem] of Object.entries(entries)) {
        map[date] = {};
        for (const [id, reasons] of Object.entries(byItem)) {
            map[date][id] = new Set(reasons);
        }
    }
    return map;
};

describe("serverMapToUnavailableByDate", () => {
    it("returns an empty map for null / payloads without availability", () => {
        expect(serverMapToUnavailableByDate(null)).to.deep.equal({});
        expect(serverMapToUnavailableByDate({})).to.deep.equal({});
    });

    it("flattens a cell's blocker and warning codes into one Set", () => {
        const map = serverMapToUnavailableByDate({
            item_ids: [1],
            availability: {
                "2026-03-20": {
                    "1": {
                        blockers: { booking: 1 },
                        confirms: {},
                        warnings: { holiday: 1 },
                    },
                },
            },
        });
        const reasons = map["2026-03-20"]["1"];
        expect(reasons).to.be.instanceOf(Set);
        expect(reasons.has("booking")).to.be.true;
        expect(reasons.has("holiday")).to.be.true;
    });

    it("translates snake_case reasons to the client's hyphenated tokens", () => {
        const map = serverMapToUnavailableByDate({
            availability: {
                "2026-03-20": {
                    "1": {
                        blockers: {},
                        confirms: {},
                        warnings: { lead_floor: 1, lead_theoretical: 1 },
                    },
                },
            },
        });
        const reasons = map["2026-03-20"]["1"];
        expect(reasons.has("lead-floor")).to.be.true;
        expect(reasons.has("lead-theoretical")).to.be.true;
        expect(reasons.has("lead_floor")).to.be.false;
    });
});

describe("dateHasConflict", () => {
    const map = mapOf({
        "2026-03-20": { "1": ["booking"], "2": ["holiday"] },
        "2026-03-21": { "1": ["lead"], "2": ["trail"] },
    });

    it("blocks the selected item on its own conflict only", () => {
        expect(dateHasConflict(map, "2026-03-20", "1", ["1", "2"])).to.be.true;
        expect(dateHasConflict(map, "2026-03-20", "2", ["1", "2"])).to.be.false;
    });

    it("treats lead/trail windows as conflicts", () => {
        expect(dateHasConflict(map, "2026-03-21", "1", ["1", "2"])).to.be.true;
        expect(dateHasConflict(map, "2026-03-21", "2", ["1", "2"])).to.be.true;
    });

    it("ignores display-only reasons (holiday, lead-floor, lead-theoretical)", () => {
        const soft = mapOf({
            "2026-03-20": {
                "1": ["holiday", "lead-floor", "lead-theoretical"],
            },
        });
        expect(dateHasConflict(soft, "2026-03-20", "1", ["1"])).to.be.false;
    });

    it("blocks in any-item mode only when every item conflicts", () => {
        expect(dateHasConflict(map, "2026-03-21", null, ["1", "2"])).to.be.true;
        expect(dateHasConflict(map, "2026-03-20", null, ["1", "2"])).to.be
            .false;
    });

    it("never blocks a date the map has no entry for", () => {
        expect(dateHasConflict(map, "2026-03-25", "1", ["1"])).to.be.false;
        expect(dateHasConflict(map, "2026-03-25", null, ["1"])).to.be.false;
    });

    it("does not block any-item mode with an empty item list", () => {
        expect(dateHasConflict(map, "2026-03-20", null, [])).to.be.false;
    });
});

describe("rangeHasConflict", () => {
    it("blocks the selected item when any day in the range conflicts", () => {
        const map = mapOf({ "2026-03-22": { "1": ["checkout"] } });
        expect(rangeHasConflict(map, "2026-03-20", "2026-03-24", "1", [])).to.be
            .true;
        expect(rangeHasConflict(map, "2026-03-23", "2026-03-24", "1", [])).to.be
            .false;
    });

    it("blocks any-item mode when every item conflicts somewhere in the range", () => {
        // Disjoint conflicts: item 1 on Mar 21, item 2 on Mar 23. Neither
        // day blocks both items, but no single item can serve the range.
        const map = mapOf({
            "2026-03-21": { "1": ["booking"] },
            "2026-03-23": { "2": ["booking"] },
        });
        expect(
            rangeHasConflict(map, "2026-03-20", "2026-03-24", null, ["1", "2"])
        ).to.be.true;
        expect(
            rangeHasConflict(map, "2026-03-22", "2026-03-24", null, ["1", "2"])
        ).to.be.false;
    });

    it("returns false for an inverted range", () => {
        const map = mapOf({ "2026-03-22": { "1": ["booking"] } });
        expect(rangeHasConflict(map, "2026-03-24", "2026-03-20", "1", [])).to.be
            .false;
    });
});

describe("itemsAvailableForPeriod", () => {
    const items = [{ item_id: "1" }, { item_id: "2" }];

    it("returns all items when none are booked or checked out in the window", () => {
        const result = itemsAvailableForPeriod(
            mapOf({}),
            items,
            "2026-03-20",
            "2026-03-24"
        );
        expect(result.map(i => i.item_id)).to.deep.equal(["1", "2"]);
    });

    it("filters items with hard conflicts, keeps soft-marked items", () => {
        const map = mapOf({
            "2026-03-21": { "1": ["booking"], "2": ["lead", "holiday"] },
        });
        const result = itemsAvailableForPeriod(
            map,
            items,
            "2026-03-20",
            "2026-03-24"
        );
        expect(result.map(i => i.item_id)).to.deep.equal(["2"]);
    });

    it("treats checkouts as hard conflicts", () => {
        const map = mapOf({ "2026-03-21": { "1": ["checkout"] } });
        const result = itemsAvailableForPeriod(
            map,
            items,
            "2026-03-20",
            "2026-03-24"
        );
        expect(result.map(i => i.item_id)).to.deep.equal(["2"]);
    });

    it("returns an empty array when every item conflicts in the window", () => {
        const map = mapOf({
            "2026-03-22": { "1": ["booking"], "2": ["booking"] },
        });
        const result = itemsAvailableForPeriod(
            map,
            items,
            "2026-03-20",
            "2026-03-24"
        );
        expect(result).to.deep.equal([]);
    });
});
