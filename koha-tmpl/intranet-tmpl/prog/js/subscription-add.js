/* global __ irregularity more_than_one_serial subscriptionid tags interface theme mana_enabled MSG_FREQUENCY_LENGTH_ERROR MSG_BIBLIO_NOT_EXIST */

var globalnumpatterndata;
var globalfreqdata;
var mananumpatterndata;
var manafreqdata;
var manaid;
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
            alert( __("Frequency and subscription length provided doesn't combine well. Please consider entering an issue count rather than a time period.") );
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
    var bookseller_id = $("#aqbooksellerid").val();
    if ( bookseller_id.length == 0) {
        input_box = confirm( __("If you wish to claim late or missing issues you must link this subscription to a vendor. Click OK to ignore or Cancel to return and enter a vendor") );
        if (input_box==false) {
            return false;
        }
    } else {
        var bookseller_ids = BOOKSELLER_IDS;
        if ( $.inArray(Number(bookseller_id), bookseller_ids) == -1 ) {
            alert ( __("The vendor does not exist") );
            return false;
        }
    }

    var biblionumber = $("#biblionumber").val()
    if ( biblionumber.length == 0 ) {
        alert( __("You must choose or create a bibliographic record") );
        return false;
    }

    var bib_exists = $("input[name='title']").val().length;

    if (!bib_exists){
        alert( __("Bibliographic record does not exist!") );
        return false;
    }

    if( isNaN( $("#staffdisplaycount").val() ) ){
        alert( __("Number of issues to display to staff must be a number") );
        return false;
    }
    if( isNaN( $("#opacdisplaycount").val() ) ){
        alert( __("Number of issues to display to the public must be a number") );
        return false;
    } else {
        return true;
    }
}

function Check_page2(){
    if( more_than_one_serial == "" ){
        if($("#acqui_date").val().length == 0){
            alert( __("You must choose a first publication date") );
            return false;
        }
    }
    if($("#sublength").val().length == 0 && $("input[name='enddate']").val().length == 0){
        alert( __("You must choose a subscription length or an end date.") );
        return false;
    }
    if(advancedpatternlocked == 0){
        alert( __("You have modified the advanced prediction pattern. Please save your work or cancel modifications.") );
        return false;
    }
    if(patternneedtobetested){
        if( irregularity !== "" ){
            alert( __("Warning! Present pattern has planned irregularities. Click on 'Test prediction pattern' to check if it's still valid") );
        } else {
            alert( __("Please click on 'Test prediction pattern' before saving subscription.") );
        }
        return false;
    }

    return true;
}

function frequencyload(){
    if ($("#frequency option:selected").val() === "mana"){
        globalfreqdata=manafreqdata;
        $("input[name='sfdescription']").val(manafreqdata.description);
        $("input[name='unit']").val(manafreqdata.unit);
        $("input[name='unitsperissue']").val(manafreqdata.unitsperissue);
        $("input[name='issuesperunit']").val(manafreqdata.issuesperunit);
        if ($( "#numberpattern option:selected" ).val() === "mana" ) {
            $("#mana_id").val(manaid);
        }
    } else {
        $.getJSON("subscription-frequency.pl",{"frequency_id":document.f.frequency.value,ajax:'true'},
            function(freqdata){
                globalfreqdata=freqdata;
                if ( globalfreqdata.unit && globalfreqdata.unit.length == 0 ) {
                    var option = $("#subtype option[value='issues']");
                    $(option).attr('selected', 'selected');
                    $("#subtype option[value!='issues']").prop('disabled', true);
                } else {
                    $("#subtype option").prop('disabled', false);
                }
            }
        );
        $("#mana_id").val("");
    }
}

function numberpatternload(){
    if($("#numberpattern option:selected" ).val() === "mana"){
        globalnumpatterndata=mananumpatterndata;
        $("input[name='sndescription']").val(mananumpatterndata.description);
        if($("#frequency option:selected" ).val() === "mana"){
            $("#mana_id").val(manaid);
        }
        if (globalnumpatterndata==undefined){
            return false;
        }
        displaymoreoptions();
        restoreAdvancedPattern();
    } else {
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
        $("#mana_id").val("");
    }
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
    $("#patternname").prop('readOnly', false).val('').focus();
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
        error_msg += "- " + __("Frequency is not defined") + "\n";
        error ++;
    }
    acquidate = $("#acqui_date").val();
    if(acquidate == undefined || acquidate == ""){
        error_msg += "-" + __("First publication date is not defined") + "\n";
        error ++;
    }
    if( more_than_one_serial !== "" ){
        var nextacquidate = $("#nextacquidate").val();
        if(nextacquidate == undefined || nextacquidate == ""){
            error_msg += "-" + __("Next issue publication date is not defined") + "\n";
            error ++;
        }
    }

    if(error){
        alert( __("Cannot test prediction pattern for the following reason(s): %s").format(error_msg) );
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
        'whenmorethan1', 'whenmorethan2', 'whenmorethan3', 'locale',
        'sfdescription', 'unitsperissue', 'issuesperunit', 'unit'
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
            showPredictionPatternTest( data );
            patternneedtobetested = 0;
        }
    });
}

function saveAdvancedPattern() {
    if ($("#patternname").val().length == 0) {
        alert( __("Please enter a name for this pattern") );
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
        var msg = __("This pattern name already exists. Do you want to modify it?")
            +"\n" + __("Warning: This will modify the pattern for all subscriptions that are using it.");
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
                    alert( __("Something went wrong. Unable to create a new numbering pattern.") );
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

function mana_search() {
    $("#mana_search").html("<p>" + __("Searching for subscription in Mana Knowledge Base") + "... <img src='" + interface + "/" + theme + "/img/spinner-small.gif' /></p>");
    $("#mana_search").show();

    $.ajax({
        type: "POST",
        url: "/cgi-bin/koha/svc/mana/search",
        data: {id: $("#biblionumber").val(), resource: 'subscription', usecomments: 1},
        dataType: "html",
    })
        .done( function( result ) {
            $("#mana_search_result .modal-body").html(result);
            $("#mana_search_result_label").text( __("Results from Mana Knowledge Base") );
            $("#mana_results_datatable").dataTable($.extend(true, {}, dataTablesDefaults, {
                "sPaginationType": "full",
                "order":[[4, "desc"], [5, "desc"]],
                "autoWidth": false,
                "columnDefs": [
                    { "width": "35%", "targets": 1 }
                ],
                "aoColumnDefs": [
                    { 'bSortable': false, "bSearchable": false, 'aTargets': [ 'NoSort' ] },
                    { 'sType': "anti-the", 'aTargets' : [ 'anti-the'] }
                ]
            }));
            if( $("#mana_results_datatable").length && $("td.dataTables_empty").length == 0){
                $("#mana_search").html("<p>" + __("Subscription found on Mana Knowledge Base:") + "</p><p> <a href=\"#\" data-toggle=\"modal\" data-target=\"#mana_search_result\"><i class=\"fa-solid fa-window-maximize\"></i> " + __("Show Mana results") + "</a></p>");
            }
            else if ( $("#mana_results_datatable").length ){
                $("#mana_search").html("<p>" + __("No subscription found on Mana Knowledge Base") + "</p><p>" + __("Please feel free to share your pattern with all others librarians once you are done") + "</p>");
            }
            else{
                $("#mana_search").html( result );
            }
            $("#mana_search").show();
        });
}

function mana_use(mana_id){
    $("tr").removeClass("selected");
    $("#row"+mana_id).addClass("selected");
    $.ajax( {
        type: "POST",
        url: "/cgi-bin/koha/svc/mana/use",
        data: {id: mana_id, resource: 'subscription'},
        dataType: "json",
    })
        .done(function(result){
            var select = document.getElementById('numberpattern');
            for(i = 0; i < select.length; i++){
                if(select[i].value === "mana"){
                    select.remove(i);
                }
            }
            var optionnumpattern = document.createElement("option");
            optionnumpattern.text = result.label + " (mana)";
            optionnumpattern.selected = true;
            optionnumpattern.value="mana";
            select.add(optionnumpattern);

            mananumpatterndata = {
                id:"mana",
                add1:result.add1,
                add2:result.add2,
                add3:result.add3,
                description:result.sndescription,
                displayorder:result.displayorder,
                every1:result.every1,
                every2:result.every2,
                every3:result.every3,
                label:result.label,
                label1:result.label1,
                label2:result.label2,
                label3:result.label3,
                numbering1:result.numbering1,
                numbering2:result.numbering2,
                numbering3:result.numbering3,
                numberingmethod:result.numberingmethod,
                setto1:result.setto1,
                setto2:result.setto2,
                setto3:result.setto3,
                whenmorethan1:result.whenmorethan1,
                whenmorethan2:result.whenmorethan2,
                whenmorethan3:result.whenmorethan3,
            };
            select = document.getElementById("frequency");
            for(i = 0; i < select.length; i++){
                if(select[i].value === "mana"){
                    select.remove(i);
                }
            }
            var optionfreq = document.createElement("option");
            optionfreq.text = result.sfdescription + " (mana)";
            optionfreq.selected = true;
            optionfreq.value="mana";
            select.add(optionfreq);
            manafreqdata = {
                id:"mana",
                description:result.sfdescription,
                displayorder:result.displayorder,
                issuesperunit:result.issuesperunit,
                unit:result.unit,
                unitsperissue:result.unitsperissue,
            };
            manaid = result.id;
            $("#mana_id").val(manaid);
            $("#mana_search_result").modal("hide");
            frequencyload();
            numberpatternload();
        })
        .done( function(){
            $("tr").removeClass("selected");
            $(".mana-use i").attr("class","fa fa-download");
        })
        .fail( function( result ){
        });
}

function mana_comment_close(){
    $("#selected_id").val("");
    $("#mana-resource-id").val("");
    $("#mana-comment").val("");
    $("#mana_results").show();
    $("#new_mana_comment").hide();
}

function showPredictionPatternTest( data ){
    $("#displayexample").html(data).show();
    $("#page_2 > div").attr("class","col-xs-6");
}

function hidePredcitionPatternTest(){
    $("#displayexample").hide();
    $("#page_2 > div").attr("class","col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2");
}

$(document).ready(function() {
    if ( mana_enabled == 1 ) {
        mana_search();
    }
    $("#displayexample").hide();

    // When Mana search results modal is hidden, hide comment form and any status messages
    $("#mana_search_result").on("hide.bs.modal", function(){
        $("#mana_results").show();
        $("#new_mana_comment").hide();
        $(".mana_comment_status").hide();
    });

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

    $("#mana_search").hide();

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
            if ( mana_enabled == 1 ) {
                mana_search();
            }
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
    $('#save-subscription').on("click", function(e){
        $('select:disabled').removeAttr('disabled');
    });

    $("body").on("click", ".mana-use", function(e) {
        e.preventDefault();
        $(this).find("i").attr("class","fa-solid fa-rotate fa-spin");
        var subscription_id = $(this).data("subscription_id");
        mana_use( subscription_id );
    });

    $("#displayexample").on("click", "#hidepredictionpattern", function(e){
        e.preventDefault();
        hidePredcitionPatternTest();
    });

    $("#biblionumber").on("change", function(){
        var biblionumber = $(this).val();
        $.ajax({
            url: "/api/v1/biblios/" + biblionumber,
            type: "GET",
            headers: {
              Accept: "application/json",
            },
            contentType: "application/json",
            success: function (biblio) {
                $("input[name='title']").val(biblio['title']);
                $("#error_bib_not_exist").html("");
            },
            error: function (x) {
                $("input[name='title']").val('');
                $("#error_bib_not_exist").html( __("This bibliographic record does not exist") );
            }
        });
    });

    $("input[name='serialsadditems']").on("change", function(){
        const display = $(this).val() == "1" ? "flex" : "none";
        $(".use_items").css('display', display).find("select").val("")
    });

});
