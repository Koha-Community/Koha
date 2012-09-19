GB_show = function(caption, url, /* optional */ height, width, callback_fn) {
    var options = {
        caption: caption,
        height: height || 500,
        width: width || 500,
        fullscreen: false,
        callback_fn: callback_fn
    }
    var win = new GB_Window(options);
    return win.show(url);
}

GB_showCenter = function(caption, url, /* optional */ height, width, callback_fn) {
    var options = {
        caption: caption,
        center_win: true,
        height: height || 500,
        width: width || 500,
        fullscreen: false,
        callback_fn: callback_fn
    }
    var win = new GB_Window(options);
    return win.show(url);
}

GB_showFullScreen = function(caption, url, callback_fn) {
    var options = {
        caption: caption,
        fullscreen: true,
        callback_fn: callback_fn
    }
    var win = new GB_Window(options);
    return win.show(url);
}

GB_Window = GreyBox.extend({
    init: function(options) {
        this.parent({});
        this.img_header = this.root_dir+"header_bg.gif";
        this.img_close = this.root_dir+"w_close.gif";
        this.show_close_img = true;
        AJS.update(this, options);
        this.addCallback(this.callback_fn);
    },

    initHook: function() {
        AJS.addClass(this.g_window, 'GB_Window');

        this.header = AJS.TABLE({'class': 'header'});
        this.header.style.backgroundImage = "url("+ this.img_header +")";

        var td_caption = AJS.TD({'class': 'caption'}, this.caption);
        var td_close = AJS.TD({'class': 'close'});

        if(this.show_close_img) {
            var img_close = AJS.IMG({'src': this.img_close});
            var span = AJS.SPAN('Close');

            var btn = AJS.DIV(img_close, span);

            AJS.AEV([img_close, span], 'mouseover', function() { AJS.addClass(span, 'on'); });
            AJS.AEV([img_close, span], 'mouseout', function() { AJS.removeClass(span, 'on'); });
            AJS.AEV([img_close, span], 'mousedown', function() { AJS.addClass(span, 'click'); });
            AJS.AEV([img_close, span], 'mouseup', function() { AJS.removeClass(span, 'click'); });
            AJS.AEV([img_close, span], 'click', GB_hide);

            AJS.ACN(td_close, btn);
        }

        tbody_header = AJS.TBODY();
        AJS.ACN(tbody_header, AJS.TR(td_caption, td_close));

        AJS.ACN(this.header, tbody_header);
        AJS.ACN(this.top_cnt, this.header);

        if(this.fullscreen)
            AJS.AEV(window, 'scroll', AJS.$b(this.setWindowPosition, this));
    },

    setFrameSize: function() {
        if(this.fullscreen) {
            var page_size = AJS.getWindowSize();
            overlay_h = page_size.h;
            this.width = Math.round(this.overlay.offsetWidth - (this.overlay.offsetWidth/100)*10);
            this.height = Math.round(overlay_h - (overlay_h/100)*10);
        }

        AJS.setWidth(this.header, this.width+6); //6 is for the left+right border
        AJS.setWidth(this.iframe, this.width);
        AJS.setHeight(this.iframe, this.height);
    },

    setWindowPosition: function() {
        var page_size = AJS.getWindowSize();
        AJS.setLeft(this.g_window, ((page_size.w - this.width)/2)-13);

        if(!this.center_win) {
            AJS.setTop(this.g_window, AJS.getScrollTop());
        }
        else {
            var fl = ((page_size.h - this.height) /2) - 20 + AJS.getScrollTop();
            if(fl < 0)
                fl = 0;
            AJS.setTop(this.g_window, fl);
        }
    }
});

AJS.preloadImages(GB_ROOT_DIR+'w_close.gif', GB_ROOT_DIR+'header_bg.gif');
