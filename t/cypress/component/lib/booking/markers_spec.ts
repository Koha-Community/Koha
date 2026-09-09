import { getDateFeedbackMessage } from "@koha-vue/lib/booking/markers.js";

// Regression coverage for a live bug: getDateFeedbackMessage used to
// re-derive leadDays/trailDays/maxPeriod from a raw circulation-rule
// object, always falling back to bare issuelength for maxPeriod and
// ignoring the active dateRangeConstraint mode (e.g.
// issuelength_with_renewals, which adds renewalsallowed*renewalperiod
// on top). That understated maxPeriod, and because the "exceeds
// maximum booking period" check runs before the marker-based reasons
// in getDisabledReason, it could report the wrong reason entirely -
// masking a genuine trail-period conflict behind a bogus "exceeds
// maximum booking period (5 days)" when the real effective period was
// 30. The caller must now pass the already-derived effective values
// (see BookingPeriodStep.vue's onDayHover, which reads them from
// bufferConfig - itself built via extractBookingConfiguration/
// toEffectiveRules, the same pipeline createDisableFunction uses).

describe("getDateFeedbackMessage - effective maxPeriod", () => {
    it("reports the trail-conflict reason, not a bogus max-period one, when maxPeriod is comfortably larger than the candidate range", () => {
        // issuelength=5, renewalsallowed=5, renewalperiod=5 -> effective
        // maxPeriod=30 (issuelength_with_renewals). Candidate end is only
        // 9 days after start, nowhere near 30 - but createDisableFunction
        // still disabled it, because its trail window would conflict
        // with another booking's lead-tagged window.
        const feedback = getDateFeedbackMessage(new Date("2026-10-09"), {
            isDisabled: true,
            selectedDateRange: ["2026-09-30"],
            leadDays: 2,
            trailDays: 3,
            maxPeriod: 30,
            unavailableByDate: {},
            holidays: [],
        });

        expect(feedback).to.not.equal(null);
        expect(feedback.message).to.equal(
            "Cannot select: trail period (3 days after return) conflicts with an existing booking"
        );
        expect(feedback.message).to.not.contain(
            "exceeds maximum booking period"
        );
    });

    it("still reports exceeding the maximum booking period when the candidate genuinely does", () => {
        const feedback = getDateFeedbackMessage(new Date("2026-10-31"), {
            isDisabled: true,
            selectedDateRange: ["2026-09-30"],
            leadDays: 2,
            trailDays: 3,
            maxPeriod: 30,
            unavailableByDate: {},
            holidays: [],
        });

        expect(feedback).to.not.equal(null);
        expect(feedback.message).to.equal(
            "Cannot select: exceeds maximum booking period (30 days)"
        );
    });

    it("defaults maxPeriod/leadDays/trailDays to 0 when the caller omits them, rather than throwing", () => {
        const feedback = getDateFeedbackMessage(new Date("2026-10-09"), {
            isDisabled: true,
            selectedDateRange: ["2026-09-30"],
            unavailableByDate: {},
            holidays: [],
        });

        expect(feedback).to.not.equal(null);
        expect(feedback.message).to.equal(
            "Cannot select: conflicts with an existing booking"
        );
    });
});
