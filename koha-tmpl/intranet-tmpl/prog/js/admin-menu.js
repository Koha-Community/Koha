$(document).ready(function() {
    var path = location.pathname.substring(1);
    if (path == "cgi-bin/koha/admin/marctagstructure.pl" || path == "cgi-bin/koha/admin/marc_subfields_structure.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/biblio_framework.pl"]').addClass("current");
    } else if (path == "cgi-bin/koha/admin/auth_tag_structure.pl" || path == "cgi-bin/koha/admin/auth_subfields_structure.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/authtypes.pl"]').addClass("current");
    } else if (path == "cgi-bin/koha/admin/oai_set_mappings.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/oai_sets.pl"]').addClass("current");
    } else if (path == "cgi-bin/koha/admin/items_search_field.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/items_search_fields.pl"]').addClass("current");
    } else if (path == "cgi-bin/koha/admin/clone-rules.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/smart-rules.pl"]').addClass("current");
    }
});
