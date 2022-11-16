/* global template_path */
$(document).ready(function(){
    $(".authority_preview a").on("click", function(e){
        e.preventDefault();
        var authid = $(this).data("authid");

        $.get("/cgi-bin/koha/authorities/detail.pl", { authid : authid }, function( data ){
            var auth_detail = $(data).find("#authoritiestabs");
            auth_detail.find("ul").remove();
            auth_detail.removeClass("toptabs");
            auth_detail.find("> div").removeClass("tab-content");
            auth_detail.find("> div > div").removeClass("tab-pane").removeAttr("role");
            $("#authorityDetail .modal-title").html(__("Authority") + " " + authid );
            $("#authorityDetail .modal-body").html( auth_detail );
        });

        $("#authorityDetail").modal("show");
    });
    $("#authorityDetail").on("hidden.bs.modal", function(){
        $("#authorityDetail .modal-body, #authorityDetail .modal-title").html("");
        $("#authorityDetail .modal-body").html("<img src=\"" + template_path + "/img/spinner-small.gif\" alt=\"\" />");
    });
});
