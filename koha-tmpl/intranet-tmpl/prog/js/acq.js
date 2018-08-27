//=======================================================================
//input validation:
// acqui/uncertainprice.tmpl uses this
function uncheckbox(form, field) {
    var price = new Number(form.elements['price' + field].value);
    var tmpprice = "";
    var errmsg = MSG_INVALIDPRICE;
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

function updateCosts(){
    var quantity = new Number($("#quantity").val());
    var discount = new Number($("#discount").val());
    var listprice   =  new Number($("#listprice").val());
    var currcode = new String($("#currency").val());
    var exchangerate =  new Number($("#currency_rate_"+currcode).val());
    var gst_on=false;

    var rrp   = new Number(listprice*exchangerate);
    var rep   = new Number(listprice*exchangerate);
    var ecost = rrp;
    if ( 100-discount != 100 ) { //Prevent rounding issues if no discount
        ecost = new Number(Math.floor(rrp * (100 - discount )) / 100);
    }
    var total =  new Number( ecost * quantity);
    $("#rrp").val(rrp.toFixed(2));
    $("#replacementprice").val(rep.toFixed(2));
    $("#ecost").val(ecost.toFixed(2));
    $("#total").val(total.toFixed(2));
    $("listprice").val(listprice.toFixed(2));

    return true;
}

// Calculates total amount in a suggestion

function calcNewsuggTotal(){
    //collect values
    var quantity = Number(document.getElementById('quantity').value);
    var currcode = String(document.getElementById('currency').value);
    var price   =  Number(document.getElementById('price').value);
    var exchangerate =  Number(document.getElementById('currency_rate_'+currcode).value);

    var total =  Number(quantity*price*exchangerate);

    document.getElementById('total').value = total.toFixed(2);
    document.getElementById('price').value =  price.toFixed(2);
    return true;
}

function getAuthValueDropbox( name, cat, destination, selected ) {
    if ( typeof(selected) == 'undefined' ) {
        selected = "";
    }
    if (cat == null || cat == "") {
        $(destination).replaceWith(' <input type="text" name="' + name + '" value="' + selected + '" />' );
        return;
    }
    $.ajax({
        url: "/cgi-bin/koha/acqui/ajax-getauthvaluedropbox.pl",
        data: {
            name: name,
            category: cat,
            default: selected
        },
        async: false,
        success: function(data){
            if(data === "0"){
                $(destination).replaceWith(' <input type="text" name="' + name + '" value="' + selected + '" />' );
            }else{
                $(destination).replaceWith(data);
            }
        }
    });
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
            return MSG_BUDGET_PARENT_ALLOCATION;
    } else if (result == '2') {
            return MSG_BUDGET_PERIOD_ALLOCATION;
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
            return MSG_PARENT_BENEATH_BUDGET;
//     } else if (result == '2') {
//            return "- New budget-parent has insufficent funds\n";
//     } else  {
//              return false;
    }
}

function hideColumn(num) {
    $("#hideall,#showall").prop("checked", false).parent().removeClass("selected");
    $("#"+num).parent().removeClass("selected");
    var hide = Number(num.replace("col","")) + 2;
    // hide header and cells matching the index
    $("#plan td:nth-child("+hide+"),#plan th:nth-child("+hide+")").toggle();
}

function showColumn(num){
    $("#hideall").prop("checked", false).parent().removeClass("selected");
    $("#"+num).parent().addClass("selected");
    // set the index of the table column to hide
    show = Number(num.replace("col","")) + 2;
    // hide header and cells matching the index
    $("#plan td:nth-child("+show+"),#plan th:nth-child("+show+")").toggle();
}

function showAllColumns(){
    $("#selections").checkCheckboxes();
    $("#selections span").addClass("selected");
    $("#plan td:nth-child(2),#plan tr th:nth-child(2)").nextAll().show();
    $("#hideall").prop("checked", false).parent().removeClass("selected");
}
function hideAllColumns(){
    var allCols = $("#plan th").length;
    $("#selections").unCheckCheckboxes();
    $("#selections span").removeClass("selected");
    $("#plan td:nth-child(2),#plan th:nth-child(2)").nextUntil("th:nth-child("+(allCols-1)+"),td:nth-child("+(allCols-1)+")").hide(); // hide all but the last two columns
    $("#hideall").prop("checked", true).parent().addClass("selected");
}
