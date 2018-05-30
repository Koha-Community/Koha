//Package Items.ItemsTable
if (typeof Items == "undefined") {
    this.Items = {}; //Set the global package
}
Items.ItemsTable = {

    instances: {}, //Store created instances here for easy retrieval by the id.
    addInstance: function(self) {
        var id = $(self.node).attr("id");
        Items.ItemsTable.instances[id] = self;
    },

    /**
     * Gets an instance of ItemsTable, or "undefined" if no instances available.
     * @param {string} id, the HTML element id hosting the ItemsTable.
     */
    getInstance: function(id) {
        return Items.ItemsTable.instances[id];
    },

    /**
     * Represents the serials in our database in a graph form.
     * @constructor
     * @param {Object} a configuration JSON, containing the following keys:
     *     @param {jQuery Node} 'node' - root element, in which element will this map be built into? Must be a <table>!
     *     @param {String} 'dataSource' - "ajax" or null
     *     @param {jQuery Node} 'datatable' - The jQuery datatable which is used to display the results.
     *     @param {long} 'biblionumber' - For which Biblio is this graph generated for?
     *     @param {String} 'loggedinbranch' - In which branch are we? Show first results from this branch.
     *     @param {Array of Int} 'hiddencolumns', Column indexes starting from 0, which should always be hidden.
     *     @param {function} 'callback' - the callback function to call when this object has been constructed.
     *         the callback function gets two parameters:
     *         @param {ItemsTable} this - This object just created.
     *         @param {String} errorString - "undefined" if nothing bad happened, otherwise the error description.
     */
    ItemsTable: function(params) {
        this.node = params.node;
        this.biblionumber = params.biblionumber;
        this.events = {};
        this.datasource = params.datasource;
        this.datatable = params.datatable;
        this.loggedinbranch = params.loggedinbranch;
        this.hiddencolumns = (params.hiddencolumns ? params.hiddencolumns : []);
        if (typeof params.callback == "function") {
            this.events.callback = callback;
        }
        else if (typeof params.callback == "undefined") {
            //it is ok if there is no callback
        }
        else {
            alert("ItemsTable.ItemsTable(node, biblionumber, callback):> Callback is not a 'function' or 'undefined'!");
        }
        Items.ItemsTable.addInstance(this);
        var htmlTableContent = Items.ItemsTableView.template();
        var aoColumns = [];

        $(this.node).html(htmlTableContent);
        var thead_row = this.datatable.find('thead tr');
        var clone = thead_row.clone().addClass('filters_row');
        clone.find("th.NoSort").html('');
        thead_row.before(clone);
        filters_row = this.datatable.find('thead tr.filters_row');

        this.datatable.DataTable($.extend(true, {}, dataTablesDefaults, {
            'sDom': 't',
            'bPaginate': false,
            'bAutoWidth': false,
            "aoColumnDefs": [
                    { "aTargets": [ "NoSort" ], "bSortable": false, "bSearchable": false }
                ]
        }));
        filters_row.find('th').each(function() {
                if (this.className.match(/NoSort/)){
                    aoColumns.push(null);
                } else {
                    aoColumns.push('text');
                }
        });
        this.datatable.dataTable().columnFilter({
            'sPlaceHolder': 'head:after',
            'aoColumns': aoColumns
        });
        filters_row.addClass('columnFilter');

        if (this.datasource == "ajax") {
            Items.ItemsTable._initAjax(this);
        }
        else {
            Items.ItemsTable._init(this);
        }

        /**
         * Implements the Subscriber-Publisher pattern.
         * Receives a publication from the Publisher.
         */
        this.publish = function(publisher, items, event) {
            if (event == "display") {
                Items.ItemsTable.setItems(this, items);
            }
        };
    },

    setItems: function(self, items) {
        var datatable = $(self.datatable).dataTable();
        if (items.length == 0) {
            datatable.fnClearTable();
            return -1;
        }
        self.items = items;
        self.items.sort(function(a, b) {
            if (!a.holdingbranch) {
                return 1;
            }
            if (!b.holdingbranch) {
                return -1;
            }
            //Use a special sorting algorithm to push the current logged in branch to top.
            if (a.holdingbranch == self.loggedinbranch) {
                return -1;
            }
            else if (b.holdingbranch == self.loggedinbranch) {
                return 1;
            }
            else {
                return a.c_holdingbranch.localeCompare(b.c_holdingbranch);
            }
        });
        var itemRows = Items.ItemsTable.createItemRows(self, items);
        datatable.fnClearTable();
        datatable.fnAddData(itemRows);

        Items.ItemsTable.hideUnusedColumns(self, datatable);
        datatable.fnDraw(true);

        //Subscribe the Table Rows to the Items' event propagation mechanism.
        for (var i=0 ; i<items.length ; i++) {
            var item = items[i];
            var itemsTableRow = new Items.ItemsTableRowTmpl.ItemsTableRowTmpl(item);
            Items.subscribe(item, itemsTableRow);
        }
    },

    hideUnusedColumns: function (self, datatable) {
        //Hide columns with no content
        var columnsContentsAvailable = [];
        var rows = datatable.fnGetData();
        for (var i=0 ; i<rows.length ; i++) {
            var row = rows[i];
            for (var j=0 ; j<row.length ; j++) {
                var col = row[j];
                if (String(col).length > 0) {
                    columnsContentsAvailable[j] = true;
                }
            }
        }
        for (var i=0 ; i<columnsContentsAvailable.length ; i++) {
            if (!columnsContentsAvailable[i]) {
                datatable.fnSetColumnVis(i, false, false);
            }
            else {
                datatable.fnSetColumnVis(i, true, false);
            }
        }
        //Always hide configured columns
        for(var i=0 ; i<self.hiddencolumns.length ; i++) {
            hidColIndex = self.hiddencolumns[i];
            datatable.fnSetColumnVis(hidColIndex, false, false);
        }
    },

    /**
     * Fetches the Items from the Koha REST API.
     * Calls the callback function after everything is ok or failed.
     */
    _initAjax: function(self) {

        var data = {
            biblionumber: self.biblionumber,
            limit: 20,
            serialStatus: 2,
        };
        //If the first one had too few results, get results from everywhere.
        if (! self.events._initedWithTooFewResults) {
            data.holdingbranch = self.loggedinbranch;
        }

        $.ajax("/api/v1/serialitems",
                { "method": "get",
                  "accepts": "application/json",
                  "data": data,
                  "beforeSend": function() {
                    $(self.datatable).parent().append('<span id="loading-holdings">'+MSG_LOADING+'</span>');
                  },
                  "complete": function() {
                    $("#loading-holdings").remove();
                  },
                  "success": function (jqXHR, textStatus, errorThrown) {
                    if (typeof self.items !== 'undefined') {
                        return 1; // return if some items are already loaded
                    }
                    var serialItems = jqXHR.serialItems;
                    if (self.events._initedWithTooFewResults && Array.isArray(serialItems) && serialItems.length > 0 ||
                        (Array.isArray(serialItems) && serialItems.length > 10))
                    {
                        Items.Cache.clear();
                        Items.Cache.addLocalItems(jqXHR.serialItems);

                        Items.ItemsTable.setItems(self, serialItems);

                        if (typeof self.events.callback == "function") {
                            self.events.callback(self, errorThrown);
                        }
                    }
                    else {
                        if (!self.events._initedWithTooFewResults) {
                            //If we get too few results, make a more broad search
                            self.events._initedWithTooFewResults = 1;
                            Items.ItemsTable._initAjax(self);
                        }
                    }
                  },
                  "error": function (jqXHR, textStatus, errorThrown) {
                    alert(errorThrown);
                    if (typeof self.events.callback == "function") {
                        self.events.callback(self, errorThrown);
                    }
                  },
                }
        );
    },

    /**
     * Initializes the object without overwriting the parent element.
     * Calls the callback function after everything is ok or failed.
     */
    _init: function(self) {
        if (typeof self.events.callback == "function") {
            self.events.callback(self);
        }
    },

    createItemRows: function (self, items) {
        var itemRows = [];
        for (var i=0 ; i<items.length ; i++) {
            var item = items[i];
            var itemRowHtml = Items.ItemsTableRowTmpl.transform(item);
            itemRows.push( itemRowHtml );
        }
        return itemRows;
    },
    /**
     * Bind event handlers
     */
    _bindEvents: function (self) {

    },
};
