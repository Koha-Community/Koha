/* global __ KohaTable table_settings */
$(document).ready(function() {
    window.modaction_legend_innerhtml = $("#modaction_legend").text();
    window.action_submit_value = $("#action_submit").val();

    $('#select_template').find("input:submit").hide();
    $('#select_template').change(function() {
        $('#select_template').submit();
    });
    $("span.match_regex_prefix" ).hide();
    $("span.match_regex_suffix" ).hide();

    $("#add_action").submit(function(){
        var action = $("#action").val();
        if ( action == 'move_field' || action == 'copy_field' || action == 'copy_and_replace_field') {
            if ( $("#from_subfield").val().length != $("#to_subfield").val().length ) {
                alert( __("Both subfield values should be filled or empty.") );
                return false;
            }
            if ( $("#to_field").val().length <= 0 ) {
                alert( __("The destination should be filled.") );
                return false;
            }
            if ( ( $("#to_field").val()   < 10 && $("#to_subfield").val().length   > 0 ) ||
                ( $("#from_field").val() < 10 && $("#from_subfield").val().length > 0 ) ) {
                alert( __("If the field is a control field, the subfield should be empty") );
                return false;
            }
            if ( ( $("#from_field").val() < 10 && $("#to_field").val()   >= 10 ) ||
                 ( $("#to_field").val()   < 10 && $("#from_field").val() >= 10 ) ) {
                alert( __("A control field cannot be used with a regular field.") );
                return false;
            }
        }
        if ( action == 'update_field' ) {
            if ( $("#from_subfield").val().length <= 0 ) {
                alert( __("The source subfield should be filled for update.") );
                return false;
            }
        }
        if ( $("#from_field").val().length <= 0 ) {
            alert( __("The source field should be filled.") );
            return false;
        }
        if ( $("#conditional").val() == 'if' || $("#conditional").val() == 'unless' ) {
            if ( $("#conditional_field").val() == '' ) {
                alert( __("The conditional field should be filled.") );
                return false;
            }
            if ( $("#conditional_comparison").val() == '' ) {
                alert( __("The conditional comparison operator should be filled.") );
                return false;
            }
            if ( $("#conditional_value").val() == '' &&
                 ( $("#conditional_comparison").val() == 'equals' || $("#conditional_comparison").val() == 'not_equals' ) ) {
                if ( document.getElementById('conditional_regex').checked == true ) {
                    alert( __("The conditional regular expression should be filled.") );
                    return false;
                } else {
                    alert( __("The conditional value should be filled.") );
                    return false;
                }
            }
        }
    });

    $("#conditional_field,#from_field").change(function(){
        updateAllEvery();
    });

    $(".new_action").on("click",function(e){
        e.preventDefault();
        cancelEditAction();
        $("#no_defined_actions").hide();
        $("#add_action").show();
        $("#action").focus();
    });

    $(".duplicate_template").on("click",function(e){
        e.preventDefault();
        var template_id = $(this).data("template_id");
        $("#duplicate_a_template").val(template_id);
        $("#duplicate_current_template").val(1);
    });

    $('#createTemplate').on('shown.bs.modal', function (e) {
        e.preventDefault();
        $("#template_name").focus();
    });

    $("#duplicate_a_template").on("change",function(e){
        e.preventDefault();
        if( this.value === '' ){
            $("#duplicate_current_template").val("");
        } else {
            $("#duplicate_current_template").val(1);
        }
    });

    $(".delete_template").on("click",function(){
        return confirmDelete();
    });

    $(".edit_action").on("click", function(){
        var mmta_id = $(this).data("mmta_id");
        var mmta = $.grep(mmtas, function(elt, id) {
            return elt['mmta_id'] == mmta_id;
        });
        editAction( mmta[0] );
        updateAllEvery();
    });

    KohaTable("templatest", {
    }, table_settings);

});

function updateAllEvery(){
    if ( $("#conditional_field").is(":visible") ) {
        if ( $("#conditional_field").val() == $("#from_field").val() && $("#from_field").val().length > 0 ) {
            $("#field_number option[value='0']").html( __("Every") );
        } else {
            $("#field_number option[value='0']").html( __("All") );
        }
    }
}

function onActionChange(selectObj) {
    // get the index of the selected option
    var idx = selectObj.selectedIndex;

    // get the value of the selected option
    var action = selectObj.options[idx].value;

    switch( action ) {
        case 'delete_field':
            show('field_number_block');
            hide('with_value_block');
            hide('to_field_block');
            break;

        case 'add_field':
            hide('field_number_block');
            show('with_value_block');
            hide('to_field_block');
            break;

        case 'update_field':
            hide('field_number_block');
            show('with_value_block');
            hide('to_field_block');
            break;

        case 'move_field':
            show('field_number_block');
            hide('with_value_block');
            show('to_field_block');
            break;

        case 'copy_field':
            show('field_number_block');
            hide('with_value_block');
            show('to_field_block');
            break;

        case 'copy_and_replace_field':
            show('field_number_block');
            hide('with_value_block');
            show('to_field_block');
            break;

    }
}

function onConditionalChange(selectObj) {
    // get the index of the selected option
    var idx = selectObj.selectedIndex;

    // get the value of the selected option
    var action = selectObj.options[idx].value;

    switch( action ) {
        case '':
            hide('conditional_block');
            break;

        case 'if':
        case 'unless':
            show('conditional_block');
            break;
    }
}

function onConditionalComparisonChange(selectObj) {
    // get the index of the selected option
    var idx = selectObj.selectedIndex;

    // get the value of the selected option
    var action = selectObj.options[idx].value;

    switch( action ) {
        case 'equals':
        case 'not_equals':
            show('conditional_comparison_block');
            break;

        default:
            hide('conditional_comparison_block');
            break;
    }
}

function onToFieldRegexChange( checkboxObj ) {
    if ( checkboxObj.checked ) {
        show('to_field_regex_value_block');
    } else {
        hide('to_field_regex_value_block');
    }
}

function onConditionalRegexChange( checkboxObj ) {
    if ( checkboxObj.checked ) {
        $("span.match_regex_prefix" ).show();
        $("span.match_regex_suffix" ).show();
    } else {
        $("span.match_regex_prefix" ).hide();
        $("span.match_regex_suffix" ).hide();
    }
}

function show(eltId) {
    elt = document.getElementById( eltId );
    elt.style.display='inline';
}

function hide(eltId) {
    clearFormElements( eltId );
    elt = document.getElementById( eltId );
    elt.style.display='none';
}

function clearFormElements(divId) {
    myBlock = document.getElementById( divId );

    var inputElements = myBlock.getElementsByTagName( "input" );
    for (var i = 0; i < inputElements.length; i++) {
        switch( inputElements[i].type ) {
            case "text":
                inputElements[i].value = '';
                break;
            case "checkbox":
                inputElements[i].checked = false;
                break;
        }
    }

    var selectElements = myBlock.getElementsByTagName( "select" );
    for (var i = 0; i < selectElements.length; i++) {
        selectElements[i].selectedIndex = 0;
    }

}

function confirmDeleteAction() {
    return confirm( __("Are you sure you wish to delete this template action?") );
}

function confirmDelete() {
    return confirm( __("Are you sure you wish to delete this template?") );
}

var modaction_legend_innerhtml;
var action_submit_value;

function editAction( mmta ) {
    $("#add_action").show();
    document.getElementById('mmta_id').value = mmta['mmta_id'];

    setSelectByValue( 'action', mmta['action'] );
    $('#action').change();

    setSelectByValue( 'field_number', mmta['field_number'] );

    document.getElementById('from_field').value = mmta['from_field'];
    document.getElementById('from_subfield').value = mmta['from_subfield'];
    document.getElementById('field_value').value = mmta['field_value'];
    document.getElementById('to_field').value = mmta['to_field'];
    document.getElementById('to_subfield').value = mmta['to_subfield'];
    if ( mmta['regex_search'] == '' && mmta['to_regex_replace'] == '' && mmta['to_regex_modifiers'] == '' ) {
        $('#to_field_regex').prop('checked', false).change();
    } else {
        $('#to_field_regex').prop('checked', true).change();
        $("#to_regex_search").val(mmta['to_regex_search']);
        $("#to_regex_replace").val(mmta['to_regex_replace']);
        $("#to_regex_modifiers").val(mmta['to_regex_modifiers']);
    }

    setSelectByValue( 'conditional', mmta['conditional'] );
    $('#conditional').change();

    document.getElementById('conditional_field').value = mmta['conditional_field'];
    document.getElementById('conditional_subfield').value = mmta['conditional_subfield'];

    setSelectByValue( 'conditional_comparison', mmta['conditional_comparison'] );
    $('#conditional_comparison').change();

    document.getElementById('conditional_value').value = mmta['conditional_value'];

    document.getElementById('conditional_regex').checked = parseInt( mmta['conditional_regex'] );
    $('#conditional_regex').change();

    document.getElementById('description').value = mmta['description'];

    window.modaction_legend_innerhtml = document.getElementById('modaction_legend').innerHTML;
    document.getElementById('modaction_legend').innerHTML = __("Edit action %s").format(mmta['ordering']);

    window.action_submit_value = document.getElementById('action_submit').value;
    document.getElementById('action_submit').value = __("Update action");
}

function cancelEditAction() {
    document.getElementById('mmta_id').value = '';

    setSelectByValue( 'action', 'delete_field' );
    $('#action').change();

    document.getElementById('from_field').value = '';
    document.getElementById('from_subfield').value = '';
    document.getElementById('field_value').value = '';
    document.getElementById('to_field').value = '';
    document.getElementById('to_subfield').value = '';
    $("#to_regex_search").val("");
    $("#to_regex_replace").val("");
    $("#to_regex_modifiers").val("");
    $("#description").val("");

    $('#to_field_regex').prop('checked', false).change();

    setSelectByValue( 'conditional', '' );
    $('#conditional').change();

    document.getElementById('conditional_field').value = '';
    document.getElementById('conditional_subfield').value = '';

    setSelectByValue( 'conditional_comparison', '' );
    $('#conditional_comparison').change();

    document.getElementById('conditional_value').value = '';

    document.getElementById('conditional_regex').checked = false;

    document.getElementById('modaction_legend').innerHTML = window.modaction_legend_innerhtml;
    document.getElementById('action_submit').value = window.action_submit_value;

    if( $("#template_actions").length < 1 ){
        $("#no_defined_actions").show();
    }

    $("#add_action").hide();
}

function setSelectByValue( selectId, value ) {
    s = document.getElementById( selectId );

    for ( i = 0; i < s.options.length; i++ ) {
        if ( s.options[i].value == value ) {
            s.selectedIndex = i;
        }
    }
}
