// Pure-function tests for circulation rule helpers.
//
// calculateMaxBookingPeriod feeds BookingPeriodStep's constraint info alert
// and the composable's classByDate constrained-range highlight. Test the
// math for each dateRangeConstraint variant so a regression points here
// rather than to the alert text or the picker.

import {
    extractBookingConfiguration,
    toEffectiveRules,
    calculateMaxBookingPeriod,
} from "@koha-vue/lib/booking/availability/predicate.js";

describe("calculateMaxBookingPeriod", () => {
    it("returns null when no dateRangeConstraint is given", () => {
        expect(calculateMaxBookingPeriod([{ issuelength: 7 }], null)).to.be
            .null;
    });

    it("returns null when circulationRules is empty", () => {
        expect(calculateMaxBookingPeriod([], "issuelength")).to.be.null;
    });

    it("returns issuelength for the 'issuelength' constraint", () => {
        expect(
            calculateMaxBookingPeriod([{ issuelength: 7 }], "issuelength")
        ).to.equal(7);
    });

    it("returns issuelength + renewalperiod * renewalsallowed for 'issuelength_with_renewals'", () => {
        expect(
            calculateMaxBookingPeriod(
                [
                    {
                        issuelength: 5,
                        renewalperiod: 3,
                        renewalsallowed: 2,
                    },
                ],
                "issuelength_with_renewals"
            )
        ).to.equal(11);
    });

    it("returns the result of customDateRangeFormula for the 'custom' constraint", () => {
        const formula = rules => Number(rules.issuelength) * 2;
        expect(
            calculateMaxBookingPeriod([{ issuelength: 7 }], "custom", formula)
        ).to.equal(14);
    });

    it("returns null for the 'custom' constraint when no formula is given", () => {
        expect(calculateMaxBookingPeriod([{ issuelength: 7 }], "custom")).to.be
            .null;
    });

    it("returns null for an unrecognised constraint name", () => {
        expect(calculateMaxBookingPeriod([{ issuelength: 7 }], "unrecognised"))
            .to.be.null;
    });
});

describe("extractBookingConfiguration", () => {
    it("normalizes empty rules to zeroed configuration", () => {
        const config = extractBookingConfiguration({}, new Date(2026, 2, 15));
        expect(config.leadDays).to.equal(0);
        expect(config.trailDays).to.equal(0);
        expect(config.maxPeriod).to.equal(0);
        expect(config.isEndDateOnly).to.be.false;
        expect(config.calculatedDueDate).to.be.null;
    });

    it("reads booking_constraint_mode === 'end_date_only' into isEndDateOnly", () => {
        const config = extractBookingConfiguration(
            { booking_constraint_mode: "end_date_only" },
            new Date(2026, 2, 15)
        );
        expect(config.isEndDateOnly).to.be.true;
    });

    it("falls back to issuelength when maxPeriod is missing", () => {
        const config = extractBookingConfiguration(
            { issuelength: 7 },
            new Date(2026, 2, 15)
        );
        expect(config.maxPeriod).to.equal(7);
    });

    it("prefers maxPeriod over issuelength when both are present", () => {
        const config = extractBookingConfiguration(
            { issuelength: 7, maxPeriod: 14 },
            new Date(2026, 2, 15)
        );
        expect(config.maxPeriod).to.equal(14);
    });
});

describe("toEffectiveRules", () => {
    it("pulls the first rule from an array and applies the constraint logic", () => {
        const result = toEffectiveRules([{ issuelength: 7 }], {
            dateRangeConstraint: "issuelength",
            maxBookingPeriod: 14,
        });
        expect(result.maxPeriod).to.equal(14);
    });

    it("applies maxBookingPeriod for issuelength_with_renewals", () => {
        const result = toEffectiveRules([{ issuelength: 7 }], {
            dateRangeConstraint: "issuelength_with_renewals",
            maxBookingPeriod: 21,
        });
        expect(result.maxPeriod).to.equal(21);
    });

    it("strips maxPeriod and issuelength for unconstrained modes", () => {
        // Without a constraint, the function strips length caps so the
        // calendar opens up to the full lookahead window.
        const result = toEffectiveRules(
            [{ issuelength: 7, maxPeriod: 14 }],
            {}
        );
        expect(result).not.to.have.property("issuelength");
        expect(result).not.to.have.property("maxPeriod");
    });

    it("treats an empty array as an empty rule object", () => {
        const result = toEffectiveRules([], {
            dateRangeConstraint: "issuelength",
            maxBookingPeriod: 14,
        });
        // Without baseRules, the function still applies the maxBookingPeriod
        // (no underlying field to strip), producing { maxPeriod: 14 }.
        expect(result.maxPeriod).to.equal(14);
    });
});
