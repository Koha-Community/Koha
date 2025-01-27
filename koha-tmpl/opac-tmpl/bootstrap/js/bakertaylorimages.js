/* global __ */
/* exported bt_verify_images */
// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function bt_verify_images() {
    $("img").each(function () {
        if (this.src.indexOf("btol.com") >= 0) {
            var h = this.height;
            if (h == 20) {
                $(this).before(
                    '<span class="no-image" style="margin-bottom:5px;width:80px;">' +
                        __("No cover image available") +
                        "</span>"
                );
            }
        }
    });
}
