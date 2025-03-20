/*
 * Plugin dealing with the Google API based on jQuery autofill plugin
 * https://plugins.jquery.com/autofill/
 *
 * Automatically fills form inputs with relevant data based on search result
 * Modified for OPAC Suggestion form
 */

(function ($) {
    function typeString(o) {
        if (typeof o != "object") return typeof o;

        if (o === null) return "null";

        //object, array, function, date, regexp, string, number, boolean, error
        var internalClass = Object.prototype.toString
            .call(o)
            .match(/\[object\s(\w+)\]/)[1];

        return internalClass.toLowerCase();
    }

    var AutoFiller = function (elm, fields, type) {
        var self = this;
        self.type = type;
        self.$elm = $(elm);
        self.fields = fields;

        var MSG_UNDO_AUTOFILL_SUGGESTION = __("Clear form");
        var MSG_SEARCH_GOOGLE_BOOKS = __("Search Google Books");

        /* decorate element as autofiller */
        self.$undo = $(
            '<input type="button" class="btn btn-info btn-sm" style="display:none;margin-left:5px;" value="' +
                MSG_UNDO_AUTOFILL_SUGGESTION +
                '" />'
        );
        self.$fillbtn = $(
            '<input type="button" class="btn btn-primary btn-sm" value="' +
                MSG_SEARCH_GOOGLE_BOOKS +
                '" />'
        );
        self.$error = $(
            '<span class="add-on" style="display:none;padding-left:5px;"></span>'
        );
        self.$elm.after(self.$error);
        self.$elm.after(self.$undo);
        self.$elm.after(self.$fillbtn);

        for (var key in fields) {
            if (fields.hasOwnProperty(key) && typeof fields[key] === "object") {
                var $target = $("#" + self.fields[key].target);
                self.fields[key].$target = $target;
            }
        }

        self.$fillbtn.click(function () {
            /* clear fields first */
            for (var key in self.fields) {
                var field = self.fields[key];
                field.$target.trigger("autofill-undo");
            }
            /* only allow forced update once every second */
            if (Date.now() - self.lastupdate > 1000) {
                self.$elm.trigger("change");
            }
        });

        self.$undo.click(function () {
            for (var key in self.fields) {
                var field = self.fields[key];
                //field.$target.val("");
                field.$target.trigger("autofill-undo");
            }
            $(":input[type='text']").each(function () {
                $(this).val("");
            });
            self.$undo.hide();
        });

        self.$elm.change(function () {
            self.lastupdate = Date.now();
            self.$error.html("");
            self.$error.hide();
            /* give user some feedback that the request is in progress */
            self.$fillbtn.fadeOut(1000).fadeIn(1000);
            if (self.$elm.val()) {
                var gAPI = "https://www.googleapis.com/books/v1/volumes?q=";
                gAPI += self.$elm.val().replace(/\-/g, "");
                gAPI += "&maxResults=1";
                $.getJSON(gAPI, function (response) {
                    if (response.totalItems == 0) {
                        self.$error.html(__("Sorry, nothing found."));
                        self.$error.show();
                        return;
                    }

                    var undos = 0;
                    var item = response.items[0];
                    for (var key in self.fields) {
                        var filled = false;
                        var value = eval("item." + key);
                        var field = self.fields[key];

                        /* field handled by caller */
                        if ("handle" in field) {
                            if (typeof field.handle === "function")
                                field.handle(field.$target, value);

                            continue; /* next please */
                        }

                        /* wouldn't know what to do with result unless we have a
                         * target */
                        if (!field.$target) continue;

                        /* format copyrightdate */
                        if (field.target == "copyrightdate") {
                            if (value.indexOf("-") > -1) {
                                var hyphenIndex = value.indexOf("-");
                                var newval = value.slice(0, hyphenIndex);
                                value = newval;
                            }
                        }

                        /* handle differently depending on datatype */
                        switch (typeString(value)) {
                            case "array":
                                switch (
                                    field.$target.prop("nodeName").toUpperCase()
                                ) {
                                    case "TEXTAREA":
                                        undos++;
                                        field.$target.bind(
                                            "autofill-undo",
                                            field.$target.text(),
                                            function (e) {
                                                $(this).text(e.data);
                                            }
                                        );
                                        field.$target.text(value.join(", "));
                                        break;
                                    case "INPUT":
                                    default:
                                        undos++;
                                        field.$target.bind(
                                            "autofill-undo",
                                            field.$target.val(),
                                            function (e) {
                                                $(this).val(e.data);
                                            }
                                        );
                                        field.$target.val(value.join(", "));
                                        break;
                                }
                                break;
                            default:
                                switch (
                                    field.$target.prop("nodeName").toUpperCase()
                                ) {
                                    case "TEXTAREA":
                                        undos++;
                                        field.$target.bind(
                                            "autofill-undo",
                                            field.$target.text(),
                                            function (e) {
                                                $(this).text(e.data);
                                            }
                                        );
                                        field.$target.text(value);
                                        break;
                                    case "SELECT":
                                    case "INPUT":
                                    default:
                                        undos++;
                                        field.$target.bind(
                                            "autofill-undo",
                                            field.$target.val(),
                                            function (e) {
                                                $(this).val(e.data);
                                            }
                                        );
                                        field.$target.val(value);
                                        break;
                                }
                        }

                        switch (field.effect) {
                            case "flash":
                                field.$target.fadeOut(500).fadeIn(500);
                                break;
                        }
                    }

                    if (undos > 0) self.$undo.show();
                });
            }
        });
    };

    /*
     * @fields object: Google Books API item properties map for
     *                 mapping against a target element. Expected
     *                 type:
     *                 {
     *                  GoogleBooksItem.property: {target: ELEM,
     *                                             handle: function(target, value),
     *                                             effect: jQuery effects,
     *                                            }
     *                 }
     *
     *                 "target" is optional and if specified alone (i.e no
     *                 handle property) autofill will automatically fill this
     *                 target element with returned data.
     *
     *                 "handle" is optional and will be called when ajax request
     *                 has finished and target is matched. Function specifies
     *                 two arguments: target and value. Target is the target
     *                 element specified by "target" and value is the value
     *                 returned by Google Books API for the matched property.
     *
     *                 If a handle function is given, full control of result data
     *                 is given to the handle function.
     *
     *                 "effect" is optional and specifies effect name of effect
     *                 to use for the target once value has been set. Can be one of:
     *
     *                      - 'flash'
     *
     * @type string: defines the query type, default to input name
     *               For example <input type="text" name="isbn"></input>
     *               will search for isbn by default
     *
     * @EXAMPLE
     *
     *  $('#isbn').autofill({
     *      'volumeInfo.title': {target: 'title', effect: 'flash'},
     *      'volumeInfo.authors': {target: 'author'},
     *      'volumeInfo.publisher': {target: 'publishercode'},
     *      'selfLink': {handle: function(t,v){window.location=v;}}
     *  });
     * */
    $.fn.autofill = function (fields, type) {
        if (type === undefined)
            // default to input name
            type = this.attr("name");

        return this.each(function (i) {
            var plugin = $.data(this, "plugin_autofill");
            if (plugin) plugin.destroy();

            $.data(this, "plugin_autofill", new AutoFiller(this, fields, type));
        });
    };
})(jQuery);
