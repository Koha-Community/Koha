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

// Adapted from https://gist.github.com/jnormore/7418776
function confirmModal(message, title, yes_label, no_label, callback) {
    $("#bootstrap-confirm-box-modal").data('confirm-yes', false);
    if($("#bootstrap-confirm-box-modal").length == 0) {
        $("body").append('<div id="bootstrap-confirm-box-modal" class="modal">\
            <div class="modal-dialog">\
                <div class="modal-content">\
                    <div class="modal-header" style="min-height:40px;">\
                        <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">&times;</button>\
                        <h4 class="modal-title"></h4>\
                    </div>\
                    <div class="modal-body"><p></p></div>\
                    <div class="modal-footer">\
                        <a href="#" id="bootstrap-confirm-box-modal-submit" class="btn btn-danger"><i class="fa fa-check"></i></a>\
                        <a href="#" id="bootstrap-confirm-box-modal-cancel" data-dismiss="modal" class="btn btn-default"><i class="fa fa-remove"></i></a>\
                    </div>\
                </div>\
            </div>\
        </div>');
        $("#bootstrap-confirm-box-modal-submit").on('click', function () {
            $("#bootstrap-confirm-box-modal").data('confirm-yes', true);
            $("#bootstrap-confirm-box-modal").modal('hide');
            return false;
        });
        $("#bootstrap-confirm-box-modal").on('hide.bs.modal', function () {
            if(callback) callback($("#bootstrap-confirm-box-modal").data('confirm-yes'));
        });
    }

    $("#bootstrap-confirm-box-modal .modal-header h4").text( title || "" );
    $("#bootstrap-confirm-box-modal .modal-body p").text( message || "" );
    $("#bootstrap-confirm-box-modal-submit").text( yes_label || 'Confirm' );
    $("#bootstrap-confirm-box-modal-cancel").text( no_label || 'Cancel' );
    $("#bootstrap-confirm-box-modal").modal('show');
}