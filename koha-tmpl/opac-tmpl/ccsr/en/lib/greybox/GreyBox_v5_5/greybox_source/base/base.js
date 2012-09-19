var GB_CURRENT = null;

GB_hide = function() {
    GB_CURRENT.hide();
}

GreyBox = new AJS.Class({
    init: function(options) {
        this.use_fx = AJS.fx;
        this.type = "page";
        this.overlay_click_close = false;
        this.salt = 0;
        this.root_dir = GB_ROOT_DIR;
        this.callback_fns = [];
        this.reload_on_close = false;
        this.src_loader = this.root_dir + 'loader_frame.html';

        //Solve the www issue
        var h_www = window.location.hostname.indexOf('www');
        var src_www = this.src_loader.indexOf('www');
        if(h_www != -1 && src_www == -1)
            this.src_loader = this.src_loader.replace('://', '://www.');

        if(h_www == -1 && src_www != -1)
            this.src_loader = this.src_loader.replace('://www.', '://');

        this.show_loading = true;
        AJS.update(this, options);
    },

    addCallback: function(fn) {
        if(fn) this.callback_fns.push(fn);
    },

    show: function(url) {
        GB_CURRENT = this;
        this.url = url;

        var elms = [AJS.$bytc("object"), AJS.$bytc("select")];
        AJS.map(AJS.flattenList(elms), function(elm) {
            elm.style.visibility = "hidden";
        });

        this.createElements();
        return false;
    },

    hide: function() {
        var c_bs = this.callback_fns;
        if(c_bs != []) {
            AJS.map(c_bs, function(fn) {
                fn();
            });
        }

        this.onHide();
        if(this.use_fx) {
            var elm = this.overlay;
            AJS.fx.fadeOut(this.overlay, {
                onComplete: function() {
                    AJS.removeElement(elm);
                    elm = null;
                },
                duration: 300
            });
            AJS.removeElement(this.g_window);
        }
        else {
            AJS.removeElement(this.g_window, this.overlay);
        }

        this.removeFrame();

        AJS.REV(window, "scroll", _GB_setOverlayDimension);
        AJS.REV(window, "resize", _GB_update);

        var elms = [AJS.$bytc("object"), AJS.$bytc("select")];
        AJS.map(AJS.flattenList(elms), function(elm) {
            elm.style.visibility = "visible";
        });

        GB_CURRENT = null;

        if(this.reload_on_close)
            window.location.reload();
    },

    update: function() {
        this.setOverlayDimension();
        this.setFrameSize();
        this.setWindowPosition();
    },

    createElements: function() {
        this.initOverlay();

        this.g_window = AJS.DIV({'id': 'GB_window'});
        AJS.hideElement(this.g_window);
        AJS.getBody().insertBefore(this.g_window, this.overlay.nextSibling);

        this.initFrame();
        this.initHook();
        this.update();

        var me = this;
        if(this.use_fx) {
            AJS.fx.fadeIn(this.overlay, {
                duration: 300,
                to: 0.7,
                onComplete: function() {
                    me.onShow();
                    AJS.showElement(me.g_window);
                    me.startLoading();
                }
            });
        }
        else {
            AJS.setOpacity(this.overlay, 0.7);
            AJS.showElement(this.g_window);
            this.onShow();
            this.startLoading();
        }

        AJS.AEV(window, "scroll", _GB_setOverlayDimension);
        AJS.AEV(window, "resize", _GB_update);
    },

    removeFrame: function() {
        try{ AJS.removeElement(this.iframe); }
        catch(e) {}

        this.iframe = null;
    },

    startLoading: function() {
        this.iframe.src = this.src_loader + '?s='+this.salt++;
        AJS.showElement(this.iframe);
    },

    setOverlayDimension: function() {
        var page_size = AJS.getWindowSize();
        if(AJS.isMozilla() || AJS.isOpera())
            AJS.setWidth(this.overlay, "100%");
        else
            AJS.setWidth(this.overlay, page_size.w);

        var max_height = Math.max(AJS.getScrollTop()+page_size.h, AJS.getScrollTop()+this.height);

        if(max_height < AJS.getScrollTop())
            AJS.setHeight(this.overlay, max_height);
        else
            AJS.setHeight(this.overlay, AJS.getScrollTop()+page_size.h);
    },

    initOverlay: function() {
        this.overlay = AJS.DIV({'id': 'GB_overlay'});

        if(this.overlay_click_close)
            AJS.AEV(this.overlay, "click", GB_hide);

        AJS.setOpacity(this.overlay, 0);
        AJS.getBody().insertBefore(this.overlay, AJS.getBody().firstChild);
    },

    initFrame: function() {
        if(!this.iframe) {
            var d = {'name': 'GB_frame', 'class': 'GB_frame', 'frameBorder': 0};
            this.iframe = AJS.IFRAME(d);
            this.middle_cnt = AJS.DIV({'class': 'content'}, this.iframe);

            this.top_cnt = AJS.DIV();
            this.bottom_cnt = AJS.DIV();

            AJS.ACN(this.g_window, this.top_cnt, this.middle_cnt, this.bottom_cnt);
        }
    },

    /* Can be implemented */
    onHide: function() {},
    onShow: function() {},
    setFrameSize: function() {},
    setWindowPosition: function() {},
    initHook: function() {}

});

_GB_update = function() { if(GB_CURRENT) GB_CURRENT.update(); }
_GB_setOverlayDimension = function() { if(GB_CURRENT) GB_CURRENT.setOverlayDimension(); }

AJS.preloadImages(GB_ROOT_DIR+'indicator.gif');

script_loaded = true;
