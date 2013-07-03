// Functions for drag-and-drop functionality

var Dom = YAHOO.util.Dom;
var Event = YAHOO.util.Event;
var DDM = YAHOO.util.DragDropMgr;

DDApp = {
    init: function() {
    var uls = document.getElementsByTagName('ul');
    var i,j;
    var ddtarget;
    for (i=0; i<uls.length;i=i+1) {
        if (uls[i].className == "draglist" || uls[i].className == "draglist_alt") {
            ddtarget = YAHOO.util.DragDropMgr.getDDById(uls[i].id);
// The yahoo drag and drop is written (broken or not) in such a way, that if an element is subscribed as a target multiple times,
// it has to be unlinked multiple times, so we need to test whether it is allready a target, otherwise we'll have a problem when closing the group
            if( ! ddtarget ) {
                new YAHOO.util.DDTarget(uls[i].id);
            }
            var children = uls[i].getElementsByTagName('li');
            for( j=0; j<children.length; j=j+1) {
// The yahoo drag and drop is (broken or not) in such a way, that if an element is subscribed as a target multiple times,
// it has to be unlinked multiple times, so we need to test whether it is allready a target, otherwise we'll have a problem when closing the group
                ddtarget = YAHOO.util.DragDropMgr.getDDById(children[j].id);
                if( ! ddtarget ) {
                    new DDList(children[j].id);
                }
            }
        }
    }
    }
};


// drag and drop implementation

DDList = function(id, sGroup, config) {

    DDList.superclass.constructor.call(this, id, sGroup, config);

    this.logger = this.logger || YAHOO;
    var el = this.getDragEl();
    Dom.setStyle(el, "opacity", 0.67); // The proxy is slightly transparent

    this.goingUp = false;
    this.lastY = 0;
};

YAHOO.extend(DDList, YAHOO.util.DDProxy, {

    startDrag: function(x, y) {
        this.logger.log(this.id + " startDrag");

        // make the proxy look like the source element
        var dragEl = this.getDragEl();
        var clickEl = this.getEl();
        Dom.setStyle(clickEl, "visibility", "hidden");

        dragEl.innerHTML = clickEl.innerHTML;

        Dom.setStyle(dragEl, "color", Dom.getStyle(clickEl, "color"));
        Dom.setStyle(dragEl, "backgroundColor", Dom.getStyle(clickEl, "backgroundColor"));
        Dom.setStyle(dragEl, "border", "2px solid gray");
    },

    endDrag: function(e) {

        var srcEl = this.getEl();
        var proxy = this.getDragEl();

        // Show the proxy element and animate it to the src element's location
        Dom.setStyle(proxy, "visibility", "");
        var a = new YAHOO.util.Motion(
            proxy, {
                points: {
                    to: Dom.getXY(srcEl)
                }
            },
            0.2,
            YAHOO.util.Easing.easeOut
        )
        var proxyid = proxy.id;
        var thisid = this.id;

        // Hide the proxy and show the source element when finished with the animation
        a.onComplete.subscribe(function() {
                Dom.setStyle(proxyid, "visibility", "hidden");
                Dom.setStyle(thisid, "visibility", "");
            });
        a.animate();
// if we are in basketgrouping page, when finished moving, edit the basket's info to reflect new status
        if(typeof(basketgroups) != 'undefined') {
            a.onComplete.subscribe(function() {
                var reg = new RegExp("[-]+", "g");
// add a changed input to each moved basket, so we know which baskets to modify,
// and so we don't need to modify each and every basket and basketgroup each time the page is loaded
// FIXME: we shouldn't use getElementsByTagName, it's not explicit enough :-(
                srcEl.getElementsByTagName('input')[1].value = "1";
                if ( srcEl.parentNode.parentNode.className == "workarea" ) {
                    var dstbgroupid = srcEl.parentNode.parentNode.getElementsByTagName('input')[srcEl.parentNode.parentNode.getElementsByTagName('input').length-2].name.split(reg)[1];
                    srcEl.className="grouped";
                    srcEl.getElementsByTagName('input')[0].value = dstbgroupid;
//FIXME: again, we shouldn't be using getElementsByTagName!!
                    srcEl.parentNode.parentNode.getElementsByTagName('input')[srcEl.parentNode.parentNode.getElementsByTagName('input').length-1].value = 1;
                }
                else if ( srcEl.parentNode.parentNode.className == "workarea_alt" ){
                        srcEl.className="ungrouped";
                        srcEl.getElementsByTagName('input')[0].value = "0";
                }
            });
        }
    },

    onDragDrop: function(e, id) {

        // If there is one drop interaction, the li was dropped either on the list,
        // or it was dropped on the current location of the source element.
        if (DDM.interactionInfo.drop.length === 1) {

            // The position of the cursor at the time of the drop (YAHOO.util.Point)
            var pt = DDM.interactionInfo.point;

            // The region occupied by the source element at the time of the drop
            var region = DDM.interactionInfo.sourceRegion;

            // Check to see if we are over the source element's location.  We will
            // append to the bottom of the list once we are sure it was a drop in
            // the negative space (the area of the list without any list items)
            if (!region.intersect(pt)) {
                var destEl = Dom.get(id);
                var destDD = DDM.getDDById(id);
                destEl.appendChild(this.getEl());
                destDD.isEmpty = false;
                DDM.refreshCache();
            }
        }
    },

    onDrag: function(e) {

        // Keep track of the direction of the drag for use during onDragOver
        var y = Event.getPageY(e);

        if (y < this.lastY) {
            this.goingUp = true;
        } else if (y > this.lastY) {
            this.goingUp = false;
        }
        this.lastY = y;
    },

    onDragOver: function(e, id) {

        var srcEl = this.getEl();
        var destEl = Dom.get(id);

        // We are only concerned with list items, we ignore the dragover
        // notifications for the list.
        if (destEl.nodeName.toLowerCase() == "li") {
            var orig_p = srcEl.parentNode;
            var p = destEl.parentNode;

            if (this.goingUp) {
                p.insertBefore(srcEl, destEl); // insert above
            } else {
                p.insertBefore(srcEl, destEl.nextSibling); // insert below
            }

            DDM.refreshCache();
        }
    }
});

//this traps enters in input fields
function enterpressed(event){
    var keycode;
    if (window.event) keycode = window.event.keyCode;
    else if (event) keycode = event.which;
    else return false;

    if (keycode == 13)
    {
        return true;
    }
    else return false;
}


//Closes a basketgroup
function closebasketgroup(bgid) {
    var answer=confirm(MSG_CONFIRM_CLOSE_BASKETGROUP);
    if(! answer){
        return;
    }
    ulid = 'bg-'+bgid;
    var i = 0;
    tagname='basketgroup-'+bgid+'-closed';
    var ddtarget;
    var closeinput = document.getElementById(tagname);
    closeinput.value = 1;
    var changed = document.getElementById("basketgroup-"+bgid+"-changed");
    changed.value=1;

    var div = document.getElementById(tagname).parentNode;
    var stufftoremove = div.getElementsByTagName('p')[0];
    var ul = document.getElementById(ulid);
    var lis = ul.getElementsByTagName('li');
    if (lis.length == 0 ) {
        alert(MSG_CLOSE_EMPTY_BASKET);
        return;
    }
    var cantprint = document.createElement('p');

    div.className = "closed";
    ul.className="closed";

    for(i=0; i<lis.length; ++i) {
        ddtarget = YAHOO.util.DragDropMgr.getDDById(lis[i].id);
        ddtarget.unreg();
    }
    ddtarget = YAHOO.util.DragDropMgr.getDDById(ul.id);
    ddtarget.unreg();
    div.removeChild(stufftoremove);
// the print button is disabled because the page's content might (or is probably) not in sync with what the database contains
    cantprint.innerHTML = MSG_SAVE_BEFORE_PRINTING;
    cantprint.id = 'cantprint-' + bgid;
    var unclosegroup = document.createElement('a');
    unclosegroup.href='javascript:unclosegroup('+bgid+');';
    unclosegroup.innerHTML = MSG_REOPEN_BASKETGROUP;
    unclosegroup.id = 'unclose-' + bgid;

    div.appendChild(cantprint);
    div.appendChild(unclosegroup);
}

function closeandprint(bg){
    if(document.location = '/cgi-bin/koha/acqui/basketgroup.pl?op=closeandprint&amp;basketgroupid=' + bg ){
        setTimeout("window.location.reload();",3000);
    }else{
        alert(MSG_FILE_DOWNLOAD_ERROR);
    }
}

//function that lets the user unclose a basketgroup as long as he hasn't submitted the changes to the page.
function unclosegroup(bgid){
    var div = document.getElementById('basketgroup-'+bgid+'-closed').parentNode;
    var divtodel = document.getElementById('unclose-' + bgid);
    if (divtodel){
        div.removeChild(divtodel);
    }
    divtodel = document.getElementById('unclose-' + bgid);
    if (divtodel){
        div.removeChild(divtodel);
    }
    var closeinput = document.getElementById('basketgroup-'+bgid+'-closed');
    var ul = document.getElementById('bg-'+bgid);

    var newclose = document.createElement('a');
    var newrename = document.createElement('a');
    var newp = document.createElement('p');

    newclose.innerHTML="close";
    newclose.href="javascript: closebasketgroup('"+bgid+"', 'bg-"+bgid+"');";

    newrename.href="javascript:" + "renameinit("+bgid+");";
    newrename.innerHTML="rename";

    var todel = div.getElementsByTagName('p')[0];
    div.removeChild(todel);

    var changed = document.getElementById("basketgroup-"+bgid+"-changed");
    changed.value=1;

    newp.innerHTML=" [ ";
    newp.appendChild(newrename);
    newp.innerHTML+=" / ";
    newp.appendChild(newclose);
    newp.innerHTML+=" ]";

    div.insertBefore(newp, ul);
    closeinput.value="0";
    div.className = "workarea";
    ul.className="draglist";

//rescan draglists, we have a new target (again :-)
    YAHOO.util.Event.onDOMReady(DDApp.init, DDApp, true);
}



function renameinit(bgid){
    var ul = document.getElementById('bg-'+bgid);
    var div = ul.parentNode;
    var nameelm = div.getElementsByTagName('h3')[0];
    var p = div.getElementsByTagName('p')[0];


    var nameinput = document.createElement("input");
    nameinput.type = "text";
    nameinput.id="rename-"+bgid;
    nameinput.value = nameelm.innerHTML;
    nameinput.onkeypress = function(e){rename(e, bgid, document.getElementById('rename-'+bgid).value); };
//    nameinput.setAttribute('onkeypress', 'rename(event, bgid, document.getElementById(rename-'+bgid+').value);');

    div.removeChild(nameelm);
    div.insertBefore(nameinput, p);
}

function rename(event, bgid, name){
    if (!enterpressed(event)){
        return false;
    }
    var ul = document.getElementById('bg-'+bgid);
    var div = ul.parentNode;
    var p = div.getElementsByTagName('p')[0];
    var nameinput = document.getElementById("rename-"+bgid);
    var changedinput = document.getElementById("basketgroup-"+bgid+"-changed");
    var newh3 = document.createElement("h3");
    var hiddenname = document.getElementById("basketgroup-"+bgid+"-name");

    div.removeChild(nameinput);

    newh3.innerHTML=name;
    hiddenname.value=name;
    changedinput.value = 1;
    div.insertBefore(newh3, p);
}
