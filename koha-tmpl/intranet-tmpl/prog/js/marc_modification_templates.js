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
                alert( MSG_MMT_SUBFIELDS_MATCH );
                return false;
            }
            if ( $("#to_field").val().length <= 0 ) {
                alert( MSG_MMT_DESTINATION_REQUIRED );
                return false;
            }
            if ( ( $("#to_field").val()   < 10 && $("#to_subfield").val().length   > 0 ) ||
                 ( $("#from_field").val() < 10 && $("#from_subfield").val().length > 0 ) ) {
                 alert( MSG_MMT_CONTROL_FIELD_EMPTY );
                 return false;
            }
            if ( ( $("#from_field").val() < 10 && $("#to_subfield").val().length   === 0 ) ||
                 ( $("#to_field").val()   < 10 && $("#from_subfield").val().length === 0 ) ) {
                alert( MSG_MMT_CONTROL_FIELD );
                return false;
             }
        }
        if ( action == 'update_field' ) {
            if ( $("#from_subfield").val().length <= 0 ) {
                alert( MSG_MMT_SOURCE_SUBFIELD );
                return false;
            }
        }
        if ( $("#from_field").val().length <= 0 ) {
            alert( MSG_MMT_SOURCE_FIELD );
            return false;
        }
    });

    $("#conditional_field,#from_field").change(function(){
        updateAllEvery();
    });

    $("#new_action").on("click",function(e){
        e.preventDefault();
        cancelEditAction();
        $("#add_action").show();
        $("#action").focus();
    });

    $(".duplicate_template").on("click",function(e){
        e.preventDefault();
        var template_id = $(this).data("template_id");
        $("#duplicate_a_template").val(template_id);
        $("#duplicate_current_template").val(1);
    });

    $('#createTemplate').on('shown', function (e) {
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

});

function updateAllEvery(){
    if ( $("#conditional_field").is(":visible") ) {
        if ( $("#conditional_field").val() == $("#from_field").val() && $("#from_field").val().length > 0 ) {
            $("#field_number option[value='0']").html( MSG_MMT_EVERY );
        } else {
            $("#field_number option[value='0']").html( MSG_MMT_ALL );
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
    return confirm( MSG_MMT_CONFIRM_DEL_TEMPLATE_ACTION );
}

function confirmDelete() {
    return confirm( MSG_MMT_CONFIRM_DEL_TEMPLATE );
}

var modaction_legend_innerhtml;
var action_submit_value;

function editAction( mmta_id, ordering, action, field_number, from_field, from_subfield, field_value, to_field,
    to_subfield, to_regex_search, to_regex_replace, to_regex_modifiers, conditional, conditional_field, conditional_subfield,
    conditional_comparison, conditional_value, conditional_regex, description
) {
    $("#add_action").show();
    document.getElementById('mmta_id').value = mmta_id;

    setSelectByValue( 'action', action );
    document.getElementById('action').onchange();

    setSelectByValue( 'field_number', field_number );

    document.getElementById('from_field').value = from_field;
    document.getElementById('from_subfield').value = from_subfield;
    document.getElementById('field_value').value = field_value;
    document.getElementById('to_field').value = to_field;
    document.getElementById('to_subfield').value = to_subfield;
    $("#to_regex_search").val(to_regex_search);
    $("#to_regex_replace").val(to_regex_replace);
    $("#to_regex_modifiers").val(to_regex_modifiers);

    document.getElementById('to_field_regex').checked = conditional_regex.length;
    document.getElementById('to_field_regex').onchange();

    setSelectByValue( 'conditional', conditional );
    document.getElementById('conditional').onchange();

    document.getElementById('conditional_field').value = conditional_field;
    document.getElementById('conditional_subfield').value = conditional_subfield;

    setSelectByValue( 'conditional_comparison', conditional_comparison );
    document.getElementById('conditional_comparison').onchange();

    document.getElementById('conditional_value').value = conditional_value;

    document.getElementById('conditional_regex').checked = parseInt( conditional_regex );

    document.getElementById('description').value = description;

    window.modaction_legend_innerhtml = document.getElementById('modaction_legend').innerHTML;
    document.getElementById('modaction_legend').innerHTML = MSG_MMT_EDIT_ACTION.format(ordering);

    window.action_submit_value = document.getElementById('action_submit').value;
    document.getElementById('action_submit').value = MSG_MMT_UPDATE_ACTION;
}

function cancelEditAction() {
    document.getElementById('mmta_id').value = '';

    setSelectByValue( 'action', 'delete_field' );
    document.getElementById('action').onchange();

    document.getElementById('from_field').value = '';
    document.getElementById('from_subfield').value = '';
    document.getElementById('field_value').value = '';
    document.getElementById('to_field').value = '';
    document.getElementById('to_subfield').value = '';
    $("#to_regex_search").val("");
    $("#to_regex_replace").val("");
    $("#to_regex_modifiers").val("");
    $("#description").val("");

    document.getElementById('to_field_regex').checked = false;
    document.getElementById('to_field_regex').onchange();

    setSelectByValue( 'conditional', '' );
    document.getElementById('conditional').onchange();

    document.getElementById('conditional_field').value = '';
    document.getElementById('conditional_subfield').value = '';

    setSelectByValue( 'conditional_comparison', '' );
    document.getElementById('conditional_comparison').onchange();

    document.getElementById('conditional_value').value = '';

    document.getElementById('conditional_regex').checked = false;

    document.getElementById('modaction_legend').innerHTML = window.modaction_legend_innerhtml;
    document.getElementById('action_submit').value = window.action_submit_value;
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
