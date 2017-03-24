<label for="offices">Select office:</label>
<div id="offices"></div>
<input type="hidden" name="Office" id="office" />
<span id="add_new_office"><a>Add new office</a></span>
<div id="office_form" style="display:none">
    <label for="office_new">Office:</label><input type="text" name="office_new" id="office_new" />
    <button id="new_office" type="button">Add new office</button>
    <p>Offices are stored as a browser cookie. Currently stored offices will disappear and need to be added again if you clear the browser cookies.</p>
    <p>You can delete a stored office by first selecting it, and then pressing the delete-key on your keyboard.</p>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        $("#add_new_office").click(function() {
            if ($("#office_form").css("display") == "none") {
                $("#office_form").css("display", "block");
            } else {
                $("#office_form").css("display", "none");
            }
        });
        loadCashRegisters();
        $("#new_office").click(function() {
            if ($("#office_new").val().length > 0) {
                newOffice($("#office_new").val());
            }
        });

        $("#office").bind("enterKey",function(e) {
            if ($("#office_new").val().length > 0) {
                newOffice($("#office_new").val());
            }
        });
        $("#office_new").keyup(function(e) {
            if(e.keyCode == 13) {
                $(this).trigger("enterKey");
            }
        });

        $("body").on("click", "button[id*=office-]", function() {
            selectOffice(this);
        });
        $("body").on("keyup", "button[id*=office-]", function(e) {
            if(e.keyCode == 46) {
                deleteOffice(this);
            }
        });
    });
    function selectOffice(button) {
        // Deselect all other buttons
        $.each($("button[id*=office-]"), function(key, obj) {
            $(obj).attr("class", "office-button");
        })
        $(button).attr("class", "office-button selected");

        $("#office").val($(button).attr("id").substr(7));
    }
    function newOffice(office) {
        var offices = getOffices();

        if (offices == null) {
            offices = [];
        }
        if (offices.indexOf(office) > -1) {
            return offices;
        }
        offices.push(office);

        $.each(offices, function(key, val){
            if (!$("#office-"+val).length) {
                $("#offices").append('<button id="office-'+val+'" type="button" class="office-button">'+val+'</button>');
            }
        });

        setCookie("offices", JSON.stringify(offices), "100*365");

        $("#office_new").val("");
        return offices;
    }
    function deleteOffice(obj) {
        var offices = getOffices();

        if (offices == null) {
            return null;
        }

        $(obj).remove();

        var index = offices.indexOf($(obj).attr("id").substr(7));

        offices.splice(index, 1);

        if ($("#office").val() == $(obj).attr("id").substr(7)) {
            $("#office").val("");
        }
        setCookie("offices", JSON.stringify(offices), "100*365");

        return offices;
    }
    function loadCashRegisters() {
        var offices = getOffices();

        if (offices == null) {
            return null;
        }
        $.each(offices, function(key, val){
            if (!$("#office-"+val).length) {
                $("#offices").append('<button id="office-'+val+'" type="button" class="office-button">'+val+'</button>');
            }
        });
    }
    function getOffices() {
        var cookie;
        var name = "offices=";
        var ca = document.cookie.split(';');
        for(var i=0; i<ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1);
            if (c.indexOf(name) == 0) cookie = c.substring(name.length,c.length);
        }

        if (!cookie) {
            return null;
        }

        return JSON.parse(cookie);
    }

    function setCookie(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays*24*60*60*1000));
        var expires = "expires="+d.toUTCString();
        document.cookie = cname + "=" + cvalue + "; " + expires;
    }

    function validatePayment(obj) {
        if ($("#office").val().length == 0) {
            alert(_("Please select office"));
            return false;
        }
        $(obj)[0].submit();
    }
</script>
