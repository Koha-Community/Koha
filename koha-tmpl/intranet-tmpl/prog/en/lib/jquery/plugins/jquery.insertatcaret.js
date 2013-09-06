/*!
 * jQuery insertAtCaret
 * Allows inserting text where the caret is in a textarea
 * Copyright (c) 2003-2010 phpMyAdmin devel team
 * Version: 1.0
 * Developed by the phpMyAdmin devel team. Modified by Alex King and variaas
 * http://alexking.org/blog/2003/06/02/inserting-at-the-cursor-using-javascript
 * http://www.mail-archive.com/jquery-en@googlegroups.com/msg08708.html
 * Licensed under the GPL license:
 * http://www.gnu.org/licenses/gpl.html
 */
;(function($) {

$.fn.insertAtCaret = function (myValue) {

    return this.each(function() {

        //IE support
        if (document.selection) {

            this.focus();
            sel = document.selection.createRange();
            sel.text = myValue;
            this.focus();

        } else if (this.selectionStart || this.selectionStart == '0') {

            //MOZILLA / NETSCAPE support
            var startPos = this.selectionStart;
            var endPos = this.selectionEnd;
            var scrollTop = this.scrollTop;
            this.value = this.value.substring(0, startPos)+ myValue+ this.value.substring(endPos,this.value.length);
            this.focus();
            this.selectionStart = startPos + myValue.length;
            this.selectionEnd = startPos + myValue.length;
            this.scrollTop = scrollTop;

        } else {

            this.value += myValue;
            this.focus();
        }
    });
};

})(jQuery);
