////Create javascript namespace
var FloMax = FloMax || {};
FloMax.Tester = FloMax.Tester || {};

//// DOCUMENT READY INIT SCRIPTS

FloMax.branchRules = {}; //Stores all the edited branchRules so we can rollback HTML changes and CRUD over AJAX.

FloMax.branchRuleDisabledColor = "#e83519";
FloMax.branchRuleAlwaysColor = "#219e0e";
FloMax.branchRulePossibleColor = "#2626bf";
FloMax.branchRuleConditionalColor = "#af21bc";
$(document).ready(function() {
    //Color cells based on their floatingType
    $(".branchRule").each(function(){
        FloMax.changeBranchRuleColor(this);
    });

    //Bind actions to the FloMax Tester
    $("#floatingRuleTester input[type='submit']").bind({
        click: function() {
            FloMax.Tester.testFloating();
        }
    });

    //Bind action listeners to the floating matrix
    $(".branchRule").bind({
        click: function() {
            //If we are clicking a branchCode element, mark it as selected and remove other selections.
            if (! $(this).hasClass('selected')) {
                $(".branchRule").removeClass('selected');
                $("input[name='conditionRules']").addClass('hidden');

                $(this).addClass('selected');
                FloMax.changeBranchRuleColor(this);
                $(this).find("input[name='conditionRules']").removeClass('hidden');
            }
        },
    });
    $(".branchRule input[name='cancel']").bind({
        click: function(event) {
            FloMax.replaceBranchRule( $(this).parents(".branchRule") );
            $(this).parents(".branchRule").removeClass('selected');
            $("input[name='conditionRules']").addClass('hidden');
            event.stopPropagation();
        },
    });
    $(".branchRule input[name='submit']").bind({
        click: function(event) {
            FloMax.storeBranchRule( $(this).parents(".branchRule") );
            $(this).parents(".branchRule").removeClass('selected');
            $("input[name='conditionRules']").addClass('hidden');
            event.stopPropagation();
        },
    });
    $(".branchRule select").bind({
        change: function() {
            //When the floatingType changes, so does the color
            var branchRule = $(this).parents(".branchRule");
            FloMax.changeBranchRuleColor(branchRule);
        },
    });
});
////EOF DOCUMENT READY INIT SCRIPTS

FloMax.changeBranchRuleColor = function (branchRule) {
    var floatingType = $(branchRule).find("select[name='floating']").val();
    var color = "#000000";
    if (floatingType == 'DISABLED') {
        color = FloMax.branchRuleDisabledColor;
    }
    else if (floatingType == 'ALWAYS') {
        color = FloMax.branchRuleAlwaysColor;
    }
    else if (floatingType == 'POSSIBLE') {
        color = FloMax.branchRulePossibleColor;
    }
    else if (floatingType == 'CONDITIONAL') {
        color = FloMax.branchRuleConditionalColor;
    }
    $(branchRule).css('color', color);
    $(branchRule).css('background-color', color);
}

FloMax.displayConditionRulesInput = function (branchRule) {
    var conditionRulesInput = $(branchRule).find("input[name='conditionRules']");
    conditionRulesInput.removeClass('hidden');
}

FloMax.buildBranchRuleFromHTML = function (branchRule) {
    //Get fromBranch by looking at the first column at this row.
    var siblingCells = $(branchRule).parent().prevAll();
    var fromBranch = $(siblingCells).eq(  ($(siblingCells).size())-1  ); //Get the first cell in this row.
    fromBranch = $(fromBranch).html();
    //Get toBranch by looking at the first row of the current column.
    var nthColumn = ($(siblingCells).size()); //Get x-position from all siblings + the column header, into this branchRule
    var toBranch = $("#floatingMatrix").find("#fmHeaderRow").children("th").eq( nthColumn ).html();
    //Get floating
    var floating = $(branchRule).find("select").val();
    //Get conditionRules
    var conditionRules = $(branchRule).find("input[name='conditionRules']").val();
    //Get id
    var id;
    if ($(branchRule).attr('id')) {
        id = $(branchRule).attr('id').substring(3); //Skip characters 'br_'
    }
    var brJSON = {'fromBranch' : fromBranch,
              'toBranch' : toBranch,
              'floating' : floating,
              'conditionRules' : conditionRules,
              'id' : id,
    };
    return brJSON;
}
FloMax.storeBranchRule = function (branchRule) {
    var brJSON = FloMax.buildBranchRuleFromHTML(branchRule);
    FloMax.branchRules[brJSON.fromBranch+'-'+brJSON.toBranch] = brJSON;
    FloMax.persistBranchRule(brJSON, branchRule);
}
FloMax.replaceBranchRule = function (branchRule) {
    var brJSON = FloMax.buildBranchRuleFromHTML(branchRule);
    var oldBrJSON = FloMax.branchRules[brJSON.fromBranch+'-'+brJSON.toBranch];
    var newBranchRule = FloMax.newBranchRuleHTML(oldBrJSON);
    branchRule.replaceWith(newBranchRule);
}
FloMax.resetBranchRule = function (branchRule) {
    branchRule.replaceWith(newBranchRuleHTML());
}
FloMax.newBranchRuleHTML = function (branchRuleJSON) {
    var branchRuleHTML = $("#br_TEMPLATE").clone('withDataAndElements');
    if (branchRuleJSON && branchRuleJSON.id) {
        $(branchRuleHTML).attr('id','br_'+branchRuleJSON.id);
    }
    else {
        $(branchRuleHTML).removeAttr('id');
    }
    if (branchRuleJSON && branchRuleJSON.conditionRules) {
        $(branchRuleHTML).find("input[name='conditionRules']").removeClass('hidden').val(branchRuleJSON.conditionRules);
    }
    else {
        $(branchRuleHTML).find("input[name='conditionRules']").removeClass('hidden').val('');
    }
    if (branchRuleJSON && branchRuleJSON.floating) {
        $(branchRuleHTML).find("select").val(  branchRuleJSON.floating || 'DISABLED'  );
    }
    else {
        $(branchRuleHTML).find("select").val(  'DISABLED'  );
    }
    $(branchRuleHTML).removeClass('TEMPLATE');
    FloMax.changeBranchRuleColor(branchRuleHTML);
    return branchRuleHTML;
}
/**
 *     var brJSON = FloMax.buildBranchRuleFromHTML(branchRule);
 *     FloMax.persistBranchRule(brJSON);
 *
 * INSERTs or UPDATEs or DELETEs the JSON:ified branchRule to the Koha DB
 * @param {object} brJSON - JSON:ified object representation of a branchRule
 *                          from buildBranchRuleFromHTML()
 * @param {object} branchRule - the HTML element matching class ".branchRule".
 *                          Used to target display modifications to it.
 */
FloMax.persistBranchRule = function (brJSON, branchRule) {
    if (brJSON.floating == 'DISABLED') {
        brJSON.delete = 1; //A hack to trick Perl CGI to understand this is a HTTP DELETE-verb.
        $.ajax('floating-matrix-api.pl',
               {method : 'POST', //Should be DELETE but damn CGI
                data : brJSON,
                dataType : 'json',
        }).done(function(data, textStatus, jqXHR){
            FloMax.resetBranchRule(branchRule);
            $(branchRule).removeClass('failedAjax');
            //alert("Saving floating rule "+brJSON.fromBranch+"-"+brJSON.toBranch+" OK, because of the following error:\n"+data.status+" "+data.statusText);
        }).fail(function (data, textStatus, jqXHR) {
            $(branchRule).addClass('failedAjax');
            var error = $.parseJSON(data.responseText); //Pass the error as JSON so we don't trigger the default Koha error pages.
            alert("Deleting floating rule "+brJSON.fromBranch+"-"+brJSON.toBranch+" failed, because of the following error:\n"+data.status+" "+data.statusText+"\n"+"More specific error: "+error.error);
        });
    }
    else {
        $.ajax('floating-matrix-api.pl',
               {method : 'POST',
                data : brJSON,
                dataType : 'json',
        }).done(function(data, textStatus, jqXHR){
            $(branchRule).removeClass('failedAjax');
            $(branchRule).attr('id', 'br_'+data.id);
        }).fail(function (data, textStatus, jqXHR) {
            $(branchRule).addClass('failedAjax');
            var error = $.parseJSON(data.responseText); //Pass the error as JSON so we don't trigger the default Koha error pages.
            alert("Saving floating rule "+brJSON.fromBranch+"-"+brJSON.toBranch+" failed, because of the following error:\n"+data.status+" "+data.statusText+"\n"+"More specific error: "+error.error);
        });
    }
}

FloMax.Tester.defaultTestResultColor = "#B9D8D9";

FloMax.Tester.testFloating = function() {
    var testCase = FloMax.Tester.buildTestCaseFromHTML();
    $(".cssload-loader").css('visibility', 'visible');

    $.ajax('floating-matrix-api.pl',
           {method : 'POST',
            data : testCase,
            dataType : 'json',
    }).done(function(data, textStatus, jqXHR){

        FloMax.Tester.displayTestResult(data.testResult);

    }).fail(function (data, textStatus, jqXHR) {
        var error = $.parseJSON(data.responseText); //Pass the error as JSON so we don't trigger the default Koha error pages.
        alert("Testing floating rule "+testCase.fromBranch+"-"+testCase.toBranch+" failed, because of the following error:\n"+data.status+" "+data.statusText+"\n"+"More specific error: "+error.error);
        FloMax.Tester.displayTestResult("error");
    });
}
FloMax.Tester.buildTestCaseFromHTML = function () {
    var fromBranch = $("#floatingRuleTester #testerFromBranch").val();
    var toBranch   = $("#floatingRuleTester #testerToBranch").val();
    var barcode    = $("#floatingRuleTester #testerBarcode").val();

    var testCase = {
        'fromBranch' : fromBranch,
        'toBranch' : toBranch,
        'barcode' : barcode,
        'test': true,
    };
    return testCase;
}
FloMax.Tester.displayTestResult = function (testResult) {
    $(".cssload-loader").css('visibility', 'hidden');
    var color;
    if (testResult == null) {
        color = FloMax.branchRuleDisabledColor;
    }
    else if (testResult == 'ALWAYS') {
        color = FloMax.branchRuleAlwaysColor;
    }
    else if (testResult == 'POSSIBLE') {
        color = FloMax.branchRulePossibleColor;
    }
    else if (testResult == "error") {
        color = FloMax.Tester.defaultTestResultColor;
    }
    else {
        color = FloMax.Tester.defaultTestResultColor;
        alert("Couldn't display test result '"+testResult+"'. Value is unknown.");
    }

    $("#testResulDisplay").css('background-color', color);
}