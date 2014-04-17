GB_showFullScreenSet = function(set, start_index, callback_fn) {
    var options = {
        type: 'page',
        fullscreen: true,
        center_win: false
    }
    var gb_sets = new GB_Sets(options, set);
    gb_sets.addCallback(callback_fn);
    gb_sets.showSet(start_index-1);
    return false;
}

GB_showImageSet = function(set, start_index, callback_fn) {
    var options = {
        type: 'image',
        fullscreen: false,
        center_win: true,
        width: 300,
        height: 300
    }
    var gb_sets = new GB_Sets(options, set);
    gb_sets.addCallback(callback_fn);
    gb_sets.showSet(start_index-1);
    return false;
}

GB_Sets = GB_Gallery.extend({
    init: function(options, set) {
        this.parent(options);
        if(!this.img_next) this.img_next = this.root_dir + 'next.gif';
        if(!this.img_prev) this.img_prev = this.root_dir + 'prev.gif';
        this.current_set = set; 
    },

    showSet: function(start_index) {
        this.current_index = start_index;

        var item = this.current_set[this.current_index];
        this.show(item.url);
        this._setCaption(item.caption);

        this.btn_prev = AJS.IMG({'class': 'left', src: this.img_prev});
        this.btn_next = AJS.IMG({'class': 'right', src: this.img_next});

        AJS.AEV(this.btn_prev, 'click', AJS.$b(this.switchPrev, this));
        AJS.AEV(this.btn_next, 'click', AJS.$b(this.switchNext, this));

        GB_STATUS = AJS.SPAN({'class': 'GB_navStatus'});
        AJS.ACN(AJS.$('GB_middle'), this.btn_prev, GB_STATUS, this.btn_next);
        
        this.updateStatus();
    },

    updateStatus: function() {
        AJS.setHTML(GB_STATUS, (this.current_index + 1) + ' / ' + this.current_set.length);
        if(this.current_index == 0) {
            AJS.addClass(this.btn_prev, 'disabled');
        }
        else {
            AJS.removeClass(this.btn_prev, 'disabled');
        }

        if(this.current_index == this.current_set.length-1) {
            AJS.addClass(this.btn_next, 'disabled');
        }
        else {
            AJS.removeClass(this.btn_next, 'disabled');
        }
    },

    _setCaption: function(caption) {
        AJS.setHTML(AJS.$('GB_caption'), caption);
    },

    updateFrame: function() {
        var item = this.current_set[this.current_index];
        this._setCaption(item.caption);
        this.url = item.url;
        this.startLoading();
    },

    switchPrev: function() {
        if(this.current_index != 0) {
            this.current_index--;
            this.updateFrame();
            this.updateStatus();
        }
    },

    switchNext: function() {
        if(this.current_index != this.current_set.length-1) {
            this.current_index++
            this.updateFrame();
            this.updateStatus();
        }
    }
});

AJS.AEV(window, 'load', function() {
    AJS.preloadImages(GB_ROOT_DIR+'next.gif', GB_ROOT_DIR+'prev.gif');
});
