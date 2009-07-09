/*
 *
 * Copyright (c) 2006-2008 Sam Collett (http://www.texotela.co.uk)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 * 
 * Version 2.1
 * Demo: http://www.texotela.co.uk/code/jquery/checkboxes/
 *
 * $LastChangedDate$
 * $Rev$
 */
;(function(d){d.fn.toggleCheckboxes=function(a,b){a=a||"*";b=b||false;var c=d([]);this.each(function(){var e=d("input[type=checkbox]",this).filter(a).each(function(){this.checked=!this.checked}).filter(":checked");c=e});if(!b){c=this}return c};d.fn.checkCheckboxes=function(a,b){a=a||"*";b=b||false;var c=d([]);this.each(function(){var e=d("input[type=checkbox]",this).filter(a).each(function(){this.checked=true}).filter(":checked");c=e});if(!b){c=this}return c};d.fn.unCheckCheckboxes=function(a,b){a=a||"*";b=b||false;var c=d([]);this.each(function(){var e=d("input[type=checkbox]",this).filter(a).each(function(){this.checked=false}).filter(":not(:checked)");c=e});if(!b){c=this}return c};d.radioCheckboxGroup=function(e,a){a=a||"*";var b="input[type=checkbox]";if(e){b+="[name="+e+"]"}var c=d(b).filter(a);c.click(function(){c.not(this).each(function(){this.checked=false}).end()})}})(jQuery);