<script type="text/javascript">
//<![CDATA[
function keep_text(clicked_index) {
    var searchboxes = document.getElementsByClassName("head-searchbox");
    var persist = searchboxes[0].value;

    for (i = 0; i < searchboxes.length - 1; i++) {
        if (searchboxes[i].value != searchboxes[i+1].value) {
            if (i === searchboxes.length-2) {
                if (searchboxes[i].value != searchboxes[0].value) {
                    persist = searchboxes[i].value;
                } else if (searchboxes.length === 2) {
                    if (clicked_index === 0) {
                        persist = searchboxes[1].value;
                    }
                } else {
                    persist = searchboxes[i+1].value;
                }
            } else if (searchboxes[i+1].value != searchboxes[i+2].value) {
                persist = searchboxes[i+1].value;
            }
        }
    }

    for (i = 0; i < searchboxes.length; i++) {
        searchboxes[i].value = persist;
    }
}
//]]>
</script>
