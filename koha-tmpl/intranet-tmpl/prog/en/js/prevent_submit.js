var prevent_nav = window.Event ? true : false;
if (prevent_nav) {
    window.captureEvents(Event.KEYDOWN);
    window.onkeydown = NetscapeEventHandler_KeyDown;
} else {
    document.onkeydown = IEEventHandler_KeyDown;
}

function NetscapeEventHandler_KeyDown(e) {
    if (e.which == 13 && e.target.type != 'textarea' && e.target.type != 'submit') { return false; }
    return true;
}

function IEEventHandler_KeyDown() {
    if (event.keyCode == 13 && event.srcElement.type != 'textarea' && event.srcElement.type != 'submit')
        return false;
    return true;
}
