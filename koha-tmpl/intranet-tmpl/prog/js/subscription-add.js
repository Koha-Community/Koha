/* global irregularity more_than_one_serial subscriptionid tags */

var globalnumpatterndata;
var globalfreqdata;
var advancedpatternlocked;
var patternneedtobetested = 0;
if ( irregularity !== "" ){
    patternneedtobetested = 1;
}

function check_issues(){
    if (globalfreqdata.unit.length >0) {
        if (document.f.subtype.value == globalfreqdata.unit){
            document.f.issuelengthcount.value=(document.f.sublength.value*globalfreqdata.issuesperunit)/globalfreqdata.unitsperissue;
        } else if (document.f.subtype.value != "issues"){
            alert( MSG_FREQUENCY_LENGTH_ERROR );
        }
    }
}

function addbiblioPopup(biblionumber) {
    var destination = "/cgi-bin/koha/cataloguing/addbiblio.pl?mode=popup";
    if(biblionumber){
        destination += "&biblionumber="+biblionumber;
    }
    window.open(destination,'AddBiblioPopup','width=1024,height=768,toolbar=no,scrollbars=yes');
}

function Plugin(){
    window.open('subscription-bib-search.pl','FindABibIndex','width=800,height=400,toolbar=no,scrollbars=yes');
}

function FindAcqui(){
    window.open('acqui-search.pl','FindASupplier','width=800,height=400,toolbar=no,scrollbars=yes');
}

function Find_ISSN(f){
    window.open('issn-search.pl','FindABibIndex','width=800,height=400,toolbar=no,scrollbars=yes');
}

function Clear(id) {
    $("#"+id).val('');
}

function Check_page1() {
    if ( $("#aqbooksellerid").val().length == 0) {
        input_box = confirm(_("If you wish to claim late or missing issues you must link this subscription to a vendor. Click OK to ignore or Cancel to return and enter a vendor"));
        if (input_box==false) {
            return false;
        }
    }
    if ($("#biblionumber").val().length == 0) {
        alert(_("You must choose or create a biblio"));
        return false;
    }

    return true;
}

function Check_page2(){
    if( more_than_one_serial == "" ){
        if($("#acqui_date").val().length == 0){
            alert(_("You must choose a first publication date"));
            return false;
        }
    }
    if($("#sublength").val().length == 0 && $("input[name='enddate']").val().length == 0){
        alert(_("You must choose a subscription length or an end date."));
        return false;
    }
    if(advancedpatternlocked == 0){
        alert(_("You have modified the advanced prediction pattern. Please save your work or cancel modifications."));
        return false;
    }
    if(patternneedtobetested){
        if( irregularity !== "" ){
           alert(_("Warning! Present pattern has planned irregularities. Click on 'Test prediction pattern' to check if it's still valid"));
        } else {
            alert(_("Please click on 'Test prediction pattern' before saving subscription."));
        }
        return false;
    }

    return true;
}

function frequencyload(){
    $.getJSON("subscription-frequency.pl",{"frequency_id":document.f.frequency.value,ajax:'true'},
        function(freqdata){
            globalfreqdata=freqdata;
            if ( globalfreqdata.unit && globalfreqdata.unit.length == 0 ) {
                var option = $("#subtype option[value='issues']");
                $(option).attr('selected', 'selected');
                $("#subtype option[value!='issues']").prop('disabled', true)
            } else {
                $("#subtype option").prop('disabled', false)
            }
        }
    )
}

function numberpatternload(){
    $.getJSON("subscription-numberpattern.pl",{"numberpattern_id":document.f.numbering_pattern.value,ajax:'true'},
        function(numpatterndata){
            globalnumpatterndata=numpatterndata;
            if (globalnumpatterndata==undefined){
                return false;
            }
            displaymoreoptions();
            restoreAdvancedPattern();
        }
    );
}

function displaymoreoptions() {
    if(globalnumpatterndata == undefined){
        $("#moreoptionst").hide();
        return false;
    }

    var X = 0, Y = 0, Z = 0;
    var numberingmethod = globalnumpatterndata.numberingmethod;
    if(numberingmethod.match(/{X}/)) X = 1;
    if(numberingmethod.match(/{Y}/)) Y = 1;
    if(numberingmethod.match(/{Z}/)) Z = 1;

    if(X || Y || Z) {
        $("#moreoptionst").show();
    } else {
        $("#moreoptionst").hide();
    }

    if(X) {
        if(globalnumpatterndata.label1) {
            $("#headerX").html(globalnumpatterndata.label1);
        } else {
            $("#headerX").html("X");
        }
        $("#headerX").show();
        $("#beginsX").show();
        $("#innerX").show();
    } else {
        $("#headerX").hide();
        $("#beginsX").hide();
        $("#innerX").hide();
        $("#lastvaluetemp1").val('');
        $("#innerlooptemp1").val('');
    }
    if(Y) {
        if(globalnumpatterndata.label2) {
            $("#headerY").html(globalnumpatterndata.label2);
        } else {
            $("#headerY").html("Y");
        }
        $("#headerY").show();
        $("#beginsY").show();
        $("#innerY").show();
    } else {
        $("#headerY").hide();
        $("#beginsY").hide();
        $("#innerY").hide();
        $("#lastvaluetemp2").val('');
        $("#innerlooptemp2").val('');
    }
    if(Z) {
        if(globalnumpatterndata.label3) {
            $("#headerZ").html(globalnumpatterndata.label3);
        } else {
            $("#headerZ").html("Z");
        }
        $("#headerZ").show();
        $("#beginsZ").show();
        $("#innerZ").show();
    } else {
        $("#headerZ").hide();
        $("#beginsZ").hide();
        $("#innerZ").hide();
        $("#lastvaluetemp3").val('');
        $("#innerlooptemp3").val('');
    }
}

function modifyAdvancedPattern() {
    $("#patternname").prop('readOnly', false).val('');
    $("#numberingmethod").prop('readOnly', false);

    $("#advancedpredictionpatternt input").each(function() {
        $(this).prop('readOnly', false);
    });
    $("#advancedpredictionpatternt select").each(function() {
        $(this).prop('disabled', false);
    });

    $("#restoreadvancedpatternbutton").show();
    $("#saveadvancedpatternbutton").show();
    $("#modifyadvancedpatternbutton").hide();

    advancedpatternlocked = 0;
}

function restoreAdvancedPattern() {
    $("#patternname").prop('readOnly', true).val(globalnumpatterndata.label);
    $("#numberingmethod").prop('readOnly', true).val(globalnumpatterndata.numberingmethod);

    $("#advancedpredictionpatternt input").each(function() {
        $(this).prop('readOnly', true);
        var id = $(this).attr('id');
        if(id.match(/lastvalue/) || id.match(/innerloop/)) {
            var tempid = id.replace(/(\d)/, "temp$1");
            $(this).val($("#"+tempid).val());
        } else {
            $(this).val(globalnumpatterndata[id]);
        }
    });
    $("#advancedpredictionpatternt select").each(function() {
        $(this).prop('disabled', true);
        var id = $(this).attr('id');
        $(this).val(globalnumpatterndata[id]);
    });

    $("#restoreadvancedpatternbutton").hide();
    $("#saveadvancedpatternbutton").hide();
    $("#modifyadvancedpatternbutton").show();

    advancedpatternlocked = 1;
}

function testPredictionPattern() {
    var frequencyid = $("#frequency").val();
    var acquidate;
    var error = 0;
    var error_msg = "";
    if(frequencyid == undefined || frequencyid == ""){
        error_msg += _("- Frequency is not defined") + "\n";
        error ++;
    }
    acquidate = $("#acqui_date").val();
    if(acquidate == undefined || acquidate == ""){
        error_msg += _("- First publication date is not defined") + "\n";
        error ++;
    }
    if( more_than_one_serial !== "" ){
        var nextacquidate = $("#nextacquidate").val();
        if(nextacquidate == undefined || nextacquidate == ""){
            error_msg += _("- Next issue publication date is not defined") + "\n";
            error ++;
        }
    }

    if(error){
        alert(_("Cannot test prediction pattern for the following reason(s): %s").format(error_msg));
        return false;
    }

    var custompattern = 0;
    if(advancedpatternlocked == 0) {
        custompattern = 1;
    }

    var ajaxData = {
        'custompattern': custompattern,
        'firstacquidate': acquidate
    };

    if( subscriptionid !== "" ){
        ajaxData.subscriptionid = subscriptionid;
    }
    if( more_than_one_serial !== "" ){
        ajaxData.nextacquidate = nextacquidate;
    }


    var ajaxParams = [
        'to', 'subtype', 'sublength', 'frequency', 'numberingmethod',
        'lastvalue1', 'lastvalue2', 'lastvalue3', 'add1', 'add2', 'add3',
        'every1', 'every2', 'every3', 'innerloop1', 'innerloop2', 'innerloop3',
        'setto1', 'setto2', 'setto3', 'numbering1', 'numbering2', 'numbering3',
        'whenmorethan1', 'whenmorethan2', 'whenmorethan3', 'locale'
    ];
    for(i in ajaxParams) {
        var param = ajaxParams[i];
        var value = $("#"+param).val();
        if(value.length > 0)
            ajaxData[param] = value;
    }

    $.ajax({
        url:"/cgi-bin/koha/serials/showpredictionpattern.pl",
        data: ajaxData,
        success: function(data) {
            $("#displayexample").html(data);
            patternneedtobetested = 0;
        }
    });
}

function saveAdvancedPattern() {
    if ($("#patternname").val().length == 0) {
        alert(_("Please enter a name for this pattern"));
        return false;
    }

    // Check if patternname already exists, and modify pattern
    // instead of creating it if so
    var found = 0;
    $("#numberpattern option").each(function(){
        if($(this).text() == $("#patternname").val()){
            found = 1;
            return false;
        }
    });
    var cnfrm = 1;
    if(found){
        var msg = _("This pattern name already exists. Do you want to modify it?")
            + "\n" + _("Warning: it will modify the pattern for all subscriptions that are using it.");
        cnfrm = confirm(msg);
    }

    if(cnfrm) {
        var ajaxData = {};
        var ajaxParams = [
            'patternname', 'numberingmethod', 'label1', 'label2', 'label3',
            'add1', 'add2', 'add3', 'every1', 'every2', 'every3',
            'setto1', 'setto2', 'setto3', 'numbering1', 'numbering2', 'numbering3',
            'whenmorethan1', 'whenmorethan2', 'whenmorethan3', 'locale'
        ];
        for(i in ajaxParams) {
            var param = ajaxParams[i];
            var value = $("#"+param).val();
            if(value.length > 0)
                ajaxData[param] = value;
        }

        $.getJSON(
            "/cgi-bin/koha/serials/create-numberpattern.pl",
            ajaxData,
            function(data){
                if (data.numberpatternid) {
                    if(found == 0){
                        $("#numberpattern").append("<option value=\""+data.numberpatternid+"\">"+$("#patternname").val()+"</option>");
                    }
                    $("#numberpattern").val(data.numberpatternid);
                    numberpatternload();
                } else {
                    alert(_("Something went wrong. Unable to create a new numbering pattern."));
                }
            }
        );
    }
}

function show_page_1() {
    $("#page_1").show();
    $("#page_2").hide();
    $("#page_number").text("1/2");
}

function show_page_2() {
    $("#page_1").hide();
    $("#page_2").show();
    $("#page_number").text("2/2");
    displaymoreoptions();
}


$(document).ready(function() {
    $("#aqbooksellerid").on('keypress', function(e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            FindAcqui();
        }
    });
    $("#biblionumber").on('keypress', function(e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            Plugin();
        }
    });
    $("select#frequency").change(function(){
        patternneedtobetested = 1;
        $("input[name='enddate']").val('');
        frequencyload();
    });
    $("select#numberpattern").change(function(){
        patternneedtobetested = 1;
        numberpatternload();
    });
    $("#subtype").change(function(){
        $("input[name='enddate']").val('');
    });
    $("#sublength").change(function(){
        $("input[name='enddate']").val('');
    });
    $("#lastvaluetemp1").keyup(function(){
        $("#lastvalue1").val($(this).val());
    });
    $("#lastvaluetemp2").keyup(function(){
        $("#lastvalue2").val($(this).val());
    });
    $("#lastvaluetemp3").keyup(function(){
        $("#lastvalue3").val($(this).val());
    });
    $("#lastvalue1").keyup(function(){
        $("#lastvaluetemp1").val($(this).val());
    });
    $("#lastvalue2").keyup(function(){
        $("#lastvaluetemp2").val($(this).val());
    });
    $("#lastvalue3").keyup(function(){
        $("#lastvaluetemp3").val($(this).val());
    });

    $("#innerlooptemp1").keyup(function(){
        $("#innerloop1").val($(this).val());
    });
    $("#innerlooptemp2").keyup(function(){
        $("#innerloop2").val($(this).val());
    });
    $("#innerlooptemp3").keyup(function(){
        $("#innerloop3").val($(this).val());
    });
    $("#innerloop1").keyup(function(){
        $("#innerlooptemp1").val($(this).val());
    });
    $("#innerloop2").keyup(function(){
        $("#innerlooptemp2").val($(this).val());
    });
    $("#innerloop3").keyup(function(){
        $("#innerlooptemp3").val($(this).val());
    });

    if($("#frequency").val() != ""){
        frequencyload();
    }
    if($("#numberpattern").val() != ""){
        numberpatternload();
    }

    if( tags.length > 0 ){
        tags.forEach( function( item ) {
            var node = $("[name='" + item + "']");
            if ( $(node).is('input') || $(node).is('textarea') ) {
                $(node).val("");
            } else if ( $(node).is('select') ) {
                $(node).find("option:first").attr('selected','selected');
            }
        });
    }

    show_page_1();
    $("#subscription_add_form").on("submit",function(){
        return Check_page2();
    });
    $("#vendor_search").on("click",function(e){
        e.preventDefault();
        FindAcqui();
    });
    $("#record_search").on("click",function(e){
        e.preventDefault();
        Plugin();
    });
    $("#biblio_add_edit").on("click",function(e){
        e.preventDefault();
        if( $(this).data("biblionumber") ){
            addbiblioPopup( $(this).data("biblionumber") );
        } else {
            addbiblioPopup();
        }
    });
    $("#subscription_add_next").on("click",function(){
        if ( Check_page1() ){
            show_page_2();
        }
    });
    $("#subscription_add_previous").on("click",function(){
        show_page_1();
    });
    $(".toggle_advanced_pattern").on("click",function(e){
        e.preventDefault();
        $("#advancedpredictionpattern").toggle();
        $(".toggle_advanced_pattern").toggle();
    });
    $("#modifyadvancedpatternbutton").on("click",function(e){
        e.preventDefault();
        modifyAdvancedPattern();
    });
    $("#restoreadvancedpatternbutton").on("click",function(e){
        e.preventDefault();
        restoreAdvancedPattern();
    });
    $("#saveadvancedpatternbutton").on("click",function(e){
        e.preventDefault();
        saveAdvancedPattern();
    });
    $("#testpatternbutton").on("click",function(e){
        e.preventDefault();
        testPredictionPattern();
    });
});