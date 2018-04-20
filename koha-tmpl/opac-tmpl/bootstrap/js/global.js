(function( w ){
    // if the class is already set, the font has already been loaded
    if( w.document.documentElement.className.indexOf( "fonts-loaded" ) > -1 ){
        return;
    }
    var PrimaryFont = new w.FontFaceObserver( "NotoSans", {
        weight: 400
    });

    PrimaryFont.load(null, 5000).then(function(){
        w.document.documentElement.className += " fonts-loaded";
    }, function(){
        console.log("Failed");
    });
}( this ));

// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function() { return formatstr(this, arguments) }
function formatstr(str, col) {
    col = typeof col === 'object' ? col : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") { return "%"; }
        if (m == "%s") { return col[idx++]; }
        return col[n];
    });
};

function confirmDelete(message) {
    return (confirm(message) ? true : false);
}

function Dopop(link) {
    newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes,resizeable=yes');
}

jQuery.fn.preventDoubleFormSubmit = function() {
    jQuery(this).submit(function() {
        if (this.beenSubmitted)
            return false;
        else
            this.beenSubmitted = true;
    });
};

function prefixOf (s, tok) {
    var index = s.indexOf(tok);
    return s.substring(0, index);
}
function suffixOf (s, tok) {
    var index = s.indexOf(tok);
    return s.substring(index + 1);
}
