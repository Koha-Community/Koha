/*
Last Modified: 25/12/06 18:26:30

AJS effects
    A very small library with a lot of functionality
AUTHOR
    4mir Salihefendic (http://amix.dk) - amix@amix.dk
LICENSE
    Copyright (c) 2006 Amir Salihefendic. All rights reserved.
    Copyright (c) 2005 Bob Ippolito. All rights reserved.
    Copyright (c) 2006 Valerio Proietti, http://www.mad4milk.net
    http://www.opensource.org/licenses/mit-license.php
VERSION
    3.6
SITE
    http://orangoo.com/AmiNation/AJS
**/
AJS.fx = {
    _shades: {0: 'ffffff', 1: 'ffffee', 2: 'ffffdd',
              3: 'ffffcc', 4: 'ffffbb', 5: 'ffffaa',
              6: 'ffff99'},

    highlight: function(elm, options) {
        var base = new AJS.fx.Base();
        base.elm = AJS.$(elm);
        base.setOptions(options);
        base.options.duration = 600;

        AJS.update(base, {
            increase: function(){
                if(this.now == 7)
                    elm.style.backgroundColor = 'transparent';
                else
                    elm.style.backgroundColor = '#' + AJS.fx._shades[Math.floor(this.now)];
            }
        });
        return base.custom(6, 0);
    },

    fadeIn: function(elm, options) {
        options = options || {};
        if(!options.from) {
            options.from = 0;
            AJS.setOpacity(elm, 0);
        }
        if(!options.to) options.to = 1;
        var s = new AJS.fx.Style(elm, 'opacity', options);
        return s.custom(options.from, options.to);
    },

    fadeOut: function(elm, options) {
        options = options || {};
        if(!options.from) options.from = 1;
        if(!options.to) options.to = 0;
        options.duration = 300;
        var s = new AJS.fx.Style(elm, 'opacity', options);
        return s.custom(options.from, options.to);
    },
    
    setWidth: function(elm, options) {
        var s = new AJS.fx.Style(elm, 'width', options);
        return s.custom(options.from, options.to);
    },

    setHeight: function(elm, options) {
        var s = new AJS.fx.Style(elm, 'height', options);
        return s.custom(options.from, options.to);
    }
}


//From moo.fx
AJS.fx.Base = new AJS.Class({
    init: function() {
        AJS.bindMethods(this);
    },

    setOptions: function(options){
        this.options = AJS.update({
                onStart: function(){},
                onComplete: function(){},
                transition: AJS.fx.Transitions.sineInOut,
                duration: 500,
                wait: true,
                fps: 50
        }, options || {});
    },

    step: function(){
        var time = new Date().getTime();
        if (time < this.time + this.options.duration){
            this.cTime = time - this.time;
            this.setNow();
        } else {
            setTimeout(AJS.$b(this.options.onComplete, this, [this.elm]), 10);
            this.clearTimer();
            this.now = this.to;
        }
        this.increase();
    },

    setNow: function(){
        this.now = this.compute(this.from, this.to);
    },

    compute: function(from, to){
        var change = to - from;
        return this.options.transition(this.cTime, from, change, this.options.duration);
    },

    clearTimer: function(){
        clearInterval(this.timer);
        this.timer = null;
        return this;
    },

    _start: function(from, to){
        if (!this.options.wait) this.clearTimer();
        if (this.timer) return;
        setTimeout(AJS.$p(this.options.onStart, this.elm), 10);
        this.from = from;
        this.to = to;
        this.time = new Date().getTime();
        this.timer = setInterval(this.step, Math.round(1000/this.options.fps));
        return this;
    },

    custom: function(from, to){
        return this._start(from, to);
    },

    set: function(to){
        this.now = to;
        this.increase();
        return this;
    },

    setStyle: function(elm, property, val) {
        if(this.property == 'opacity')
            AJS.setOpacity(elm, val);
        else
            AJS.setStyle(elm, property, val);
    }
});

AJS.fx.Style = AJS.fx.Base.extend({
    init: function(elm, property, options) {
        this.parent();
        this.elm = elm;
        this.setOptions(options);
        this.property = property;
    },

    increase: function(){
        this.setStyle(this.elm, this.property, this.now);
    }
});

AJS.fx.Styles = AJS.fx.Base.extend({
    init: function(elm, options){
        this.parent();
        this.elm = AJS.$(elm);
        this.setOptions(options);
        this.now = {};
    },

    setNow: function(){
        for (p in this.from) 
            this.now[p] = this.compute(this.from[p], this.to[p]);
    },

    custom: function(obj){
        if (this.timer && this.options.wait) return;
        var from = {};
        var to = {};
        for (p in obj){
                from[p] = obj[p][0];
                to[p] = obj[p][1];
        }
        return this._start(from, to);
    },

    increase: function(){
        for (var p in this.now) this.setStyle(this.elm, p, this.now[p]);
    }
});

//Transitions (c) 2003 Robert Penner (http://www.robertpenner.com/easing/), BSD License.
AJS.fx.Transitions = {
    linear: function(t, b, c, d) { return c*t/d + b; },
    sineInOut: function(t, b, c, d) { return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b; }
};

script_loaded = true;
