/*
Last Modified: 29/01/07 14:16:09

AJS JavaScript library
    A very small library with a lot of functionality
AUTHOR
    4mir Salihefendic (http://amix.dk) - amix@amix.dk
LICENSE
    Copyright (c) 2006 Amir Salihefendic. All rights reserved.
    Copyright (c) 2005 Bob Ippolito. All rights reserved.
    http://www.opensource.org/licenses/mit-license.php
VERSION
    3.7
SITE
    http://orangoo.com/AmiNation/AJS
**/
if(!AJS) {
var AJS = {
    BASE_URL: "",

    drag_obj: null,
    drag_elm: null,
    _drop_zones: [],
    _drag_zones: [],
    _cur_pos: null,

    ajaxErrorHandler: null,

////
// General accessor functions
////
    getQueryArgument: function(var_name) {
        var query = window.location.search.substring(1);
        var vars = query.split("&");
        for (var i=0;i<vars.length;i++) {
            var pair = vars[i].split("=");
            if (pair[0] == var_name) {
                return pair[1];
            }
        }
        return null;
    },

    isIe: function() {
        return (navigator.userAgent.toLowerCase().indexOf("msie") != -1 && navigator.userAgent.toLowerCase().indexOf("opera") == -1);
    },
    isNetscape7: function() {
        return (navigator.userAgent.toLowerCase().indexOf("netscape") != -1 && navigator.userAgent.toLowerCase().indexOf("7.") != -1);
    },
    isSafari: function() {
        return (navigator.userAgent.toLowerCase().indexOf("khtml") != -1);
    },
    isOpera: function() {
        return (navigator.userAgent.toLowerCase().indexOf("opera") != -1);
    },
    isMozilla: function() {
        return (navigator.userAgent.toLowerCase().indexOf("gecko") != -1 && navigator.productSub >= 20030210);
    },


////
// Array functions
////
    //Shortcut: AJS.$A
    createArray: function(v) {
        if(AJS.isArray(v) && !AJS.isString(v))
            return v;
        else if(!v)
            return [];
        else
            return [v];
    },

    forceArray: function(args) {
        var r = [];
        AJS.map(args, function(elm) {
            r.push(elm);
        });
        return r;
    },

    join: function(delim, list) {
        try {
            return list.join(delim);
        }
        catch(e) {
            var r = list[0] || '';
            AJS.map(list, function(elm) {
                r += delim + elm;
            }, 1);
            return r + '';
        }
    },

    isIn: function(elm, list) {
        var i = AJS.getIndex(elm, list);
        if(i != -1)
            return true;
        else
            return false;
    },

    getIndex: function(elm, list/*optional*/, eval_fn) {
        for(var i=0; i < list.length; i++)
            if(eval_fn && eval_fn(list[i]) || elm == list[i])
                return i;
        return -1;
    },

    getFirst: function(list) {
        if(list.length > 0)
            return list[0];
        else
            return null;
    },

    getLast: function(list) {
        if(list.length > 0)
            return list[list.length-1];
        else
            return null;
    },

    update: function(l1, l2) {
        for(var i in l2)
            l1[i] = l2[i];
        return l1;
    },

    flattenList: function(list) {
        var r = [];
        var _flatten = function(r, l) {
            AJS.map(l, function(o) {
                if(o == null) {}
                else if (AJS.isArray(o))
                    _flatten(r, o);
                else
                    r.push(o);
            });
        }
        _flatten(r, list);
        return r;
    },


////
// Functional programming
////
    map: function(list, fn,/*optional*/ start_index, end_index) {
        var i = 0, l = list.length;
        if(start_index)
             i = start_index;
        if(end_index)
             l = end_index;
        for(i; i < l; i++)
            fn.apply(null, [list[i], i]);
    },

    rmap: function(list, fn) {
        var i = list.length-1, l = 0;
        for(i; i >= l; i--)
            fn.apply(null, [list[i], i]);
    },

    filter: function(list, fn, /*optional*/ start_index, end_index) {
        var r = [];
        AJS.map(list, function(elm) {
            if(fn(elm))
                r.push(elm);
        }, start_index, end_index);
        return r;
    },

    partial: function(fn) {
        var args = AJS.forceArray(arguments);
        return AJS.$b(fn, null, args.slice(1, args.length).reverse(), false, true);
    },


////
// DOM functions
////
    //Shortcut: AJS.$
    getElement: function(id) {
        if(AJS.isString(id) || AJS.isNumber(id))
            return document.getElementById(id);
        else
            return id;
    },

    //Shortcut: AJS.$$
    getElements: function(/*id1, id2, id3*/) {
        var args = AJS.forceArray(arguments);
        var elements = new Array();
            for (var i = 0; i < args.length; i++) {
                var element = AJS.getElement(args[i]);
                elements.push(element);
            }
            return elements;
    },

    //Shortcut: AJS.$bytc
    getElementsByTagAndClassName: function(tag_name, class_name, /*optional*/ parent) {
        var class_elements = [];
        if(!AJS.isDefined(parent))
            parent = document;
        if(!AJS.isDefined(tag_name))
            tag_name = '*';

        var els = parent.getElementsByTagName(tag_name);
        var els_len = els.length;
        var pattern = new RegExp("(^|\\s)" + class_name + "(\\s|$)");

        for (i = 0, j = 0; i < els_len; i++) {
            if ( pattern.test(els[i].className) || class_name == null ) {
                class_elements[j] = els[i];
                j++;
            }
        }
        return class_elements;
    },

    _nodeWalk: function(elm, tag_name, class_name, fn_next_elm) {
        var p = fn_next_elm(elm);

        var checkFn;
        if(tag_name && class_name) {
            checkFn = function(p) {
                return AJS.nodeName(p) == tag_name && AJS.hasClass(p, class_name);
            }
        }
        else if(tag_name) {
            checkFn = function(p) { return AJS.nodeName(p) == tag_name; }
        }
        else {
            checkFn = function(p) { return AJS.hasClass(p, class_name); }
        }

        while(p) {
            if(checkFn(p))
                return p;
            p = fn_next_elm(p);
        }
        return null;
    },

    getParentBytc: function(elm, tag_name, class_name) {
        return AJS._nodeWalk(elm, tag_name, class_name, function(m) { return m.parentNode; });
    },

    getPreviousSiblingBytc: function(elm, tag_name, class_name) {
        return AJS._nodeWalk(elm, tag_name, class_name, function(m) { return m.previousSibling; });
    },

    getNextSiblingBytc: function(elm, tag_name, class_name) {
        return AJS._nodeWalk(elm, tag_name, class_name, function(m) { return m.nextSibling; });
    },

    //Shortcut: AJS.$f
    getFormElement: function(form, name) {
        form = AJS.$(form);
        var r = null;
        AJS.map(form.elements, function(elm) {
            if(elm.name && elm.name == name)
                r = elm;
        });
        return r;
    },

    formContents: function(form) {
        var form = AJS.$(form);
        var r = {};
        var fn = function(elms) {
            AJS.map(elms, function(e) {
                if(e.name)
                    r[e.name] = e.value || '';
            });
        }
        fn(AJS.$bytc('input', null, form));
        fn(AJS.$bytc('textarea', null, form));
        return r;
    },

    getBody: function() {
        return AJS.$bytc('body')[0]
    },

    nodeName: function(elm) {
        return elm.nodeName.toLowerCase();
    },

    hasParent: function(elm, parent_to_consider, max_look_up) {
        if(elm == parent_to_consider)
            return true;
        if(max_look_up == 0)
            return false;
        return AJS.hasParent(elm.parentNode, parent_to_consider, max_look_up-1);
    },

    isElementHidden: function(elm) {
        return elm.style.visibility == "hidden";
    },

    //Shortcut: AJS.DI
    documentInsert: function(elm) {
        if(typeof(elm) == 'string')
            elm = AJS.HTML2DOM(elm);
        document.write('<span id="dummy_holder"></span>');
        AJS.swapDOM(AJS.$('dummy_holder'), elm);
    },

    cloner: function(element) {
        return function() {
            return element.cloneNode(true);
        }
    },

    appendToTop: function(elm/*, elms...*/) {
        var args = AJS.forceArray(arguments).slice(1);
        if(args.length >= 1) {
            var first_child = elm.firstChild;
            if(first_child) {
                while(true) {
                    var t_elm = args.shift();
                    if(t_elm)
                        AJS.insertBefore(t_elm, first_child);
                    else
                        break;
                }
            }
            else {
                AJS.ACN.apply(null, arguments);
            }
        }
        return elm;
    },

    //Shortcut: AJS.ACN
    appendChildNodes: function(elm/*, elms...*/) {
        if(arguments.length >= 2) {
            AJS.map(arguments, function(n) {
                if(AJS.isString(n))
                    n = AJS.TN(n);
                if(AJS.isDefined(n))
                    elm.appendChild(n);
            }, 1);
        }
        return elm;
    },

    //Shortcut: AJS.RCN
    replaceChildNodes: function(elm/*, elms...*/) {
        var child;
        while ((child = elm.firstChild))
            elm.removeChild(child);
        if (arguments.length < 2)
            return elm;
        else
            return AJS.appendChildNodes.apply(null, arguments);
        return elm;
    },

    insertAfter: function(elm, reference_elm) {
        reference_elm.parentNode.insertBefore(elm, reference_elm.nextSibling);
        return elm;
    },

    insertBefore: function(elm, reference_elm) {
        reference_elm.parentNode.insertBefore(elm, reference_elm);
        return elm;
    },

    showElement: function(/*elms...*/) {
        var args = AJS.forceArray(arguments);
        AJS.map(args, function(elm) { elm.style.display = ''});
    },

    hideElement: function(elm) {
        var args = AJS.forceArray(arguments);
        AJS.map(args, function(elm) { elm.style.display = 'none'});
    },

    swapDOM: function(dest, src) {
        dest = AJS.getElement(dest);
        var parent = dest.parentNode;
        if (src) {
            src = AJS.getElement(src);
            parent.replaceChild(src, dest);
        } else {
            parent.removeChild(dest);
        }
        return src;
    },

    removeElement: function(/*elm1, elm2...*/) {
        var args = AJS.forceArray(arguments);
        AJS.map(args, function(elm) { AJS.swapDOM(elm, null); });
    },

    createDOM: function(name, attrs) {
        var i=0, attr;
        elm = document.createElement(name);

        if(AJS.isDict(attrs[i])) {
            for(k in attrs[0]) {
                attr = attrs[0][k];
                if(k == "style")
                    elm.style.cssText = attr;
                else if(k == "class" || k == 'className')
                    elm.className = attr;
                else {
                    elm.setAttribute(k, attr);
                }
            }
            i++;
        }

        if(attrs[0] == null)
            i = 1;

        AJS.map(attrs, function(n) {
            if(n) {
                if(AJS.isString(n) || AJS.isNumber(n))
                    n = AJS.TN(n);
                elm.appendChild(n);
            }
        }, i);
        return elm;
    },

    _createDomShortcuts: function() {
        var elms = [
                "ul", "li", "td", "tr", "th",
                "tbody", "table", "input", "span", "b",
                "a", "div", "img", "button", "h1",
                "h2", "h3", "br", "textarea", "form",
                "p", "select", "option", "iframe", "script",
                "center", "dl", "dt", "dd", "small",
                "pre"
        ];
        var extends_ajs = function(elm) {
            var c_dom = "return AJS.createDOM.apply(null, ['" + elm + "', arguments]);";
            var c_fun_dom = 'function() { ' + c_dom + '    }';
            eval("AJS." + elm.toUpperCase() + "=" + c_fun_dom);
        }
        AJS.map(elms, extends_ajs);
        AJS.TN = function(text) { return document.createTextNode(text) };
    },

    getCssDim: function(dim) {
        if(AJS.isString(dim))
            return dim;
        else
            return dim + "px";
    },
    getCssProperty: function(elm, prop) {
        elm = AJS.$(elm);
        var y;
        if(elm.currentStyle)
            y = elm.currentStyle[prop];
	else if (window.getComputedStyle)
            y = document.defaultView.getComputedStyle(elm,null).getPropertyValue(prop);
	return y;
    },

    setStyle: function(/*elm1, elm2..., property, new_value*/) {
        var args = AJS.forceArray(arguments);
        var new_val = args.pop();
        var property = args.pop();
        AJS.map(args, function(elm) { 
            elm.style[property] = AJS.getCssDim(new_val);
        });
    },

    setWidth: function(/*elm1, elm2..., width*/) {
        var args = AJS.forceArray(arguments);
        args.splice(args.length-1, 0, 'width');
        AJS.setStyle.apply(null, args);
    },
    setHeight: function(/*elm1, elm2..., height*/) {
        var args = AJS.forceArray(arguments);
        args.splice(args.length-1, 0, 'height');
        AJS.setStyle.apply(null, args);
    },
    setLeft: function(/*elm1, elm2..., left*/) {
        var args = AJS.forceArray(arguments);
        args.splice(args.length-1, 0, 'left');
        AJS.setStyle.apply(null, args);
    },
    setTop: function(/*elm1, elm2..., top*/) {
        var args = AJS.forceArray(arguments);
        args.splice(args.length-1, 0, 'top');
        AJS.setStyle.apply(null, args);
    },
    setClass: function(/*elm1, elm2..., className*/) {
        var args = AJS.forceArray(arguments);
        var c = args.pop();
        AJS.map(args, function(elm) { elm.className = c});
    },
    addClass: function(/*elm1, elm2..., className*/) {
        var args = AJS.forceArray(arguments);
        var cls = args.pop();
        var add_class = function(o) {
            if(!new RegExp("(^|\\s)" + cls + "(\\s|$)").test(o.className))
                o.className += (o.className ? " " : "") + cls;
        };
        AJS.map(args, function(elm) { add_class(elm); });
    },
    hasClass: function(elm, cls) {
        if(!elm.className)
            return false;
        return elm.className == cls || 
               elm.className.search(new RegExp(" " + cls)) != -1
    },
    removeClass: function(/*elm1, elm2..., className*/) {
        var args = AJS.forceArray(arguments);
        var cls = args.pop();
        var rm_class = function(o) {
            o.className = o.className.replace(new RegExp("\\s?" + cls, 'g'), "");
        };
        AJS.map(args, function(elm) { rm_class(elm); });
    },

    setHTML: function(elm, html) {
        elm.innerHTML = html;
        return elm;
    },

    RND: function(tmpl, ns, scope) {
        scope = scope || window;
        var fn = function(w, g) {
            g = g.split("|");
            var cnt = ns[g[0]];
            for(var i=1; i < g.length; i++)
                cnt = scope[g[i]](cnt);
            if(cnt == '')
                return '';
            if(cnt == 0 || cnt == -1)
                cnt += '';
            return cnt || w;
        };
        return tmpl.replace(/%\(([A-Za-z0-9_|.]*)\)/g, fn);
    },

    HTML2DOM: function(html,/*optional*/ first_child) {
        var d = AJS.DIV();
        d.innerHTML = html;
        if(first_child)
            return d.childNodes[0];
        else
            return d;
    },

    preloadImages: function(/*img_src1, ..., img_srcN*/) {
        AJS.AEV(window, 'load', AJS.$p(function(args) {
            AJS.map(args, function(src) {
                var pic = new Image();
                pic.src = src;
            });
        }, arguments));
    },


////
// Effects
////
    setOpacity: function(elm, p) {
        elm.style.opacity = p;
        elm.style.filter = "alpha(opacity="+ p*100 +")";
    },


////
// Ajax functions
////
    getXMLHttpRequest: function() {
        var try_these = [
            function () { return new XMLHttpRequest(); },
            function () { return new ActiveXObject('Msxml2.XMLHTTP'); },
            function () { return new ActiveXObject('Microsoft.XMLHTTP'); },
            function () { return new ActiveXObject('Msxml2.XMLHTTP.4.0'); },
            function () { throw "Browser does not support XMLHttpRequest"; }
        ];
        for (var i = 0; i < try_these.length; i++) {
            var func = try_these[i];
            try {
                return func();
            } catch (e) {
            }
        }
    },

    getRequest: function(url, data, type) {
        if(!type)
            type = "POST";
        var req = AJS.getXMLHttpRequest();

        if(url.indexOf("http://") == -1) {
            if(AJS.BASE_URL != '') {
                if(AJS.BASE_URL.lastIndexOf('/') != AJS.BASE_URL.length-1)
                    AJS.BASE_URL += '/';
                url = AJS.BASE_URL + url;
            }
            else
                url = window.location + url;
        }

        req.open(type, url, true);
        if(type == "POST")
            req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        return AJS._sendXMLHttpRequest(req);
    },

    _sendXMLHttpRequest: function(req, data) {
        var d = new AJSDeferred(req);

        var onreadystatechange = function () {
            if (req.readyState == 4) {
                var status = '';
                try {
                    status = req.status;
                }
                catch(e) {};
                if(status == 200 || status == 304 || req.responseText == null) {
                    d.callback();
                }
                else {
                    if(AJS.ajaxErrorHandler)
                        AJS.ajaxErrorHandler(req.responseText, req);
                    else 
                        d.errback();
                }
            }
        }
        req.onreadystatechange = onreadystatechange;
        return d;
    },

    _reprString: function(o) {
        return ('"' + o.replace(/(["\\])/g, '\\$1') + '"'
        ).replace(/[\f]/g, "\\f"
        ).replace(/[\b]/g, "\\b"
        ).replace(/[\n]/g, "\\n"
        ).replace(/[\t]/g, "\\t"
        ).replace(/[\r]/g, "\\r");
    },

    serializeJSON: function(o) {
        var objtype = typeof(o);
        if (objtype == "undefined") {
            return "undefined";
        } else if (objtype == "number" || objtype == "boolean") {
            return o + "";
        } else if (o === null) {
            return "null";
        }
        if (objtype == "string") {
            return AJS._reprString(o);
        }
        var me = arguments.callee;
        if (objtype != "function" && typeof(o.length) == "number") {
            var res = [];
            for (var i = 0; i < o.length; i++) {
                var val = me(o[i]);
                if (typeof(val) != "string") {
                    val = "undefined";
                }
                res.push(val);
            }
            return "[" + res.join(",") + "]";
        }
        // it's a function with no adapter, bad
        if (objtype == "function")
            return null;
        res = [];
        for (var k in o) {
            var useKey;
            if (typeof(k) == "number") {
                useKey = '"' + k + '"';
            } else if (typeof(k) == "string") {
                useKey = AJS._reprString(k);
            } else {
                // skip non-string or number keys
                continue;
            }
            val = me(o[k]);
            if (typeof(val) != "string") {
                // skip non-serializable values
                continue;
            }
            res.push(useKey + ":" + val);
        }
        return "{" + res.join(",") + "}";
    },

    loadJSONDoc: function(url) {
        var d = AJS.getRequest(url);
        var eval_req = function(data, req) {
            var text = req.responseText;
            if(text == "Error")
                d.errback(req);
            else
                return AJS.evalTxt(text);
        };
        d.addCallback(eval_req);
        return d;
    },

    evalTxt: function(txt) {
        try {
            return eval('('+ txt + ')');
        }
        catch(e) {
            return eval(txt);
        }
    },

    evalScriptTags: function(html) {
        var script_data = html.match(/<script.*?>((\n|\r|.)*?)<\/script>/g);
        if(script_data != null) {
            for(var i=0; i < script_data.length; i++) {
                var script_only = script_data[i].replace(/<script.*?>/g, "");
                script_only = script_only.replace(/<\/script>/g, "");
                eval(script_only);
            }
        }
    },

    queryArguments: function(data) {
        var post_data = [];
        for(k in data)
            post_data.push(k + "=" + AJS.urlencode(data[k]));
        return post_data.join("&");
    },


////
// Position and size
////
    getMousePos: function(e) {
        var posx = 0;
        var posy = 0;
        if (!e) var e = window.event;
        if (e.pageX || e.pageY)
        {
            posx = e.pageX;
            posy = e.pageY;
        }
        else if (e.clientX || e.clientY)
        {
            posx = e.clientX + document.body.scrollLeft;
            posy = e.clientY + document.body.scrollTop;
        }
        return {x: posx, y: posy};
    },

    getScrollTop: function() {
        //From: http://www.quirksmode.org/js/doctypes.html
        var t;
        if (document.documentElement && document.documentElement.scrollTop)
                t = document.documentElement.scrollTop;
        else if (document.body)
                t = document.body.scrollTop;
        return t;
    },

    absolutePosition: function(elm) {
        var posObj = {'x': elm.offsetLeft, 'y': elm.offsetTop};
        if(elm.offsetParent) {
            var temp_pos = AJS.absolutePosition(elm.offsetParent);
            posObj.x += temp_pos.x;
            posObj.y += temp_pos.y;
        }
        // safari bug
        if (AJS.isSafari() && elm.style.position == 'absolute' ) {
            posObj.x -= document.body.offsetLeft;
            posObj.y -= document.body.offsetTop;
        }
        return posObj;
    },

    getWindowSize: function(doc) {
        doc = doc || document;
        var win_w, win_h;
        if (self.innerHeight) {
            win_w = self.innerWidth;
            win_h = self.innerHeight;
        } else if (doc.documentElement && doc.documentElement.clientHeight) {
            win_w = doc.documentElement.clientWidth;
            win_h = doc.documentElement.clientHeight;
        } else if (doc.body) {
            win_w = doc.body.clientWidth;
            win_h = doc.body.clientHeight;
        }
        return {'w': win_w, 'h': win_h};
    },

    isOverlapping: function(elm1, elm2) {
        var pos_elm1 = AJS.absolutePosition(elm1);
        var pos_elm2 = AJS.absolutePosition(elm2);

        var top1 = pos_elm1.y;
        var left1 = pos_elm1.x;
        var right1 = left1 + elm1.offsetWidth;
        var bottom1 = top1 + elm1.offsetHeight;
        var top2 = pos_elm2.y;
        var left2 = pos_elm2.x;
        var right2 = left2 + elm2.offsetWidth;
        var bottom2 = top2 + elm2.offsetHeight;
        var getSign = function(v) {
            if(v > 0) return "+";
            else if(v < 0) return "-";
            else return 0;
        }

        if ((getSign(top1 - bottom2) != getSign(bottom1 - top2)) &&
                (getSign(left1 - right2) != getSign(right1 - left2)))
            return true;
        return false;
    },


////
// Events
////
    getEventElm: function(e) {
        if(e && !e.type && !e.keyCode)
            return e
        var targ;
        if (!e) var e = window.event;
        if (e.target) targ = e.target;
        else if (e.srcElement) targ = e.srcElement;
        if (targ.nodeType == 3) // defeat Safari bug
            targ = targ.parentNode;
        return targ;
    },

    _getRealScope: function(fn, /*optional*/ extra_args, dont_send_event, rev_extra_args) {
        var scope = window;
        extra_args = AJS.$A(extra_args);
        if(fn._cscope)
            scope = fn._cscope;

        return function() {
            //Append all the orginal arguments + extra_args
            var args = [];
            var i = 0;
            if(dont_send_event)
                i = 1;

            AJS.map(arguments, function(arg) { args.push(arg) }, i);
            args = args.concat(extra_args);
            if(rev_extra_args)
                args = args.reverse();
            return fn.apply(scope, args);
        };
    },

    _unloadListeners: function() {
        if(AJS.listeners)
            AJS.map(AJS.listeners, function(elm, type, fn) { AJS.REV(elm, type, fn) });
        AJS.listeners = [];
    },

    setEventKey: function(e) {
        e.key = e.keyCode ? e.keyCode : e.charCode;

        if(window.event) {
            e.ctrl = window.event.ctrlKey;
            e.shift = window.event.shiftKey;
        }
        else {
            e.ctrl = e.ctrlKey;
            e.shift = e.shiftKey;
        }
        switch(e.key) {
            case 63232:
                e.key = 38;
                break;
            case 63233:
                e.key = 40;
                break;
            case 63235:
                e.key = 39;
                break;
            case 63234:
                e.key = 37;
                break;
        }
    },

    //Shortcut: AJS.AEV
    addEventListener: function(elm, type, fn, /*optional*/listen_once, cancle_bubble) {
        if(!cancle_bubble)
            cancle_bubble = false;

        var elms = AJS.$A(elm);
        AJS.map(elms, function(elmz) {
            if(listen_once)
                fn = AJS._listenOnce(elmz, type, fn);
            
            //Hack since it does not work in all browsers
            if(AJS.isIn(type, ['submit', 'load', 'scroll', 'resize'])) {
                var old = elm['on' + type];
                elm['on' + type] = function() {
                    if(old) {
                        fn(arguments);
                        return old(arguments);
                    }
                    else
                        return fn(arguments);
                };
                return;
            }

            //Fix keyCode
            if(AJS.isIn(type, ['keypress', 'keydown', 'keyup', 'click'])) {
                var old_fn = fn;
                fn = function(e) {
                    AJS.setEventKey(e);
                    return old_fn.apply(null, arguments);
                }
            }

            if (elmz.attachEvent) {
                //FIXME: We ignore cancle_bubble for IE... could be a problem?
                elmz.attachEvent("on" + type, fn);
            }
            else if(elmz.addEventListener)
                elmz.addEventListener(type, fn, cancle_bubble);

            AJS.listeners = AJS.$A(AJS.listeners);
            AJS.listeners.push([elmz, type, fn]);
        });
    },

    //Shortcut: AJS.REV
    removeEventListener: function(elm, type, fn, /*optional*/cancle_bubble) {
        if(!cancle_bubble)
            cancle_bubble = false;
        if(elm.removeEventListener) {
            elm.removeEventListener(type, fn, cancle_bubble);
            if(AJS.isOpera())
                elm.removeEventListener(type, fn, !cancle_bubble);
        }
        else if(elm.detachEvent)
            elm.detachEvent("on" + type, fn);
    },

    //Shortcut: AJS.$b
    bind: function(fn, scope, /*optional*/ extra_args, dont_send_event, rev_extra_args) {
        fn._cscope = scope;
        return AJS._getRealScope(fn, extra_args, dont_send_event, rev_extra_args);
    },

    bindMethods: function(self) {
        for (var k in self) {
            var func = self[k];
            if (typeof(func) == 'function') {
                self[k] = AJS.$b(func, self);
            }
        }
    },

    _listenOnce: function(elm, type, fn) {
        var r_fn = function() {
            AJS.removeEventListener(elm, type, r_fn);
            fn(arguments);
        }
        return r_fn;
    },

    callLater: function(fn, interval) {
        var fn_no_send = function() {
            fn();
        };
        window.setTimeout(fn_no_send, interval);
    },

    preventDefault: function(e) {
        if(AJS.isIe()) 
            window.event.returnValue = false;
        else 
            e.preventDefault();
    },


////
// Drag and drop
////
    dragAble: function(elm, /*optional*/ handler, args) {
        if(!args)
            args = {};
        if(!AJS.isDefined(args['move_x']))
            args['move_x'] = true;
        if(!AJS.isDefined(args['move_y']))
            args['move_y'] = true;
        if(!AJS.isDefined(args['moveable']))
            args['moveable'] = false;
        if(!AJS.isDefined(args['hide_on_move']))
            args['hide_on_move'] = true;
        if(!AJS.isDefined(args['on_mouse_up']))
            args['on_mouse_up'] = null;
        if(!AJS.isDefined(args['cursor']))
            args['cursor'] = 'move';
        if(!AJS.isDefined(args['max_move']))
            args['max_move'] = {'top': null, 'left': null};

        elm = AJS.$(elm);

        if(!handler)
            handler = elm;

        handler = AJS.$(handler);
        var old_cursor = handler.style.cursor;
        handler.style.cursor = args['cursor'];
        elm.style.position = 'relative';

        AJS.addClass(handler, '_ajs_handler');
        handler._args = args;
        handler._elm = elm;
        AJS.AEV(handler, 'mousedown', AJS._dragStart);
    },

    _dragStart: function(e) {
        var handler = AJS.getEventElm(e);
        if(!AJS.hasClass(handler, '_ajs_handler')) {
            handler = AJS.getParentBytc(handler, null, '_ajs_handler');
        }
        if(handler)
            AJS._dragInit(e, handler._elm, handler._args);
    },

    dropZone: function(elm, args) {
        elm = AJS.$(elm);
        var item = {elm: elm};
        AJS.update(item, args);
        AJS._drop_zones.push(item);
    },

    removeDragAble: function(elm) {
        AJS.REV(elm, 'mousedown', AJS._dragStart);
        elm.style.cursor = '';
    },

    removeDropZone: function(elm) {
        var i = AJS.getIndex(elm, AJS._drop_zones, function(item) {
            if(item.elm == elm) return true;
        });
        if(i != -1) {
            AJS._drop_zones.splice(i, 1);
        }
    },

    _dragInit: function(e, click_elm, args) {
        AJS.drag_obj = new Object();
        AJS.drag_obj.args = args;

        AJS.drag_obj.click_elm = click_elm;
        AJS.drag_obj.mouse_pos = AJS.getMousePos(e);
        AJS.drag_obj.click_elm_pos = AJS.absolutePosition(click_elm);

        AJS.AEV(document, 'mousemove', AJS._dragMove, false, true);
        AJS.AEV(document, 'mouseup', AJS._dragStop, false, true);

        if (AJS.isIe())
            window.event.cancelBubble = true;
        AJS.preventDefault(e);
    },

    _initDragElm: function(elm) {
        if(AJS.drag_elm && AJS.drag_elm.style.display == 'none')
            AJS.removeElement(AJS.drag_elm);

        if(!AJS.drag_elm) {
            AJS.drag_elm = AJS.DIV();
            var d = AJS.drag_elm;
            AJS.insertBefore(d, AJS.getBody().firstChild);
            AJS.setHTML(d, elm.innerHTML);

            d.className = elm.className;
            d.style.cssText = elm.style.cssText;

            d.style.position = 'absolute';
            d.style.zIndex = 10000;

            var t = AJS.absolutePosition(elm);
            AJS.setTop(d, t.y);
            AJS.setLeft(d, t.x);

            if(AJS.drag_obj.args.on_init) {
                AJS.drag_obj.args.on_init(elm);
            }
        }
    },

    _dragMove: function(e) {
        var drag_obj = AJS.drag_obj;
        var click_elm = drag_obj.click_elm;

        AJS._initDragElm(click_elm);
        var drag_elm = AJS.drag_elm;

        if(drag_obj.args['hide_on_move'])
            click_elm.style.visibility = 'hidden';

        var cur_pos = AJS.getMousePos(e);

        var mouse_pos = drag_obj.mouse_pos;

        var click_elm_pos = drag_obj.click_elm_pos;

        AJS.map(AJS._drop_zones, function(d_z) {
            if(AJS.isOverlapping(d_z['elm'], drag_elm)) {
                if(d_z['elm'] != drag_elm) {
                    var on_hover = d_z['on_hover'];
                    if(on_hover)
                        on_hover(d_z['elm'], click_elm, drag_elm);
                }
            }
        });

        if(drag_obj.args['on_drag'])
            drag_obj.args['on_drag'](click_elm, e);

        var max_move_top = drag_obj.args['max_move']['top'];
        var max_move_left = drag_obj.args['max_move']['left'];
        var p;
        if(drag_obj.args['move_x']) {
            p = cur_pos.x - (mouse_pos.x - click_elm_pos.x);
            if(max_move_left == null || max_move_left <= p)
                AJS.setLeft(elm, p);
        }

        if(drag_obj.args['move_y']) {
            p = cur_pos.y - (mouse_pos.y - click_elm_pos.y);
            if(max_move_top == null || max_move_top <= p)
                AJS.setTop(elm, p);
        }
        if(AJS.isIe()) {
            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }
        else
            e.preventDefault();
    },

    _dragStop: function(e) {
        var drag_obj = AJS.drag_obj;
        var drag_elm = AJS.drag_elm;
        var click_elm = drag_obj.click_elm;

        AJS.REV(document, "mousemove", AJS._dragMove, true);
        AJS.REV(document, "mouseup", AJS._dragStop, true);

        var dropped = false;
        AJS.map(AJS._drop_zones, function(d_z) {
            if(AJS.isOverlapping(d_z['elm'], click_elm)) {
                if(d_z['elm'] != click_elm) {
                    var on_drop = d_z['on_drop'];
                    if(on_drop) {
                        dropped = true;
                        on_drop(d_z['elm'], click_elm);
                    }
                }
            }
        });

        if(drag_obj.args['moveable']) {
            var t = parseInt(click_elm.style.top) || 0;
            var l = parseInt(click_elm.style.left) || 0;
            var drag_elm_xy = AJS.absolutePosition(drag_elm);
            var click_elm_xy = AJS.absolutePosition(click_elm);
            AJS.setTop(click_elm, t + drag_elm_xy.y - click_elm_xy.y);
            AJS.setLeft(click_elm, l + drag_elm_xy.x - click_elm_xy.x);
        }

        if(!dropped && drag_obj.args['on_mouse_up'])
            drag_obj.args['on_mouse_up'](click_elm, e);

        if(drag_obj.args['hide_on_move'])
            drag_obj.click_elm.style.visibility = 'visible';

        if(drag_obj.args.on_end) {
            drag_obj.args.on_end(click_elm);
        }

        AJS._dragObj = null;
        if(drag_elm)
            AJS.hideElement(drag_elm);
        AJS.drag_elm = null;
    },


////
// Misc.
////
    keys: function(obj) {
        var rval = [];
        for (var prop in obj) {
            rval.push(prop);
        }
        return rval;
    },

    values: function(obj) {
        var rval = [];
        for (var prop in obj) {
            rval.push(obj[prop]);
        }
        return rval;
    },

    urlencode: function(str) {
        return encodeURIComponent(str.toString());
    },

    isDefined: function(o) {
        return (o != "undefined" && o != null)
    },

    isArray: function(obj) {
        return obj instanceof Array;
    },

    isString: function(obj) {
        return (typeof obj == 'string');
    },

    isNumber: function(obj) {
        return (typeof obj == 'number');
    },

    isObject: function(obj) {
        return (typeof obj == 'object');
    },

    isFunction: function(obj) {
        return (typeof obj == 'function');
    },

    isDict: function(o) {
        var str_repr = String(o);
        return str_repr.indexOf(" Object") != -1;
    },

    exportToGlobalScope: function() {
        for(e in AJS)
            eval(e + " = AJS." + e);
    },

    log: function(o) {
        if(AJS.isMozilla())
            console.log(o);
        else {
            var div = AJS.DIV({'style': 'color: green'});
            AJS.ACN(AJS.getBody(), AJS.setHTML(div, ''+o));
        }
    }

}

AJS.Class = function(members) {
    var fn = function() {
        if(arguments[0] != 'no_init') {
            return this.init.apply(this, arguments);
        }
    }
    fn.prototype = members;
    AJS.update(fn, AJS.Class.prototype);
    return fn;
}
AJS.Class.prototype = {
    extend: function(members) {
        var parent = new this('no_init');
        for(k in members) {
            var prev = parent[k];
            var cur = members[k];
            if (prev && prev != cur && typeof cur == 'function') {
                cur = this._parentize(cur, prev);
            }
            parent[k] = cur;
        }
        return new AJS.Class(parent);
    },

    implement: function(members) {
        AJS.update(this.prototype, members);
    },

    _parentize: function(cur, prev) {
        return function(){
            this.parent = prev;
            return cur.apply(this, arguments);
        }
    }
};

//Shortcuts
AJS.$ = AJS.getElement;
AJS.$$ = AJS.getElements;
AJS.$f = AJS.getFormElement;
AJS.$b = AJS.bind;
AJS.$p = AJS.partial;
AJS.$FA = AJS.forceArray;
AJS.$A = AJS.createArray;
AJS.DI = AJS.documentInsert;
AJS.ACN = AJS.appendChildNodes;
AJS.RCN = AJS.replaceChildNodes;
AJS.AEV = AJS.addEventListener;
AJS.REV = AJS.removeEventListener;
AJS.$bytc = AJS.getElementsByTagAndClassName;

AJSDeferred = function(req) {
    this.callbacks = [];
    this.errbacks = [];
    this.req = req;
}
AJSDeferred.prototype = {
    excCallbackSeq: function(req, list) {
        var data = req.responseText;
        while (list.length > 0) {
            var fn = list.pop();
            var new_data = fn(data, req);
            if(new_data)
                data = new_data;
        }
    },

    callback: function () {
        this.excCallbackSeq(this.req, this.callbacks);
    },

    errback: function() {
        if(this.errbacks.length == 0)
            alert("Error encountered:\n" + this.req.responseText);

        this.excCallbackSeq(this.req, this.errbacks);
    },

    addErrback: function(fn) {
        this.errbacks.unshift(fn);
    },

    addCallback: function(fn) {
        this.callbacks.unshift(fn);
    },

    addCallbacks: function(fn1, fn2) {
        this.addCallback(fn1);
        this.addErrback(fn2);
    },

    sendReq: function(data) {
        if(AJS.isObject(data)) {
            this.req.send(AJS.queryArguments(data));
        }
        else if(AJS.isDefined(data))
            this.req.send(data);
        else {
            this.req.send("");
        }
    }
};

//Prevent memory-leaks
AJS.addEventListener(window, 'unload', AJS._unloadListeners);
AJS._createDomShortcuts()
}

script_loaded = true;
