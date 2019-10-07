[% USE raw %]
[% USE Asset %]
[% #Enable tinymce for system preferences %]
[% Asset.js("lib/tiny_mce/tinymce.min.js") | $raw %]
[% INCLUDE 'str/tinymce_i18n.inc' %]

<script>
    // Save TinyMCE content and trigger an event on the original element
    function wysiwyg_change (ed){
        ed.save();
        var original_textarea = ed.getElement();
        $(original_textarea).trigger("input");
    }

    tinyMCE.init({
        branding : false,
        content_css : "[% interface | html %]/[% theme | html %]/css/tinymce.css",
        editor_selector : "mce",
        menubar : "file edit view insert format tools table",
        mode : "specific_textareas",
        plugins : "autoresize table hr link image charmap lists code emoticons",
        toolbar : [
            "formatselect | bold italic | cut copy paste | alignleft aligncenter alignright | outdent indent | image link unlink anchor cleanup hr",
            "table | bullist numlist | undo redo | removeformat | emoticons charmap | forecolor backcolor | code visualaid help"
        ],
        init_instance_callback: function (editor) {
            editor.on('Dirty', function (e) {
                // When a change has been made to the contents of an editor,
                // enable the corresponding preference Save button
                wysiwyg_change( editor );
            });
        }
    });
</script>
