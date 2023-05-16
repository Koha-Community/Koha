/* global __ */
/* exported openAuth ExpandField CloneField CloneSubfield UnCloneField CloneItemSubfield CheckMandatorySubfields */

/*
 * Unified file for catalogue edition
 */

/* Functions developed for addbiblio.tt and authorities.tt */

// returns the fieldcode based upon tag div id
function getFieldCode(tagDivId){
    // format : tag_<tagnumber>_...
    return tagDivId.substr(3+1,3);
}

//returns the field and subfieldcode based upon subfield div id
function getFieldAndSubfieldCode(subfieldDivId){
    // format : subfield<tagnumber><subfieldnumber>...
    return subfieldDivId.substr(8,3+1);
}

//returns the subfieldcode based upon subfieldid writing
function getSubfieldCode(tagsubfieldid){
    // 3 : tag +3 : tagnumber +4 : number of _ +8 subfield -1 begins at 0
    return tagsubfieldid.substr(3+3+4+8-1,1);
}

// Take the base of tagsubfield information (removing the subfieldcodes and subfieldindexes)
// returns the filter
function getTagInputnameFilter(tagsubfieldid){
    var tagsubfield=tagsubfieldid.substr(0,tagsubfieldid.lastIndexOf("_"));
    var tagcode=tagsubfield.substr(tagsubfield.lastIndexOf("_"));
    tagsubfield=tagsubfield.substr(0,tagsubfield.lastIndexOf("_"));
    tagsubfield=tagsubfield.substr(0,tagsubfield.lastIndexOf("_"));
    tagsubfield=tagsubfield+"_."+tagcode;
    return tagsubfield;
}

// if source is "auth", we are editing an authority otherwise it is a biblio
function openAuth(tagsubfieldid,authtype,source) {
    // let's take the base of tagsubfield information (removing the indexes and the codes
    var element=document.getElementById(tagsubfieldid);
    var tagsubfield=getTagInputnameFilter(tagsubfieldid);
    var elementsubfcode=getSubfieldCode(element.name);
    var mainmainstring=element.value;
    var mainstring = new Array();

    var ul = element.closest('ul');
    var inputs = ul ? ul.getElementsByTagName('input') : element.parentNode.getElementsByTagName('input');
    for (var myindex =0; myindex<inputs.length;myindex++){
        if (inputs[myindex].name && inputs[myindex].name.match(tagsubfield)){
            var subfieldcode=getSubfieldCode(inputs[myindex].name);
            if (isNaN(parseInt(subfieldcode)) && inputs[myindex].value != "" && subfieldcode!=elementsubfcode){
                mainstring.push(inputs[myindex].value);
            }
        }
    }
    mainstring = mainstring.join(' ');
    window.open("../authorities/auth_finder.pl?source="+source+"&authtypecode="+authtype+"&index="+tagsubfieldid+"&value_mainstr="+encodeURIComponent(mainmainstring)+"&value_main="+encodeURIComponent(mainstring), "_blank",'width=700,height=550,toolbar=false,scrollbars=yes');
}

function ExpandField() {
    let index = this.dataset.field_id;
    var original = document.getElementById(index); //original <li>
    var lis = original.getElementsByTagName('li');
    for(var i=0,lislen = lis.length ; i<lislen ; i++){   // foreach li
        if(lis[i].hasAttribute('id') == 0 ) {continue; } // li element is specific to Select2
        if(lis[i].getAttribute('id').match(/^subfield/)){  // if it s a subfield
            if (!lis[i].style.display) {
                // first time => show all subfields
                lis[i].style.display = 'flex';
            } else if (lis[i].style.display == 'none') {
                // show
                lis[i].style.display = 'flex';
            } else {
                // hide
                lis[i].style.display = 'none';
            }
        }
    }
    return false;
}

var current_select2;
var Select2Utils = {
    removeSelect2: function(selects) {
        if ($.fn.select2) {
            $(selects).each(function(){
                $(this).select2('destroy');
            });
        }
    },

    initSelect2: function(selects) {
        if ($.fn.select2) {
            if ( window.auth_values_creation === undefined || ! auth_values_creation ) {
                $(selects).select2().on("select2:clear", function () {
                    $(this).on("select2:opening.cancelOpen", function (evt) {
                        evt.preventDefault();
                        $(this).off("select2:opening.cancelOpen");
                    });
                });
            } else {
                $(selects).each(function(){
                    if ( !$(this).data("category") ) {
                        $(this).select2().on("select2:clear", function () {
                            $(this).on("select2:opening.cancelOpen", function (evt) {
                                evt.preventDefault();
                                $(this).off("select2:opening.cancelOpen");
                            });
                        });
                    } else {
                        $(this).select2({
                            tags: true,
                            createTag: function (tag) {
                                return {
                                    id: tag.term,
                                    text: tag.term,
                                    newTag: true
                                };
                            },
                            templateResult: function(state) {
                                if (state.newTag) {
                                    return state.text + " " + __("(select to create)");
                                }
                                return state.text;
                            }
                        }).on("select2:select", function(e) {
                            if(e.params.data.newTag){
                                current_select2 = this;
                                var category = $(this).data("category");
                                $("#avCreate #new_av_category").html(category);
                                $("#avCreate input[name='category']").val(category);
                                $("#avCreate input[name='value']").val('');
                                $("#avCreate input[name='description']").val(e.params.data.text);

                                $(this).val($(this).find("option:first").val()).trigger('change');
                                $('#avCreate').modal({show:true});
                            }
                        }).on("select2:clear", function () {
                            $(this).on("select2:opening.cancelOpen", function (evt) {
                                evt.preventDefault();

                                $(this).off("select2:opening.cancelOpen");
                            });
                        });
                    }
                });
            }
        }
    }
};

/**
 * To clone a field
 * @param hideMarc '0' for false, '1' for true
 * @param advancedMARCEditor '0' for false, '1' for true
 */
function CloneField(index, hideMarc, advancedMARCEditor) {
    var original = document.getElementById(index); //original <li>
    Select2Utils.removeSelect2($(original).find('select'));

    var clone = original.cloneNode(true);
    var new_key = CreateKey();
    var new_id  = original.getAttribute('id')+new_key;

    clone.setAttribute('id',new_id); // setting a new id for the parent li

    var divs = Array.from(clone.getElementsByTagName('li')).concat(Array.from(clone.getElementsByTagName('div')));

    // if hide_marc, indicators are hidden fields
    // setting a new name for the new indicator
    for(var i=0; i < 2; i++) {
        var indicator = clone.getElementsByTagName('input')[i];
        indicator.setAttribute('name',indicator.getAttribute('name')+new_key);
    }

    // settings all subfields
    var divslen = divs.length;
    for( i=0; i < divslen ; i++ ){      // foreach div/li
        if( divs[i].getAttribute("id") && divs[i].getAttribute("id").match(/^subfield/)){  // if it s a subfield

            // set the attribute for the new 'li' subfields
            divs[i].setAttribute('id',divs[i].getAttribute('id')+new_key);

            var inputs   = divs[i].getElementsByTagName('input');
            var id_input = "";
            var olddiv;
            var oldcontrol;

            for( j = 0 ; j < inputs.length ; j++ ) {
                if(inputs[j].getAttribute("id") && inputs[j].getAttribute("id").match(/^tag_/) ){
                    inputs[j].value = "";

                    //Remove the color added by the automatic linker
                    $(inputs[j]).removeClass("matching_authority_field no_matching_authority_field");
                }
            }
            var textareas = divs[i].getElementsByTagName('textarea');
            for( j = 0 ; j < textareas.length ; j++ ) {
                if(textareas[j].getAttribute("id") && textareas[j].getAttribute("id").match(/^tag_/) ){
                    textareas[j].value = "";
                }
            }
            // Remove the status icons added by the automatic linker
            $(divs[i]).find('.subfield_status').remove();
            if( inputs.length > 0 ){
                inputs[0].setAttribute('id',inputs[0].getAttribute('id')+new_key);
                inputs[0].setAttribute('name',inputs[0].getAttribute('name')+new_key);

                try {
                    id_input = inputs[1].getAttribute('id')+new_key;
                    inputs[1].setAttribute('id',id_input);
                    inputs[1].setAttribute('name',inputs[1].getAttribute('name')+new_key);
                } catch(e) {
                    try{ // it s a select if it is not an input
                        var selects = divs[i].getElementsByTagName('select');
                        id_input = selects[0].getAttribute('id')+new_key;
                        selects[0].setAttribute('id',id_input);
                        selects[0].setAttribute('name',selects[0].getAttribute('name')+new_key);
                    }catch(e2){ // it is a textarea if it s not a select or an input
                        var textareas = divs[i].getElementsByTagName('textarea');
                        if( textareas.length > 0 ){
                            id_input = textareas[0].getAttribute('id')+new_key;
                            textareas[0].setAttribute('id',id_input);
                            textareas[0].setAttribute('name',textareas[0].getAttribute('name')+new_key);
                        }
                    }
                }
                if( $(inputs[1]).hasClass('framework_plugin') ) {
                    olddiv= original.getElementsByTagName('li')[i];
                    oldcontrol= olddiv.getElementsByTagName('input')[1];
                    AddEventHandlers( oldcontrol,inputs[1],id_input );
                }
            }
            // when cloning a subfield, re set its label too.
            try {
                var labels = divs[i].getElementsByTagName('label');
                labels[0].setAttribute('for', id_input);
            }
            catch(e) {
                // do nothing if label does not exist.
            }

            // setting its '+' and '-' buttons
            try {
                var anchors = divs[i].getElementsByTagName('a');
                for (var j = 0; j < anchors.length; j++) {
                    if(anchors[j].getAttribute('class') == 'buttonPlus'){
                        anchors[j].setAttribute('onclick',"CloneSubfield('" + divs[i].getAttribute('id') + "','" + advancedMARCEditor + "'); return false;");
                    } else if (anchors[j].getAttribute('class') == 'buttonMinus') {
                        anchors[j].setAttribute('onclick',"UnCloneField('" + divs[i].getAttribute('id') + "'); return false;");
                    }
                }
            }
            catch(e){
                // do nothig if ButtonPlus & CloneButtonPlus don t exist.
            }

            // button ...
            var spans=0;
            try {
                spans = divs[i].getElementsByTagName('a');
            } catch(e) {
                // no spans
            }
            if(spans){
                var buttonDot;
                if(!CloneButtonPlus){ // it s impossible to have  + ... (buttonDot AND buttonPlus)
                    buttonDot = spans[0];
                    if(buttonDot){
                        // 2 possibilities :
                        try{
                            if( $(buttonDot).hasClass('framework_plugin') ) {
                                olddiv= original.getElementsByTagName('li')[i];
                                oldcontrol= olddiv.getElementsByTagName('a')[0];
                                AddEventHandlers(oldcontrol,buttonDot,id_input);
                            }
                            try {
                                // do not copy the script section.
                                var script = spans[0].getElementsByTagName('script')[0];
                                spans[0].removeChild(script);
                            } catch(e) {
                                // do nothing if there is no script
                            }
                        } catch(e){
                            //
                        }
                    }
                }
            }

        } else { // it's a indicator div
            if ( divs[i].getAttribute("id") && divs[i].getAttribute('id').match(/^div_indicator/)) {

                // setting a new id for the indicator div
                divs[i].setAttribute('id',divs[i].getAttribute('id')+new_key);

                inputs = divs[i].getElementsByTagName('input');
                inputs[0].setAttribute('id',inputs[0].getAttribute('id')+new_key);
                inputs[1].setAttribute('id',inputs[1].getAttribute('id')+new_key);

                var CloneButtonPlus;
                try {
                    anchors = divs[i].getElementsByTagName('a');
                    for ( j = 0; j < anchors.length; j++) {
                        if (anchors[j].getAttribute('class') == 'buttonPlus') {
                            anchors[j].setAttribute('onclick',"CloneField('" + new_id + "','" + hideMarc + "','" + advancedMARCEditor + "'); return false;");
                        } else if (anchors[j].getAttribute('class') == 'buttonMinus') {
                            anchors[j].setAttribute('onclick',"UnCloneField('" + new_id + "'); return false;");
                        } else if (anchors[j].getAttribute('class') == 'expandfield') {
                            anchors[j].setAttribute('data-field_id',new_id);
                        }
                    }
                }
                catch(e){
                    // do nothig CloneButtonPlus doesn't exist.
                }

            }
        }
    }

    // insert this line on the page
    original.parentNode.insertBefore(clone,original.nextSibling);

    $("ul.sortable_subfield", clone).sortable();

    Select2Utils.initSelect2($(original).find('select'));
    Select2Utils.initSelect2($(clone).find('select'));
}


/**
 * To clone a subfield
 * @param index
 * @param advancedMARCEditor '0' for false, '1' for true
 */
function CloneSubfield(index, advancedMARCEditor){
    var original = document.getElementById(index); //original <div>
    Select2Utils.removeSelect2($(original).find('select'));
    var clone = original.cloneNode(true);
    var new_key = CreateKey();
    // set the attribute for the new 'li' subfields
    var inputs     = clone.getElementsByTagName('input');
    var selects    = clone.getElementsByTagName('select');
    var textareas  = clone.getElementsByTagName('textarea');
    var linkid;
    var oldcontrol;

    // input
    var id_input = "";
    for(var i=0,len=inputs.length; i<len ; i++ ){
        id_input = inputs[i].getAttribute('id')+new_key;
        inputs[i].setAttribute('id',id_input);
        inputs[i].setAttribute('name',inputs[i].getAttribute('name')+new_key);
        if(inputs[i].getAttribute("id") && inputs[i].getAttribute("id").match(/^tag_/) ){
            inputs[i].value = "";
        }
        linkid = id_input;
    }

    // Plugin input
    if( $(inputs[1]).hasClass('framework_plugin') ) {
        oldcontrol= original.getElementsByTagName('input')[1];
        AddEventHandlers( oldcontrol, inputs[1], linkid );
    }

    // select
    for(i=0,len=selects.length; i<len ; i++ ){
        id_input = selects[i].getAttribute('id')+new_key;
        selects[i].setAttribute('id',selects[i].getAttribute('id')+new_key);
        selects[i].setAttribute('name',selects[i].getAttribute('name')+new_key);
        linkid = id_input;
    }

    // textarea
    for( i=0,len=textareas.length; i<len ; i++ ){
        id_input = textareas[i].getAttribute('id')+new_key;
        textareas[i].setAttribute('id',textareas[i].getAttribute('id')+new_key);
        textareas[i].setAttribute('name',textareas[i].getAttribute('name')+new_key);
        if(textareas[i].getAttribute("id") && textareas[i].getAttribute("id").match(/^tag_/) ){
            textareas[i].value = "";
        }
        linkid = id_input;
    }

    // Handle click event on buttonDot for plugin
    var links  = clone.getElementsByTagName('a');
    if( $(links[0]).hasClass('framework_plugin') ) {
        oldcontrol= original.getElementsByTagName('a')[0];
        AddEventHandlers( oldcontrol, links[0], linkid );
    }

    if(advancedMARCEditor == '0') {
        // when cloning a subfield, reset its label too.
        var label = clone.getElementsByTagName('label')[0];
        if( label ){
            label.setAttribute('for',id_input);
        }
    }

    // setting a new id for the parent div
    var new_id  = original.getAttribute('id')+new_key;
    clone.setAttribute('id',new_id);

    try {
        var anchors = clone.getElementsByTagName('a');
        if(anchors.length){
            for( i = 0 ,len = anchors.length ; i < len ; i++){
                if(anchors[i].getAttribute('class') == 'buttonPlus'){
                    anchors[i].setAttribute('onclick',"CloneSubfield('" + new_id + "','" + advancedMARCEditor + "'); return false;");
                } else if (anchors[i].getAttribute('class') == 'buttonMinus') {
                    anchors[i].setAttribute('onclick',"UnCloneField('" + new_id + "'); return false;");
                }
            }
        }
    }
    catch(e){
        // do nothig if ButtonPlus & CloneButtonPlus don't exist.
    }
    // insert this line on the page
    original.parentNode.insertBefore(clone,original.nextSibling);

    //Restablish select2 for the cloned elements.
    Select2Utils.initSelect2($(original).find('select'));
    Select2Utils.initSelect2($(clone).find('select'));

    // delete data of cloned subfield
    clone.querySelectorAll('input.input_marceditor').value = "";
}

function AddEventHandlers (oldcontrol, newcontrol, newinputid ) {
// This function is a helper for CloneField and CloneSubfield.
// It adds the event handlers from oldcontrol to newcontrol.
// newinputid is the id attribute of the cloned controlling input field
// Note: This code depends on the jQuery data for events; this structure
// is moved to _data as of jQuery 1.8.
    var ev = $._data(oldcontrol, "events");
    if(typeof ev != 'undefined') {
        $.each(ev, function(prop,val) {
            $.each(val, function(prop2,val2) {
                $(newcontrol).off( val2.type );
                $(newcontrol).on( val2.type, {id: newinputid}, val2.handler );
            });
        });
    }
}

/**
 * This function removes or clears unwanted subfields
 */
function UnCloneField(index) {
    var original = document.getElementById(index);
    var canUnclone = false;
    if ($(original).hasClass("tag")) {
        // unclone a field, check if there will remain one field
        var fieldCode = getFieldCode(index);
        // tag divs with id begining with original field code
        var cloneFields = $('.tag[id^="tag_'+fieldCode+'"]');
        if (cloneFields.length > 1) {
            canUnclone = true;
        }
    } else {
        // unclone a subfield, check if there will remain one subfield
        var subfieldCode = getFieldAndSubfieldCode(index);
        // subfield divs of same field with id begining with original field and subfield field code
        var cloneSubfields = $(original).parent().children('.subfield_line[id^="subfield'+subfieldCode+'"]');
        if (cloneSubfields.length > 1) {
            canUnclone = true;
        }
    }
    if (canUnclone) {
        // remove clone
        original.parentNode.removeChild(original);
    } else {
        // clear inputs, but don't delete
        $(":input.input_marceditor", original).each(function(){
            // thanks to http://www.learningjquery.com/2007/08/clearing-form-data for
            // hint about clearing selects correctly
            var type = this.type;
            var tag = this.tagName.toLowerCase();
            if (type == 'text' || type == 'password' || tag == 'textarea') {
                this.value = "";
            } else if (type == 'checkbox' || type == 'radio') {
                this.checked = false;
            } else if (tag == 'select') {
                this.selectedIndex = -1;
                // required for Select2 to be able to update its control
                $(this).trigger('change');
            }
        });
        $(":input.indicator", original).val("");
    }
}

/**
 * This function create a random number
 */
function CreateKey(){
    return parseInt(Math.random() * 100000);
}

/* Functions developed for additem.tt */

/**
 * To clone a subfield.<br>
 * @param original subfield div to clone
 */
function CloneItemSubfield(original){
    Select2Utils.removeSelect2($(original).find('select'));
    var clone = original.cloneNode(true);
    var new_key = CreateKey();

    // set the attribute for the new 'li' subfields
    var inputs     = clone.getElementsByTagName('input');
    var selects    = clone.getElementsByTagName('select');
    var textareas  = clone.getElementsByTagName('textarea');

    // input (except hidden type)
    var id_input = "";
    for(var i=0,len=inputs.length; i<len ; i++ ){
        if (inputs[i].getAttribute('type') != 'hidden') {
            id_input = inputs[i].getAttribute('id')+new_key;
            inputs[i].setAttribute('id',id_input);
        }
    }

    // select
    for( i=0,len=selects.length; i<len ; i++ ){
        id_input = selects[i].getAttribute('id')+new_key;
        selects[i].setAttribute('id',selects[i].getAttribute('id')+new_key);
    }

    // textarea
    for( i=0,len=textareas.length; i<len ; i++ ){
        id_input = textareas[i].getAttribute('id')+new_key;
        textareas[i].setAttribute('id',textareas[i].getAttribute('id')+new_key);
    }

    // when cloning a subfield, reset its label too.
    var label = clone.getElementsByTagName('label')[0];
    label.setAttribute('for',id_input);

    // setting a new if for the parent div
    var new_id = original.getAttribute('id')+new_key;
    clone.setAttribute('id',new_id);

    // Don't clone "RegEx". We don't handle it for repeatable subfields
    var links = clone.getElementsByTagName('a');
    for( i = 0 ,len = links.length ; i < len ; i++){
        if( $(links[i]).hasClass('field_regex') ) {
            $(links[i]).remove();
        }
    }

    // insert this line on the page
    original.parentNode.insertBefore(clone,original.nextSibling);
    Select2Utils.initSelect2($(original).find('select'));
    Select2Utils.initSelect2($(clone).find('select'));
}

/**
 * Check mandatory subfields of a cataloging form and adds <code>missing</code> class to those who are empty.<br>
 * @param p the parent object of subfields to check
 * @return the number of empty mandatory subfields
 */
function CheckMandatorySubfields(p){
    var total = 0;
    $(p).find(".subfield_line input[name='mandatory'][value='1']").each(function(){
        var editor = $(this).siblings(".input_marceditor");
        if ( !editor.length ) { // Deal with date inputs
            editor = $(this).siblings(".flatpickr_wrapper").find(".input_marceditor");
        }
        if (!editor.val()) {
            editor.addClass("missing");
            total++;
        }
    });
    return total;
}

function CheckImportantSubfields(p){
    var total = 0;
    $(p).find(".subfield_line input[name='important'][value='1']").each(function(i){
        var editor = $(this).siblings(".input_marceditor");
        if ( !editor.length ) { // Deal with date inputs
            editor = $(this).siblings(".flatpickr_wrapper").find(".input_marceditor");
        }
        if (!editor.val()) {
            editor.addClass("missing");
            total++;
        }
    });
    return total;
}

$(document).ready(function() {
    $("input.input_marceditor, input.indicator").addClass('noEnterSubmit');
    $(document).ajaxSuccess(function() {
        $("input.input_marceditor, input.indicator").addClass('noEnterSubmit');
    });

    if ( window.editor === undefined ) { // TODO This does not work with the advanced editor
        Select2Utils.initSelect2($('.subfield_line select[data-category=""]')); // branches, itemtypes and cn_source
        Select2Utils.initSelect2($('.subfield_line select[data-category!=""]'));
    }

    $("#avCreate").on("hidden.bs.modal", function(){
        add_new_av.resetForm(); /* resets form state for jQuery Validate plugin */
        $("#add_new_av")[0].reset();
        $(".avCreate_error").hide();
    });

    var add_new_av = $("#add_new_av").validate({
        submitHandler: function(form) {
            var category         = form.category.value;
            var value            = form.value.value;
            var description      = form.description.value;
            var opac_description = form.opac_description.value;

            var data = "category="+encodeURIComponent(category)
                +"&value="+encodeURIComponent(value)
                +"&description="+encodeURIComponent(description)
                +"&opac_description="+encodeURIComponent(opac_description);
            $.ajax({
                type: "POST",
                url: "/cgi-bin/koha/svc/authorised_values",
                data: data,
                success: function(response) {
                    $('#avCreate').modal('hide');

                    $(current_select2).append('<option selected value="'+response.value+'">'+response.description+'</option>');
                    $("#avCreate").modal("hide");
                },
                error: function() {
                    $(".avCreate_error").html(__("Something went wrong. Maybe the value already exists?")).show();
                }
            });
            return false;
        }
    });

});
