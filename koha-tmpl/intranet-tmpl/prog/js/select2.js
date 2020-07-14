/* global __ */
$.fn.select2.defaults.set("allowClear", true);
$.fn.select2.defaults.set("placeholder", "");
$.fn.select2.defaults.set("width", select2Width || "element" );

// Internationalization
$.fn.select2.defaults.set("language", {
    errorLoading:function(){ return __("The results could not be loaded"); },
    inputTooLong:function(e){
        var n = e.input.length - e.max;
        return __("Please delete %d character(s)").format(n);
    },
    inputTooShort:function(e){
        var n = e.min - e.input.length;
        return __("Please enter %n or more characters").format(n);
    },
    formatResult: function(item) {
        return $('<div>', {title: item.element[0].title}).text(item.text);
    },
    loadingMore:function(){ return __("Loading more results…"); },
    maximumSelected:function(e){
        return __("You can only select %s item(s)").format(e.max);
    },
    noResults:function(){return __("No results found"); },
    searching:function(){return __("Searching…"); },
    removeAllItems:function(){return __("Remove all items"); },
    removeItem:function(){return __("Remove item"); }
});

$(document).ready(function(){
    $(".select2").select2();
    $(".select2").on("select2:clear", function () {
        $(this).on("select2:opening.cancelOpen", function (evt) {
            evt.preventDefault();

            $(this).off("select2:opening.cancelOpen");
        });
    });
});
