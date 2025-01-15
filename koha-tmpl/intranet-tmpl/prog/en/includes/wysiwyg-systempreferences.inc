[% USE raw %]
[% USE Asset %]
[%#Enable tinymce for system preferences %]
[% Asset.js("lib/tiny_mce/tinymce.min.js") | $raw %]
[% INCLUDE 'str/tinymce_i18n.inc' %]
<!-- wysiwyg-systempreferences.inc -->
<script>
    // Save TinyMCE content and trigger an event on the original element
    function wysiwyg_change (ed){
        ed.save();
        var original_textarea = ed.getElement();
        $(original_textarea).trigger("input");
    }

    tinyMCE.init({
        verify_html: false,
        force_br_newlines : false,
        force_p_newlines : false,
        forced_root_block : '',
        extended_valid_elements:"style,link[href|rel]",
        custom_elements:"style,link,~link",
        branding : false,
        relative_urls : false,
        content_css : "[% interface | html %]/[% theme | html %]/css/tinymce.css",
        convert_urls : false,
        editor_selector : "mce",
        menubar : "file edit view insert format tools table",
        mode : "specific_textareas",
        plugins : "autoresize table hr link image charmap lists code emoticons",
        toolbar : [
            "formatselect | bold italic | cut copy paste | alignleft aligncenter alignright | outdent indent | image link unlink anchor cleanup hr",
            "table | bullist numlist | undo redo | removeformat | emoticons charmap | forecolor backcolor | code"
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
<!-- / wysiwyg-systempreferences.inc -->
