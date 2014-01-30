//Package Labels
if (typeof Labels == "undefined") {
    this.Labels = {}; //Set the global package
}

Labels.init = function () {
    Labels.Sheets.loadSheets();
}
Labels.getObjectFromHtmlElem = function (htmlElem) {
    if (htmlElem.hasClass("sheet")) {
        return Labels.Sheets.getSheet(htmlElem);
    }
    else if (htmlElem.hasClass("region")) {
        return Labels.Regions.getRegion(htmlElem);
    }
    else if (htmlElem.hasClass("element")) {
        return Labels.Elements.getElement(htmlElem);
    }
}

//Package Labels.Sheets
Labels.Sheets = {};
Labels.Sheets.sheets = {};
Labels.Sheets.getSheetsFromREST = function (callback) {
    $.ajax({
        url: "/api/v1/labels/sheets",
        type: "GET",
        accepts: "application/json",
        success: function (data, textStatus, jqXHR) {
            Labels.Sheets.jsonToSheets(data);
            if (callback) callback(Labels.Sheets.sheets, textStatus, jqXHR);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert(JSON.stringify(jqXHR.responseJSON));
            if (callback) callback(jqXHR, textStatus, errorThrown);
        }
    });
}
Labels.Sheets.deleteToREST = function (sheetId, version) {
    var url = "/api/v1/labels/sheets/"+sheetId;
    if (version) url += "/"+version;
    $.ajax({
        url: url,
        type: "DELETE",
        dataType: "json",
        success: function (data, textStatus, jqXHR) {
            if (callback) callback(data, textStatus, jqXHR);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert(JSON.stringify(jqXHR.responseJSON));
            if (callback) callback(jqXHR, textStatus, errorThrown);
        }
    });
}
Labels.Sheets.saveNewToREST = function (sheet, callback) {
    var json = sheet.toJSON();
    $.ajax({
        url: "/api/v1/labels/sheets",
        type: "POST",
        accepts: "application/json",
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: {sheet: JSON.stringify(json)},
        success: function (data, textStatus, jqXHR) {
            if (callback) callback(data, textStatus, jqXHR);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert(JSON.stringify(jqXHR.responseJSON));
            if (callback) callback(jqXHR, textStatus, errorThrown);
        }
    });
}
Labels.Sheets.saveUpdatedToREST = function (sheet, callback) {
    var json = sheet.toJSON();
    $.ajax({
        url: "/api/v1/labels/sheets",
        type: "PUT",
        accepts: "application/json",
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: {sheet: JSON.stringify(json)},
        success: function (data, textStatus, jqXHR) {
            if (callback) callback(data, textStatus, jqXHR);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert(JSON.stringify(jqXHR.responseJSON));
            if (callback) callback(jqXHR, textStatus, errorThrown);
        }
    });
}
Labels.Sheets.jsonToSheets = function (jsonSheets) {
    for (var si=0 ; si < jsonSheets.length ; si++) {
        var sheetJson = jsonSheets[si];
        if (typeof sheetJson == "string") {
            sheetJson = JSON.parse(sheetJson);
        }
        var sheet = new Labels.Sheet($("#sheetContainer"), sheetJson);

        for (var ii=0 ; ii < sheetJson.items.length ; ii++) {
            var itemJson = sheetJson.items[ii]
            var item = new Labels.Item(sheet, itemJson);

            for (var ri=0 ; ri < itemJson.regions.length ; ri++) {
                var regionJson = itemJson.regions[ri];
                var region = new Labels.Region(item, regionJson);

                for (var ei=0 ; ei < regionJson.elements.length ; ei++) {
                    var elementJson = regionJson.elements[ei];
                    var element = new Labels.Element(region, elementJson);
                }
            }
        }
    }
}
Labels.Sheets.loadSheets = function() {
    Labels.Sheets.getSheetsFromREST(function(sheets, textStatus, errorThrown) {
        if (textStatus == "error") {
            sheets = [];
        }
        new Labels.GUI.SheetList( {containerElem: $("#sheetListContainer"), sheets: sheets, activeSheetId: cachedSheetId} );
    });
}
Labels.Sheets.getNewId = function () {
    var keys = Object.keys(Labels.Sheets.sheets);
    var maxId = 0;
    keys.forEach(function(element, index, array) {
        if (maxId < element) {
            maxId = element;
        }
    });
    return parseInt(maxId)+1;
}
Labels.Sheet = function(parentElem, params) {
    this.name = params.name;
    this.dpi = params.dpi || 100;
    this.id = parseInt(params.id || Labels.Sheets.getNewId()).toString();
    this.version = params.version || 0.0;
    this.author = params.author || loggedinuser;
    this.timestamp = params.timestamp || new Date().toISOString();
    this.boundingBox = (params.boundingBox == "true" || params.boundingBox == true) ? true : false;
    this.items = [];
    this.parentElem = parentElem;
    this.htmlElem = Labels.Sheets.createHtmlElement(this);
    var self = this;
    Labels.Sheets.sheets[this.id] = this;

    this.save = function () {
        //Is the sheet just created and not yet saved?
        //Thus we save it as a new one, starting a sheet-lineage of versions, or
        //only increment the version.
        var babyboygirl = false;
        if (this.version == 0.0) {
            babyboygirl = true;
        }

        this.setAuthor(loggedinuser);
        this.setVersion((parseFloat(this.version)+0.1).toFixed(1));

        var callback = function(payload, textStatus) {
            //If the initial save fails, don't increment version
            if (textStatus == "error" && babyboygirl == true) {
                self.setVersion(0.0);
            }
            if (textStatus == "error" && payload.responseJSON.error) {
                var reCaptures = payload.responseJSON.error.match(/\[element(\d+)\]/);
                var elem = Labels.Elements.getElement(reCaptures[1]);
                elem.htmlElem.addClass('exceptionTarget');
            }
        };
        if (babyboygirl) {
            Labels.Sheets.saveNewToREST(this, callback);
        }
        else {
            Labels.Sheets.saveUpdatedToREST(this, callback);
        }
    }
    this.display = function () {
        $(this.parentElem).append(this.htmlElem);
        Labels.GUI.init(this);
    }
    this.hide = function () {
        $(this.parentElem).remove( this.htmlElem.attr("id") );
    }
    this.refreshSpacings = function () {
        this.dimensions.width  = $(this.htmlElem).css("width");
        this.dimensions.height = $(this.htmlElem).css("height");
    }
    this.getSheet = function () {
        return this;
    }
    this.getItem = function (itemnumber) {
        return this.items[itemnumber];
    }
    this.createItem = function (itemnumber) {
        var item = new Labels.Item(this, {index: itemnumber});
        return item;
    }
    this.addItem = function(item) {
        this.items[item.index] = item;
    }
    this._removeItem = function (item) {
        delete this.items[item.index];
    }
    this.destroy = function () {
        this.htmlElem.remove();
        delete Labels.Sheets.sheets[this.id]; //Flush global pointer
        Labels.Sheets.deleteToREST(this.id, this.version);
    }
    this.setName = function (newName) {
        this.name = newName;
        Labels.GUI.sheetlist.setSheetListName(this.id, this.name);
    }
    this.setAuthor = function (newAuthor) {
        this.author = newAuthor;
        Labels.GUI.sheetlist.setSheetListAuthor(this.id, this.author.userid);
    }
    this.setVersion = function (newVersion) {
        this.version = newVersion;
        Labels.GUI.sheetlist.setSheetListVersion(this.id, this.version);
    }
    this.setDimensions = function (dim) {
        if (!dim) {
            dim = {};
        }
        if (dim.width) {
            this.htmlElem.css("width", dim.width+"px");
        }
        if (dim.height) {
            this.htmlElem.css("height",dim.height+"px");
        }
        this.dimensions = dim;
    }
    this.setSpacings = function (dim, pos) {
        this.setDimensions(dim);
    }
    this.toJSON = function () {
        var me = {};
        me.name = this.name;
        me.dpi = this.dpi;
        me.id = this.id
        me.dimensions = {};
        me.dimensions.width  = Math.round(parseInt(this.dimensions.width));
        me.dimensions.height = Math.round(parseInt(this.dimensions.height));
        me.version = this.version;
        me.author = {};
        me.author.userid = this.author.userid;
        me.author.borrowernumber = this.author.borrowernumber;
        me.timestamp = this.timestamp;
        me.boundingBox = this.boundingBox;
        me.items = [];
        for (index in this.items) {
            me.items.push( this.items[index].toJSON() );
        }
        return me;
    }

    this.setDimensions( params.dimensions );
    this.refreshSpacings();
}
Labels.Sheets.createHtmlElement = function (sheet) {
    var sheetElem = $('<div/>',{
                        id: "sheet"+sheet.id,
                        class: "sheet"
    });
    sheetElem.droppable({
        drop: function( event, ui ) {
          if (ui.draggable.hasClass("item")) {
              var itemnumber = ui.draggable.attr("id").replace("regionDispenser","");
              Labels.Regions.dispenseRegion(sheet, sheetElem, itemnumber, ui.offset);
          }
        }
    }).resizable({
        stop: function (event, ui) {
            sheet.refreshSpacings();
        },
        resize: function (event, ui) {
            Labels.GUI.tooltip.publish(sheet, null, "resize");
        }
    })
    .click(function (event) {
        Labels.GUI.setActive(event, $(this));
    });

    return sheetElem;
}
Labels.Sheets.getSheet = function (htmlElemOrId) {
    var sheet;
    if (typeof htmlElemOrId == "object") { //jQuery object
        var sheetId = Labels.Sheets.getSheetIdFromElem(htmlElemOrId);
        sheet = Labels.Sheets.sheets[sheetId];
    }
    else { //Integer of Id
        sheet = Labels.Sheets.sheets[htmlElemOrId];
    }
    return sheet;
}
Labels.Sheets.getSheetIdFromElem = function (htmlElem) {
    return $(htmlElem).attr("id").replace("sheet","");
}
Labels.Sheets.getActiveSheet = function () {
    return Labels.Sheets.getSheet(  $("#sheetContainer").children(".sheet")  );
}

//Package Labels.Items
Labels.Items = {};
Labels.Item = function(sheet, params) {
    this.index = parseInt(params.index);
    this.regions = {};
    this.sheet = sheet;
    sheet.addItem(this);

    this.createRegion = function (offset) {
        var region = new Labels.Region(this, {});
        if (offset) {
            Labels.GUI.reorientOffsetToParent(this.sheet.htmlElem, region.htmlElem, offset);
            region.refreshSpacings();
        }
        return region;
    }
    this.addRegion = function (region) {
        this.regions[region.id] = region;
    }
    this._removeRegion = function (region) {
        delete this.regions[region.id];
        if (Object.keys(this.regions).length == 0) {
            this.destroy();
        }
    }
    this.getSheet = function () {
        return this.sheet;
    }
    this.destroy = function () {
        this.sheet._removeItem(this);
        Labels.GUI.RegionDispenser.markUnused(this.index);
    }
    this.toJSON = function () {
        var me = {};
        me.index = this.index;
        me.regions = [];
        for (id in this.regions) {
            me.regions.push( this.regions[id].toJSON() );
        }
        return me;
    }
}

//Package Labels.Regions
Labels.Regions = {};
Labels.Regions.regions = {}; //Keep track of all the regions.
Labels.Regions.regionIdDispenser = 0;
Labels.Region = function(item, params) {
    this.id = Labels.Regions.regionIdDispenser++;
    this.boundingBox = (params.boundingBox == "true" || params.boundingBox == true) ? true : false;
    this.elements = [];
    this.item = item;
    //Set references
    this.item.addRegion(this);
    Labels.Regions.regions[this.id] = this;
    this.htmlElem = Labels.Regions.createHtmlElement(this, this.item);

    this.refreshSpacings = function () {
        this.dimensions.width  = $(this.htmlElem).css("width");
        this.dimensions.height = $(this.htmlElem).css("height");
        this.position.left     = $(this.htmlElem).css("left");
        this.position.top      = $(this.htmlElem).css("top");
    }
    this.addElement = function (element) {
        this.elements[element.id] = element;
    }
    this.createElement = function (offset) {
        var element = new Labels.Element(this, {});
        if (offset) {
            Labels.GUI.reorientOffsetToParent(this.htmlElem, element.htmlElem, offset);
            element.refreshSpacings();
        }
        return element;
    }
    this.getSheet = function () {
        return this.item.sheet;
    }
    this.setDimensions = function (dim) {
        if (!dim) {
            dim = {};
        }
        if (dim.width) {
            this.htmlElem.css("width", dim.width+"px");
        }
        if (dim.height) {
            this.htmlElem.css("height",dim.height+"px");
        }
        this.dimensions = dim;
    }
    this.setPosition = function (pos) {
        if (!pos) {
            pos = {};
        }
        if (pos.top) {
            this.htmlElem.css("top", pos.top+"px");
        }
        if (pos.left) {
            this.htmlElem.css("left",pos.left+"px");
        }
        this.position = pos;
    }
    this.setSpacings = function (dim, pos) {
        this.setDimensions(dim);
        this.setPosition(pos);
    }
    this.remove = function () {
        this.htmlElem.remove();
        delete Labels.Regions.regions[this.id]; //Flush global pointer
        this.item._removeRegion(this); //Flush parent pointer
        delete this.item;
    }
    this._removeElement = function (element) {
        delete this.elements[element.id];
    }
    this.toJSON = function () {
        var me = {};
        me.dimensions = {};
        me.dimensions.width  = Math.round(parseInt(this.dimensions.width));
        me.dimensions.height = Math.round(parseInt(this.dimensions.height));
        me.position = {};
        me.position.left = Math.round(parseInt(this.position.left));
        me.position.top = Math.round(parseInt(this.position.top));
        me.boundingBox = this.boundingBox;
        me.elements = [];
        for (id in this.elements) {
            me.elements.push( this.elements[id].toJSON() );
        }
        return me;
    }

    this.setSpacings(params.dimensions, params.position);
}
//Template for Region
Labels.Regions.createHtmlElement = function (region, item) {
    var regionElem = $('<div/>', {
        id:    "region"+region.id,
        class: "region"
    })
    .html('<label class="itemnumber">'+item.index+'</label>');
    $(item.sheet.htmlElem).append(regionElem);
    regionElem
    .draggable({
        stop: function (event, ui) {
            region.refreshSpacings();
        },
        drag: function (event, ui) {
            Labels.GUI.tooltip.publish(region, null, "drag");
        }
    })
    .resizable({
        stop: function (event, ui) {
            region.refreshSpacings();
        },
        resize: function (event, ui) {
            Labels.GUI.tooltip.publish(region, null, "resize");
        }
    });

    //Bind event handlers
    regionElem.click(function( event ) {
        Labels.GUI.setActive(event, $(this));
    });
    regionElem.droppable({
        drop: function( event, ui ) {
            if (ui.draggable.hasClass("elementDispenser")) {
                region.createElement(ui.offset);
            }
        }
    });

    return regionElem;
}
Labels.Regions.dispenseRegion = function (sheet, sheetElem, itemnumber, offset) {
    var item = sheet.getItem(itemnumber);
    if (! item) {
        item = sheet.createItem(itemnumber);
        Labels.GUI.RegionDispenser.createNewItemHandle(parseInt(itemnumber,10)+1);
    }
    Labels.GUI.RegionDispenser.markUsed(itemnumber);
    item.createRegion(offset);
}
Labels.Regions.getRegion = function (htmlElemOrId) {
    var region;
    if (typeof htmlElemOrId == "object") { //jQuery object
        var regionId = Labels.Regions.getRegionIdFromElem(htmlElemOrId);
        region = Labels.Regions.regions[regionId];
    }
    else { //Integer of Id
        region = Labels.Regions.regions[htmlElemOrId];
    }
    return region;
}
Labels.Regions.getRegionIdFromElem = function (htmlElem) {
    return $(htmlElem).attr("id").replace("region","");
}

//Package Labels.Element
Labels.Element = function(region, params) {
    this.id = (region.item.sheet.id*100000)+Labels.Elements.elementIdDispenser++;
    this.boundingBox = (params.boundingBox == "true" || params.boundingBox == true) ? true : false;
    this.region = region;
    this.region.addElement(this);
    Labels.Elements.elements[this.id] = this;
    this.htmlElem = Labels.Elements.createHtmlElement(this);

    this.refreshSpacings = function () {
        this.dimensions.width  = $(this.htmlElem).css("width");
        this.dimensions.height = $(this.htmlElem).css("height");
        this.position.left     = $(this.htmlElem).css("left");
        this.position.top      = $(this.htmlElem).css("top");
    }
    this.remove = function () {
        this.htmlElem.remove();
        delete Labels.Elements.elements[this.id]; //Flush global pointer
        this.region._removeElement(this); //Flush parent pointer
        delete this.region; //Flush pointer to parent
    }
    this.getSheet = function () {
        return this.region.item.sheet;
    }
    this.setDataSource = function (newDataSource) {
        this.dataSource = newDataSource;
        this.htmlElem.children(".dataSource").html(this.dataSource);
    }
    this.setDataFormat = function (newDataFormat) {
        this.dataFormat = newDataFormat;
        this.htmlElem.children(".dataFormat").html(this.dataFormat);
    }
    this.setColour = function (newColour) {
        var tc = tinycolor(newColour);
        this.colour = "#"+tc.toHex() || "#000000";
        this.htmlElem.css("color", this.colour);
    }
    this.setCustomAttr = function (newCustomAttr) {
        this.customAttr = newCustomAttr;
    }
    this.setFontSize = function (newFS) {
        this.fontSize = newFS || 12;
        this.htmlElem.css("font-size", this.fontSize+"px");
    }
    this.setFont = function (newF) {
        this.font = newF;
    }
    this.setDimensions = function (dim) {
        if (!dim) {
            dim = {};
        }
        if (dim.width) {
            this.htmlElem.css("width", dim.width+"px");
        }
        if (dim.height) {
            this.htmlElem.css("height",dim.height+"px");
        }
        this.dimensions = dim;
    }
    this.setPosition = function (pos) {
        if (!pos) {
            pos = {};
        }
        if (pos.top) {
            this.htmlElem.css("top", pos.top+"px");
        }
        if (pos.left) {
            this.htmlElem.css("left",pos.left+"px");
        }
        this.position = pos;
    }
    this.setSpacings = function (dim, pos) {
        this.setDimensions(dim);
        this.setPosition(pos);
    }
    this.toJSON = function () {
        var me = {};
        me.id = this.id;
        me.dimensions = {};
        me.dimensions.width  = Math.round(parseInt(this.dimensions.width));
        me.dimensions.height = Math.round(parseInt(this.dimensions.height));
        me.position = {};
        me.position.left = Math.round(parseInt(this.position.left));
        me.position.top = Math.round(parseInt(this.position.top));
        me.boundingBox = this.boundingBox;
        me.dataSource = this.dataSource;
        me.dataFormat = this.dataFormat;
        me.fontSize = this.fontSize;
        me.font = this.font;
        var tc = tinycolor(this.colour);
        me.customAttr = this.customAttr;
        me.colour = tc.toRgb();
        return me;
    }

    this.setDataSource(params.dataSource);
    this.setDataFormat(params.dataFormat);
    this.setFontSize(parseInt(params.fontSize));
    this.setFont(params.font);
    this.setCustomAttr(params.customAttr);
    this.setColour(params.colour);
    this.setSpacings(params.dimensions, params.position);
}

//Package Labels.Elements
Labels.Elements = {};
Labels.Elements.elements = {};
Labels.Elements.elementIdDispenser = 0;
Labels.Elements.createHtmlElement = function (element) {
    var elementElem = $('<div/>', {
                class: "element",
                id: "element"+element.id
    }).html('<div class="dataSource"></div><div class="dataFormat"></div>');

    $(element.region.htmlElem).append(elementElem);
    elementElem
    .draggable({
        stop: function (event, ui) {
            element.refreshSpacings();
        },
        drag: function (event, ui) {
            Labels.GUI.tooltip.publish(element, null, "drag");
        }
    })
    .resizable({
        stop: function (event, ui) {
            element.refreshSpacings();
        },
        resize: function (event, ui) {
            Labels.GUI.tooltip.publish(element, null, "resize");
        }
    })
    .click(function( event ) {
        Labels.GUI.setActive(event, $(this));
    });

    return elementElem;
}
Labels.Elements.getElement = function (htmlElemOrId) {
    var element;
    if (typeof htmlElemOrId == "object") { //jQuery object
        var elementId = Labels.Elements.getElementIdFromElem(htmlElemOrId);
        element = Labels.Elements.elements[elementId];
    }
    else { //Integer of Id
        element = Labels.Elements.elements[htmlElemOrId];
    }
    return element;
}
Labels.Elements.getElementIdFromElem = function (htmlElem) {
    return $(htmlElem).attr("id").replace("element","");
}
