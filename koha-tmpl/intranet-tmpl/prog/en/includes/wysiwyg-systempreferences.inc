[% #Enable tinymce for system preferences %]
<script type="text/javascript" src="[% interface %]/lib/tiny_mce/tiny_mce_[% KOHA_VERSION %].js"></script>
<script>

[%# Save TinyMCE content and trigger an event on the original element %]
function wysiwyg_change (ed){
    ed.save();
    var original_textarea = ed.getElement();
    $(original_textarea).trigger("input");
}

tinyMCE.init({
    setup : function(ed) {
        ed.onInit.add(function(editor){
            [%-
            #Ideally, it would be nice just to use the "oninput" event, which captures keyboard input, dragging, pasting, etc.
            #However, it doesn't work in IE when the event listener is for an element which is "contenteditable". Since TinyMCE
            #uses a "contenteditable" body element in an iframe element, it's never going to fire in IE.

            #We can get around this a bit by using "onkeyup" and "ondragend".

            #"ondragend" occurs after you drag content within the editor. "ondrop" is for when you drag content from outside the
            #editor but it doesn't "dirty" the editor, which makes it useless, as the editor won't save unless it's dirty.
            #"onpaste" is useless in this same way.

            #Reference:
            #https://developer.mozilla.org/en-US/docs/Web/Events/input
            #https://connect.microsoft.com/IE/feedbackdetail/view/794285
            -%]

            tinyMCE.dom.Event.bind(editor.getBody(), 'input keyup dragend', function(e){
                if (ed.isDirty()){
                    wysiwyg_change(ed);
                }
            });
        });

        // Register change when TinyMCE command returns isDirty()
        ed.onExecCommand.add(function(ed, cmd, ui, val) {
            if (ed.isDirty()){
                wysiwyg_change(ed);
            }
        });

    },
    mode : "specific_textareas",
    editor_selector : "mce",
    theme : "advanced",
    content_css : "[% interface %]/[% theme %]/css/tinymce.css",
    plugins : "table,save,advhr,advlink,contextmenu,advimage",
    theme_advanced_buttons1 : "bold,italic,|,cut,copy,paste,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,|,image,link,unlink,anchor,cleanup,help,code,advhr,",
    theme_advanced_buttons2 : "tablecontrols,|,bullist,numlist,|,outdent,indent,|,undo,redo,|,removeformat,|,visualaid,|,sub,sup,|,charmap|,forecolor,backcolor",
    theme_advanced_buttons3 : "",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left",
    theme_advanced_path_location : "bottom",
    theme_advanced_resizing : true,
    apply_source_formatting : true
});
//]]>
</script>
