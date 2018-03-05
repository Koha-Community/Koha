(function($) {
  $.fn.goTo = function() {
    $('html, body').animate({
      scrollTop: $(this).offset().top + 'px'
    }, 'fast');
    return this; // for chaining...
  }
})(jQuery);

$(document).ready(function() {

  shortcut.add('F1', function() {
    location.href = '/cgi-bin/koha/catalogue/search.pl';
  });
  shortcut.add('F2', function() {
    location.href = '/cgi-bin/koha/members/members-home.pl';
  });
  shortcut.add('F3', function() {
    location.href = '/cgi-bin/koha/catalogue/search.pl#UB=barcode';
  });

  shortcut.add('F4', function() {
    location.href = '/cgi-bin/koha/circ/returns.pl#UB=barcode';
  });

  shortcut.add('F5', function() {
    location.href = '/cgi-bin/koha/circ/circulation-home.pl#UB=checkout';
  });

  shortcut.add('F6', function() {
    location.href = '/cgi-bin/koha/circ/renew.pl';
  });
  shortcut.add('F7', function() {
    location.href = '/cgi-bin/koha/tools/stage-marc-import.pl#UB=openupload';
  });

  shortcut.add('F8', function() {
    addItem();

  });

  shortcut.add('F9', function() {
    location.href = '/cgi-bin/koha/catalogue/search.pl#UB=searchtitle';
  });

  shortcut.add('F10', function() {
    location.href = '/cgi-bin/koha/serials/serials-home.pl';
  });

  shortcut.add('F11', function() {
    if (location.pathname === '/cgi-bin/koha/members/memberentry.pl') {
      $('#saverecord').click();
    }
  });

  function addItem() {
    switch (location.pathname) {
      case '/cgi-bin/koha/catalogue/detail.pl':
      case '/cgi-bin/koha/catalogue/MARCdetail.pl':
      case '/cgi-bin/koha/catalogue/ISBDdetail.pl':
      case '/cgi-bin/koha/catalogue/moredetail.pl':
      case '/cgi-bin/koha/reserve/request.pl?':
      case '/cgi-bin/koha/catalogue/issuehistory.pl':
      case '/cgi-bin/koha/tools/viewlog.pl':
        var biblioNumber = getQueryVariable('biblionumber');
        var objectId = getQueryVariable('object')
        if (biblioNumber || objectId) {
          // we're in biblio view, make a new item and then break
          location.href = '/cgi-bin/koha/cataloguing/additem.pl?biblionumber=' + (biblioNumber || objectId) + '#additema';
          break;
        }
      default:
        location.href = '/cgi-bin/koha/catalogue/search.pl';
        break;
    }

  }

  function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i = 0; i < vars.length; i++) {
      var pair = vars[i].split("=");
      if (pair[0] == variable) { return pair[1]; }
    }
    return (false);
  }

  // F3
  if (location.pathname === "/cgi-bin/koha/catalogue/search.pl" &&
      location.hash === "#UB=barcode") {
    var $theSelect = $('#catalog_advsearch #searchterms legend+div select');
    $theSelect.val('bc');
  }

  //F4
  if (location.pathname === '/cgi-bin/koha/circ/returns.pl' &&
    location.hash === "#UB=barcode") {
    $('input[name="q"]').focus();
    $('input[name="q"]').parent().parent().goTo();
  }

  //F5
  if (location.pathname === '/cgi-bin/koha/circ/circulation-home.pl' &&
    location.hash === "#UB=checkout") {
    $("#header_search").selectTabByID("#circ_search");
    $("#findborrower").focus();
  }

  //F9
  if (location.pathname === "/cgi-bin/koha/catalogue/search.pl" &&
    location.hash === "#UB=searchtitle") {
    $('fieldset#searchterms select').eq(0).val('ti,phr');
    $('fieldset#searchtermsinput[name="q"]').eq(0).focus();
  }


  //F10
  if (location.pathname === '/cgi-bin/koha/serials/serials-home.pl') {
    $('input#ISSN_filter').focus();
  }

  if (location.pathname === "/cgi-bin/koha/catalogue/itemsearch.pl" &&
    location.hash === "#UB=itemcallnumber") {
    $('select[name="f"]').val("itemcallnumber");
    $('input[name="q"]').focus();
    $('input[name="q"]').parent().parent().goTo();
  }

  if (location.pathname === "/cgi-bin/koha/catalogue/itemsearch.pl") {
    if ($('#results-wrapper').text().match(/\S+/)) {
      $('div#results-wrapper').goTo();
    }
  }


});

(function($) {
  /* Helpers */
  function ub_koha_set_select_value_by_option_text($select, text) {
    $select.find('option').filter(function() {
      return $(this).text().trim() === text;
    }).attr('selected', 'selected');
  }

  /* Main */
  $(function() {
    // Detect stage marc import page
    if ($('#tools_stage-marc-import').length) {
      // Set form values
      /*
      ub_koha_set_select_value_by_option_text(
        $('#marc_modification_template_id'),
        'TODO'
      );
      */
      ub_koha_set_select_value_by_option_text(
        $('#matcher'),
        'KohaBiblio (999$c)'
      );

      $('#format').val('Koha::Plugin::Se::Ub::Gu::MarcImport');
      $('#overlay_action').val('replace');
      $('#nomatch_action').val('create_new');
      $('#parse_itemsyes').attr('checked', 'checked'); //Deselect #parseitemsno?
      $('#item_action').val('always_add');

      // Hide elements where defaults should not be changed
      var hidden_elements = [];
      //hidden_elements.push($('#marc_modification_template_id').closest('fieldset').get(0));
      hidden_elements.push($('#format').closest('fieldset').get(0));
      hidden_elements.push($('#overlay_action').closest('fieldset').get(0));
      hidden_elements.push($('#parse_itemsyes').closest('fieldset').get(0));
      $(hidden_elements).hide();
    }
    // Detect manage marc import page
    else if ($('#tools_manage-marc-import').length) {
      // Set "Show all entities" as default
      // Possible race condition? Seems to work but does not feel
      // very robust
      dataTablesDefaults.iDisplayLength = -1;

      // Hide elements where defaults should not be changed
      if ($('#new_matcher_id').length) {
        var hidden_elements = [];
        hidden_elements.push($('#new_matcher_id').closest('li').get(0));
        hidden_elements.push($('#overlay_action').closest('li').get(0));
        hidden_elements.push($('#nomatch_action').closest('li').get(0));
        hidden_elements.push($('#item_action').closest('li').get(0));
        hidden_elements.push($('#staged-record-matching-rules .action').get(0));
        $(hidden_elements).hide();
      }
    }

    // detect 'receive shipment from vendor' page
    if ($('#acq_parcels').length) {
      //move html block
      $('#parcels_new_parcel').prependTo('#resultlist');
      //gather elements to hide
      $('#shipmentdate').parent().hide();
      $('#shipmentcost').parent().hide();
      $('#shipmentcost_budgetid').parent().hide();

    }
    //Detect invoice page
    if ($('#acq_invoices').length) {
      // hide colums on invoice page
      var table = $('#acq_invoices').find('#resultst');
      table.find('th').eq(4).hide();
      var numChildren = table.find('td').length;
      //Dont really like this solution, maybe check index of the TH instead...
      var td = 4;
      var tds = table.find('td');

      while (td < numChildren) {

        tds.eq(td).hide();
        td += 10;
      }
    }

    // set filter default in fines tab
    if (location.pathname === '/cgi-bin/koha/members/boraccount.pl') {
      setTimeout(function() {
        $('#filter_transacs').trigger('click');
      }, 300);

    }

    // New order modifications

    // Detect new order page
    //    if ($('#acq_neworderempty').length) {
    //hide form part
    //      $('form fieldset').eq(0).hide();
    //change quantity default value
    //      $('form fieldset #quantity').attr('readonly',false);
    //      $('form fieldset #quantity').val(1);
    //    }

    // Detect "new basket page"
    if ($('#acq_basket').length) {
      // hide row 'managed by'
      $('#acqui_basket_summary #managedby').hide();
      // hide row 'Library'
      $('#acqui_basket_summary #branch').hide();
    }

    // Detect circulation page
    if ($('#circ_circulation').length) {
      $('#onsite_checkout').change(function() {
        if ($('#duedatespec')) {
          // need to do this because the datepicker forces a date into the #duedatespec input
          setTimeout(function() {
            $('#cleardate').trigger("click");
          }, 10);
        }
      });
      // When the username 'xg00623' is logged in...
      if ($('.loggedinusername:first').text() === 'xg00623') {
        $("#show-checkout-settings > a").click();

        $('#onsite_checkout').prop('checked', true).change();
      }

    }
    if ($('#pat_moremember').length) {
      $("#pat_moremember #patron-messaging-prefs").find("input").prop('disabled', true);
    }

    /* #### ADDING SELECT INSTEAD OF SIMPLE INPUT FOR RESTRICTIONS #### */
    $comment_input = $('#rcomment');
    var modify_patron_page = false;
    if (!$comment_input.length) {
      var $comment_input = $('#debarred_comment');
      var modify_patron_page = true;
    }
    if ($comment_input.length) {
      var $comment_input_wrapper = $comment_input.parent();
      $comment_input_wrapper.before('<li><label for="restriction_reason">Orsak</label><select id="restriction_reason"><option value="">Välj orsak</option><option value="WR, Webbregistrerad">WR, Webbregistrerad</option><option value="GU, GU-spärr">GU, GU-spärr</option><option value="AV, Avstängd">AV, Avstängd</option><option value="OR, Obetald räkning">OR, Obetald räkning</option><option value="ORI, Obetald räkning inkasso">ORI, Obetald räkning inkasso</option></select></li>');
      var $restriction_reason_select = $('#restriction_reason');
      var $add_debarment_hidden = $('#add_debarment');
      $comment_input_wrapper.hide();

      var commentable_restriction_reason = function(reason) {
        return reason && (reason === 'OR, Obetald räkning' || reason === 'ORI, Obetald räkning inkasso');
      };

      $restriction_reason_select.on('change', function() {
        if (commentable_restriction_reason(this.value)) {
          $comment_input.val('');
          $comment_input_wrapper.show();
        } else {
          $comment_input_wrapper.hide();
          $comment_input.val(this.value).change();
        }
        if (this.value === "" && $add_debarment_hidden.length) {
          $add_debarment_hidden.val(0);
        }
      });
      $(modify_patron_page ? '#saverecord' : '#manual_restriction_form input[type="submit"]').click(function(e) {
        var reason = $restriction_reason_select.val();
        if (commentable_restriction_reason(reason)) {
          // Comment form is visible and may contain user input, prepend selected reason
          $comment_input.val(reason + ": " + $comment_input.val());
        }
      });
    }
    /* ###### END RESTRICTION CODE ###### */

    // detect catalog detail page
    if ($('#catalog_detail').length) {
      // hide opac-link
      $('#catalogue_detail_biblio span.results_summary > a[href*="/opac-detail.pl"]').parent().hide()
    }

    if ($('#catalog_results').length) {
      // hide opac-link
      $('#catalog_results span.view-in-opac').hide()
    }



    if ($('#circ_returns').length) {
      if ($('.modal').length) {
        setTimeout(function() {
          $('.btn.btn-default.print').focus();
        }, 200)
      }
    }


    if ($('#catalog_results').length) {
      if ($('.modal').length) {
        setTimeout(function() {
          $('.btn.btn-default.print').focus();
        }, 200)
      }
    }

    /*
    if ($('#catalog_advsearch').length) {
      $('#advanced-search #toolbar fieldset .btn-group:nth-child(2)').hide();
      $('#advanced-search #searchterms div+div').hide();
    }
    */

    if ($('#catalog_moredetail').length) {
      $(".bibliodetails select[name='itemlost']").each(function(index) {
        if (this.value === "2") {
          $(this).find('option').attr('disabled', 'disabled')
        } else {
          $(this).find('option[value="2"]').attr('disabled', 'disabled')
        }
      })
    }


  });




  // remove order is standing in acquisitions
  if (location.pathname === '/cgi-bin/koha/acqui/basketheader.pl') {
    setTimeout(function() {
      $('#is_standing').parent().hide();
    }, 300);

  }


  // Set permanent location automatically when selecting shelving location
  if (location.pathname === '/cgi-bin/koha/cataloguing/additem.pl') {

    setTimeout(function() {
      // exceptions maps locations ids to other locations ids
      var exceptions = {'50':'50'};
      $('#subfield952c').on('change', function(e) {
        var val = e.val.toString().substr(0,2);
        if (val === "") {
          return;
        }
        if(exceptions[val]){
          val = exceptions[val];
        }
        $('#subfield952a select').select2('val', val).trigger('change');
      });
    }, 300);
  }




  $('#subscription_summary .rows ol li:nth-child(5)').css('white-space', 'pre');
  $('#subscription_summary .rows ol li:nth-child(5) span.label').css('display', 'block').css('float', 'none');

  /*KOHA-1092:*/

  if ( $( "#circ_returns #exemptcheck" ).length ) {
    $( "#circ_returns #dropboxcheck" ).parent().hide();
  }else{
    $( "#circ_returns fieldset#checkin_options" ).hide();
  }

  /* Modify advance search options */
  $('#catalog_advsearch #advanced-search #searchterms .advsearch option[value="ln,rtrn"]').attr('value', 'language');
  $('#catalog_advsearch #advanced-search #searchterms .advsearch option[value="pn"]').attr('value', 'name');
  $('#catalog_advsearch #advanced-search #searchterms .advsearch option[value="pn,phr"]').attr('value', 'name,phr');
  $('#catalog_advsearch #advanced-search #searchterms .advsearch option[value="pl"]').attr('value', 'place-of-publication');
  $('#catalog_advsearch #advanced-search #searchterms .advsearch option[value="curriculum"]').hide();
  $('#catalog_advsearch #advanced-search #searchterms .advsearch option[value="yr,st-year"]').hide();



  if (("#pat_maninvoice").length) {
      $("#pat_maninvoice #invoice_type").prepend($("<option></option>").attr("selected",'selected').attr("value",'').text("-- Välj --")); 
      $("#pat_maninvoice #desc").attr("required",'required');
  } 





/* #### filter based on booksellerid #### */ 

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
} 

let bookseller_ids = [{id: "1", identity_str: " Adlib "},{id: "2", identity_str: " Daw "},{id: "3", identity_str: " Delb " }];
let current_bookseller_id = getParameterByName("booksellerid");
let bookseller_to_filter_out_arr = jQuery.grep(bookseller_ids, function(item) {
  return item.id !== current_bookseller_id;
});


// make array from select
let select_arr = [];
$("#ean option").each  ( function() {
  select_arr.push({id: $(this).val(), content: $(this).text()});
});

let select_arr_filtered = [];
select_arr_filtered =  $.map(select_arr, function(select_item,index) {
  let temp = $.map(bookseller_to_filter_out_arr, function(item,index) {
     if (select_item.content.indexOf(item.identity_str) === -1) {
         return null;
     }
     else {
       return true;
     }
  });
  // compact it by removing null
  temp = $.grep(temp, function(n, i){
    return (n != null);
  });
  if (temp.length === 0) {
    return select_item;
  }
  else {
    return null;
  }
});

// compact it by removing null
select_arr_filtered = $.grep(select_arr_filtered, function(n, i){
 return (n != null);
});

// create new select
$('#ean option').remove().end();
$.each(select_arr_filtered, function(index, item) {
  $('#ean').append('<option value="' + item.id + '">' + item.content + '</option>');
})



})(jQuery);
