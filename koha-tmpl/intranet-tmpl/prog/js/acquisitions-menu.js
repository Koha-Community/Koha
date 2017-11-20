$(document).ready(function() {
    var path = location.pathname.substring(1);
    $('#navmenulist a[href$="/' + path + '"]').css('font-weight','bold');
});