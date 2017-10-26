//Package Labels.GUI
Labels.GUI = {};
Labels.GUI.setActive = function (event, htmlJqElem) {
    if (!htmlJqElem.hasClass("activeTarget")) {
        var actives = $(".activeTarget").removeClass("activeTarget");
        htmlJqElem.addClass("activeTarget");

        Labels.GUI.Controls.display(htmlJqElem);
    }
    event.stopPropagation();
}
Labels.GUI.deleteActive = function () {
    var object = Labels.GUI.getActive();
    object.remove();
}

Labels.GUI.copyActive = function () {
    var cloned = $(".activeTarget:first");
    var message = $(".alert-errors");
    if(cloned.length == 0) {
        alert(message.find(".item-missing").text());
    }
    var regionid = cloned.attr("id").replace("region","");
    var NextItemId = $('#NewIdValue').val();
    var firstUnusedItem = $( "#regionsDispenser" ).find(".staged").text();
    if(NextItemId.length == 0) {
        alert(message.find(".number-missing").text());
    } else if (parseInt(NextItemId) > parseInt(firstUnusedItem)) {
        alert(message.find(".greater-than").text());
    } else {
        $(".activeTarget:first").removeClass("activeTarget");
        var sheet = Labels.Sheets.getSheet(Labels.GUI.activeSheetId);
        var region = Labels.Regions.getRegion(regionid);
        Labels.Regions.dispenseRegion(sheet, sheet.htmlElem, parseInt(NextItemId), cloned.offset(), region);
        var newDiv = $( "#sheet"+Labels.GUI.activeSheetId ).children().last();
        newDiv.offset({top: cloned.offset().top+10, left: cloned.offset().left+10});
        newDiv.css("width", $(cloned).css("width"));
        newDiv.css("height", $(cloned).css("height"));
        $(cloned).find('.element').clone().appendTo(newDiv);
    }
}

Labels.GUI.getActive = function () {
    var activeElem = $(".activeTarget");
    return Labels.getObjectFromHtmlElem(activeElem);
}
Labels.GUI.reorientOffsetToParent = function (parent, element, offset) {
    var newpos = Labels.GUI.reorientOffset( $(parent).offset(), offset );

    element.css({"top": newpos.top, "left": newpos.left});
}
Labels.GUI.reorientOffset = function (offset1, offset2) {
    var newpos = {};
    newpos.left = offset1.left - offset2.left;
    newpos.top = offset1.top - offset2.top;
    if (newpos.left < 0) {
        newpos.left = newpos.left * -1;
    }
    if (newpos.top < 0) {
        newpos.top = newpos.top * -1;
    }
    return newpos;
}
Labels.GUI.pxToMm = function (pixels) {
    var sheet = Labels.Sheets.getActiveSheet();
    var dpmm = sheet.dpi / 25.4; //Calculate dpi to dpmm
    return (parseFloat(pixels)/dpmm).toFixed(1);
}
Labels.GUI.mmToPx = function (mm) {
    var sheet = Labels.Sheets.getActiveSheet();
    var dpmm = sheet.dpi / 25.4; //Calculate dpi to dpmm
    return (parseFloat(mm) * dpmm).toFixed(1);
}
Labels.GUI.NextItemId = null;
Labels.GUI.init = function (sheet) {
    Labels.GUI.RegionDispenser.clear();

    var item = null;
    var itemIndex = 0; //There might not be an item, so we default.
    for (var ii=1 ; ii < sheet.items.length ; ii++) {
        item = sheet.items[ii];
        itemIndex = item.index;
        Labels.GUI.RegionDispenser.createNewItemHandle(item.index);
        Labels.GUI.RegionDispenser.markUsed(item.index);
    }
    Labels.GUI.RegionDispenser.createNewItemHandle(itemIndex+1); //Create a new Item handle for the next Item.
    Labels.GUI.NextItemId = itemIndex+1;

    if(!Labels.GUI.tooltip) {
        new Labels.GUI.Tooltip("#sheetEditor",{});
    }
    Labels.GUI.Controls.init();
}

//Package Labels.GUI.SheetList
Labels.GUI.sheetlist = null;
Labels.GUI.activeSheetId = null;
Labels.GUI.SheetList = function (params) {
    Labels.GUI.sheetlist = this;
    this.containerElem = params.containerElem;
    this.sheets = params.sheets;
    Labels.GUI.activeSheetId = params.activeSheetId;

    this.display = function () {
        //Sort the Sheets by their order-parameter.
        var sheetIds = Object.keys(this.sheets);
        sheetIds.sort(function(a,b){
            return (a.order < b.order) ? 1 : (a.order > b.order) ? -1 : 0;
        });

        //Iterate in the correct order
        for (var i=0 ; i<sheetIds.length ; i++) {
            var id = sheetIds[i];
            var htmlElem = Labels.GUI.SheetList.createListElement(this, this.sheets[id]);
        }

        //Load the default sheet
        $(this.containerElem).find('input[id="sheetList'+Labels.GUI.activeSheetId+'"]').prop("checked", "true");
    }
    this._createHtmlElems = function () {
        if (Permissions.labels.sheets_mod) {
            $("<button/>",{
                id: "editSheet"
            }).addClass("btn btn-primary").html("Edit").appendTo(this.containerElem)
            .click(function (event) {
                var sheet = Labels.Sheets.getSheet( Labels.GUI.activeSheetId );
                Labels.GUI.SheetEditor.display(sheet);
            });
        }
        if (Permissions.labels.sheets_del) {
            $("<button/>",{
                id: "deleteSheet"
            }).addClass("btn btn-danger").html("Delete").appendTo(this.containerElem)
            .click(function (event) {
                Labels.Sheets.getSheet( Labels.GUI.activeSheetId ).destroy();
                Labels.GUI.SheetList.getSheetListNode( Labels.GUI.activeSheetId ).remove();
            });
        }
        if (Permissions.labels.sheets_new) {
            $("<button/>",{
                id: "newSheet"
            }).addClass("btn btn-success").html("New").appendTo(this.containerElem)
            .click(function (event) {
                var sheet = new Labels.Sheet($("#sheetContainer"), {});
                Labels.GUI.SheetList.createListElement(Labels.GUI.sheetlist, sheet);
            });
        }
        if (Permissions.labels.sheets_new) {
            $("<button/>",{
                id: "importSheet",
                "data-toggle":"modal",
                "data-target":"#importModal"
            }).addClass("btn btn-default").html('<i class="fa fa-upload" aria-hidden="true"></i> Import').appendTo(this.containerElem);
        }
        if (Permissions.labels.sheets_new) {
            $("<a>",{
                id: "exportSheet"
            }).addClass("btn btn-default hidden").html('<i class="fa fa-download" aria-hidden="true"></i> Export').appendTo(this.containerElem);
        }
    }
    this.setSheetListName = function (sheetId, newVal) {
        var sheetListNodeJqHtml = Labels.GUI.SheetList.getSheetListNode(sheetId);
        sheetListNodeJqHtml.find(".title").html(newVal);
    }
    this.setSheetListAuthor = function (sheetId, newVal) {
        var sheetListNodeJqHtml = Labels.GUI.SheetList.getSheetListNode(sheetId);
        sheetListNodeJqHtml.find(".author").html(newVal);
    }
    this.setSheetListVersion = function (sheetId, newVal) {
        var sheetListNodeJqHtml = Labels.GUI.SheetList.getSheetListNode(sheetId);
        sheetListNodeJqHtml.find(".version").html(newVal);
    }

    this._createHtmlElems();
    this.display();
}
Labels.GUI.SheetList.createListElement = function (sheetList, sheet) {
    var html = '<div id="sheetListNode'+sheet.id+'" class="sheetListNode">'+
               '  <input type="radio" id="sheetList'+sheet.id+'" class="sheetList"'+
               '        name="sheetLists" value="'+sheet.id+'"/>'+
               '  <label for="sheetList'+sheet.id+'">'+
               '    <span class="title">'+sheet.name+'</span>'+
               '    <a class="author" href="/cgi-bin/koha/members/moremember.pl?borrowernumber='+sheet.author.borrowernumber+'">'+sheet.author.userid+'</a>'+
               '    <span class="version">'+sheet.version+'</span>'+
               '  </label>'+
               '</div>';
    var htmlElem = $(html);
    $(sheetList.containerElem).append(htmlElem);

    $("#sheetList"+sheet.id).change(function(event) {
        Labels.GUI.activeSheetId = sheet.id;
        Labels.GUI.SheetList.exportSheet(sheet);
    });

    return htmlElem;
}
Labels.GUI.SheetList.getSheetListNode = function (sheetListId) {
    return $("#sheetListNode"+sheetListId);
}

Labels.GUI.SheetList.exportSheet = function (sheet) {
    var data = "text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(sheet));
    $('#exportSheet').attr('href', 'data:' + data).attr('download','sheet'+sheet.id+'.json').removeClass('hidden');
}

Labels.GUI.SheetList.importSheet = function (sheetname, username, userid, file) {
    var sheet = Labels.Sheets.importFile(file);
    sheet.name = sheetname;
    sheet.version = parseFloat(0.1);
    sheet.author.userid = username;
    sheet.author.borrowernumber = parseInt(userid);
    sheet.id = Labels.Sheets.getNewId().toString();

    var response = Labels.Sheets.importToREST(sheet);

    Labels.Sheets.jsonToSheet(response);
    Labels.GUI.SheetList.createListElement(Labels.GUI.sheetlist, response);
}

//Package Labels.GUI.Controls
Labels.GUI.Controls = {};
Labels.GUI.Controls.initialized = null;
Labels.GUI.Controls.init = function () {
    if (!Labels.GUI.Controls.initialized) {
        Labels.GUI.Controls.createElements();
        Labels.GUI.Controls.DataSources.init();
        Labels.GUI.Controls.DataFormats.init();
    }
    Labels.GUI.Controls.initialized = 1;
}
Labels.GUI.Controls.createElements = function () {
    Labels.GUI.Controls.bindEvents();
}
Labels.GUI.Controls.bindEvents = function () {
    $("#selectionControls input, #selectionControls select, #sheetEditorConfig input").change(function (event) {
        Labels.GUI.Controls.handleControlChange($(this));
    });
}
Labels.GUI.Controls.display = function (htmlElem) {
    var object = Labels.getObjectFromHtmlElem(htmlElem);
    if (object instanceof Labels.Sheet) {
        Labels.GUI.Controls.displaySheetControls(object);
    }
    else if (object instanceof Labels.Region) {
        Labels.GUI.Controls.displayRegionControls(object);
    }
    else if (object instanceof Labels.Element) {
        Labels.GUI.Controls.displayElementControls(object);
    }
    else {
        alert("Labels.GUI.Controls.display():> "+object+" is of unknown type");
    }
}
Labels.GUI.Controls.displaySheetControls = function (sheet) {
    $("#selectionControls, #sheetEditorConfig").show(500);
    $("#selectionControls input, #selectionControls select, #sheetEditorConfig input, #sc_copy").parent().hide();

    $("#sc_boundingBox").parent().show();
    if (sheet.boundingBox == true) {
        $("#sc_boundingBox").prop("checked", true);
    }
    else {
        $("#sc_boundingBox").prop("checked", false);
    }
    $("#sc_name").parent().show();
    if (sheet.name) {
        $("#sc_name").val( sheet.name );
    }
    else {
        $("#sc_name").val("");
    }
    $("#sc_dpi").parent().show();
    if (sheet.dpi) {
        $("#sc_dpi").val( sheet.dpi );
    }
    else {
        $("#sc_dpi").val("");
    }

    $("#dataSourceFunctionDocs").hide();
    Labels.GUI.tooltip.publish(sheet, null, "reload");
}
Labels.GUI.Controls.displayRegionControls = function (region) {
    $("#selectionControls, #sheetEditorConfig").show(500);
    $("#selectionControls input, #selectionControls select, #sheetEditorConfig input").parent().hide();

    $("#sc_boundingBox, #sc_copy").parent().show();
    $("#sc_copy").show();
    if (region.boundingBox == true) {
        $("#sc_boundingBox").prop("checked", true);
    }
    else {
        $("#sc_boundingBox").prop("checked", false);
    }

    $("#dataSourceFunctionDocs").hide();
    Labels.GUI.tooltip.publish(region, null, "reload");
}
Labels.GUI.Controls.displayElementControls = function (element) {
    $("#selectionControls, #sheetEditorConfig").show(500);
    $("#selectionControls input, #selectionControls select, #sheetEditorConfig input, #sc_copy").parent().hide();

    $("#sc_dataSource").parent().show();
    if (element.dataSource) {
        $("#sc_dataSource").val( element.dataSource );
    }
    else {
        $("#sc_dataSource").val("");
    }
    $("#sc_dataFormat").parent().show();
    if (element.dataFormat) {
        $("#sc_dataFormat").val( element.dataFormat );
        $("#sc_dataFormat").siblings(".comment").html('');
    }
    else {
        $("#sc_dataFormat").val("");
    }
    $("#sc_fontSize").parent().show();
    if (element.fontSize) {
        $("#sc_fontSize").val( element.fontSize );
    }
    else {
        $("#sc_fontSize").val("");
    }
    $("#sc_font").parent().show();
    if (element.font) {
        $("#sc_font").val( element.font );
    }
    else {
        $("#sc_font").val("");
    }
    $("#sc_customAttr").parent().show();
    if (element.customAttr) {
        $("#sc_customAttr").val( element.customAttr );
    }
    else {
        $("#sc_customAttr").val("");
    }
    $("#sc_colour").parent().show();
    if (element.colour) {
        $("#sc_colour").val( element.colour );
    }
    else {
        $("#sc_colour").val("");
    }
    $("#sc_boundingBox").parent().show();
    if (element.boundingBox == true) {
        $("#sc_boundingBox").prop("checked", true);
    }
    else {
        $("#sc_boundingBox").prop("checked", false);
    }

    $("#dataSourceFunctionDocs").show();
    Labels.GUI.tooltip.publish(element, null, "reload");
}
Labels.GUI.Controls.handleControlChange = function (inputJqElem) {
    var object = Labels.GUI.getActive();
    var value = inputJqElem.val();
    if (inputJqElem.attr("type") == "checkbox") {
        value = (inputJqElem.prop("checked") == true) ?
            value = true : value = false;
    }

    //Dispatch object.set<property>(value) setter call, if available
    var funcName = inputJqElem.attr("id").replace("sc_","");
    funcName = "set" + funcName[0].toUpperCase() + funcName.substr(1); //ucfirst()
    if(object[funcName]) {
        object[funcName](value);
    }
    else {
        //or inject property
        var attribute = inputJqElem.attr("id").replace("sc_","");
        object[attribute] = value;
    }
    if (object.htmlElem.hasClass("exceptionTarget")) {
        object.htmlElem.removeClass("exceptionTarget");
    }
}

//Package Labels.GUI.Controls.DataSources
Labels.GUI.Controls.DataSources = {};
Labels.GUI.Controls.DataSource = function (container, params) {
    this.funcName = params.funcName;
    this.title    = params.title;
    this.doc      = params.doc;
    var self      = this; //Save a reference to this, so we can access self from nested event handler definitions

    this.showErrors = function () {
        var eElem;
        if (!this.funcName) {
            var eElem = $("#dsfd-errors .dsfd-undefined-function-error").clone();
        }
        if (!this.doc) {
            var eElem = $("#dsfd-errors .dsfd-undocumented-function-error").clone();
        }
        if (eElem) {
            var id = Labels.GUI.Controls.DataSources.getId(this.funcName);
            $("#"+id).children(".comment").before(eElem);
        }
    }
    this.template = function () {
        var html =
        '<div class="dsfd-doc" id="'+Labels.GUI.Controls.DataSources.getId(this.funcName)+'">'+
        '    <h5><i class="fa fa-info-circle" aria-hidden="true"></i> '+(this.title || this.funcName)+'</h5><button class="addButton btn btn-default"><i class="fa fa-plus" aria-hidden="true"></i></button>'+
        '    <span class="comment">'+(this.doc || '')+'</span>'+
        '</div>';
        return html;
    }
    this.bindEvents = function () {
        this.htmlElem.children("h5").click(function (event) {
            var commentElem = $(this).parent().children(".comment");
            if (commentElem.is(":visible") == true) {
                $(this).css("color", "");
                commentElem.hide();
            }
            else {
                $(this).css("color", "#0275d8");
                commentElem.show();
            }
            $(this).html(html);
        });
        this.htmlElem.find(".addButton").click(function (event) {
            var functionName = Labels.GUI.Controls.DataSources.getFunctionName(self.htmlElem);
            functionName += "()";
            $("#sc_dataSource").val( functionName );
            $("#sc_dataSource").change(); //Trigger the onChange event handlers to propagate the changed value to underlying objects.

            event.preventDefault();
            event.stopPropagation();
        });
    }
    this.htmlElem = $(this.template());
    $(container).append(this.htmlElem);
    this.bindEvents();
    this.showErrors();
}
Labels.GUI.Controls.DataSources.initialized = false;
Labels.GUI.Controls.DataSources.init = function () {
    var container = $("#dataSourceFunctionDocs");
    if (Labels.GUI.Controls.DataSources.initialized == false) {
        var docs = Labels.GUI.Controls.DataSources.getDocumentation(container);
        var funcs = Labels.GUI.Controls.DataSources.getDefinedFunctions();
        Labels.GUI.Controls.DataSources.createDataSources(container, docs, funcs);
        Labels.GUI.Controls.DataSources.initialized = true;
    }
}
Labels.GUI.Controls.DataSources.getDocumentation = function (parent) {
    var docs = {};
    parent.children(".dsfd-doc").each(function (index, element) {
        var functionName = Labels.GUI.Controls.DataSources.getFunctionName($(element));
        var title = $(element).children(".title").html();
        var docHtml = $(element).children(".comment").html();
        docs[functionName] = {doc: docHtml, title: title};
        $(element).remove();
    });
    return docs;
}
Labels.GUI.Controls.DataSources.getDefinedFunctions = function () {
    if (!(dataSourceFunctions && dataSourceFunctions instanceof Array)) { //dataSourceFunctions is given straight from Koha to templates.
        alert("Prerequisite 'dataSourceFunctions' couldn't be loaded. Please notify your friendly administrator!");
    }
    return dataSourceFunctions;
}
Labels.GUI.Controls.DataSources.createDataSources = function (container, documentsObj, funcsArray) {
    //Merge documents and function names to one list so we can better see missing components
    funcsArray.forEach(function (item, index, array) {
        if (!documentsObj[item]) { documentsObj[item] = {}; }
        documentsObj[item].funcName = item;
    });

    var funcNames = Object.keys(documentsObj);
    funcNames.forEach(function (item, index, array) {
        var obj = documentsObj[item];
        var ds = new Labels.GUI.Controls.DataSource(container, obj);
    });
}
Labels.GUI.Controls.DataSources.getFunctionName = function (jqHtmlElem) {
    return jqHtmlElem.attr("id").replace(/^dsfd-/,"");
}
Labels.GUI.Controls.DataSources.getId = function (funcName) {
    return "dsfd-"+funcName;
}

//Package Labels.GUI.Controls.DataFormats
Labels.GUI.Controls.DataFormats = {};
Labels.GUI.Controls.DataFormats.dataFormats = {};
Labels.GUI.Controls.DataFormat = function (container, documentationContainer, params) {
    this.funcName = params.funcName;
    this.title    = params.title;
    this.doc      = params.doc;
    var self      = this;
    Labels.GUI.Controls.DataFormats.dataFormats[this.funcName] = this;

    this.showErrors = function () {
        var eElem;
        if (!this.funcName) {
            var eElem = $("#dsfod-errors .dsfod-undefined-function-error").clone();
        }
        if (!this.doc) {
            var eElem = $("#dsfod-errors .dsfod-undocumented-function-error").clone();
        }
        if (eElem) {
            eElem.append(" "+this.funcName+"()");
            $(container).prepend(eElem);
        }
    }
    this.template = function () {
        var html =
        '<option value="'+this.funcName+'">'+(this.title || this.funcName)+'</option>'
        return html;
    }
    this.showDocumentation = function () {
        $(documentationContainer).html('').append(this.doc);
    }
    this.bindEvents = function () {
        this.htmlElem.click(function (event) {
            self.showDocumentation();
        });
    }

    this.htmlElem = $(this.template());
    $(container).append(this.htmlElem);
    this.bindEvents();
    this.showErrors();
}
Labels.GUI.Controls.DataFormats.initialized = false;
Labels.GUI.Controls.DataFormats.init = function () {
    var container = $("#sc_dataFormat");
    var documentationContainer = $("#dataFormatDoc");
    if (Labels.GUI.Controls.DataFormats.initialized == false) {
        var docs = Labels.GUI.Controls.DataFormats.getDocumentation(documentationContainer);
        var funcs = Labels.GUI.Controls.DataFormats.getDefinedFunctions();
        Labels.GUI.Controls.DataFormats.createDataFormats(container, documentationContainer, docs, funcs);
        Labels.GUI.Controls.DataFormats.initialized = true;
    }
}
Labels.GUI.Controls.DataFormats.getDocumentation = function (parent) {
    var docs = {};
    parent.children(".dsfod-doc").each(function (index, element) {
        var functionName = Labels.GUI.Controls.DataFormats.getFunctionName($(element));
        var title = $(element).children(".title").html();
        var docHtml = $(element).children(".comment").html();
        docs[functionName] = {doc: docHtml, title: title};
        $(element).remove();
    });
    return docs;
}
Labels.GUI.Controls.DataFormats.getDefinedFunctions = function () {
    if (!(dataFormatFunctions && dataFormatFunctions instanceof Array)) { //dataSourceFunctions is given straight from Koha to templates.
        alert("Prerequisite 'dataFormats' couldn't be loaded. Please notify your friendly administrator!");
    }
    return dataFormatFunctions;
}
Labels.GUI.Controls.DataFormats.createDataFormats = function (container, documentationContainer, documentsObj, funcsArray) {
    //Merge documents and function names to one list so we can better see missing components
    funcsArray.forEach(function (item, index, array) {
        if (!documentsObj[item]) { documentsObj[item] = {}; }
        documentsObj[item].funcName = item;
    });

    var funcNames = Object.keys(documentsObj);
    funcNames.forEach(function (item, index, array) {
        var obj = documentsObj[item];
        var ds = new Labels.GUI.Controls.DataFormat(container, documentationContainer, obj);
    });
}
Labels.GUI.Controls.DataFormats.getFunctionName = function (jqHtmlElem) {
    return jqHtmlElem.attr("id").replace(/^dsfod-/,"");
}
Labels.GUI.Controls.DataFormats.getId = function (funcName) {
    return "dsfod-"+funcName;
}

//Package Labels.GUI.RegionDispenser
Labels.GUI.RegionDispenser = {};
Labels.GUI.RegionDispenser.clear = function () {
    $("#regionsDispenser").html("<h4>Items</h4>");
}
Labels.GUI.RegionDispenser.createNewItemHandle = function (itemIndex) {
    //Don't add a new dispenser if there already is one for the next item.
    if ($('#regionDispenser'+itemIndex).length > 0) {
        return;
    }
    var regionDispenser = $("<div/>", {
                            id: 'regionDispenser'+itemIndex,
                            class: "button item staged"
    }).html(itemIndex);
    regionDispenser.draggable({
        helper: "clone"
    });
    $("#regionsDispenser").append(regionDispenser);
}
Labels.GUI.RegionDispenser.markUsed = function (itemIndex) {
    var regionDispenser = $('#regionDispenser'+itemIndex).removeClass("staged").addClass("deployed");
}
Labels.GUI.RegionDispenser.markUnused = function (itemIndex) {
    var regionDispenser = $('#regionDispenser'+itemIndex).removeClass("deployed").addClass("staged");
}

//Package Labels.GUI.SheetEditor
Labels.GUI.SheetEditor = {};
Labels.GUI.SheetEditor.display = function (sheet) {
    $("#labelPrinter").hide(500);
    $("#sheetContainer .sheet").detach();
    sheet.display();
    $("#sheetEditor").show(500);
}
Labels.GUI.SheetEditor.hide = function () {
    $("#sheetEditor").hide(500);
    $("#labelPrinter").show(500);
}

//Package Labels.GUI.Tooltip
Labels.GUI.tooltip = null; //Reference to the static object
Labels.GUI.Tooltip = function (parentElem, params) {
    Labels.GUI.tooltip = this;
    this.parentElem = $(parentElem);
    var self = this;

    this._template = function () {
        var html =
        '<div id="sheetEditorTooltip">'+
        '  '+MSG_LEFT+': '+
        '  <input type="number" id="sc_left" step="0.1"/>'+
        '  '+MSG_TOP+': '+
        '  <input type="number" id="sc_top" step="0.1"/>'+
        '  '+MSG_WIDTH+': '+
        '  <input type="number" id="sc_width" step="0.1"/>'+
        '  '+MSG_HEIGHT+': '+
        '  <input type="number" id="sc_height" step="0.1"/>'+
        '   mm'+
        '</div>';
        return $(html);
    }
    this._bindEvents = function (htmlElem) {
        htmlElem.draggable();
        htmlElem.children("input").change(function (event) {
            var object = Labels.GUI.getActive();
            var dim = {}; var pos = {};
            pos.left   = Labels.GUI.mmToPx(  $("#sc_left").val()    );
            pos.top    = Labels.GUI.mmToPx(  $("#sc_top").val()     );
            dim.width  = Labels.GUI.mmToPx(  $("#sc_width").val()   );
            dim.height = Labels.GUI.mmToPx(  $("#sc_height").val()  );
            object.setSpacings( dim, pos );

            self._recalculateInputWidth();
        });
    }
    this.render = function () {
        this.parentElem.append(this.htmlElem);
    }

    /**
     * Implements the Subscriber-Publisher pattern.
     * Receives a publication from the Publisher.
     */
    this.publish = function(publisher, data, event) {
        if (event == "resize" || event == "drag" || event == "reload") {
            this._handleResizeEvent(publisher, data, event);
        }
    };
    this._handleResizeEvent = function (publisher, data, event) {
        var posDim = publisher.htmlElem.css(['left','top','width','height']);
        $("#sc_left").val(  Labels.GUI.pxToMm(posDim.left)  );
        $("#sc_top").val(  Labels.GUI.pxToMm(posDim.top)  );
        $("#sc_width").val(  Labels.GUI.pxToMm(posDim.width)  );
        $("#sc_height").val(  Labels.GUI.pxToMm(posDim.height)  );
        this._recalculateInputWidth();
    }
    this._recalculateInputWidth = function () {
        this.htmlElem.find('input[type="number"]').each(function (index, element) {
            var e = $(element);
            var length = String(e.val()).length;
            /*e.css("width", (15+length*6)+"px");*/
        });
    }

    this.htmlElem = this._template();
    this._bindEvents(this.htmlElem);
    this.render();
}
