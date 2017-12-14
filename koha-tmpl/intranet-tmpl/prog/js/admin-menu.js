$(document).ready(function() {
    var path = location.pathname.substring(1);
    if (path == "cgi-bin/koha/admin/marctagstructure.pl" || path == "cgi-bin/koha/admin/marc_subfields_structure.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/biblio_framework.pl"]').css('font-weight','bold');
    } else if (path == "cgi-bin/koha/admin/auth_tag_structure.pl" || path == "cgi-bin/koha/admin/auth_subfields_structure.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/authtypes.pl"]').css('font-weight','bold');
    } else if (path == "cgi-bin/koha/admin/oai_set_mappings.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/oai_sets.pl"]').css('font-weight','bold');
    } else if (path == "cgi-bin/koha/admin/items_search_field.pl") {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/items_search_fields.pl"]').css('font-weight','bold');
    } else if ( path.indexOf("clone-rules") ) {
        $('#navmenulist a[href$="/cgi-bin/koha/admin/smart-rules.pl"]').css('font-weight','bold');
    } else {
        $('#navmenulist a[href$="/' + path + '"]').css('font-weight','bold');
    }
});
