$(document).ready(function(){
    $(".none").click(function(){
        if($(this).prop("checked")){
            var rowid = $(this).attr("id");
            var newid = Number(rowid.replace("none",""));
            $("#sms"+newid).prop("checked", false);
            $("#email"+newid).prop("checked", false);
            $("#phone"+newid).prop("checked", false);
            $("#digest"+newid).prop("checked", false);
            $("#rss"+newid).prop("checked", false);
        }
    });
    $(".active_notify").on("change",function(){
        var attr_id = $(this).data("attr-id");
        if( $(this).prop("checked") ){
            $("#none" + attr_id ).prop("checked", false);
        }
    });
    $("#info_digests").tooltip();
});
