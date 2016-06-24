<script type="text/javascript">
//<![CDATA[

    var MSG_CHOOSE_Z3950 = _("Please choose at least one external target");

[% IF ( total_pages ) %]
    var interface = "[% interface %]";
    var theme = "[% theme %]";
    var MSG_LOADING = _("Loading");

function validate_goto_page(){
    var page = $('#goto_page').val();
    if(isNaN(page)) {
        alert(_("The page entered is not a number."));
        return false;
    }
    else if(page < 1 || page > [% total_pages %] ) {
        alert(_("The page should be a number between 1 and %s.").format([% total_pages %]));
        return false;
    }
    else {
        return true;
    }
}
[% END %]

//]]>
</script>
