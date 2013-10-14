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