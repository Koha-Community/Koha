<!-- js-patron-format-address.inc -->
[% USE raw %]
[% USE To %]
[% USE AuthorisedValues %]
<script>
    (function() {

        const roadtypes = [% To.json(AuthorisedValues.Get('ROADTYPE')) | $raw %];
        let roadtypes_map = roadtypes.reduce((map, r) => {
            map[r.street_type] = r;
            return map;
        }, {});

        function member_display_address_style_us(data, line_break) {
            let address = "";
            if ( data.address || data.address2 ) {
                if ( data.address ) {
                    let roadtype_desc = '';
                    if ( data.street_type ) {
                        roadtype_desc = roadtypes_map[data.street_type] ? roadtypes_map[data.street_type].street_type : data.street_type;
                    }
                    address += '<li class="patronaddress1">' + escape_str(data.street_number) + ' ' + escape_str(data.address) + ' ' + escape_str(roadtype_desc) + '</li>';
                }
            }
            if ( data.address2 ) {
                address += '<li class="patronaddress2">' + escape_str(data.address2) + '</li>'
            }
            if ( data.city || data.postal_code || data.state || data.country ) {
                address += '<li class="patroncity">' + escape_str(data.city);
                if ( data.state ) {
                    if ( data.city ) {
                        address += ', ';
                    }
                    address += escape_str(data.state);
                }
                if ( data.postal_code ) {
                    address += " " + escape_str(data.postal_code);
                }
                if ( data.country ) {
                    if ( data.postal_code || data.state || data.city ) {
                        address += ', ';
                    }
                    address += escape_str(data.country)
                }
                address += '</li>'
            }

            return address;
        }

        function member_display_address_style_de(data, line_break) {
            let address = "";
            if ( data.address || data.address2 ) {
                if ( data.address ) {
                    let roadtype_desc = '';
                    if ( data.street_type ) {
                        roadtype_desc = roadtypes_map[data.street_type] ? roadtypes_map[data.street_type].street_type : data.street_type;
                    }
                    address += '<li class="patronaddress1">' + escape_str(data.address) + ' ' + escape_str(roadtype_desc) + escape_str(data.street_number) + '</li>';
                }
            }
            if ( data.address2 ) {
                address += '<li class="patronaddress2">' + escape_str(data.address2) + '</li>'
            }
            if ( data.city || data.postal_code || data.state || data.country ) {
                address += '<li class="patroncity">';
                address += escape_str(data.postal_code) + ' ' + escape_str(data.city);
                address += data.state   ? line_break + escape_str(data.state)   : '';
                address += data.country ? line_break + escape_str(data.country) : '';
                address += '</li>'
            }

            return address;
        }

        function member_display_address_style_fr(data, line_break) {
            let address = "";
            if ( data.address || data.address2 ) {
                if ( data.address ) {
                    let roadtype_desc = '';
                    if ( data.street_type ) {
                        roadtype_desc = roadtypes_map[data.street_type] ? roadtypes_map[data.street_type].street_type : data.street_type;
                    }
                    address += '<li class="patronaddress1">' + escape_str(data.street_number) + ' ' + escape_str(roadtype_desc) + escape_str(data.address) + '</li>';
                }
            }
            if ( data.address2 ) {
                address += '<li class="patronaddress2">' + escape_str(data.address2) + '</li>'
            }
            if ( data.city || data.postal_code || data.state || data.country ) {
                address += '<li class="patroncity">';
                address += escape_str(data.postal_code) + ' ' + escape_str(data.city);
                address += data.state   ? line_break + escape_str(data.state)   : '';
                address += data.country ? line_break + escape_str(data.country) : '';
                address += '</li>'
            }

            return address;
        }

        window.$format_address = function(data, options) {
            let line_break = options && options.no_line_break ? ' ' : '<br/>';
            [%~ IF Koha.Preference( 'AddressFormat' ) ~%]
                return member_display_address_style_[% Koha.Preference( 'AddressFormat' ) | html %](data, line_break);
            [%~ ELSE ~%]
                return member_display_address_style_us(data, line_break);
            [%~ END ~%]
        }

    })();
</script>
<!-- / js-patron-format-address.inc -->
