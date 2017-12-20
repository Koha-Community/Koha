//Package Items.ItemsTableRow
if (typeof Items == "undefined") {
    this.Items = {}; //Set the global package
}

if (typeof Items.ItemsTableView == "undefined") {
    this.Items.ItemsTableView = {}; //Set the global package
}

Items.ItemsTableView.template = function () {
    var html = ""+
    '<thead>'+
    '    <tr>'+
    '        <th class="NoSort"></th>'+
    '        <th>'+MSG_ITEM_TYPE+'</th>'+
    '        <th>'+MSG_CURRENT_LOCATION+'</th>'+
    '        <th>'+MSG_HOME_LIBRARY+'</th>'+
    '        <th>'+MSG_COLLECTION+'</th>'+
    '        <th>'+MSG_CALL_NUMBER+'</th>'+
    '        <th>'+MSG_STATUS+'</th>'+
    '        <th>'+MSG_LAST_SEEN+'</th>'+
    '        <th>'+MSG_BARCODE+'</th>'+
    '        <th>'+MSG_PUBLICATION_DETAILS+'</th>'+
    '        <th>'+MSG_URL+'</th>'+
    '        <th>'+MSG_COPY_NUMBER+'</th>'+
    '        <th>'+MSG_MATERIALS_SPECIFIED+'</th>'+
    '        <th>'+MSG_PUBLIC_NOTES+'</th>'+
    '        <th>'+MSG_SPINE_LABEL+'</th>'+
    '        <th>'+MSG_HOST_RECORDS+'</th>'+
    '        <th class="NoSort"></th>'+
    '        <th class="NoSort"></th>'+
    '    </tr>'+
    '</thead>'+
    '<tbody>'+
    '</tbody>';
    return html;
}

//Introducing some kind of a petit templating javascript unigine.
Items.ItemsTableRowTmpl = {
    ItemsTableRowTmpl: function (item) {
        this.element = Items.ItemsTableRowTmpl.getTableRow(item);
        /**
         * Implements the Subscriber-Publisher pattern.
         * Receives a publication from the Publisher.
         */
        this.publish = function(publisher, data, event) {
            if (event == "place_hold_succeeded") {
                Items.ItemsTableRowTmpl.displayPlaceHoldSucceeded(this, publisher, data);
            }
            if (event == "place_hold_failed") {
                Items.ItemsTableRowTmpl.displayPlaceHoldFailed(this, publisher, data);
            }
        };
    },
    transform: function (item) {
        return [
            '<input id="'+Items.ItemsTableRowTmpl.getId(item)+'" value="'+item.itemnumber+'" name="itemnumber" type="checkbox">',
            (itemTypeImages===true ? '<img src="/intranet-tmpl/prog/img/itemtypeimg/bridge/periodical.gif" alt="'+item.c_itype+'" title="'+item.c_itype+'" />' : '') + item.translated_description,
            (item.c_holdingbranch ? item.c_holdingbranch : ''),
            item.c_homebranch+'<span class="shelvingloc">'+item.c_location+'</span>',
            (item.c_ccode ? item.c_ccode : ''),
            (item.itemcallnumber ? item.itemcallnumber : ''),
            Items.getAvailability(item),
            (item.datelastseen ? item.datelastseen : ''),
            (item.barcode ? '<a href="/cgi-bin/koha/catalogue/moredetail.pl?type=&amp;itemnumber='+item.itemnumber+'&amp;biblionumber='+item.biblionumber+'&amp;bi='+item.biblioitemnumber+'#item'+item.itemnumber+'">'+item.barcode+'</a>' : ""),
            (item.enumchron ? item.enumchron+' <span class="pubdate">('+item.publisheddate+')</span>' : ""),
            (item.uri ? item.uri : ''),
            (item.copynumber ? item.copynumber : ''),
            (item.materials ? item.materials : ''),
            (item.itemnotes ? item.itemnotes : ''),
            '<a href="/cgi-bin/koha/labels/spinelabel-print.pl?barcode='+item.barcode+'" >'+MSG_PRINT_LABEL+'</a>',
            ( item.hostbiblionumber ? '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber='+item.hostbiblionumber+'" >'+item.hosttitle+'</a>' : ''),
            '<a class="btn btn-default btn-xs" href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&amp;biblionumber='+item.biblionumber+'&amp;itemnumber='+item.itemnumber+'#edititem"><i class="fa fa-pencil"></i> '+MSG_EDIT+'</a><br/>',
            '<a class="btn btn-default btn-xs placeHold" onclick="holdPicker.selectItem('+item.itemnumber+')"><i class="fa fa-sticky-note-o"></i> '+MSG_HOLD+'</a>'
        ];
    },
    getSelector: function (item) {
        return "#"+Items.ItemsTableRowTmpl.getId(item);
    },
    getTableRow: function (item) {
        return $(Items.ItemsTableRowTmpl.getSelector(item)).parents("tr");
    },
    getId: function (item) {
        return "itr_"+item.itemnumber;
    },
    displayPlaceHoldSucceeded: function (self, publisher, item) {
        $(self.element).find("button.placeHold").parent().append("<br/><span class='notification' style='color: #00AA00;'>"+MSG_HOLD_PLACED+"</span>");
    },
    displayPlaceHoldFailed: function (self, publisher, errorObject) {
        $(self.element).find("button.placeHold").parent().append("<br/><span class='notification' style='color: #AA0000;'>"+errorObject.error+"</span>");
    }
};
