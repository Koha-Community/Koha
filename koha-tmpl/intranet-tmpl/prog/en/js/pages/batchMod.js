// Set expiration date for cookies
    var date = new Date();
    date.setTime(date.getTime()+(365*24*60*60*1000));
    var expiration = date.toGMTString();


function hideColumns(){
  valCookie = $.cookie("showColumns");
  if(valCookie){
    valCookie = valCookie.split("/");
    $("#showall").removeAttr("checked").parent().removeClass("selected");
    for( i=0; i<valCookie.length; i++ ){
      if(valCookie[i] !== ''){
        index = valCookie[i] - 2;
        $("#itemst td:nth-child("+valCookie[i]+"),#itemst th:nth-child("+valCookie[i]+")").toggle();
        $("#checkheader"+index).removeAttr("checked").parent().removeClass("selected");
      }
    }
  }
}

function hideColumn(num) {
  $("#hideall,#showall").removeAttr("checked").parent().removeClass("selected");
  valCookie = $.cookie("showColumns");
  // set the index of the table column to hide
  $("#"+num).parent().removeClass("selected");
  var hide = Number(num.replace("checkheader","")) + 2;
  // hide header and cells matching the index
  $("#itemst td:nth-child("+hide+"),#itemst th:nth-child("+hide+")").toggle();
  // set or modify cookie with the hidden column's index
  if(valCookie){
    valCookie = valCookie.split("/");
    var found = false;
    for( $i=0; $i<valCookie.length; $i++ ){
        if (hide == valCookie[i]) {
            found = true;
            break;
        }
    }
    if( !found ){
        valCookie.push(hide);
        var cookieString = valCookie.join("/");
        $.cookie("showColumns", cookieString, { expires : date });
    }
  } else {
        $.cookie("showColumns", hide, { expires : date });
  }
}

// Array Remove - By John Resig (MIT Licensed)
// http://ejohn.org/blog/javascript-array-remove/
Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

function showColumn(num){
  $("#hideall").removeAttr("checked").parent().removeClass("selected");
  $("#"+num).parent().addClass("selected");
  valCookie = $.cookie("showColumns");
  // set the index of the table column to hide
  show = Number(num.replace("checkheader","")) + 2;
  // hide header and cells matching the index
  $("#itemst td:nth-child("+show+"),#itemst th:nth-child("+show+")").toggle();
  // set or modify cookie with the hidden column's index
  if(valCookie){
    valCookie = valCookie.split("/");
    var found = false;
    for( i=0; i<valCookie.length; i++ ){
        if (show == valCookie[i]) {
          valCookie.remove(i);
          found = true;
        }
    }
    if( found ){
        var cookieString = valCookie.join("/");
        $.cookie("showColumns", cookieString, { expires : date });
    }
  }
}
function showAllColumns(){
    $("#selections").checkCheckboxes();
    $("#selections span").addClass("selected");
    $("#itemst td:nth-child(2),#itemst tr th:nth-child(2)").nextAll().show();
    $.cookie("showColumns",null);
    $("#hideall").removeAttr("checked").parent().removeClass("selected");
}
function hideAllColumns(){
    $("#selections").unCheckCheckboxes();
    $("#selections span").removeClass("selected");
    $("#itemst td:nth-child(2),#itemst th:nth-child(2)").nextAll().hide();
    $("#hideall").attr("checked","checked").parent().addClass("selected");
    var cookieString = allColumns.join("/");
    $.cookie("showColumns", cookieString, { expires : date });
}

  $(document).ready(function() {
    hideColumns();
    $("#itemst").dataTable($.extend(true, {}, dataTablesDefaults, {
        "sDom": 't',
        "aoColumnDefs": [
            { "aTargets": [ 0 ], "bSortable": false, "bSearchable": false }
        ],
        "bPaginate": false
    }));
    $("#selectallbutton").click(function(){
      $("#itemst").checkCheckboxes();
      return false;
    });
    $("#clearallbutton").click(function(){
      $("#itemst").unCheckCheckboxes();
      return false;
    });
    $("#selections input").change(function(e){
      var num = $(this).attr("id");
      if(num == 'showall'){
        showAllColumns();
        e.stopPropagation();
      } else if(num == 'hideall'){
        hideAllColumns();
        e.stopPropagation();
      } else {
        if($(this).attr("checked")){
          showColumn(num);
        } else {
          hideColumn(num);
        }
      }
    });
  });
