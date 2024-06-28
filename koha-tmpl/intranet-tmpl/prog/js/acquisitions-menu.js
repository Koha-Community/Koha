function searchToOrder(basketno, vendorid) {
    var date = new Date();
    var cookieData = "";
    date.setTime(date.getTime() + 10 * 60 * 1000);
    cookieData += basketno + "/" + vendorid;
    Cookies.set("searchToOrder", cookieData, {
        path: "/",
        expires: date,
        sameSite: "Lax",
    });
}

$(document).ready(function () {
    var path = location.pathname.substring(1);
    if (path.indexOf("invoice") >= 0) {
        $('.sidebar_menu a[href$="/cgi-bin/koha/acqui/invoices.pl"]').addClass(
            "current"
        );
    }

    $("body").on("click", "#searchtoorder", function () {
        var vendorid = $(this).data("booksellerid");
        var basketno = $(this).data("basketno");
        searchToOrder(basketno, vendorid);
    });
});
