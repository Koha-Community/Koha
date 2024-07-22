$(document).ready(function () {
    var path = location.pathname.substring(1);
    if (path.indexOf("label-edit-batch") >= 0) {
        $(
            '#labels-menu a[href$="/cgi-bin/koha/labels/label-manage.pl?label_element=batch"]'
        ).addClass("current");
    } else if (path.indexOf("label-edit-layout") >= 0) {
        $(
            '#labels-menu a[href$="/cgi-bin/koha/labels/label-manage.pl?label_element=layout"]'
        ).addClass("current");
    } else if (path.indexOf("label-edit-template") >= 0) {
        $(
            '#labels-menu a[href$="/cgi-bin/koha/labels/label-manage.pl?label_element=template"]'
        ).addClass("current");
    } else if (path.indexOf("label-edit-profile") >= 0) {
        $(
            '#labels-menu a[href$="/cgi-bin/koha/labels/label-manage.pl?label_element=profile"]'
        ).addClass("current");
    } else if (path.indexOf("label-edit-range") >= 0) {
        $(
            '#labels-menu a[href$="/cgi-bin/koha/labels/label-edit-range.pl"]'
        ).addClass("current");
    }
});
