import { ref } from "vue";
import BookingModal from "@koha-vue/components/Bookings/BookingModal.vue";

const submittedDetail = {
    booking: { booking_id: 22 },
    bookingPatron: { patron_id: 42 },
    isUpdate: false,
};

const BookingFormStub = {
    name: "BookingForm",
    props: [
        "active",
        "biblionumber",
        "bookingId",
        "pickupLibraryId",
        "submitType",
    ],
    emits: ["submitted"],
    setup(_props, { expose }) {
        expose({
            isSubmitReady: ref(true),
            submitLabel: ref("Place booking"),
            submitLoading: ref(false),
        });
    },
    template: `
        <form id="form-booking">
            <button
                data-test="emit-submitted"
                type="button"
                @click="$emit('submitted', submittedDetail)"
            >
                Save
            </button>
        </form>
    `,
    data() {
        return { submittedDetail };
    },
};

class ModalStub {
    static latest;
    element;
    options;
    showCalls = 0;
    hideCalls = 0;
    disposeCalls = 0;

    constructor(element, options) {
        this.element = element;
        this.options = options;
        ModalStub.latest = this;
    }

    show() {
        this.showCalls += 1;
    }

    hide() {
        this.hideCalls += 1;
        this.element.dispatchEvent(new window.Event("hidden.bs.modal"));
    }

    toggle() {
        this.show();
    }

    dispose() {
        this.disposeCalls += 1;
    }

    static getInstance() {
        return ModalStub.latest;
    }

    static getOrCreateInstance(element, options) {
        return ModalStub.latest || new ModalStub(element, options);
    }
}

function mountModal(props = {}) {
    return cy.mount(BookingModal, {
        props: {
            biblionumber: 1,
            ...props,
        },
        global: {
            stubs: { BookingForm: BookingFormStub },
        },
    });
}

describe("BookingModal", () => {
    beforeEach(() => {
        ModalStub.latest = null;
        window.bootstrap = { Modal: ModalStub };
    });

    it("composes the booking form without changing the island contract", () => {
        mountModal({
            open: true,
            bookingId: 12,
            pickupLibraryId: "CPL",
            submitType: "api",
        }).then(({ wrapper }) => {
            const form = wrapper.findComponent(BookingFormStub);
            expect(form.props()).to.include({
                active: true,
                biblionumber: 1,
                bookingId: 12,
                pickupLibraryId: "CPL",
                submitType: "api",
            });
        });

        cy.get(".modal").should("have.attr", "aria-labelledby");
        cy.get(".modal-title").should("contain.text", "Edit booking");
        cy.get('button[form="form-booking"][type="submit"]').should("exist");
        cy.then(() => {
            expect(ModalStub.latest.options).to.deep.equal({
                backdrop: "static",
            });
            expect(ModalStub.latest.showCalls).to.equal(1);
        });
    });

    it("leaves Escape-to-close at Bootstrap's default (not disabled)", () => {
        mountModal({ open: true });

        cy.then(() => {
            expect(ModalStub.latest.options).to.not.have.property("keyboard");
        });
    });

    it("deactivates the form and emits close only after Bootstrap hides", () => {
        let wrapper;
        mountModal({ open: true }).then(mounted => {
            wrapper = mounted.wrapper;
        });

        cy.contains("button", "Cancel").click();

        cy.then(() => {
            expect(ModalStub.latest.hideCalls).to.equal(1);
            expect(
                wrapper.findComponent(BookingFormStub).props("active")
            ).to.equal(false);
            expect(wrapper.emitted("close")).to.have.length(1);
        });
    });

    it("maps form success to booking-saved and closes the modal", () => {
        let wrapper;
        mountModal({ open: true }).then(mounted => {
            wrapper = mounted.wrapper;
        });

        cy.get('[data-test="emit-submitted"]').click();

        cy.then(() => {
            expect(wrapper.emitted("booking-saved")[0][0]).to.deep.equal(
                submittedDetail
            );
            expect(wrapper.emitted("close")).to.have.length(1);
            expect(ModalStub.latest.hideCalls).to.equal(1);
        });
    });

    it("restores focus to the control that opened the modal", () => {
        mountModal({ open: false }).then(({ wrapper }) => {
            const trigger = document.createElement("button");
            trigger.type = "button";
            document.body.appendChild(trigger);
            trigger.focus();

            return wrapper
                .setProps({ open: true })
                .then(() =>
                    wrapper.find("button.btn-secondary").trigger("click")
                )
                .then(() => {
                    expect(document.activeElement).to.equal(trigger);
                    trigger.remove();
                });
        });
    });

    it("maps the open prop to modal lifecycle and disposes on unmount", () => {
        mountModal({ open: false }).then(({ wrapper }) => {
            expect(ModalStub.latest.showCalls).to.equal(0);
            return wrapper
                .setProps({ open: true })
                .then(() => {
                    expect(ModalStub.latest.showCalls).to.equal(1);
                    return wrapper.setProps({ open: false });
                })
                .then(() => {
                    expect(ModalStub.latest.hideCalls).to.equal(1);
                    wrapper.unmount();
                    expect(ModalStub.latest.disposeCalls).to.equal(1);
                });
        });
    });
});
