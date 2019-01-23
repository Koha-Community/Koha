<script>
//<![CDATA[
$(document).ready(function() {
    function mana_increment(mana_id, resource, fieldvalue, stepvalue = 1) {
        $.ajax( {
            type: "POST",
            url: "/cgi-bin/koha/svc/mana/increment",
            data: {id: mana_id, resource: resource, field: fieldvalue, step: stepvalue},
            datatype: "json",
        })
    }

    function mana_comment( target_id, manamsg, resource_type ) {
        $.ajax( {
            type: "POST",
            url: "/cgi-bin/koha/svc/mana/share",
            data: {message: manamsg, resource: resource_type , resource_id: target_id},
            datatype: "json",
        })
    }

    $(document).on('click', 'ul li.mana-comment', function() {
        id = $(this).attr('data-id');
        mana_increment(id, 'resource_comment', 'nb');
    });

    $(document).on('click', 'ul li.mana-other-comment', function() {
        $('#mana-comment-box').modal('show');
    });

    $(document).on('click', '#mana-send-comment', function() {
        var resource_type = $('#mana-resource').val();
        var resource_id = $('#mana-resource-id').val();
        var comment = $("#mana-comment").val();
        mana_comment(resource_id, comment, resource_type);
        $("#mana-comment-box").modal("hide");
    });

    $(document).on('click', '#mana-comment-close', function() {
        $("#mana-comment-box").modal("hide");
    });
});
//]]>
</script>
