<script>
    (function() {
        /**
        * Format the patron response from a Koha RESTful API request.
        * @param  {Object}  patron  The patron json object as returned from the Koha RESTful API
        * @param  {Object}  config  A configuration object
        *                           Valid keys are: `invert_name`, `display_cardnumber` and `url`
        * @return {string}          The formatted HTML string
        */
        window.$patron_to_html = function( patron, config ) {

            if ( patron == null ) {
                return ''; // empty string for no patron
            }

            var title = null;
            if ( patron.title != null && patron.title != '' ) {
                title = '<span class="patron-title">' + escape_str(patron.title) + '</span>';
            }

            var name;
            var firstname   = escape_str(patron.firstname);
            var surname     = escape_str(patron.surname);

            if ( patron.middle_name != null && patron.middle_name != '' ) {
                firstname += ' ' + escape_str(patron.middle_name);
            }

            if ( patron.other_name != null && patron.other_name != '' ) {
                firstname += ' (' + escape_str(patron.other_name) + ')';
            }
            if ( config && config.invert_name ) {
                name = surname + ( firstname ? ', ' + firstname : '' );
            }
            else {
                name = firstname + ' ' + surname;
            }

            if ( config && config.display_cardnumber ) {
                name = name + ' (' + escape_str(patron.cardnumber)  + ')';
            }

            if (config && config.url) {
                if ( config.url === 'circulation_reserves' ) {
                    name = '<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber='+ encodeURIComponent(patron.patron_id) +'#reserves">' + name + '</a>';
                }
                else {
                    name = '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber='+ encodeURIComponent(patron.patron_id) +'">' + name + '</a>';
                }
            }

            return name;
        };
    })();
</script>
