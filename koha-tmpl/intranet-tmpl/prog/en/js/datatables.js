// These default options are for translation but can be used
// for any other datatables settings
// MSG_DT_* variables comes from datatables-strings.inc
// To use it, write:
//  $("#table_id").dataTable($.extend(true, {}, dataTableDefaults, {
//      // other settings
//  } ) );
var dataTablesDefaults = {
    "oLanguage": {
        "oPaginate": {
            "sFirst"    : window.MSG_DT_FIRST || "First",
            "sLast"     : window.MSG_DT_LAST || "Last",
            "sNext"     : window.MSG_DT_NEXT || "Next",
            "sPrevious" : window.MSG_DT_PREVIOUS || "Previous"
        },
        "sEmptyTable"       : window.MSG_DT_EMPTY_TABLE || "No data available in table",
        "sInfo"             : window.MSG_DT_INFO || "Showing _START_ to _END_ of _TOTAL_ entries",
        "sInfoEmpty"        : window.MSG_DT_INFO_EMPTY || "No entries to show",
        "sInfoFiltered"     : window.MSG_DT_INFO_FILTERED || "(filtered from _MAX_ total entries)",
        "sLengthMenu"       : window.MSG_DT_LENGTH_MENU || "Show _MENU_ entries",
        "sLoadingRecords"   : window.MSG_DT_LOADING_RECORDS || "Loading...",
        "sProcessing"       : window.MSG_DT_PROCESSING || "Processing...",
        "sSearch"           : window.MSG_DT_SEARCH || "Search:",
        "sZeroRecords"      : window.MSG_DT_ZERO_RECORDS || "No matching records found"
    },
    "sDom": '<"top pager"ilpf>t<"bottom pager"ip>'
};


// Return an array of string containing the values of a particular column
$.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
    // check that we have a column id
    if ( typeof iColumn == "undefined" ) return new Array();
    // by default we only wany unique data
    if ( typeof bUnique == "undefined" ) bUnique = true;
    // by default we do want to only look at filtered data
    if ( typeof bFiltered == "undefined" ) bFiltered = true;
    // by default we do not wany to include empty values
    if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;
    // list of rows which we're going to loop through
    var aiRows;
    // use only filtered rows
    if (bFiltered == true) aiRows = oSettings.aiDisplay;
    // use all rows
    else aiRows = oSettings.aiDisplayMaster; // all row numbers

    // set up data array
    var asResultData = new Array();
    for (var i=0,c=aiRows.length; i<c; i++) {
        iRow = aiRows[i];
        var aData = this.fnGetData(iRow);
        var sValue = aData[iColumn];
        // ignore empty values?
        if (bIgnoreEmpty == true && sValue.length == 0) continue;
        // ignore unique values?
        else if (bUnique == true && jQuery.inArray(sValue, asResultData) > -1) continue;
        // else push the value onto the result data array
        else asResultData.push(sValue);
    }
    return asResultData;
}

// List of unbind keys (Ctrl, Alt, Direction keys, etc.)
// These keys must not launch filtering
var blacklist_keys = new Array(0, 16, 17, 18, 37, 38, 39, 40);

// Set a filtering delay for global search field
jQuery.fn.dataTableExt.oApi.fnSetFilteringDelay = function ( oSettings, iDelay ) {
    /*
     * Inputs:      object:oSettings - dataTables settings object - automatically given
     *              integer:iDelay - delay in milliseconds
     * Usage:       $('#example').dataTable().fnSetFilteringDelay(250);
     * Author:      Zygimantas Berziunas (www.zygimantas.com) and Allan Jardine
     * License:     GPL v2 or BSD 3 point style
     * Contact:     zygimantas.berziunas /AT\ hotmail.com
     */
    var
        _that = this,
        iDelay = (typeof iDelay == 'undefined') ? 250 : iDelay;

    this.each( function ( i ) {
        $.fn.dataTableExt.iApiIndex = i;
        var
            $this = this,
            oTimerId = null,
            sPreviousSearch = null,
            anControl = $( 'input', _that.fnSettings().aanFeatures.f );

        anControl.unbind( 'keyup.DT' ).bind( 'keyup.DT', function(event) {
            var $$this = $this;
            if (blacklist_keys.indexOf(event.keyCode) != -1) {
                return this;
            }else if ( event.keyCode == '13' ) {
                $.fn.dataTableExt.iApiIndex = i;
                _that.fnFilter( $(this).val() );
            } else {
                if (sPreviousSearch === null || sPreviousSearch != anControl.val()) {
                    window.clearTimeout(oTimerId);
                    sPreviousSearch = anControl.val();
                    oTimerId = window.setTimeout(function() {
                        $.fn.dataTableExt.iApiIndex = i;
                        _that.fnFilter( anControl.val() );
                    }, iDelay);
                }
            }
        });

        return this;
    } );
    return this;
}

// Add a filtering delay on general search and on all input (with a class 'filter')
jQuery.fn.dataTableExt.oApi.fnAddFilters = function ( oSettings, sClass, iDelay ) {
    var table = this;
    this.fnSetFilteringDelay(iDelay);
    var filterTimerId = null;
    $("input."+sClass).keyup(function(event) {
      if (blacklist_keys.indexOf(event.keyCode) != -1) {
        return this;
      }else if ( event.keyCode == '13' ) {
        table.fnFilter( $(this).val(), $(this).attr('data-column_num') );
      } else {
        window.clearTimeout(filterTimerId);
        var input = this;
        filterTimerId = window.setTimeout(function() {
          table.fnFilter($(input).val(), $(input).attr('data-column_num'));
        }, iDelay);
      }
    });
}

// Useful if you want to filter on dates with 2 inputs (start date and end date)
// You have to include calendar.inc to use it
function dt_add_rangedate_filter(begindate_id, enddate_id, dateCol) {
    $.fn.dataTableExt.afnFiltering.push(
        function( oSettings, aData, iDataIndex ) {

            var beginDate = Date_from_syspref($("#"+begindate_id).val()).getTime();
            var endDate   = Date_from_syspref($("#"+enddate_id).val()).getTime();

            var data = Date_from_syspref(aData[dateCol]).getTime();

            if ( !parseInt(beginDate) && ! parseInt(endDate) ) {
                return true;
            }
            else if ( beginDate <= data && !parseInt(endDate) ) {
                return true;
            }
            else if ( data <= endDate && !parseInt(beginDate) ) {
                return true;
            }
            else if ( beginDate <= data && data <= endDate) {
                return true;
            }
            return false;
        }
    );
}

//Sorting for dates (uk format)
function dt_add_type_uk_date() {
  jQuery.fn.dataTableExt.aTypes.unshift(
    function ( sData )
    {
      if (sData.match(/(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20|21)\d\d/))
      {
        return 'uk_date';
      }
      return null;
    }
  );

  jQuery.fn.dataTableExt.oSort['uk_date-asc']  = function(a,b) {
    var re = /(\d{2}\/\d{2}\/\d{4})/;
    a.match(re);
    var ukDatea = RegExp.$1.split("/");
    b.match(re);
    var ukDateb = RegExp.$1.split("/");

    var x = (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
    var y = (ukDateb[2] + ukDateb[1] + ukDateb[0]) * 1;

    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
  };

  jQuery.fn.dataTableExt.oSort['uk_date-desc'] = function(a,b) {
    var re = /(\d{2}\/\d{2}\/\d{4})/;
    a.match(re);
    var ukDatea = RegExp.$1.split("/");
    b.match(re);
    var ukDateb = RegExp.$1.split("/");

    var x = (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
    var y = (ukDateb[2] + ukDateb[1] + ukDateb[0]) * 1;

    return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
  };
}

// Sorting on html contains
// <a href="foo.pl">bar</a> sort on 'bar'
function dt_overwrite_html_sorting_localeCompare() {
    jQuery.fn.dataTableExt.oSort['html-asc']  = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if (typeof(a.localeCompare == "function")) {
           return a.localeCompare(b);
        } else {
           return (a > b) ? 1 : ((a < b) ? -1 : 0);
        }
    };

    jQuery.fn.dataTableExt.oSort['html-desc'] = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if(typeof(b.localeCompare == "function")) {
            return b.localeCompare(a);
        } else {
            return (b > a) ? 1 : ((b < a) ? -1 : 0);
        }
    };

    jQuery.fn.dataTableExt.oSort['num-html-asc']  = function(a,b) {
        var x = a.replace( /<.*?>/g, "" );
        var y = b.replace( /<.*?>/g, "" );
        x = parseFloat( x );
        y = parseFloat( y );
        return ((x < y) ? -1 : ((x > y) ?  1 : 0));
    };

    jQuery.fn.dataTableExt.oSort['num-html-desc'] = function(a,b) {
        var x = a.replace( /<.*?>/g, "" );
        var y = b.replace( /<.*?>/g, "" );
        x = parseFloat( x );
        y = parseFloat( y );
        return ((x < y) ?  1 : ((x > y) ? -1 : 0));
    };
}

// Sorting on string without accentued characters
function dt_overwrite_string_sorting_localeCompare() {
    jQuery.fn.dataTableExt.oSort['string-asc']  = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if (typeof(a.localeCompare == "function")) {
           return a.localeCompare(b);
        } else {
           return (a > b) ? 1 : ((a < b) ? -1 : 0);
        }
    };

    jQuery.fn.dataTableExt.oSort['string-desc'] = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if(typeof(b.localeCompare == "function")) {
            return b.localeCompare(a);
        } else {
            return (b > a) ? 1 : ((b < a) ? -1 : 0);
        }
    };
}

// Replace a node with a html and js contain.
function replace_html( original_node, type ) {
    switch ( $(original_node).attr('data-type') ) {
        case "range_dates":
            var id = $(original_node).attr("data-id");
            var format = $(original_node).attr("data-format");
            replace_html_date( original_node, id, format );
            break;
        default:
            alert("_(This node can't be replaced)");
    }
}

// Replace a node with a "From [date] To [date]" element
// Used on tfoot > td
function replace_html_date( original_node, id, format ) {
    var node = $('<span style="white-space:nowrap">' + _("From") + '<input type="text" id="' + id + 'from" readonly="readonly" placeholder=\'' + _("Pick date") + '\' size="7" /><a title="Delete this filter" style="cursor:pointer" onclick=\'$("#' + id + 'from").val("").change();\' >&times;</a></span><br/><span style="white-space:nowrap">' + _("To") + '<input type="text" id="' + id + 'to" readonly="readonly" placeholder=\'' + _("Pick date") + '\' size="7" /><a title="Delete this filter" style="cursor:pointer" onclick=\'$("#' + id + 'to").val("").change();\' >&times;</a></span>');
    $(original_node).replaceWith(node);
    var script = document.createElement( 'script' );
    script.type = 'text/javascript';
    var script_content = "Calendar.setup({";
    script_content += "    inputField: \"" + id + "from\",";
    script_content += "    ifFormat: \"" + format + "\",";
    script_content += "    button: \"" + id + "from\",";
    script_content += "    onClose: function(){ $(\"#" + id + "from\").change(); this.hide();}";
    script_content += "  });";
    script_content += "  Calendar.setup({";
    script_content += "    inputField: \"" + id + "to\",";
    script_content += "    ifFormat: \"" + format + "\",";
    script_content += "    button: \"" + id + "to\",";
    script_content += "    onClose: function(){ $(\"#" + id + "to\").change(); this.hide();}";
    script_content += "  });";
    script.text = script_content;
    $(original_node).append( script );
}

$.fn.dataTableExt.oPagination.four_button = {
    /*
     * Function: oPagination.four_button.fnInit
     * Purpose:  Initalise dom elements required for pagination with a list of the pages
     * Returns:  -
     * Inputs:   object:oSettings - dataTables settings object
     *           node:nPaging - the DIV which contains this pagination control
     *           function:fnCallbackDraw - draw function which must be called on update
     */
    "fnInit": function ( oSettings, nPaging, fnCallbackDraw )
    {
        nFirst = document.createElement( 'span' );
        nPrevious = document.createElement( 'span' );
        nNext = document.createElement( 'span' );
        nLast = document.createElement( 'span' );

        nFirst.appendChild( document.createTextNode( oSettings.oLanguage.oPaginate.sFirst ) );
        nPrevious.appendChild( document.createTextNode( oSettings.oLanguage.oPaginate.sPrevious ) );
        nNext.appendChild( document.createTextNode( oSettings.oLanguage.oPaginate.sNext ) );
        nLast.appendChild( document.createTextNode( oSettings.oLanguage.oPaginate.sLast ) );

        nFirst.className = "paginate_button first";
        nPrevious.className = "paginate_button previous";
        nNext.className="paginate_button next";
        nLast.className = "paginate_button last";

        nPaging.appendChild( nFirst );
        nPaging.appendChild( nPrevious );
        nPaging.appendChild( nNext );
        nPaging.appendChild( nLast );

        $(nFirst).click( function () {
            oSettings.oApi._fnPageChange( oSettings, "first" );
            fnCallbackDraw( oSettings );
        } );

        $(nPrevious).click( function() {
            oSettings.oApi._fnPageChange( oSettings, "previous" );
            fnCallbackDraw( oSettings );
        } );

        $(nNext).click( function() {
            oSettings.oApi._fnPageChange( oSettings, "next" );
            fnCallbackDraw( oSettings );
        } );

        $(nLast).click( function() {
            oSettings.oApi._fnPageChange( oSettings, "last" );
            fnCallbackDraw( oSettings );
        } );

        /* Disallow text selection */
        $(nFirst).bind( 'selectstart', function () { return false; } );
        $(nPrevious).bind( 'selectstart', function () { return false; } );
        $(nNext).bind( 'selectstart', function () { return false; } );
        $(nLast).bind( 'selectstart', function () { return false; } );
    },

    /*
     * Function: oPagination.four_button.fnUpdate
     * Purpose:  Update the list of page buttons shows
     * Returns:  -
     * Inputs:   object:oSettings - dataTables settings object
     *           function:fnCallbackDraw - draw function which must be called on update
     */
    "fnUpdate": function ( oSettings, fnCallbackDraw )
    {
        if ( !oSettings.aanFeatures.p )
        {
            return;
        }

        /* Loop over each instance of the pager */
        var an = oSettings.aanFeatures.p;
        for ( var i=0, iLen=an.length ; i<iLen ; i++ )
        {
            var buttons = an[i].getElementsByTagName('span');
            if ( oSettings._iDisplayStart === 0 )
            {
                buttons[0].className = "paginate_disabled_previous";
                buttons[1].className = "paginate_disabled_previous";
            }
            else
            {
                buttons[0].className = "paginate_enabled_previous";
                buttons[1].className = "paginate_enabled_previous";
            }

            if ( oSettings.fnDisplayEnd() == oSettings.fnRecordsDisplay() )
            {
                buttons[2].className = "paginate_disabled_next";
                buttons[3].className = "paginate_disabled_next";
            }
            else
            {
                buttons[2].className = "paginate_enabled_next";
                buttons[3].className = "paginate_enabled_next";
            }
        }
    }
};

$.fn.dataTableExt.oSort['num-html-asc']  = function(a,b) {
    var x = a.replace( /<.*?>/g, "" );
    var y = b.replace( /<.*?>/g, "" );
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

$.fn.dataTableExt.oSort['num-html-desc'] = function(a,b) {
    var x = a.replace( /<.*?>/g, "" );
    var y = b.replace( /<.*?>/g, "" );
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

(function() {

/*
 * Natural Sort algorithm for Javascript - Version 0.7 - Released under MIT license
 * Author: Jim Palmer (based on chunking idea from Dave Koelle)
 * Contributors: Mike Grier (mgrier.com), Clint Priest, Kyle Adams, guillermo
 * See: http://js-naturalsort.googlecode.com/svn/trunk/naturalSort.js
 */
function naturalSort (a, b) {
    var re = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?$|^0x[0-9a-f]+$|[0-9]+)/gi,
        sre = /(^[ ]*|[ ]*$)/g,
        dre = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/,
        hre = /^0x[0-9a-f]+$/i,
        ore = /^0/,
        // convert all to strings and trim()
        x = a.toString().replace(sre, '') || '',
        y = b.toString().replace(sre, '') || '',
        // chunk/tokenize
        xN = x.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
        yN = y.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
        // numeric, hex or date detection
        xD = parseInt(x.match(hre), 10) || (xN.length != 1 && x.match(dre) && Date.parse(x)),
        yD = parseInt(y.match(hre), 10) || xD && y.match(dre) && Date.parse(y) || null;
    // first try and sort Hex codes or Dates
    if (yD)
        if ( xD < yD ) return -1;
        else if ( xD > yD )  return 1;
    // natural sorting through split numeric strings and default strings
    for(var cLoc=0, numS=Math.max(xN.length, yN.length); cLoc < numS; cLoc++) {
        // find floats not starting with '0', string or 0 if not defined (Clint Priest)
        var oFxNcL = !(xN[cLoc] || '').match(ore) && parseFloat(xN[cLoc]) || xN[cLoc] || 0;
        var oFyNcL = !(yN[cLoc] || '').match(ore) && parseFloat(yN[cLoc]) || yN[cLoc] || 0;
        // handle numeric vs string comparison - number < string - (Kyle Adams)
        if (isNaN(oFxNcL) !== isNaN(oFyNcL)) return (isNaN(oFxNcL)) ? 1 : -1;
        // rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
        else if (typeof oFxNcL !== typeof oFyNcL) {
            oFxNcL += '';
            oFyNcL += '';
        }
        if (oFxNcL < oFyNcL) return -1;
        if (oFxNcL > oFyNcL) return 1;
    }
    return 0;
}

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "natural-asc": function ( a, b ) {
        return naturalSort(a,b);
    },

    "natural-desc": function ( a, b ) {
        return naturalSort(a,b) * -1;
    }
} );

}());
/* Plugin to allow sorting on data stored in a span's title attribute
 *
 * Ex: <td><span title="[% ISO_date %]">[% formatted_date %]</span></td>
 *
 * In DataTables config:
 *     "aoColumns": [
 *        { "sType": "title-string" },
 *      ]
 * http://datatables.net/plug-ins/sorting#hidden_title_string
 */
jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "title-string-pre": function ( a ) {
        return a.match(/title="(.*?)"/)[1].toLowerCase();
    },

    "title-string-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "title-string-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );

(function() {

    /* Plugin to allow text sorting to ignore articles
     *
     * In DataTables config:
     *     "aoColumns": [
     *        { "sType": "anti-the" },
     *      ]
     * Based on the plugin found here:
     * http://datatables.net/plug-ins/sorting#anti_the
     * Modified to exclude HTML tags from sorting
     * Extended to accept a string of space-separated articles
     * from a configuration file (in English, "a," "an," and "the")
     */

    if(CONFIG_EXCLUDE_ARTICLES_FROM_SORT){
        var articles = CONFIG_EXCLUDE_ARTICLES_FROM_SORT.split(" ");
        var rpattern = "";
        for(i=0;i<articles.length;i++){
            rpattern += "^" + articles[i] + " ";
            if(i < articles.length - 1){ rpattern += "|"; }
        }
        var re = new RegExp(rpattern, "i");
    }

    jQuery.extend( jQuery.fn.dataTableExt.oSort, {
        "anti-the-pre": function ( a ) {
            var x = String(a).replace( /<[\s\S]*?>/g, "" );
            var y = x.trim();
            var z = y.replace(re, "").toLowerCase();
            return z;
        },

        "anti-the-asc": function ( a, b ) {
            return ((a < b) ? -1 : ((a > b) ? 1 : 0));
        },

        "anti-the-desc": function ( a, b ) {
            return ((a < b) ? 1 : ((a > b) ? -1 : 0));
        }
    });

}());