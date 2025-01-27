/* global __ */
/* exported verify_images */
// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_images() {
    $("img").each(function () {
        if (
            this.src.indexOf("images.amazon.com") >= 0 ||
            this.src.indexOf("g-images.amazon.com") >= 0 ||
            this.src.indexOf("syndetics.com") >= 0
        ) {
            var w = this.width;
            var h = this.height;
            if (w == 1 || h == 1) {
                $(this)
                    .parent()
                    .html(
                        '<span class="no-image">' +
                            __("No cover image available") +
                            "</span>"
                    );
            } else if (this.complete != null && !this.complete) {
                $(this)
                    .parent()
                    .html(
                        '<span class="no-image">' +
                            __("No cover image available") +
                            "</span>"
                    );
            }
        }
    });
}
