GB_showImage = function(caption, url, callback_fn) {
    var options = {
        width: 300,
        height: 300,
        type: 'image',

        fullscreen: false,
        center_win: true,
        caption: caption,
        callback_fn: callback_fn
    }
    var win = new GB_Gallery(options);
    return win.show(url);
}

GB_showPage = function(caption, url, callback_fn) {
    var options = {
        type: 'page',

        caption: caption,
        callback_fn: callback_fn,
        fullscreen: true,
        center_win: false
    }
    var win = new GB_Gallery(options);
    return win.show(url);
}

GB_Gallery = GreyBox.extend({
    init: function(options) {
        this.parent({});
        this.img_close = this.root_dir + 'g_close.gif';
        AJS.update(this, options);
        this.addCallback(this.callback_fn);
    },

    initHook: function() {
        AJS.addClass(this.g_window, 'GB_Gallery');

        var inner = AJS.DIV({'class': 'inner'});
        this.header = AJS.DIV({'class': 'GB_header'}, inner);
        AJS.setOpacity(this.header, 0);
        AJS.getBody().insertBefore(this.header, this.overlay.nextSibling);

        var td_caption = AJS.TD({'id': 'GB_caption', 'class': 'caption', 'width': '40%'}, this.caption);
        var td_middle = AJS.TD({'id': 'GB_middle', 'class': 'middle', 'width': '20%'});

        var img_close = AJS.IMG({'src': this.img_close});
        AJS.AEV(img_close, 'click', GB_hide);
        var td_close = AJS.TD({'class': 'close', 'width': '40%'}, img_close);

        var tbody = AJS.TBODY(AJS.TR(td_caption, td_middle, td_close));

        var table = AJS.TABLE({'cellspacing': '0', 'cellpadding': 0, 'border': 0}, tbody);
        AJS.ACN(inner, table);

        if(this.fullscreen)
            AJS.AEV(window, 'scroll', AJS.$b(this.setWindowPosition, this));
        else
            AJS.AEV(window, 'scroll', AJS.$b(this._setHeaderPos, this));
    },

    setFrameSize: function() {
        var overlay_w = this.overlay.offsetWidth;
        var page_size = AJS.getWindowSize();

        if(this.fullscreen) {
            this.width = overlay_w-40;
            this.height = page_size.h-80;
        }
        AJS.setWidth(this.iframe, this.width);
        AJS.setHeight(this.iframe, this.height);

        AJS.setWidth(this.header, overlay_w);
    },

    _setHeaderPos: function() {
        AJS.setTop(this.header, AJS.getScrollTop()+10);
    },

    setWindowPosition: function() {
        var overlay_w = this.overlay.offsetWidth;
        var page_size = AJS.getWindowSize();
        AJS.setLeft(this.g_window, ((overlay_w - 50 - this.width)/2));

        var header_top = AJS.getScrollTop()+55;
        if(!this.center_win) {
            AJS.setTop(this.g_window, header_top);
        }
        else {
            var fl = ((page_size.h - this.height) /2) + 20 + AJS.getScrollTop();
            if(fl < 0) fl = 0;
            if(header_top > fl) {
                fl = header_top;
            }
            AJS.setTop(this.g_window, fl);
        }
        this._setHeaderPos();
    },

    onHide: function() {
        AJS.removeElement(this.header);
        AJS.removeClass(this.g_window, 'GB_Gallery');
    },

    onShow: function() {
        if(this.use_fx)
            AJS.fx.fadeIn(this.header, {to: 1});
        else
            AJS.setOpacity(this.header, 1);
    }
});

AJS.preloadImages(GB_ROOT_DIR+'g_close.gif');
