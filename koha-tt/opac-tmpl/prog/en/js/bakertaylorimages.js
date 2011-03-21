// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function bt_verify_images() {
	$("img").each(function(i){
	       if (this.src.indexOf('btol.com') >= 0) {
            h = this.height;
            if (h == 20) {
				$(this).before("<span class=\"no-image\" style=\"margin-bottom:5px;width:80px;\">"+NO_BAKERTAYLOR_IMAGE+"</span>");
            }
		}
		});
		}
