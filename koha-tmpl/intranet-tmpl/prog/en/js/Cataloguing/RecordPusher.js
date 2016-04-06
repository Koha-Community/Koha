//package Cataloguing.RecordPusher
if (typeof Cataloguing == "undefined") {
    this.Cataloguing = {}; //Set the global package
}

/**
 *  Cataloguing.RecordPusher enables pushing the given biblio to a user selectable remote repository.
 *  First the recordPusher adds links to the remote repositories to a given container, then listens
 *  for click-events on those links.
 *  When a link is clicked, the recordPusher fetches the complete MARC Record of the given biblio
 *  from the local database and pushes it to the selected remote API.
 *
 *  The remote API should return a list of hateoas links which are used to construct the available
 *  follow-up actions, like DELETE or show the pushed record in the target environment.
 *
 *  Currently authentication to remote APIs is done with the CGISESSID-cookie and if the user wants
 *  to interact with the remote API, they need to log-in to that system first with the same browser.
 *
 *  @param {jQuery selector or element} displayElementContainer, where to display the list of allowed
 *              remote APIs.
 *  @param {String} displayType, Any of:
 *              "dropdown-menu-list" - show remote APIs as <li>-elements in the container.
 *  @param {jQuery selector or element} operationsMenuContainer, where to display the menu of all the
 *              operations that are available on the remote API
 *  @param {Array of RemoteAPI-objects} remoteAPIs, which APIs should be made available to connect to?
 *  @param {Biblio} activeBiblio, which biblio is being pushed?
 */
Cataloguing.RecordPusher = function (displayElementContainer, displayType, operationsMenuContainer, remoteAPIs, activeBiblio) {
    var self = this;
    this.displayElementContainer = $(displayElementContainer);
    this.operationsMenuContainer = $(operationsMenuContainer);
    this.displayType = displayType;
    this.remoteAPIs = Cataloguing.RecordPusher.getValidRemoteAPIs(remoteAPIs);
    this.activeBiblio = activeBiblio; //This RecordPusher is bound to this Biblio.
    this.menuActivationClickLocation; //From where was the remote operation triggered, so we can display the operations menu there.

    //Render this object
    var decHtml;
    if (this.displayType == "dropdown-menu-list") {
        decHtml = Cataloguing.RecordPusher.template_dropdownMenuList(this);
    }
    else {
        alert("Cataloguing.RecordPusher unknown displayType '"+this.displayType+"'.");
    }
    this.displayElementContainer.append(decHtml);
    Cataloguing.RecordPusher.dropdownMenuListBindEvents(this, decHtml);
    //Rendering done!

    this.setOperationsMenuLocation = function (event) {
        self.menuActivationClickLocation = {left: event.pageX, top: event.pageY};
    };
    this.castRemoteAPI = function (remoteAPIorId) {
        if (remoteAPIorId instanceof Object) {
            return remoteAPIorId;
        }
        return this.remoteAPIs[remoteAPIorId];
    };
    this.pushToRemote = function (remoteAPIOrId) {
        var remoteAPIPushDestination = this.castRemoteAPI(remoteAPIOrId);
        if (!remoteAPIPushDestination) {
            alert("Cataloguing.RecordPusher.pushToRemote("+remoteAPIOrId+"):> Unknown remote API id '"+remoteAPIOrId+"' given. Don't know where to push?");
            return;
        }
        if (! confirm("Are you sure you want to push Record '"+self.activeBiblio.biblionumber+"' to '"+remoteAPIPushDestination.name+"' ?")) {
            return;
        }

        RemoteAPIs.Driver.KohaSuomi.records_get("local", self.activeBiblio, function (remoteAPI, error, result) {
            if (error) {
                alert("Cataloguing.RecordPusher.pushToRemote():> Accessing API '"+remoteAPI.name+"' using RemoteAPIs.Driver.records_get() failed with "+error);
                return;
            }
            RemoteAPIs.Driver.records_add(remoteAPIPushDestination, result.marcxml, function (remoteAPI, error, result) {
                if (error) {
                    alert("Cataloguing.RecordPusher.pushToRemote():> Accessing API '"+remoteAPI.name+"' using RemoteAPIs.Driver.records_add() failed with "+error);
                    return;
                }
                self.displayMenu(remoteAPI, result.biblionumber, result.marcxml, result.links);
            });
        });
    };
    this.deleteFromRemote = function (remoteAPIOrId, biblionumber) {
        var remoteAPI = this.castRemoteAPI(remoteAPIOrId);
        if (!remoteAPI) {
            alert("Cataloguing.RecordPusher.pushToRemote():> Remote API not known. Don't know where to DELETE!");
            return;
        }
        if (! confirm("Are you sure you want to DELETE a Record from '"+remoteAPI.name+"' ?")) {
            return;
        }
        RemoteAPIs.Driver.records_delete(remoteAPI, biblionumber, function (remoteAPI, error, result) {
            if (error) {
                alert("Cataloguing.RecordPusher.pushToRemote():> Accessing API '"+remoteAPI.name+"' using RemoteAPIs.Driver.KohaSuomi.records_delete() failed with "+error);
                return;
            }
            //Delete succeeded, hide the Operations menu
            self.operationsMenuContainer.find("#pushRecordOpMenu .circular-menu .circle").removeClass('open');
            self.operationsMenuContainer.find("#pushRecordOpMenu a").hide(1000, function () {$(this).parent().remove();});
        });
    };
    this.displayMenu = function (remoteAPI, biblionumber, record, hateoasLinks) {
        this.operationsMenuContainer.find("#pushRecordOpMenu").remove();
        var html = $("<div id='pushRecordOpMenu'></div>");

        var nativeViewUrl;
        hateoasLinks.forEach(function(v,i,a){
            if(v.ref == "self.nativeView"){    nativeViewUrl = remoteAPI.host+'/'+v.href;    }
        });
        this.operationsMenuContainer.append(html);
        var radialMenu = new RadialMenu(html, [
                                {   class: "fa fa-trash-o fa-2x",
                                    title: "DELETE",
                                    "data-verb": "DELETE",
                                    events: {   click: function (event) { event.preventDefault(); self.deleteFromRemote(remoteAPI, biblionumber) }    }
                                },
                                {   class: "fa fa-sign-in fa-2x",
                                    title: "OPEN IN HOME",
                                    "data-verb": "GET",
                                    href: nativeViewUrl,
                                    target: '_blank'
                                },
                        ]);
        this.operationsMenuContainer.find("#pushRecordOpMenu").css(self.menuActivationClickLocation);
        this.operationsMenuContainer.find("#pushRecordOpMenu .menu-button").click(); //Open up the radial menu
    };
};

/**
 *  Find the Remote APIs that are capable of doing operations on MARC records.
 *  @param {Array} remoteAPIs
 *  @returns {Array} remoteAPIs that are capable
 */
Cataloguing.RecordPusher.getValidRemoteAPIs = function (remoteAPIs) {
    return remoteAPIs;
}
Cataloguing.RecordPusher.template_dropdownMenuList = function (recordPusher) {
    var remoteAPIs = recordPusher.remoteAPIs;
    if (!remoteAPIs) {
        return '';
    }

    var html =  '<li class="divider" role="presentation"></li>\n'+
                '<li role="presentation"><a href="#" tabindex="-1" class="menu-inactive" role="menuitem"><strong>Push to remote:</strong></a></li>\n'+
                '<li class="divider" role="presentation"></li>\n';
    Object.keys(remoteAPIs).sort().forEach(function(v, i, a) { var api =remoteAPIs[v];
        html += '<li><a href="#" id="pushTarget_'+api.id+'">'+api.name+'</a></li>\n';
    });
    return $(html);
}
Cataloguing.RecordPusher.dropdownMenuListBindEvents = function (recordPusher, displayHtml) {
    displayHtml.find("[id^='pushTarget_']").click(function (event) {
        recordPusher.setOperationsMenuLocation(event);
        recordPusher.pushToRemote($(this).attr("id").substr(11));
        event.preventDefault();
    });
}
