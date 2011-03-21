/*
 * Copyright (c) 2008 Greg Weber greg at gregweber.info
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * documentation at http://gregweber.info/projects/uitablefilter
 *
 * allows table rows to be filtered (made invisible)
 * <code>
 * t = $('table')
 * $.uiTableFilter( t, phrase )
 * </code>
 * arguments:
 *   jQuery object containing table rows
 *   phrase to search for
 *   optional arguments:
 *     column to limit search too (the column title in the table header)
 *     ifHidden - callback to execute if one or more elements was hidden
 */
jQuery.uiTableFilter = function(jq, phrase, column, ifHidden){
  var new_hidden = false;
  if( this.last_phrase === phrase ) return false;

  var phrase_length = phrase.length;
  var words = phrase.toLowerCase().split(" ");

  // these function pointers may change
  var matches = function(elem) { elem.show() }
  var noMatch = function(elem) { elem.hide(); new_hidden = true }
  var getText = function(elem) { return elem.text() }

  if( column ) {
    var index = null;
    jq.find("thead > tr:last > th").each( function(i){
      if( $.trim($(this).text()) == column ){
        index = i; return false;
      }
    });
    if( index == null ) throw("given column: " + column + " not found")

    getText = function(elem){ return jQuery(elem.find(
      ("td:eq(" + index + ")")  )).text()
    }
  }

  // if added one letter to last time,
  // just check newest word and only need to hide
  if( (words.size > 1) && (phrase.substr(0, phrase_length - 1) ===
        this.last_phrase) ) {

    if( phrase[-1] === " " )
    { this.last_phrase = phrase; return false; }

    var words = words[-1]; // just search for the newest word

    // only hide visible rows
    matches = function(elem) {;}
    var elems = jq.find("tbody > tr:visible")
  }
  else {
    new_hidden = true;
    var elems = jq.find("tbody > tr")
  }

  elems.each(function(){
    var elem = jQuery(this);
    jQuery.uiTableFilter.has_words( getText(elem), words, false ) ?
      matches(elem) : noMatch(elem);
  });

  last_phrase = phrase;
  if( ifHidden && new_hidden ) ifHidden();
  return jq;
};

// caching for speedup
jQuery.uiTableFilter.last_phrase = ""

// not jQuery dependent
// "" [""] -> Boolean
// "" [""] Boolean -> Boolean
jQuery.uiTableFilter.has_words = function( str, words, caseSensitive )
{
  var text = caseSensitive ? str : str.toLowerCase();
  for (var i=0; i < words.length; i++) {
    if (text.indexOf(words[i]) === -1) return false;
  }
  return true;
}
