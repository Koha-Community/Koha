// http://stackoverflow.com/questions/1038746/equivalent-of-string-format-in-jquery/5341855#5341855
String.prototype.format = function () {
    return formatstr(this, arguments);
};
function formatstr(str, col) {
    col =
        typeof col === "object"
            ? col
            : Array.prototype.slice.call(arguments, 1);
    var idx = 0;
    return str.replace(/%%|%s|%(\d+)\$s/g, function (m, n) {
        if (m == "%%") {
            return "%";
        }
        if (m == "%s") {
            return col[idx++];
        }
        return col[n];
    });
}
