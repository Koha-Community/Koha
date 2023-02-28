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

        function member_display_address_style_us(data, line_break, include_li) {
            let address = "";
            if ( data.address || data.address2 ) {
                if ( data.address ) {
                    let roadtype_desc = '';
                    if ( data.street_type ) {
                        roadtype_desc = roadtypes_map[data.street_type] ? roadtypes_map[data.street_type].street_type : data.street_type;
                    }
                    address += include_li ? '<li class="patronaddress1">' : '';
                    address += escape_str(data.street_number) + ' ' + escape_str(data.address) + ' ' + escape_str(roadtype_desc);
                    address += include_li ? '</li>' : '';
                }
            }
            if ( data.address2 ) {
                address += include_li ? '<li class="patronaddress2">' : ' ';
                address += escape_str(data.address2);
                address += include_li ? '</li>' : '';
            }
            if ( data.city || data.postal_code || data.state || data.country ) {
                address += include_li ? '<li class="patroncity">' : ' ';
                address += escape_str(data.city);
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
                address += include_li ? '</li>' : '';
            }

            return address;
        }

        function member_display_address_style_de(data, line_break, include_li) {
            let address = "";
            if ( data.address || data.address2 ) {
                if ( data.address ) {
                    let roadtype_desc = '';
                    if ( data.street_type ) {
                        roadtype_desc = roadtypes_map[data.street_type] ? roadtypes_map[data.street_type].street_type : data.street_type;
                    }
                    address += include_li ? '<li class="patronaddress1">' : ' ';
                    address += escape_str(data.address) + ' ' + escape_str(roadtype_desc) + escape_str(data.street_number);
                    address += include_li ? '</li>' : '';
                }
            }
            if ( data.address2 ) {
                address += include_li ? '<li class="patronaddress2">' : ' ';
                address += escape_str(data.address2);
                address += include_li ? '</li>' : '';
            }
            if ( data.city || data.postal_code || data.state || data.country ) {
                address += include_li ? '<li class="patroncity">' : ' ';
                address += escape_str(data.postal_code) + ' ' + escape_str(data.city);
                address += data.state   ? line_break + escape_str(data.state)   : '';
                address += data.country ? line_break + escape_str(data.country) : '';
                address += include_li ? '</li>' : '';
            }

            return address;
        }

        function member_display_address_style_fr(data, line_break, include_li) {
            let address = "";
            if ( data.address || data.address2 ) {
                if ( data.address ) {
                    let roadtype_desc = '';
                    if ( data.street_type ) {
                        roadtype_desc = roadtypes_map[data.street_type] ? roadtypes_map[data.street_type].street_type : data.street_type;
                    }
                    address += include_li ? '<li class="patronaddress1">' : '';
                    address += escape_str(data.street_number) + ' ' + escape_str(roadtype_desc) + escape_str(data.address);
                    address += include_li ? '</li>' : '';
                }
            }
            if ( data.address2 ) {
                address += include_li ? '<li class="patronaddress2">' : ' ';
                address += escape_str(data.address2);
                address += include_li ? '</li>' : '';
            }
            if ( data.city || data.postal_code || data.state || data.country ) {
                address += include_li ? '<li class="patroncity">' : ' ';
                address += escape_str(data.postal_code) + ' ' + escape_str(data.city);
                address += data.state   ? line_break + escape_str(data.state)   : '';
                address += data.country ? line_break + escape_str(data.country) : '';
                address += include_li ? '</li>' : '';
            }

            return address;
        }

        window.$format_address = function(data, options) {
            let line_break = options && options.no_line_break ? ' ' : '<br/>';
            let include_li = options && options.include_li;
            [%~ IF Koha.Preference( 'AddressFormat' ) ~%]
                return member_display_address_style_[% Koha.Preference( 'AddressFormat' ) | html %](data, line_break, include_li);
            [%~ ELSE ~%]
                return member_display_address_style_us(data, line_break, include_li);
            [%~ END ~%]
        }

    })();
</script>
<!-- / js-patron-format-address.inc -->
