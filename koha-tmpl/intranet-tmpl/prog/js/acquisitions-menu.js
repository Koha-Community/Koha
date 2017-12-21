$(document).ready(function() {
    var path = location.pathname.substring(1);
    if (path.indexOf("invoice") >= 0) {
        $('#navmenulist a[href$="/cgi-bin/koha/acqui/invoices.pl"]').css('font-weight','bold');
    } else {
        $('#navmenulist a[href$="/' + path + '"]').css('font-weight','bold');
    }
});
