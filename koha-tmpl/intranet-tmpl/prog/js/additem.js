function addItem( node, unique_item_fields ) {
    var index = $(node).closest("div").attr('id');
    var current_qty = parseInt($("#quantity").val());
    var max_qty;
    if($("#quantity_to_receive").length != 0){
        max_qty = parseInt($("#quantity_to_receive").val());
    } else  {
        max_qty = 99999;
    }
    if ( $("#items_list table").find('tr[idblock="' + index + '"]').length == 0 ) {
        if ( current_qty < max_qty ) {
            if ( current_qty < max_qty - 1 )
                cloneItemBlock(index, unique_item_fields);
            addItemInList(index, unique_item_fields);
            $("#" + index).find("input[name='buttonPlus']").val( (window.MSG_ADDITEM_JS_UPDATEITEM ) );
            $("#"+ index).find("input[name='buttonPlusMulti']").remove();
            $("#" + index).find("input[name='multiValue']").remove();
            $("#quantity").val(current_qty + 1).change();
        } else if ( current_qty >= max_qty ) {
            alert(window.MSG_ADDITEM_JS_CANT_RECEIVE_MORE_ITEMS
                || "You can't receive any more items.");
        }
    } else {
        if ( current_qty < max_qty )
            cloneItemBlock(index, unique_item_fields);
        var tr = constructTrNode(index);
        $("#items_list table").find('tr[idblock="' + index + '"]:first').replaceWith(tr);
    }
    $("#" + index).hide();
}

function addMulti( count, node, unique_item_fields){
    var index = $(node).closest("div").attr('id');
    var countItemsBefore = $("#items_list tbody tr").length;
    var current_qty = parseInt( $('#quantity').val(), 10 );
    $("#procModal").modal('show');
    $("#" + index).hide();
    for(var i=0;i<count;i++){
       cloneItemBlock(index, unique_item_fields, function(cloneIndex){
            addItemInList(cloneIndex,unique_item_fields, function(){
                    if( ($("#items_list tbody tr").length-countItemsBefore)==(count)){
                        $("#multiValue").val('');
                        $('#'+index).appendTo('#outeritemblock');
                        $('#'+index).show();
                        $('#'+index + ' #add_multiple_copies' ).css("visibility","hidden");
                        $("#procModal").modal('hide');
                    }
            });
            $("#" + cloneIndex).find("input[name='buttonPlus']").val( (window.MSG_ADDITEM_JS_UPDATEITEM ) );
            $("#" + cloneIndex).find("input[name='buttonPlusMulti']").remove();
            $("#" + cloneIndex).find("input[name='multiValue']").remove();
            $("#" + cloneIndex).hide();
            current_qty++;
            $('#quantity').val( current_qty );
       });
    }
}


function checkCount(node, unique_item_fields){
    var count = parseInt( $("#multiValue").val(), 10 );
    if ( isNaN( count ) || count <=0) {
        $("#multiCountModal").modal('show');
    }
    else{
        addMulti( count, node, unique_item_fields);
    }
}

function showItem(index) {
    $("#outeritemblock").children("div").each(function(){
        if ( $(this).attr('id') == index ) {
            $(this).show();
        } else {
            if ( $("#items_list table").find('tr[idblock="' + $(this).attr('id') + '"]').length == 0 ) {
                $(this).remove();
            } else {
                $(this).hide();
            }
        }
    });
}

function constructTrNode(index, unique_item_fields) {
    var fields = ['barcode', 'homebranch', 'holdingbranch', 'notforloan',
        'restricted', 'location', 'itemcallnumber', 'copynumber',
        'stocknumber', 'ccode', 'itype', 'materials', 'itemnotes'];

    var result = "<tr idblock='" + index + "'>";
    var edit_link = "<a href='#itemfieldset' style='text-decoration:none' onclick='showItem(\"" + index + "\");'>"
        + (window.MSG_ADDITEM_JS_EDIT || "Edit") + "</a>";
    var del_link = "<a style='cursor:pointer' "
        + "onclick='deleteItemBlock(this, \"" + index + "\", \"" + unique_item_fields + "\");'>"
        + (window.MSG_ADDITEM_JS_DELETE || "Delete") + "</a>";
    result += "<td>" + edit_link + "</td>";
    result += "<td>" + del_link + "</td>";
    for(i in fields) {
        var field = fields[i];
        var field_elt = $("#" + index)
            .find("[name='kohafield'][value='items."+field+"']")
            .prevAll("[name='field_value']")[0];
        var field_value;
        if($(field_elt).is('select')) {
            field_value = $(field_elt).find("option:selected").text();
        } else {
            field_value = $(field_elt).val();
        }
        if (field_value == undefined) {
            field_value = '';
        }
        result += "<td>" + field_value + "</td>";
    }
    result += "</tr>";

    return result;
}

function addItemInList(index, unique_item_fields, callback) {
    $("#items_list").show();
    var tr = constructTrNode(index, unique_item_fields);
    $("#items_list table tbody").append(tr);
    if (typeof callback === "function"){
        callback();
    }
}

function deleteItemBlock(node_a, index, unique_item_fields) {
    $("#" + index).remove();
    var current_qty = parseInt($("#quantity").val());
    var max_qty;
    if($("#quantity_to_receive").length != 0) {
        max_qty = parseInt($("#quantity_to_receive").val());
    } else {
        max_qty = 99999;
    }
    $("#quantity").val(current_qty - 1).change();
    $(node_a).parents('tr').remove();
    if(current_qty - 1 == 0)
        $("#items_list").hide();

    if ( $("#quantity").val() <= max_qty - 1) {
        if ( $("#outeritemblock").children("div :visible").length == 0 ) {
            $("#outeritemblock").children("div:last").show();
        }
    }
    if ( $("#quantity").val() == 0 && $("#outeritemblock > div").length == 0) {
        cloneItemBlock(0, unique_item_fields);
    }
}

function cloneItemBlock(index, unique_item_fields, callback) {
    var original;
    if(index) {
        original = $("#" + index); //original <div>
    }
    var dont_copy_fields = new Array();
    if(unique_item_fields) {
        var dont_copy_fields = unique_item_fields.split(' ');
        for(i in dont_copy_fields) {
            dont_copy_fields[i] = "items." + dont_copy_fields[i];
        }
    }

    $.ajax({
        url: "/cgi-bin/koha/services/itemrecorddisplay.pl",
        dataType: 'html',
        data: {
            frameworkcode: 'ACQ'
        },
        success: function(data, textStatus, jqXHR) {
            /* Create the item block */
            var random = Math.floor(Math.random()*100000); // get a random itemid.
            var clone = $("<div/>", { id: 'itemblock'+random });
            $("#outeritemblock").append(clone);
            $(clone).append(data);
            /* Change all itemid fields value */
            $(clone).find("input[name='itemid']").each(function(){
                $(this).val(random);
            });
            /* Add buttons + and Clear */
            var buttonPlus = "<fieldset class=\"action\">";
                buttonPlus += '<input type="button" class="addItemControl" name="buttonPlus" style="cursor:pointer; margin:0 1em;" onclick="addItem(this,\'' + unique_item_fields + '\')" value="' + (window.MSG_ADDITEM_JS_ADDITEM || 'Add item')+ '" />';
                buttonPlus += '<input type="button" class="addItemControl cancel" name="buttonClear" style="cursor:pointer;" onclick="clearItemBlock(this)" value="' + (window.MSG_ADDITEM_JS_CLEAR || 'Clear')+ '" />';
                buttonPlus += '<input type="button" class="addItemControl" name="buttonPlusMulti" onclick="javascript:this.nextSibling.style.display=\'inline\'; return false;" style="cursor:pointer; margin:0 1em;" value="' + (window.MSG_ADDITEM_JS_ADDMULTI || 'Add multiple items')+ '" />';
                buttonPlus += '<span id="add_multiple_copies" style="display:none">'
                            +     '<input type="number" class="addItemControl" id="multiValue" name="multiValue" placeholder="'+window.MSG_ADDITEM_JS_MULTIVAL+'" />'
                            +     '<input type="button" class="addItemControl" name=buttonAddMulti" style="cursor:pointer; margin:0 1em;" onclick="checkCount( this ,\'' + unique_item_fields + '\')" value="' + (window.MSG_ADDITEM_JS_SUBMITMULTI || 'Add') + '" />'
                            +     '<div class="dialog message">' + window.MSG_ADDITEM_JS_MULTI_UNIQUE_NOTE + '</div>'
                            + '</span>';
                buttonPlus += "</fieldset>";
            $(clone).append(buttonPlus);
            /* Copy values from the original block (input) */
            $(original).find("input[name='field_value']").each(function(){
                var kohafield = $(this).siblings("input[name='kohafield']").val();
                if($(this).val() && $.inArray(kohafield,dont_copy_fields) == -1) {
                    $(this).parent("div").attr("id").match(/^(subfield.)/);
                    var id = RegExp.$1;
                    var value = $(this).val();
                    $(clone).find("div[id^='"+id+"'] input[name='field_value']").val(value);
                }
            });
            /* Copy values from the original block (select) */
            $(original).find("select[name='field_value']").each(function(){
                var kohafield = $(this).siblings("input[name='kohafield']").val();
                if($(this).val() && $.inArray(kohafield,dont_copy_fields) == -1) {
                    $(this).parent("div").attr("id").match(/^(subfield.)/);
                    var id = RegExp.$1;
                    var value = $(this).val();
                    $(clone).find("div[id^='"+id+"'] select[name='field_value']").val(value);
                }
            });

            if (typeof callback === "function"){
                var cloneIndex = "itemblock"+random;
                callback(cloneIndex);
            }
            BindPluginEvents(data);
        }
    });
}

function BindPluginEvents(data) {
// the script tag in data for plugins contains a document ready that binds
// the events for the plugin
// when we append, this code does not get executed anymore; so we do it here
    var events= data.match(/BindEventstag_\d+_subfield_._\d+/g);
    if ( events == null ) return;
    for(var i=0; i<events.length; i++) {
        window[events[i]]();
        if( i<events.length-1 && events[i]==events[i+1] ) { i++; }
            // normally we find the function name twice
    }
}

function clearItemBlock(node) {
    var index = $(node).closest("div").attr('id');
    var block = $("#"+index);
    $(block).find("input[type='text']").each(function(){
        $(this).val("");
    });
    $(block).find("select").each(function(){
        $(this).find("option:first").attr("selected", true);
    });
}

function check_additem(unique_item_fields) {
    var success = true;
    var data = new Object();
    data['field'] = new Array();
    data['value'] = new Array();
    var array_fields = unique_item_fields.split(' ');
    $(".error").empty(); // Clear error div

    // Check if a value is duplicated in form
    for ( field in array_fields ) {
        var fieldname = array_fields[field];
        if (fieldname == '') {
            continue;
        }
        var values = new Array();
        $("[name='kohafield'][value='items."+ fieldname +"']").each(function(){
            var input = $(this).prevAll("input[name='field_value']")[0];
            if($(input).val()) {
                values.push($(input).val());
                data['field'].push(fieldname);
                data['value'].push($(input).val());
            }
        });

        var sorted_arr = values.sort();
        for (var i = 0; i < sorted_arr.length - 1; i += 1) {
            if (sorted_arr[i + 1] == sorted_arr[i]) {
                $(".error").append(
                    fieldname + " '" + sorted_arr[i] + "' "
                    + (window.MSG_ADDITEM_JS_IS_DUPLICATE || "is duplicated")
                    + "<br/>");
                success = false;
            }
        }
    }

    // If there is a duplication, we raise an error
    if ( success == false ) {
        $(".error").show();
        return false;
    }

    $.ajax({
        url: '/cgi-bin/koha/acqui/check_uniqueness.pl',
        async: false,
        dataType: 'json',
        data: data,
        success: function(data) {
            for (field in data) {
                success = false;
                for (var i=0; i < data[field].length; i++) {
                    var value = data[field][i];
                    $(".error").append(
                        field + " '" + value + "' "
                        + (window.MSG_ADDITEM_JS_ALREADY_EXISTS_IN_DB
                            || "already exists in database")
                        + "<br />"
                    );
                }
            }
        }
    });

    if ( success == false ) {
        $(".error").show();
    }
    return success;
}

