var ssn_url = $("input[name=ssn_url]").val();

if (ssn_url.match(/^http/)) {
$("input[id=ssn_submit]").click(function( event ) { 

    event.preventDefault();

    //var ssn_username = $(".loggedinusername").html().trim();
    var ssn_username = $("input[name=ssn_username]").val();
    var ssn_password = $("input[name=ssn_password]").val();
    var ssn_value = $("input[name=ssn_ssn]").val();

    $.ajax({
        type: "POST",
        url: ssn_url,
        dataType: 'json',
        data: { ssn: ssn_value, username: ssn_username, password: ssn_password }
    })  
    .done(function( msg ) { 

        var ssnkey_container = $("input[value=SSN]").siblings("textarea");
        var notification_container = $("#ssn_notifier");

        //Make sure the SSN-key is removed if a failed attempt is made after a value is fetched
        $(ssnkey_container).val( '' );

        if (msg.msg) {

            $(notification_container).html(msg.msg).addClass('dialog alert');
        }   
    //We don't want to enable ssnvalue lookups here
    //    if (msg.ssnvalue) {
    //  
    //    }
        if (msg.ssnkey) {

            $(notification_container).html(
                $(notification_container).html() + "<br/>Avain "+msg.ssnkey+" löytyi")
                .addClass('dialog alert');
            if (msg.msg == "Sotu lisätty") {
                $(notification_container).css({
                        'background':  'linear-gradient(to bottom, #d7e5d7, #bcdbbc)',
                }); 
            }   
            else {
                $(notification_container).css("background", "");
            }   


            $(ssnkey_container).val( msg.ssnkey );
        }   
    })  
    .fail(function(msg) {
        alert("Joku ihmeen tietoliikennehärö tapahtui! " +msg);
    }); 
});
}
