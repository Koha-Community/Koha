<script>
    (function() {
        /**
        * Format the biblio response from a Koha RESTful API request.
        * @param  {Object}  biblio  The biblio json object as returned from the Koha RESTful API
        * @param  {Object}  config  A configuration object
        *                           Valid keys are: `link`
        * @return {string}          The formatted HTML string
        */
        window.$biblio_to_html = function( biblio, config ) {

            if ( biblio === undefined ) {
                return ''; // empty string for no biblio
            }

            var title = '<span class="biblio-title">';
            if ( biblio.title != null && biblio.title != '' ) {
                title += escape_str(biblio.title);
            } else {
                title += __("No title");
            }
            title += '</span>';

            if ( biblio.subtitle != null && biblio.subtitle != '' ) {
                title += '<span clas="biblio-subtitle">' + escape_str(biblio.subtitle) + '</span>';
            }

            if (config && config.link) {
                if ( config.link === 'marcdetail' ) {
                    title = '<a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber='+ encodeURIComponent(biblio.biblio_id) +'">' + title + '</a>';
                }
                else if ( config.link === 'labeled_marc') {
                    title = '<a href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber='+ encodeURIComponent(biblio.biblio_id) +'">' + title + '</a>';
                }
                else if ( config.link === 'isbd' ) {
                    title = '<a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber='+ encodeURIComponent(biblio.biblio_id) +'">' + title + '</a>';
                }
                else {
                    title = '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber='+ encodeURIComponent(biblio.biblio_id) +'">' + title + '</a>';
                }
            }

            if ( biblio.medium != null && biblio.medium != '' ) {
                title +=  '<span class="biblio-medium">'+escape_str(biblio.medium)+'</span>';
            }

            return title;
        };
    })();
</script>
