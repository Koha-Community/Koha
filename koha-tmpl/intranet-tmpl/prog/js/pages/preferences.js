/* global KOHA CodeMirror to_highlight search_jumped humanMsg dataTablesDefaults themelang */
// We can assume 'KOHA' exists, as we depend on KOHA.AJAX

KOHA.Preferences = {
    Save: function ( form ) {
        if ( ! $(form).valid() ) {
            humanMsg.displayAlert( __("Error: presence of invalid data prevent saving. Please make the corrections and try again.") );
            return;
        }

        modified_prefs = $( form ).find( '.modified' );
        // $.serialize removes empty value, we need to keep them.
        // If a multiple select has all its entries unselected
        var unserialized = new Array();
        $(modified_prefs).each(function(){
            if ( $(this).attr('multiple') && $(this).val().length == 0 ) {
                unserialized.push($(this));
            }
        });
        data = modified_prefs.serialize();
        $(unserialized).each(function(){
            data += '&' + $(this).attr('name') + '=';
        });
        if ( !data ) {
            humanMsg.displayAlert( __("Nothing to save") );
            return;
        }
        let csrf_token_el = $( form ).find('input[name="csrf_token"]');
        if (csrf_token_el.length > 0){
            let csrf_token = csrf_token_el.val();
            if (csrf_token){
                data += '&' + 'csrf_token=' + csrf_token;
            }
        }
        KOHA.AJAX.MarkRunning($(form).find('.save-all'), __("Saving...") );
        KOHA.AJAX.Submit( {
            data: data,
            url: '/cgi-bin/koha/svc/config/systempreferences/',
            success: function ( data ) { KOHA.Preferences.Success( form ) },
            complete: function () { KOHA.AJAX.MarkDone( $( form ).find( '.save-all' ) ) }
        } );
    },
    Success: function ( form ) {
        var msg = "";
        modified_prefs.each(function(){
            var modified_pref = $(this).attr("id");
            modified_pref = modified_pref.replace("pref_","");
            msg += "<strong>" + __("Saved preference %s").format(modified_pref) + "</strong>\n";
        });
        humanMsg.displayAlert(msg);

        $( form )
            .find( '.modified-warning' ).remove().end()
            .find( '.modified' ).removeClass('modified');
        KOHA.Preferences.Modified = false;
    }
};

function mark_modified() {
    $( this.form ).find( '.save-all' ).prop('disabled', false);
    $( this ).addClass( 'modified' );
    var name_cell = $( this ).parents( '.name-row' ).find( '.name-cell' );
    if ( !name_cell.find( '.modified-warning' ).length )
        name_cell.append('<em class="modified-warning">(' + __("modified") + ')</em>');
    KOHA.Preferences.Modified = true;
}

window.onbeforeunload = function () {
    if ( KOHA.Preferences.Modified ) {
        return __("You have made changes to system preferences.");
    }
};

$( document ).ready( function () {

    $("table.preferences").dataTable($.extend(true, {}, dataTablesDefaults, {
        "sDom": 't',
        "aoColumnDefs": [
            { "aTargets": [ -1 ], "bSortable": false, "bSearchable": false }
        ],
        "bPaginate": false
    }));

    $( '.prefs-tab' )
        .find( 'input.preference, textarea.preference' ).on('input', function () {
            if ( this.defaultValue === undefined || this.value != this.defaultValue ) mark_modified.call( this );
        } ).end()
        .find( 'select.preference' ).change( mark_modified );
    $('.preference-checkbox').change( function () {
        $('.preference-checkbox').addClass('modified');
        mark_modified.call(this);
    } );

    $(".set_syspref").click(function() {
        var s = $(this).attr('data-syspref');
        var v = $(this).attr('data-value');
        // populate the input with the value in data-value
        $("#pref_"+s).val(v);
        // pass the DOM element to trigger "modified" to enable submit button
        mark_modified.call($("#pref_"+s)[0]);
        return false;
    });

    $(".sortable").sortable();
    $(".sortable").on( "sortchange", function( event, ui ) {
        // This is not exact but we just need to trigger a change
        $(ui.item.find('input:first')).change();
    } );

    $( '.prefs-tab .action .cancel' ).click( function () { KOHA.Preferences.Modified = false } );

    $( '.prefs-tab .save-all' ).prop('disabled', true).click( function () {
        KOHA.Preferences.Save( this.form );
        return false;
    });

    $( ".expand-textarea" ).on("click", function(e){
        e.preventDefault();
        $(this).hide();
        var target = $(this).data("target");
        var syntax = $(this).data("syntax");
        $("#collapse_" + target ).show();
        if( syntax ){
            var editor = CodeMirror.fromTextArea( document.getElementById( "pref_" + target ), {
                lineNumbers: true,
                mode: syntax,
                lineWrapping: true,
                viewportMargin: Infinity,
                gutters: ["CodeMirror-lint-markers"],
                lint: true
            });
            editor.on("change", function(){
                mark_modified.call( $("#pref_" + target )[0]);
            });
            editor.on("blur", function(){
                editor.save();
            });
        } else {
            $("#pref_" + target ).show();
        }
    });

    $( ".collapse-textarea" ).on("click", function(e){
        e.preventDefault();
        $(this).hide();
        var target = $(this).data("target");
        var syntax = $(this).data("syntax");
        $("#expand_" + target ).show();
        if( syntax ){
            var editor = $("#pref_" + target ).next(".CodeMirror")[0].CodeMirror;
            editor.toTextArea();
        }
        $("#pref_" + target ).hide();
    });

    $("h3").attr("class", "expanded").attr("title", __("Click to collapse this section"));
    var collapsible = $(".collapsed,.expanded");

    $(collapsible).on("click",function(){
        var h3Id = $(this).attr("id");
        var panel = $("#collapse_" + h3Id);
        if(panel.is(":visible")){
            $(this).addClass("collapsed").removeClass("expanded").attr("title", __("Click to expand this section") );
            panel.hide();
        } else {
            $(this).addClass("expanded").removeClass("collapsed").attr("title", __("Click to collapse this section") );
            panel.show();
        }
    });

    $(".pref_sublink").on("click", function(){
        /* If the user clicks a sub-menu link in the sidebar,
           check to see if it is collapsed. If so, expand it */
        var href = $(this).attr("href");
        href = href.replace("#","");
        var panel = $("#collapse_" + href );
        if( panel.is(":hidden") ){
            $("#" + href).addClass("expanded").removeClass("collapsed").attr("title", __("Click to collapse this section") );
            panel.show();
        }
    });

    if ( to_highlight ) {
        var words = to_highlight.split( ' ' );
        $( '.prefs-tab table' ).find( 'td, th' ).not( '.name-cell' ).each( function ( i, td ) {
            $.each( words, function ( i, word ) { $( td ).highlight( word ) } );
        } ).find( 'option, textarea' ).removeHighlight();
    }

    if ( search_jumped ) {
        document.location.hash = "jumped";
    }

    $("#pref_UpdateItemLocationOnCheckin").change(function(){
        var the_text = $(this).val();
        var alert_text = '';
        if (the_text.indexOf('_ALL_:') != -1) alert_text = __("Note: _ALL_ value will override all other values") + '\n';
        var split_text  =the_text.split("\n");
        var alert_issues = '';
        var issue_count = 0;
        var reg_check = /.*:\s.*/;
        for (var i=0; i < split_text.length; i++){
            if ( !split_text[i].match(reg_check) && split_text[i].length ) {
                alert_issues+=split_text[i]+"\n";
                issue_count++;
            }
        }
        if (issue_count) alert_text += "\n" + __("The following values are not formatted correctly:") + "\n" + alert_issues;
        if ( alert_text.length )  alert(alert_text);
    });

    $(".prefs-tab form").each(function () {
        $(this).validate({
            rules: { },
            errorPlacement: function(error, element) {
                var placement = $(element).parent();
                if (placement) {
                    $(placement).append(error)
                } else {
                    error.insertAfter(element);
                }
            }
        });
    });

    $(".preference-email").each(function() {
        $(this).rules("add", {
            email: true
        });
    });


    $(".modalselect").on("click", function(){
        var datasource = $(this).data("source");
        var exclusions = $(this).data("exclusions").split('|');
        var required = $(this).data("required").split('|');
        var pref_name = this.id.replace(/pref_/, '');
        var pref_value = this.value;
        var prefs = pref_value.split("|");

        let data = db_columns[datasource];
        var items = [];
        var checked = "";
        var readonly = "";
        var disabled = "";
        var style = "";
        $.each( Object.keys(data).sort(), function( i, key ){
            if( prefs.indexOf( key ) >= 0 ){
                checked = ' checked="checked" ';
            } else {
                checked = "";
            }
            if( required.indexOf( key ) >= 0 ){
                style = "required";
                checked  = ' checked="checked" ';
            } else if( exclusions.indexOf( key ) >= 0 ){
                style = "disabled";
                disabled = ' disabled="disabled" ';
                checked  = "";
            } else {
                style = "";
                disabled = "";
            }
            items.push('<label class="' + style +'"><input class="dbcolumn_selection" type="checkbox" id="' + key + '"' + checked + disabled + ' name="pref" value="' + key + '" /> ' + data[key]+ ' (' + key + ')</label>');
        });
        $("<div/>", {
            "class": "columns-2",
            html: items.join("")
        }).appendTo("#prefModalForm");

        $("#saveModalPrefs").data("target", this.id );
        $("#prefModalLabel").text( pref_name );
        $("#prefModal").modal("show");
    });

    $("#saveModalPrefs").on("click", function(){
        var formfieldid = $("#" + $(this).data("target") );
        var prefs = [];
        $("#prefModal input[type='checkbox']").each(function(){
            if( $(this).prop("checked") ){
                prefs.push( this.value );
            }
        });

        formfieldid.val( prefs.join("|") )
            .addClass("modified");
        mark_modified.call( formfieldid );
        KOHA.Preferences.Save( formfieldid.closest("form") );
        $("#prefModal").modal("hide");
    });

    $("#prefModal").on("hide.bs.modal", function(){
        $("#prefModalLabel,#prefModalForm").html("");
        $("#saveModalPrefs").data("target", "" );
    });

    $("#select_all").on("click",function(e){
        e.preventDefault();
        $("label:not(.required) .dbcolumn_selection:not(:disabled)").prop("checked", true);
    });
    $("#clear_all").on("click",function(e){
        e.preventDefault();
        $("label:not(.required) .dbcolumn_selection").prop("checked", false);
    });

    $("body").on("click", "label.required input.dbcolumn_selection", function(e){
        e.preventDefault();
    });

} );
