/* Source: http://www.webspeaks.in/2011/07/new-gmail-like-floating-toolbar-jquery.html
   Revision: http://jsfiddle.net/pasmalin/AyjeZ/
*/
(function($){
  $.fn.fixFloat = function(options){

    var defaults = {
      enabled: true
    };
    var options = $.extend(defaults, options);

    var offsetTop;    /**Distance of the element from the top of window**/
    var s;        /**Scrolled distance from the top of window through which we have moved**/
    var fixMe = true;
    var repositionMe = true;

    var tbh = $(this);
    var originalOffset = tbh.position().top;  /**Get the actual distance of the element from the top mychange:change to position better work**/

    if (tbh.css('position')!='absolute') {
      var tbhBis = $("<div></div>");
      tbhBis.css({"display":tbh.css("display"),"visibility":"hidden"});
      tbhBis.width(tbh.outerWidth(true));
      tbhBis.height(tbh.outerHeight(true));
      tbh.after(tbhBis);
      tbh.width(tbh.width());
      tbh.css({'position':'absolute'});
    }

    if(options.enabled){
      $(window).scroll(function(){
        var offsetTop = tbh.offset().top;  /**Get the current distance of the element from the top **/
        var s = parseInt($(window).scrollTop(), 10);  /**Get the from the top of wondow through which we have scrolled**/
        var fixMe = true;
        if(s > offsetTop){
          fixMe = true;
        }else{
          fixMe = false;
        }

        if(s < originalOffset){
          repositionMe = true;
        }else{
          repositionMe = false;
        }

        if(fixMe){
          var cssObj = {
            'position' : 'fixed',
            'top' : '0px',
            'z-index' : '1000'
          }
          tbh.css(cssObj);
          tbh.addClass("floating");
        }
        if(repositionMe){
          var cssObj = {
            'position' : 'absolute',
            'top' : originalOffset,
            'z-index' : '1'
          }
          tbh.css(cssObj);
          tbh.removeClass("floating");
        }
      });
    }
  };
})(jQuery);