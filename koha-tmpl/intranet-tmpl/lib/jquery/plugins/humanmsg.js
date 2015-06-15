/*
	HUMANIZED MESSAGES 1.0
	idea - http://www.humanized.com/weblog/2006/09/11/monolog_boxes_and_transparent_messages
	home - http://humanmsg.googlecode.com
*/

var humanMsg = {
	setup: function(appendTo, logName, msgOpacity) {
		humanMsg.msgID = 'humanMsg';
		humanMsg.logID = 'humanMsgLog';

		// appendTo is the element the msg is appended to
		if (appendTo == undefined) appendTo = 'body';

		// The text on the Log tab
		if (logName == undefined) logName = 'Message Log';

		// Opacity of the message
		humanMsg.msgOpacity = 0.8;

		if (msgOpacity != undefined) humanMsg.msgOpacity = parseFloat(msgOpacity);

		// Inject the message structure
		jQuery(appendTo).append('<div id="'+humanMsg.msgID+'" class="humanMsg"><div id="'+humanMsg.msgID+'-contents"></div></div> <div id="'+humanMsg.logID+'"><p class="launcher">'+logName+'</p><ul></ul></div>');

		jQuery('#'+humanMsg.logID+' p').click(
			function() { jQuery(this).siblings('ul').slideToggle() }
		)
	},

	displayAlert: function(msg, options) {
		humanMsg.displayMsg('<p>' + msg + '</p>', options);
	},

    logMsg: function(msg) {
        jQuery('#'+humanMsg.logID)
            .show().children('ul').prepend('<li>'+msg+'</li>')	// Prepend message to log
            .children('li:first').slideDown(200)				// Slide it down

        if ( jQuery('#'+humanMsg.logID+' ul').css('display') == 'none') {
            jQuery('#'+humanMsg.logID+' p').animate({ bottom: 40 }, 200, 'linear', function() {
                jQuery(this).animate({ bottom: 0 }, 300, 'swing', function() { jQuery(this).css({ bottom: 0 }) })
            })
        }
    },

	displayMsg: function(msg, options) {
		if (msg == '')
			return;

        options = $.extend({
            delay: 1000,
            life: Infinity,
            log: true,
            className: '',
        }, options);

		clearTimeout(humanMsg.t1);
		clearTimeout(humanMsg.t2);

		// Inject message
		jQuery('#'+humanMsg.msgID+'-contents').html(msg);

		// Show message
		jQuery('#'+humanMsg.msgID).attr('class', 'humanMsg ' + options.className).show().animate({ opacity: humanMsg.msgOpacity}, 200, function() {
            humanMsg.logMsg(msg, options);
		})

		// Watch for mouse & keyboard in `delay`
		humanMsg.t1 = setTimeout("humanMsg.bindEvents()", options.delay)
		// Remove message after `life`
		humanMsg.t2 = setTimeout("humanMsg.removeMsg()", options.life)
	},

	bindEvents: function() {
	// Remove message if mouse is moved or key is pressed
		jQuery(document)
			.mousemove(humanMsg.removeMsg)
			.click(humanMsg.removeMsg)
			.keypress(humanMsg.removeMsg)
	},

	removeMsg: function() {
		// Unbind mouse & keyboard
		jQuery(document)
			.unbind('mousemove', humanMsg.removeMsg)
			.unbind('click', humanMsg.removeMsg)
			.unbind('keypress', humanMsg.removeMsg)

                // If message is fully transparent, fade it out
                if ( Math.abs(jQuery('#'+humanMsg.msgID).css('opacity') - humanMsg.msgOpacity ) < 0.00001 )
                        jQuery('#'+humanMsg.msgID).animate({ opacity: 0 }, 500, function() { jQuery(this).hide() })
	}
};

jQuery(document).ready(function(){
	humanMsg.setup();
})
