// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_images() {
	$("img").each(function(i){
	       if ((this.src.indexOf('images.amazon.com') >= 0) || (this.src.indexOf('g-images.amazon.com') >=0)) {
            w = this.width;
            h = this.height;
            if ((w == 1) || (h == 1)) {
                this.src = 'http://g-images.amazon.com/images/G/01/x-site/icons/no-img-sm.gif';
            } else if ((this.complete != null) && (!this.complete)) {
                this.src = 'http://g-images.amazon.com/images/G/01/x-site/icons/no-img-sm.gif';
            }
        }
		});
		}
