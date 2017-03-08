$(document).ready(function(){
    $("#activatemana").on("click", function(){
        var mylastname = $("#lastname").val()
        var myfirstname = $("#firstname").val()
        var myemail = $("#email").val()
        $.ajax( {
            type: "POST",
            url: "/cgi-bin/koha/svc/mana/token",
            data: { lastname: mylastname, firstname: myfirstname, email: myemail},
            dataType: "json",
        })
        .done(function(result){
            $("#pref_ManaToken").val(result.token);
            $("#pref_ManaToken").trigger("input");
        });
        return false;
    });
});
