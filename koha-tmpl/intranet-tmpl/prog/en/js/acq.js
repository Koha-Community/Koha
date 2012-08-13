//=======================================================================
//input validation:
// acqui/uncertainprice.tmpl uses this
function uncheckbox(form, field) {
    var price = new Number(form.elements['price' + field].value);
    var tmpprice = "";
    var errmsg = _("ERROR: Price is not a valid number, please check the price and try again!")
    if (isNaN(price)) {
        alert(errmsg);
        for(var i=0; i<form.elements['price' + field].value.length; ++i) {
            price = new Number(form.elements['price' + field].value[i]);
            if(! isNaN(price) || form.elements['price' + field].value[i] == ".") {
                tmpprice += form.elements['price' + field].value[i];
            }
        }
        form.elements['price' + field].value = tmpprice;
        return false;
    }
    form.elements['uncertainprice' + field].checked = false;
    return true;
}

// returns false if value is empty
function isNotNull(f,noalert) {
    if (f.value.length ==0) {
        return false;
    }
    return true;
}

function isNull(f,noalert) {
    if (f.value.length > 0) {
        return false;
    }
    return true;
}







//Function returns false if v is not a number (if maybenull is 0, it also returns an error if the number is 0)
function isNum(v,maybenull) {
    var n = new Number(v.value);
    if (isNaN(n)) {
        return false;
    }
    if (maybenull==0 && v.value=='') {


    return false;
    }
    return true;
}

//=======================================================================

//=======================================================================
// Functions for drag-and-drop functionality


(function() {

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
})();




//creates new group, parameter is the group's name
function newGroup(event, name) {
    if (name == ''){
        return 0;
    }
    if (!enterpressed(event) && event != "button"){
        return false;
    }
    var pardiv = document.getElementById('groups');
    var newdiv = document.createElement('div');
    var newh3 = document.createElement('h3');
    var newul = document.createElement('ul');
    var newclose = document.createElement('a');
    var newrename = document.createElement('a');
    var newbasketgroupname = document.createElement('input');
    var nbgclosed = document.createElement('input');
    var newp = document.createElement('p');
    var reg=new RegExp("[-]+", "g");
    var i = 0;
    var maxid = 0;
    while( i < pardiv.getElementsByTagName('input').length ){
        if (! isNaN(parseInt(pardiv.getElementsByTagName('input')[i].name.split(reg)[1])) && parseInt(pardiv.getElementsByTagName('input')[i].name.split(reg)[1]) > maxid){
            maxid = parseInt(pardiv.getElementsByTagName('input')[i].name.split(reg)[1]);
        }
        ++i;
    }
// var bgid = parseInt(pardiv.getElementsByTagName('input')[pardiv.getElementsByTagName('input').length-2].name.split(reg)[1]) + 1;
    var bgid = maxid + 1;
    var newchanged = document.createElement('input');

    newul.id="bg-"+bgid;
    newul.className='draglist';

    newh3.innerHTML=name;
//    newh3.style.display="inline";

    newclose.innerHTML="close";
    newclose.href="javascript: closebasketgroup('"+bgid+"', 'bg-"+bgid+"');";

    newrename.href="javascript:" + "renameinit("+bgid+");";
    newrename.innerHTML="rename";

//    newp.style.display="inline";
    newp.innerHTML=" [ ";
    newp.appendChild(newrename);
    newp.innerHTML+=" / ";
    newp.appendChild(newclose);
    newp.innerHTML+=" ]";

    newbasketgroupname.type="hidden";
    newbasketgroupname.name="basketgroup-" + bgid + "-name";
    newbasketgroupname.id = "basketgroup-" + bgid + "-name";
    newbasketgroupname.value=name;

    nbgclosed.type="hidden";
    nbgclosed.name="basketgroup-" + bgid + "-closed";
    nbgclosed.value="0";
    nbgclosed.id=nbgclosed.name;

    newchanged.type="hidden";
    newchanged.id="basketgroup-"+bgid+"-changed";
    newchanged.name=newchanged.id;
    newchanged.value="1";

    newdiv.style.backgroundColor='red';
    newdiv.appendChild(newh3);
    newdiv.appendChild(newp);
    newdiv.appendChild(newul);
    newdiv.appendChild(newbasketgroupname);
    newdiv.appendChild(nbgclosed);
    newdiv.appendChild(newchanged);
    newdiv.className='workarea';
    pardiv.appendChild(newdiv);

    YAHOO.util.Event.onDOMReady(DDApp.init, DDApp, true);
}

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
    var answer=confirm(_("Are you sure you want to close this basketgroup?"));
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
        alert(_("Why close an empty basket?"));
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
    cantprint.innerHTML=_("You need to save the page before printing");
    cantprint.id = 'cantprint-' + bgid;
    var unclosegroup = document.createElement('a');
    unclosegroup.href='javascript:unclosegroup('+bgid+');';
    unclosegroup.innerHTML=_("reopen basketgroup");
    unclosegroup.id = 'unclose-' + bgid;

    div.appendChild(cantprint);
    div.appendChild(unclosegroup);
}

function closeandprint(bg){
	if(document.location = '/cgi-bin/koha/acqui/basketgroup.pl?op=closeandprint&amp;basketgroupid=' + bg ){
		setTimeout("window.location.reload();",3000);
	}else{
		alert(_('Error downloading the file'));
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

//a function to filter basketgroups using a regex (javascript regex)
function filterGroups(event, searchstring ){
    if (!enterpressed(event) && event != "button"){
        return false;
    }
    var reg = new RegExp(searchstring, "g");
    var Dom = YAHOO.util.Dom;
    var divs = Dom.getElementsByClassName("workarea", "div");

    for (var i = 0; i < divs.length; ++i){
        if (! reg.exec(divs[i].innerHTML)){
            divs[i].style.display='none';
        }
        else {
            divs[i].style.display='';
        }
    }
    divs = Dom.getElementsByClassName("closed", "div");
    for (var i = 0; i < divs.length; ++i){
        if (! reg.exec(divs[i].innerHTML)){
            divs[i].style.display='none';
        }
        else {
            divs[i].style.display='';
        }
    }
}

//function to hide (or show) closed baskets (if show is true, it shows all the closed baskets)
function showhideclosegroups(show){
    var Dom = YAHOO.util.Dom;
    var divs = Dom.getElementsByClassName("closed", "div");
    var display;
    if (show){
        display = '';
    }
    else display = 'none';
    for(var i = 0; i < divs.length; ++i){
        divs[i].style.display=display;
    }
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

//=======================================================================
//a logging function (a bit buggy, might open millions of log pages when initializing, but works fine after...
function log(message) {
    if (!log.window_ || log.window_.closed) {
        var win = window.open("", null, "width=400,height=200," +
                            "scrollbars=yes,resizable=yes,status=no," +
                            "location=no,menubar=no,toolbar=no");
        if (!win) return;
        var doc = win.document;
        doc.write("<html><head><title>Debug Log</title></head>" +
                "<body></body></html>");
        doc.close();
        log.window_ = win;
    }
    var logLine = log.window_.document.createElement("div");
    logLine.appendChild(log.window_.document.createTextNode(message));
    log.window_.document.body.appendChild(logLine);
}

//=======================================================================
function getElementsByClass( searchClass, domNode, tagName) {
    if (domNode == null) domNode = document;
    if (tagName == null) tagName = '*';
    var el = new Array();
    var tags = domNode.getElementsByTagName(tagName);
    var tcl = " "+searchClass+" ";
    for(i=0,j=0; i<tags.length; i++) {
        var test = " " + tags[i].className + " ";
        if (test.indexOf(tcl) != -1)
            el[j++] = tags[i];
    }
    return el;
}


function calcTotalRow(cell) {

    var string = cell.name;
    var pos = string.indexOf(",", 0);
    var bud_id = string.substring(0, pos);
    var val1 =    cell.value;
    var remainingTotal =   document.getElementById("budget_est_"+bud_id);
    var remainingNew =0;
    var budgetTotal  =  document.getElementById("budget_tot_"+bud_id ).textContent;
    var arr =  getElementsByClass(cell.className);

    budgetTotal   =  budgetTotal.replace(/\,/, "");

//percent strip and convert
    if ( val1.match(/\%/) )   {
        val1 = val1.replace(/\%/, "");
        cell.value =    (val1 / 100) *  Math.abs(budgetTotal ) ;
    }

    for ( var i=0, len=arr.length; i<len; ++i ){
        remainingNew   +=   Math.abs(arr[i].value);
    }

    var cc = new Number(cell.value);
    cell.value =  cc.toFixed(2); // TIDYME...
    remainingNew    =    Math.abs( budgetTotal  ) -  remainingNew   ;

    if ( remainingNew  == 0)  {
        remainingTotal.style.color = 'black';
    }
    else if ( remainingNew   > 0   )       {
        remainingTotal.style.color = 'green';
    } else  {    // if its negative, make it red..
        remainingTotal.style.color = 'red';
    }

    remainingTotal.textContent  = remainingNew.toFixed(2) ;
}

function autoFillRow(bud_id) {

    var remainingTotal =   document.getElementById("budget_est_"+bud_id);
    var remainingNew = new Number;
    var budgetTotal  =  document.getElementById("budget_tot_"+bud_id ).textContent;
    var arr =  getElementsByClass("plan_entry_" + bud_id);

    budgetTotal   =  budgetTotal.replace(/\,/, "");
    var qty = new Number;
// get the totals
    var novalueArr = new Array();
    for ( var i=0, len=arr.length; i<len; ++i ) {
        remainingNew   +=   Math.abs (arr[i].value );

        if ( arr[i].value == 0 ) {
	    novalueArr[qty] = arr[i];
            qty += 1;
        }
    }

    remainingNew    =    Math.abs( budgetTotal) -  remainingNew   ;
    var newCell = new Number (remainingNew / qty);
    var rest = new Number (remainingNew - (newCell.toFixed(2) * (novalueArr.length - 1)));

    for (var i = 0; i<novalueArr.length; ++i) {
         if (i == novalueArr.length - 1) {
             novalueArr[i].value = rest.toFixed(2);
         }else {
             novalueArr[i].value = newCell.toFixed(2);
        }
    }

    remainingTotal.textContent = '0.00' ;
    remainingTotal.style.color = 'black';
}


function messenger(X,Y,etc){    // FIXME: unused?
    win=window.open("","mess","height="+X+",width="+Y+",screenX=150,screenY=0");
    win.focus();
    win.document.close();
    win.document.write("<body link='#333333' bgcolor='#ffffff' text='#000000'><font size='2'><p><br />");
    win.document.write(etc);
    win.document.write("<center><form><input type=button onclick='self.close()' value='Close'></form></center>");
    win.document.write("</font></body></html>");
}


//=======================================================================

//  NEXT BLOCK IS USED BY NEWORDERBEMPTY

function calcNeworderTotal(){
    //collect values
    var f        = document.getElementById('Aform');
    var quantity = new Number(f.quantity.value);
    var discount = new Number(f.discount.value);
    var listinc  = new Number (f.listinc.value);
    //var currency = f.currency.value;
    var applygst = new Number (f.applygst.value);
    var listprice   =  new Number(f.listprice.value);
    var invoiceingst =  new Number (f.invoiceincgst.value);
//    var exchangerate =  new Number(f.elements[currency].value);      //get exchange rate
        var currcode = new String(document.getElementById('currency').value);
	var exchangerate =  new Number(document.getElementById(currcode).value);

    var gst_on=(!listinc && invoiceingst);

    //do real stuff
    var rrp   = new Number(listprice*exchangerate);
    var ecost = rrp;
    if (100-discount != 100) { //Prevent rounding issues if no discount
        ecost = new Number(Math.floor(rrp * (100 - discount ))/100);
    }
    var GST   = new Number(0);
    if (gst_on) {
            rrp=rrp * (1+f.gstrate.value / 100);
        GST=ecost * f.gstrate.value / 100;
    }

    var total =  new Number( (ecost + GST) * quantity);

    f.rrp.value = rrp.toFixed(2);

//	f.rrp.value = rrp
//	f.rrp.value = 'moo'

    f.ecost.value = ecost.toFixed(2);
    f.total.value = total.toFixed(2);
    f.listprice.value =  listprice.toFixed(2);

//  gst-stuff needs verifing, mason.
    if (f.GST) {
        f.GST.value=GST;
    }
    return true;
}

// Calculates total amount in a suggestion

function calcNewsuggTotal(){
    //collect values
    var quantity = new Number(document.getElementById('quantity').value);
//    var currency = f.currency.value;
    var currcode = new String(document.getElementById('currency').value);
    var price   =  new Number(document.getElementById('price').value);
    var exchangerate =  new Number(document.getElementById(currcode).value);

    var total =  new Number(quantity*price*exchangerate);

    document.getElementById('total').value = total.toFixed(2);
    document.getElementById('price').value =  price.toFixed(2);
    return true;
}


// ----------------------------------------
//USED BY NEWORDEREMPTY.PL
/*
function fetchSortDropbox(f) {
    var  budgetId=f.budget_id.value;
    var handleSuccess = function(o){
        if(o.responseText !== undefined){
            sort_dropbox.innerHTML   = o.responseText;
        }
    }

    var callback = {   success:handleSuccess };
    var sUrl = '../acqui/fetch_sort_dropbox.pl?sort=1&budget_id='+budgetId
    var sort_dropbox = document.getElementById('sort1');
    var request1 = YAHOO.util.Connect.asyncRequest('GET', sUrl, callback);
    var rr = '00';

// FIXME: ---------  twice , coz the 2 requests get mixed up otherwise

    var handleSuccess2 = function(o){
    if(o.responseText !== undefined){
        sort2_dropbox.innerHTML   = o.responseText;
        }
    }

    var callback2 = {   success:handleSuccess };
    var sUrl2 = '../acqui/fetch_sort_dropbox.pl?sort=2&budget_id='+budgetId;
    var sort2_dropbox = document.getElementById('sort2');
    var request2 = YAHOO.util.Connect.asyncRequest('GET', sUrl2, callback2);

}
*/



//USED BY NEWORDEREMPTY.PL
function fetchSortDropbox(f) {
    var  budgetId=f.budget_id.value;

for (i=1;i<=2;i++) {

    var sort_zone = document.getElementById('sort'+i+'_zone');
    var url = '../acqui/fetch_sort_dropbox.pl?sort='+i+'&budget_id='+budgetId;

    var xmlhttp = null;
    xmlhttp = new XMLHttpRequest();
    if ( typeof xmlhttp.overrideMimeType != 'undefined') {
        xmlhttp.overrideMimeType('text/xml');
    }

    xmlhttp.open('GET', url, false);
    xmlhttp.send(null);

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
    // stupid JS...
        } else {
    // wait for the call to complete
        }
    };
    // rc =  eval ( xmlhttp.responseText );
    var retRootType = xmlhttp.responseXML.firstChild.nodeName;
    var existingInputs = sort_zone.getElementsByTagName('input');
    if (existingInputs.length > 0 && retRootType == 'input') {
        // when sort is already an input, do not override to preseve value
        return;
    }
    sort_zone.innerHTML = xmlhttp.responseText;
}
}







//USED BY NEWORDEREMPTY.PL
function totalExceedsBudget(budgetId, total) {

    var xmlhttp = null;
    xmlhttp = new XMLHttpRequest();
    if ( typeof xmlhttp.overrideMimeType != 'undefined') {
        xmlhttp.overrideMimeType('text/xml');
    }

    var url = '../acqui/check_budget_total.pl?budget_id=' + budgetId + "&total=" + total;
    xmlhttp.open('GET', url, false);
    xmlhttp.send(null);

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {

            actTotal = eval ( xmlhttp.responseText );

            if (  Math.abs(actTotal) < Math.abs(total)  ) {
            // if budget is to low :(
                return true ;
            } else {
                return false;
            }
        }
    }
}


//USED BY AQBUDGETS.TMPL
function budgetExceedsParent(budgetTotal, budgetId, newBudgetParent, periodID) {


    var xmlhttp = null;
    xmlhttp = new XMLHttpRequest();
    if ( typeof xmlhttp.overrideMimeType != 'undefined') {
        xmlhttp.overrideMimeType('text/xml');
    }

// make the call... yawn
//    var url = '../admin/check_parent_total.pl?budget_id=' + budgetId +   '&parent_id=' + newBudgetParent  + "&total=" + budgetTotal + "&period_id="+ periodID   ;


    var url = '../admin/check_parent_total.pl?total=' + budgetTotal + "&period_id="+ periodID   ;

if (budgetId ) { url +=  '&budget_id=' + budgetId };
if ( newBudgetParent  ) { url +=  '&parent_id=' + newBudgetParent};


    xmlhttp.open('GET', url, false);
    xmlhttp.send(null);

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
    // stupid JS...
        } else {
    // wait for the call to complete
        }
    };

    var result = eval ( xmlhttp.responseText );

    if (result == '1') {
            return _("- Budget total exceeds parent allocation\n");
    } else if (result == '2') {
            return _("- Budget total exceeds period allocation\n");
    } else  {
            return false;
    }
}




//USED BY AQBUDGETS.TMPL
function checkBudgetParent(budgetId, newBudgetParent) {
    var xmlhttp = null;
    xmlhttp = new XMLHttpRequest();
    if ( typeof xmlhttp.overrideMimeType != 'undefined') {
        xmlhttp.overrideMimeType('text/xml');
    }

    var url = '../admin/check_budget_parent.pl?budget_id=' + budgetId + '&new_parent=' + newBudgetParent;
    xmlhttp.open('GET', url, false);
    xmlhttp.send(null);

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
    // do something with the results
        } else {
    // wait for the call to complete
        }
    };

    var result = eval ( xmlhttp.responseText );

    if (result == '1') {
            return _("- New budget-parent is beneath budget\n");
//     } else if (result == '2') {
//            return "- New budget-parent has insufficent funds\n";
//     } else  {
//              return false;
    }
}


function addColumn(p_sType, p_aArgs, p_oValue)
{
    var allRows = document.getElementById('plan').rows;
    var colnum  = p_oValue[0];
    var code   = p_oValue[1];
    var colnum  = new Number(colnum);

    for (var i=0; i<allRows.length; i++) {
            var allCells  = allRows[i].cells;
            allCells[colnum+1].style.display="table-cell";
    }

// make a menuitem object
    var hids = document.getElementsByName("hide_cols")
    for (var i=0; i<hids.length; i++) {
        if (hids[i].value == code) {
            var x =  hids[i];
            x.parentNode.removeChild(x)    // sigh...
            break;
        }
    }
}


function delColumn(n, code)
{
    var allRows = document.getElementById('plan').rows;

// find index
    var index;
    var nn  = new Number(n);
    var code   = code ;
    for (var i=0; i<allRows.length; i++) {
        var allCells  = allRows[i].cells;
        allCells[nn+1].style.display="none";
    }

    var r = 0;
    var hids = document.getElementsByName("hide_cols")
    for (var i=0; i<hids.length; i++) {
        if (hids[i].value == code) {
            r = 1;
            break;
        }
    }

    if (r == 0 ) {
        // add hide_col to form
        var el = document.createElement("input");
        el.setAttribute("type", 'hidden' );
        el.setAttribute("value", code);
        el.setAttribute("name", 'hide_cols');
        document.getElementById("hide_div").appendChild(el);
    }
}


