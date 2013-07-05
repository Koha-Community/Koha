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
    var mainstring="";
    var inputs = element.parentNode.parentNode.getElementsByTagName("input");

    for (var myindex =0; myindex<inputs.length;myindex++){
        if (inputs[myindex].name && inputs[myindex].name.match(tagsubfield)){
            var subfieldcode=getSubfieldCode(inputs[myindex].name);
            if (isNaN(parseInt(subfieldcode)) && inputs[myindex].value != "" && subfieldcode!=elementsubfcode){
                mainstring=inputs[myindex].value+" "+mainstring;
            }
        }
    }
    newin=window.open("../authorities/auth_finder.pl?source="+source+"&authtypecode="+authtype+"&index="+tagsubfieldid+"&value_mainstr="+encodeURI(mainmainstring)+"&value_main="+encodeURI(mainstring), "_blank",'width=700,height=550,toolbar=false,scrollbars=yes');
}

function ExpandField(index) {
    var original = document.getElementById(index); //original <div>
    var divs = original.getElementsByTagName('div');
    for(var i=0,divslen = divs.length ; i<divslen ; i++){   // foreach div
        if(divs[i].getAttribute('id').match(/^subfield/)){  // if it s a subfield
            if (!divs[i].style.display) {
                // first time => show all subfields
                divs[i].style.display = 'block';
            } else if (divs[i].style.display == 'none') {
                // show
                divs[i].style.display = 'block';
            } else {
                // hide
                divs[i].style.display = 'none';
            }
        }
    }
}
/**
 * To clone a field
 * @param hideMarc '0' for false, '1' for true
 * @param advancedMARCEditor '0' for false, '1' for true
 */
function CloneField(index, hideMarc, advancedMARCEditor) {
    var original = document.getElementById(index); //original <div>
    var clone = original.cloneNode(true);
    var new_key = CreateKey();
    var new_id  = original.getAttribute('id')+new_key;

    clone.setAttribute('id',new_id); // setting a new id for the parent div

    var divs = clone.getElementsByTagName('div');

    // if hide_marc, indicators are hidden fields
    // setting a new name for the new indicator
    for(var i=0; i < 2; i++) {
        var indicator = clone.getElementsByTagName('input')[i];
        indicator.setAttribute('name',indicator.getAttribute('name')+new_key);
    }

    // settings all subfields
    for(var i=0,divslen = divs.length ; i<divslen ; i++){      // foreach div
        if(divs[i].getAttribute("id").match(/^subfield/)){  // if it s a subfield

            // set the attribute for the new 'div' subfields
            divs[i].setAttribute('id',divs[i].getAttribute('id')+new_key);

            var inputs   = divs[i].getElementsByTagName('input');
            var id_input = "";

            for( j = 0 ; j < inputs.length ; j++ ) {
                if(inputs[j].getAttribute("id") && inputs[j].getAttribute("id").match(/^tag_/) ){
                    inputs[j].value = "";
                }
            }

            inputs[0].setAttribute('id',inputs[0].getAttribute('id')+new_key);
            inputs[0].setAttribute('name',inputs[0].getAttribute('name')+new_key);
            var id_input;
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
                    var textaeras = divs[i].getElementsByTagName('textarea');
                    id_input = textaeras[0].getAttribute('id')+new_key;
                    textaeras[0].setAttribute('id',id_input);
                    textaeras[0].setAttribute('name',textaeras[0].getAttribute('name')+new_key);
                }
            }

            if (advancedMARCEditor == '0') {
                // when cloning a subfield, re set its label too.
                var labels = divs[i].getElementsByTagName('label');
                labels[0].setAttribute('for',id_input);
            }

            if(hideMarc == '0') {
                // updating javascript parameters on button up
                var imgs = divs[i].getElementsByTagName('img');
                imgs[0].setAttribute('onclick',"upSubfield(\'"+divs[i].getAttribute('id')+"\');");
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
                            var buttonDotOnClick = buttonDot.getAttribute('onclick');
                            if(buttonDotOnClick.match('Clictag')){   // -1- It s a plugin
                                var re = /\('.*'\)/i;
                                buttonDotOnClick = buttonDotOnClick.replace(re,"('"+inputs[1].getAttribute('id')+"')");
                                if(buttonDotOnClick){
                                    buttonDot.setAttribute('onclick',buttonDotOnClick);
                                }
                            } else {
                                if(buttonDotOnClick.match('Dopop')) {  // -2- It's a auth value
                                    var re1 = /&index=.*',/;
                                    var re2 = /,.*\)/;

                                    buttonDotOnClick = buttonDotOnClick.replace(re1,"&index="+inputs[1].getAttribute('id')+"',");
                                    buttonDotOnClick = buttonDotOnClick.replace(re2,",'"+inputs[1].getAttribute('id')+"')");

                                    if(buttonDotOnClick){
                                            buttonDot.setAttribute('onclick',buttonDotOnClick);
                                    }
                                }
                            }
                            try {
                                // do not copy the script section.
                                var script = spans[0].getElementsByTagName('script')[0];
                                spans[0].removeChild(script);
                            } catch(e) {
                                // do nothing if there is no script
                            }
                        }catch(e){}
                    }
                }
            }
            if(hideMarc == '0') {
                var buttonUp = divs[i].getElementsByTagName('img')[0];
                buttonUp.setAttribute('onclick',"upSubfield('" + divs[i].getAttribute('id') + "')");
            }

        } else { // it's a indicator div
            if(divs[i].getAttribute('id').match(/^div_indicator/)){

                // setting a new id for the indicator div
                divs[i].setAttribute('id',divs[i].getAttribute('id')+new_key);

                var inputs = divs[i].getElementsByTagName('input');
                inputs[0].setAttribute('id',inputs[0].getAttribute('id')+new_key);
                inputs[1].setAttribute('id',inputs[1].getAttribute('id')+new_key);

                var CloneButtonPlus;
                try {
                    var anchors = divs[i].getElementsByTagName('a');
                    for (var j = 0; j < anchors.length; j++) {
                        if (anchors[j].getAttribute('class') == 'buttonPlus') {
                            anchors[j].setAttribute('onclick',"CloneField('" + new_id + "','" + hideMarc + "','" + advancedMARCEditor + "'); return false;");
                        } else if (anchors[j].getAttribute('class') == 'buttonMinus') {
                            anchors[j].setAttribute('onclick',"UnCloneField('" + new_id + "'); return false;");
                        } else if (anchors[j].getAttribute('class') == 'expandfield') {
                            anchors[j].setAttribute('onclick',"ExpandField('" + new_id + "'); return false;");
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
}

/**
 * To clone a subfield
 * @param index
 * @param advancedMARCEditor '0' for false, '1' for true
 */
function CloneSubfield(index, advancedMARCEditor){
    var original = document.getElementById(index); //original <div>
    var clone = original.cloneNode(true);
    var new_key = CreateKey();

    // set the attribute for the new 'div' subfields
    var inputs     = clone.getElementsByTagName('input');
    var selects    = clone.getElementsByTagName('select');
    var textareas  = clone.getElementsByTagName('textarea');
    var linkid;

    // input
    var id_input = "";
    for(var i=0,len=inputs.length; i<len ; i++ ){
        id_input = inputs[i].getAttribute('id')+new_key;
        inputs[i].setAttribute('id',id_input);
        inputs[i].setAttribute('name',inputs[i].getAttribute('name')+new_key);
        linkid = id_input;
    }

    // select
    for(var i=0,len=selects.length; i<len ; i++ ){
        id_input = selects[i].getAttribute('id')+new_key;
        selects[i].setAttribute('id',selects[i].getAttribute('id')+new_key);
        selects[i].setAttribute('name',selects[i].getAttribute('name')+new_key);
    }

    // textarea
    for(var i=0,len=textareas.length; i<len ; i++ ){
        id_input = textareas[i].getAttribute('id')+new_key;
        textareas[i].setAttribute('id',textareas[i].getAttribute('id')+new_key);
        textareas[i].setAttribute('name',textareas[i].getAttribute('name')+new_key);
    }

    // Changing the "..." link's onclick attribute for plugin callback
    var links  = clone.getElementsByTagName('a');
    var link = links[0];
    var buttonDotOnClick = link.getAttribute('onclick');
    if(buttonDotOnClick.match('Clictag')){   // -1- It s a plugin
    var re = /\('.*'\)/i;
        buttonDotOnClick = buttonDotOnClick.replace(re,"('"+linkid+"')");
        if(buttonDotOnClick){
        link.setAttribute('onclick',buttonDotOnClick);
        }
    }

    if(advancedMARCEditor == '0') {
        // when cloning a subfield, reset its label too.
        var label = clone.getElementsByTagName('label')[0];
        label.setAttribute('for',id_input);
    }

    // setting a new id for the parent div
    var new_id  = original.getAttribute('id')+new_key;
    clone.setAttribute('id',new_id);

    try {
        var buttonUp = clone.getElementsByTagName('img')[0];
        buttonUp.setAttribute('onclick',"upSubfield('" + new_id + "')");
        var anchors = clone.getElementsByTagName('a');
        if(anchors.length){
            for(var i = 0 ,lenanchors = anchors.length ; i < lenanchors ; i++){
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

/**
 * This function allows to move a subfield up by clickink on the 'up' button .
 */
function upSubfield(index) {
    try{
        var line = document.getElementById(index); // get the line where the user has clicked.
    } catch(e) {
        return; // this line doesn't exist...
    }
    var tag = line.parentNode; // get the dad of this line. (should be "<div id='tag_...'>")

    // getting all subfields for this tag
    var subfields = tag.getElementsByTagName('div');
    var subfieldsLength = subfields.length;

    if(subfieldsLength<=1) return; // nothing to do if there is just one subfield.

    // among all subfields
    for(var i=0;i<subfieldsLength;i++){
        if(subfields[i].getAttribute('id') == index){ //looking for the subfield which is clicked :
            if(i==1){ // if the clicked subfield is on the top
                tag.appendChild(subfields[1]);
                return;
            } else {
                var lineAbove = subfields[i-1];
                tag.insertBefore(line,lineAbove);
                return;
            }
        }
    }
}

// FIXME :: is it used ?
function unHideSubfield(index,labelindex) {
    subfield = document.getElementById(index);
    subfield.style.display = 'block';
    label = document.getElementById(labelindex);
    label.style.display='none';
}

/* Functions developed for additem.tt */

/**
 * To clone a subfield.<br>
 * @param original subfield div to clone
 */
function CloneItemSubfield(original){
    var clone = original.cloneNode(true);
    var new_key = CreateKey();

    // set the attribute for the new 'div' subfields
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
    for(var i=0,len=selects.length; i<len ; i++ ){
        id_input = selects[i].getAttribute('id')+new_key;
        selects[i].setAttribute('id',selects[i].getAttribute('id')+new_key);
    }

    // textarea
    for(var i=0,len=textareas.length; i<len ; i++ ){
        id_input = textareas[i].getAttribute('id')+new_key;
        textareas[i].setAttribute('id',textareas[i].getAttribute('id')+new_key);
    }

    // when cloning a subfield, reset its label too.
    var label = clone.getElementsByTagName('label')[0];
    label.setAttribute('for',id_input);

    // setting a new if for the parent div
    var new_id = original.getAttribute('id')+new_key;
    clone.setAttribute('id',new_id);

    // insert this line on the page
    original.parentNode.insertBefore(clone,original.nextSibling);
}

/**
 * Check mandatory subfields of a cataloging form and adds <code>missing</code> class to those who are empty.<br>
 * @param p the parent object of subfields to check
 * @return the number of empty mandatory subfields
 */
function CheckMandatorySubfields(p){
    var total = 0;
    $(p).find(".subfield_line input[name='mandatory'][value='1']").each(function(i){
        var editor = $(this).siblings("[name='field_value']");
        if (!editor.val()) {
            editor.addClass("missing");
            total++;
        }
    });
    return total;
}
