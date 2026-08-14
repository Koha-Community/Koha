[% USE raw %]
[% USE Asset %]

<div id="booking-modal-mount">
    <booking-modal biblionumber="[% biblionumber | html %]" show-patron-select show-item-details-selects show-pickup-location-select date-range-constraint="issuelength_with_renewals"></booking-modal>
</div>
[% Asset.js("js/modals/booking.js") | $raw %]
