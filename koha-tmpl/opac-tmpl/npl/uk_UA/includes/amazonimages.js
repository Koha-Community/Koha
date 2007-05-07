// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_images() {
    for (var i = 0; i < document.images.length; i++) {
        img = document.images[i];
        if ((img.src.indexOf('images.amazon.com') >= 0) || (img.src.indexOf('g-images.amazon.com') >=0)) {
            w = img.width;
            h = img.height;
            if ((w == 1) || (h == 1)) {
                img.src = 'http://g-images.amazon.com/images/G/01/x-site/icons/no-img-sm.gif';
            } else if ((img.complete != null) && (!img.complete)) {
                img.src = 'http://g-images.amazon.com/images/G/01/x-site/icons/no-img-sm.gif';
            }
        }
    }
}
