//Package Holds
if (typeof Holds == "undefined") {
    this.Holds = {}; //Set the global package
}
var log = log;
if (!log) {
    log = log4javascript.getDefaultLogger();
}

Holds.placeHold = function (item, borrower, pickupBranch, biblio, expirationdate, suspend_until) {
    if (!item || !item.itemnumber) {
        log.error("Holds.placeHold():> No Item!");
        return;
    }
    if (!borrower || !borrower.borrowernumber) {
        log.error("Holds.placeHold():> No Borrower!");
        return;
    }
    if (!pickupBranch || !pickupBranch.branchcode) {
        log.error("Holds.placeHold():> No Pickup Branch!");
        return;
    }

    //Build the request parameters
    var requestBody = {};
    if (biblio) {
        requestBody.biblionumber   = parseInt(biblio.biblionumber);
    }
    if (item) {
        requestBody.itemnumber     = parseInt(item.itemnumber);
    }
    if (borrower) {
        requestBody.borrowernumber = parseInt(borrower.borrowernumber);
    }
    if (pickupBranch) {
        requestBody.branchcode     = pickupBranch.branchcode;
    }
    if (expirationdate) {
        requestBody.expirationdate = expirationdate;
    }
    if (suspend_until) {
        requestBody.suspend_until  = suspend_until;
    }

    $.ajax("/api/v1/holds",
        { "method": "POST",
          "accepts": "application/json",
          "contentType": "application/json; charset=utf8",
          "processData": false,
          "data": JSON.stringify(requestBody),
          "success": function (jqXHR, textStatus, errorThrown) {
            var hold = jqXHR;

            if (hold.itemnumber) {
                var item = Items.Cache.getLocalItem(hold.itemnumber);
                Items.publicate(item, hold, 'place_hold_succeeded');
            }
            if (holdPicker) {
                holdPicker.publish(item, hold, 'place_hold_succeeded');
            }
//            //You can extend the publication targets here.
//            if (hold.biblionumber) {
//                var biblio = Biblios.Cache.getLocalBiblio(hold.biblionumber);
//                Biblios.publicate(biblio, hold, 'place_hold_succeeded');
//            }
          },
          "error": function (jqXHR, textStatus, errorThrown) {
            var responseObject = JSON.parse(jqXHR.responseText);
            if (requestBody.itemnumber) { //See if this ajax-call was called with an Item.
                var item = Items.Cache.getLocalItem( requestBody.itemnumber );
                Items.publicate(item, responseObject, 'place_hold_failed');
            }
            if (holdPicker) {
                holdPicker.publish(item, responseObject, 'place_hold_failed');
            }
//            //You can extend the publication targets here.
//            if (requestBody.biblionumber) {
//                var biblio = Biblios.Cache.getLocalBiblio(hold.biblionumber);
//                Biblios.publicate(biblio, responseObject, 'place_hold_failed');
//            }
            else {
                alert(textStatus+" "+(responseObject ? responseObject.error : errorThrown));
            }
          },
        }
    );
}



//Package Holds.HoldsPicker

/**
 * var holdPicker = new Holds.HoldPicker(params);
 * @param {Object} params, parameters as an object, valid attributes:
 *            {Object} 'biblio' - The Biblio-object the holds are targeted at.
 *            {Object} 'item' - The Item-object the holds are tergeted at.
 *            {Object} 'borrower' - The Borrower who is receiving the Hold
 *            {String ISO8601 Date} 'suspend_until' - Activate the Hold after this date.
 *            {String} 'pickupBranch' - Where the Borrower wants the Item delivered.
 */
Holds.HoldPicker = function (params) {
    params = (params ? params : {});
    var self = this; //Create a closure-variable to pass to event handler.
    this.biblio = params.biblio;
    this.item = params.item;
    this.borrower = params.borrower;
    this.suspend_until = params.suspend_until;
    this.pickupBranch = params.pickupBranch;

    this._template = function () {
        var html =
        '<fieldset id="holdPicker" style="position: absolute; width: 200px; right: 75px;">'+
        '  <legend>'+MSG_HOLD_PLACER+'</legend>'+
        '  <div class="biblioInfo"></div><button id="hp_exit" style="position: absolute; top: -10px; right: 4px;"> X </button>'+
        '  <br/><span class="borrowerInfo"></span>'+
        '  <br/><input placeholder="'+MSG_CARDNUMBER+'" id="hp_cardnumber" type="text" width="16"/>'+
        '  <div id="hp_datepicker"></div>'+
        '  <label for="hp_pickupBranches">'+MSG_PICKUP_BRANCH+'</label>'+
        Branches.getBranchSelectorHtml({}, "hp_pickupBranches")+
        '  <div class="result"></div>'+
        '  <button id="hp_placeHold">'+MSG_PLACE_HOLD+'</button><button id="hp_clear">'+MSG_CLEAR+'</button>'+
        '</fieldset>'+
        '';
        return $(html);
    }
    /**
     * Implements the Subscriber-Publisher pattern.
     * Receives a publication from the Publisher.
     */
    this.publish = function(publisher, data, event) {
        var resultElem = this.getResultElement();
        if (event == "place_hold_succeeded") {
            $(resultElem).html("<span class='notification' style='color: #00AA00;'>"+MSG_HOLD_PLACED+"</span>");
        }
        else if (event == "place_hold_failed") {
            $(resultElem).html("<span class='notification' style='color: #AA0000;'>"+data.error+"</span>");
        }
        else if (event == "get_borrower_failed") {
            $(resultElem).html('<span class="error">'+data+'</span>');
        }
        else if (event == "get_borrower_succeeded") {
            $(resultElem).html('');
        }
        else {
            alert("Holds.HoldPicker.publish():> Unknown event-type '"+event+"'");
        }
    };
    this.getBiblioElement = function () {
        return $(this.rootElement).find(".biblioInfo");
    }
    this.clearBiblioElement = function () {
        var ie = this.getBiblioElement();
        ie.html("");
    }
    this.getBorrowerInfoElement = function () {
        return $(this.rootElement).find(".borrowerInfo");
    }
    this.getExitElement = function () {
        return $(this.rootElement).find("#hp_exit");
    }
    this.getCardnumberElement = function () {
        return $(this.rootElement).find("#hp_cardnumber");
    }
    this.clearCardnumber = function () {
        var ce = this.getCardnumberElement();
        ce.val("");
        this.borrower = null;
        this.renderBorrower();
    }
    this.setBorrower = function (borrower) {
        this.borrower = borrower;
    }
    this.getDatepickerElement = function () {
        return $(this.rootElement).find("#hp_datepicker");
    }
    this.clearDatepicker = function () {
        var de = this.getDatepickerElement();
        de.val("");
        this.suspend_until = null;
    }
    this.getPickupBranchesElement = function () {
        return $(this.rootElement).find("#hp_pickupBranches");
    }
    this.clearPickupBranch = function () {
        var pe = this.getPickupBranchesElement();
        pe.val("");
        this.pickupBranch = null;
    }
    this.getResultElement = function () {
        return $(this.rootElement).find(".result");
    }
    this.displayResult = function (result) {
        var re = this.getResultElement();
        re.html(result);
    }
    this.getPlaceHoldElement = function () {
        return $(this.rootElement).find("#hp_placeHold");
    }
    this.placeHold = function () {
        //Prevent accidental double hold placements by using a timer to prevent repeated Place Hold-actions.
        if (this._placeHoldInProgress) {
            return;
        }
        this._placeHoldInProgress = Date.now();
        window.setTimeout(function () {
                self._placeHoldInProgress = 0;
            }, 2000);
        Holds.placeHold(this.item, this.borrower, this.pickupBranch, this.biblio, null, this.suspend_until);
    }
    this.getClearElement = function () {
        return $(this.rootElement).find("#hp_clear");
    }
    this.clear = function () {
        this.clearCardnumber();
        this.clearDatepicker();
        this.clearPickupBranch();
        this.clearBiblioElement();
        this.biblio = null;
        this.item = null;
        this.hide();
    }
    this.render = function () {
        this.renderBiblio();
        this.renderBorrower();
    }
    this.renderBiblio = function () {
        var ie = this.getBiblioElement();
        var html = "";
        if (this.biblio) {
            html +=
            '<span class="title">'+
                (this.biblio.title ? this.biblio.title : this.biblio.biblionumber)+" "+
            '</span>';
        }
        if (this.item) {
            html +=
            '<span>'+
                (this.item.barcode ? this.item.barcode : "")+" "+
                (this.item.enumchron ? '('+this.item.enumchron+')' : "")+" "+
                (this.item.homebranch ? '<strong class="branchcode">'+this.item.homebranch+'</strong>' : "")+
            '</span>';
        }
        $(ie).html(html);
    }
    this.renderBorrower = function () {
        var be = this.getBorrowerInfoElement();
        if (!this.borrower) {
            $(be).html('');
        }
        else {
            $(be).html(
                (this.borrower.cardnumber ? this.borrower.cardnumber : this.borrower.borrowernumber)+' '+
                (this.borrower.surname ? this.borrower.surname : '')+' '+
                (this.borrower.firstname ? this.borrower.firstname : '')
            );
            this.getCardnumberElement().val((this.borrower.cardnumber ? this.borrower.cardnumber : ''));
        }
    }
    this.selectItem = function (itemnumber) {
        this.item = Items.Cache.getLocalItem(itemnumber);
        var tableRow = $(Items.ItemsTableRowTmpl.getTableRow(this.item));
        self.alignToElement(tableRow);
        this.renderBiblio();
        $(this.rootElement).draggable();
        if ($(self.rootElement).is(':hidden')) {
            $(self.rootElement).show(5);
        }
    }
    this.alignToElement = function (jq_element) {
        $(self.rootElement).appendTo(jq_element);
    }
    this.hide = function () {
        $(self.rootElement).hide(500, function () {
            $(self.rootElement).draggable("destroy").css("left","").css("top","");
        });
    }
    this._bindEvents = function () {
        this.getExitElement().bind({
            "click": function (event) {
                self.hide();
            }
        });
        this.getClearElement().bind({
            "click": function (event) {
                self.clear(this, event);
            }
        });
        this.getPlaceHoldElement().bind({
            "click": function (event) {
                self.placeHold();
            }
        });
        this.getPickupBranchesElement().bind({
            "change": function (event) {
                self.pickupBranch = {branchcode: $(this).val()};
            }
        });
        this.getCardnumberElement().bind({
            "change": function (event) {
                var searchTerm = self.getCardnumberElement().val();
                Borrowers.getBorrowers({cardnumber: searchTerm,
                                        userid: searchTerm,
                                    }, function (jqXHR, textStatus, errorThrown) {
                    if (String(errorThrown.status).search(/^2\d\d/) >= 0) { //Status is OK
                        if (jqXHR[0]) {
                            self.setBorrower(jqXHR[0]);
                            self.publish(self, jqXHR[0], 'get_borrower_succeeded');
                        }
                        else {
                            self.publish(self, MSG_NO_SUCH_BORROWER, 'get_borrower_failed');
                            self.clearCardnumber();
                        }
                    }
                    else {
                        self.setBorrower(null)
                        self.publish(self, errorThrown, 'get_borrower_failed');
                        self.clearCardnumber();
                    }
                    self.renderBorrower();
                });
            }
        });
    }

    this.rootElement = this._template();
    this._bindEvents(this.rootElement);
    this.render();
    $(this.rootElement).hide(); //If the element is not attached to anything, it is neither considered :hidden or :visible.
    $(this.rootElement).appendTo('body').draggable();


    return this;
}
