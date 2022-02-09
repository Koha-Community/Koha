<!-- js-patron-format-address.inc -->
<script>
    (function() {

        window.$format_address = function(data, options) {

            let address = '';
            address += (data.street_number ? data.street_number + ' ' : '' );
            address += (data.address ? data.address + ' ' : '' );
            address += (data.address2 ? data.address2 + ' ' : '' );
            address += (data.city ? data.city + ' ' : '' );
            address += (data.state ? data.state + ' ' : '' );
            address += (data.postal_code ? data.postal_code + ' ' : '' );
            address += (data.country ? data.country + ' ' : '' );
            return address;
        }

    })();
</script>
<!-- / js-patron-format-address.inc -->
