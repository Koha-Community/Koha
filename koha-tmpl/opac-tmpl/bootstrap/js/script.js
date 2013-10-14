enquire.register("screen and (max-width:608px)", {
    match : function() {
        $("#masthead_search").insertAfter("#select_library");
        $(".sort_by").removeClass("pull-right");
        if($("body.scrollto").length > 0){
            $("body.scrollto").animate({
                scrollTop: $(".maincontent").offset().top
            }, 10);
        }
    },
    unmatch : function() {
        $(".sort_by").addClass("pull-right");
    }
});

enquire.register("screen and (min-width:768px)", {
    match : function() {
        $(".menu-collapse").show();
    },
    unmatch : function() {
        $(".menu-collapse").hide();
    }
});

$(document).ready(function(){
    $(".close").click(function(){
        window.close();
    });
    $(".focus").focus();

    // clear the basket when user logs out
    $("#logout").click(function(){
        var nameCookie = "bib_list";
        var valCookie = readCookie(nameCookie);
        if (valCookie) { // basket has contents
            updateBasket(0,null);
            delCookie(nameCookie);
            return true;
        } else {
            return true;
        }
    });
    $("#user-menu-trigger").on("click",function(){
        var mem = $("#members");
        if(mem.is(":hidden")){
            mem.show();
        } else {
            mem.removeAttr("style");
        }
    });
    $(".menu-collapse-toggle").on("click",function(e){
        e.preventDefault();
        $(this).toggleClass("menu-open");
        $(".menu-collapse").toggle();
    });
    $(".loginModal-trigger").on("click",function(e){
        e.preventDefault();
        $("#loginModal").modal("show");
        $("#members").removeAttr("style");
    });
    $("#loginModal").on("hide",function(){
        if($("#user-menu-trigger").is(":hidden")){
            $("#members").removeAttr("style");
        }
    });
});