
<script>
    (function () {
        /**
         * Format the biblio response from a Koha RESTful API request.
         * @param  {Object}  biblio  The biblio json object as returned from the Koha RESTful API
         * @param  {Object}  config  A configuration object
         *                           Valid keys are: `link`
         * @return {string}          The formatted HTML string
         */
        window.$biblio_to_html = function (biblio, config) {
            if (!biblio) {
                return ""; // empty string for no biblio
            }

            var title = "";

            if (config && config.biblio_id_only) {
                title = escape_str(biblio.biblio_id);
            } else {
                title = '<span class="biblio-title">';
                if (config && config.deleted) {
                    title += _("(Bibliographic record deleted) ");
                }
                if (biblio.title != null && biblio.title != "") {
                    title += escape_str(biblio.title);
                } else {
                    title += _("No title");
                }
                title += "</span>";

                // add subtitle
                if (biblio.subtitle != null && biblio.subtitle != "") {
                    title += ' <span class="biblio-subtitle">' + escape_str(biblio.subtitle) + "</span>";
                }
            }

            // set title as link
            if (config && config.link) {
                if (config.link === "marcdetail") {
                    title = '<a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=' + encodeURIComponent(biblio.biblio_id) + '" class="title">' + title + "</a>";
                } else if (config.link === "labeled_marc") {
                    title = '<a href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=' + encodeURIComponent(biblio.biblio_id) + '" class="title">' + title + "</a>";
                } else if (config.link === "isbd") {
                    title = '<a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=' + encodeURIComponent(biblio.biblio_id) + '" class="title">' + title + "</a>";
                } else if (config.link === "bookings") {
                    title = '<a href="/cgi-bin/koha/bookings/list.pl?biblionumber=' + encodeURIComponent(biblio.biblio_id) + '" class="title">' + title + "</a>";
                } else {
                    title = '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' + encodeURIComponent(biblio.biblio_id) + '" class="title">' + title + "</a>";
                }
            }

            if (!config || !config.biblio_id_only) {
                // add medium
                if (biblio.medium != null && biblio.medium != "") {
                    title += ' <span class="biblio-medium">' + escape_str(biblio.medium) + "</span>";
                }

                // add part numbers/names
                let part_numbers = typeof biblio.part_number === "string" ? biblio.part_number.split("|") : [];
                let part_names = typeof biblio.part_name === "string" ? biblio.part_name.split("|") : [];
                let i = 0;
                while (part_numbers[i] || part_names[i]) {
                    if (part_numbers[i]) {
                        title += ' <span class="part-number">' + escape_str(part_numbers[i]) + "</span>";
                    }
                    if (part_names[i]) {
                        title += ' <span class="part-name">' + escape_str(part_names[i]) + "</span>";
                    }
                    i++;
                }
            }

            return title;
        };
    })();
</script>
