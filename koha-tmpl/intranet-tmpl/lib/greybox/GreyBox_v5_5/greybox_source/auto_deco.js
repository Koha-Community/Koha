var GB_SETS = {};
function decoGreyboxLinks() {
    var as = AJS.$bytc('a');
    AJS.map(as, function(a) {
        if(a.getAttribute('href') && a.getAttribute('rel')) {
            var rel = a.getAttribute('rel');
            if(rel.indexOf('gb_') == 0) {
                var name = rel.match(/\w+/)[0];
                var attrs = rel.match(/\[(.*)\]/)[1];
                var index = 0;

                var item = {
                    'caption': a.title || '',
                    'url': a.href
                }

                //Set up GB_SETS
                if(name == 'gb_pageset' || name == 'gb_imageset') {
                    if(!GB_SETS[attrs]) { GB_SETS[attrs] = []; }
                    GB_SETS[attrs].push(item);
                    index = GB_SETS[attrs].length;
                }

                //Append onclick
                if(name == 'gb_pageset') {
                    a.onclick = function() {
                        GB_showFullScreenSet(GB_SETS[attrs], index);
                        return false;
                    };
                }
                if(name == 'gb_imageset') {
                    a.onclick = function() {
                        GB_showImageSet(GB_SETS[attrs], index);
                        return false;
                    };
                }
                if(name == 'gb_image') {
                    a.onclick = function() {
                        GB_showImage(item.caption, item.url);
                        return false;
                    };
                }
                if(name == 'gb_page') {
                    a.onclick = function() {
                        var sp = attrs.split(/, ?/);
                        GB_show(item.caption, item.url, parseInt(sp[1]), parseInt(sp[0]));
                        return false;
                    };
                }
                if(name == 'gb_page_fs') {
                    a.onclick = function() {
                        GB_showFullScreen(item.caption, item.url);
                        return false;
                    };
                }
                if(name == 'gb_page_center') {
                    a.onclick = function() {
                        var sp = attrs.split(/, ?/);
                        GB_showCenter(item.caption, item.url, parseInt(sp[1]), parseInt(sp[0]));
                        return false;
                    };
                }
            }
        }});
}

AJS.AEV(window, 'load', decoGreyboxLinks);
