var BatchOverlay = {};

var reportsDataTable;
$(function() {

  $( "#toptabs" ).tabs();

  reportsDataTable = $( "#reportsTable" ).DataTable({
    "paging": false,
    "order": [[ 0, "desc" ]]
  });

  if (justExecutedReportContainerId) {
    toptabs.getReportFromREST(justExecutedReportContainerId);
  }
  if (encodingLevelSearchPerfromed) {
    $("#toptabs").tabs("option", "active", 1);
  }

  $(".deleteReportContainer").click(function (event) {
    event.preventDefault();
    if (confirm("Are you sure you want to delete this report container?")) {
      var row = $(this).parents("tr");
      reportsDataTable.row( row ).remove().draw( false );
      //TODO: Persist in DB
    }
  });
  $(".showReportContainer").click(function (event) {
    event.preventDefault();
    var row = $(this).parents("tr");
    var id = row.attr("id").replace('reportContainer-', '');
    toptabs.getReportFromREST(id);
  });

  BatchOverlay.StatusesTester.getResults();
});

var toptabs = {};
toptabs.showReport = function (reportContainerId, reports) {
  var activeReportBody = toptabs.prepareReportTab(reportContainerId);
  for(var ri=0 ; ri<reports.length ; ri++) {
    var report = reports[ri];
    report.diff = JSON.parse(report.diff);

    var reportRow = $("<div class='reportRow' id='reportRow-"+report.id+"'></div>");
    activeReportBody.append(reportRow);

    if (report.operation.match(/error/)) {
      reportRow.append(  toptabs.errorTitle(report)  );
      toptabs.populateReportErrorBody(reportRow, report);
    }
    else {
      reportRow.append(  toptabs.reportTitle(report)  );
      toptabs.populateReportReportBody(reportRow, report);
    }
  }
}
toptabs.prepareReportTab = function (reportContainerId) {
  var activeReportTab = $("#toptabs > ul > li#activeReportTab");
  if (activeReportTab) {
    activeReportTab.remove();
  }
  var activeReportBody = $("#toptabs > div#activeReportBody");
  if (activeReportBody) {
    activeReportBody.remove();
  }
  $("#toptabs ul").append("<li id='activeReportTab'><a href='#activeReportBody'>"+reportContainerId+"</a></li>");
  $("#toptabs").append("<div id='activeReportBody'></div>");

  $("#toptabs").tabs( "refresh" );

  var index = $('#toptabs a[href="#activeReportBody"]').parent().index();
  $("#toptabs").tabs("option", "active", index);

  return $("div#activeReportBody");
}
toptabs.populateReportReportBody = function (activeReportBody, report) {
  var headers = report.headers;
  var diff = report.diff;
  var comparedRecordsCount;

  var htmlRows = "";
  Object.keys(diff).sort().forEach(function (tag, index, array) {
    if (tag.match(/^00\d/)) { //This is a control field
      htmlRows += toptabs.diffRowTemplate(tag, '', diff[tag])+"\n";
      if (!comparedRecordsCount) {  comparedRecordsCount = diff[tag].length;  }
      return;
    }
    var fields = diff[tag];
    for (var fi=0 ; fi<fields.length ; fi++) {
      var field = fields[fi];
      if (!field) { //TODO_ Ungly hack to prevent crashing when something is wrong in the C4::Biblio::Diff leaking null array indexes
        continue;
      }
      Object.keys(field).sort().forEach(function (code, index, array) {
        if (code.match(/^_i/)) { //This is an indicator
          htmlRows += toptabs.diffRowTemplate(tag, code, field[code])+"\n";
          if (!comparedRecordsCount) {  comparedRecordsCount = field[code].length;  }
          return;
        }
        var subfields = field[code];
        for (var sfi=0 ; sfi<subfields.length ; sfi++) {
          var subfieldDiff = subfields[sfi];
          htmlRows += toptabs.diffRowTemplate(tag, code, subfieldDiff)+"\n";
          if (!comparedRecordsCount) {  comparedRecordsCount = field[code].length;  }
        }
      });
    }
  });
  var htmlTable = "<table id='diff'>\n"+
                  "  <thead>\n"+
                  "    <td>f</td>\n"+
                  "    <td>sf</td>\n";
  for(var i=0 ; i<headers.length ; i++) {
    htmlTable +=  "    <td>"+toptabs.headerTemplate(headers[i])+"</td>\n";
  }
  htmlTable +=    "  </thead>\n"+
                  htmlRows+
                  "</table>\n";

  htmlTable = $(htmlTable);
  activeReportBody.append(htmlTable);
  htmlTable.DataTable({
    "paging": false,
    "info": false,
    "searching": false,
    "columnDefs": [
      { "width": "10", "targets": 0 },
      { "width": "10", "targets": 1 }
    ]
  });

  return htmlTable;
}
toptabs.headerTemplate = function (header) {
  return "<span>"+header.title+"</span>, <span>"+header.stdid+"</span>";
}
toptabs.reportTitle = function (report) {
  var html = "<h4>";
  html += "<span class='operation'>["+report.operation+"]</span> ";
  html += "<span class='biblio'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="+report.biblionumber+"'>biblio:"+report.biblionumber+"</a></span>, ";
  html += "<span>using "+report.ruleName+"</span>";
  html += "<span style='float:right' class='identifier'>id:"+report.id+"</span>";
  html += "</h4>";
  return html;
}
toptabs.errorTitle = function (report) {
  var html = "<h4>";
  html += "<span class='operation'>["+report.operation+"]</span> ";
  if (report.biblionumber) {
    html += "<span class='biblio'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="+report.biblionumber+"'>biblio:"+report.biblionumber+"</a></span>, ";
  }
  if (report.ruleName) {
    html += "<span>using "+report.ruleName+"</span>";
  }
  html += "<span style='float:right' class='identifier'>id:"+report.id+"</span>";
  html += "</h4>";
  return html;
}
toptabs.populateReportErrorBody = function (activeReportBody, error) {
  var headers = error.headers;
  var diff = error.diff;

  var html = "";
  if (headers && headers[0]) {
    html += "<div> Record: "+toptabs.headerTemplate(headers[0])+"</div>";
  }
  html += "<span class='error'>"+diff['class']+"<br/>"+diff.error+"</span>";
  html += "<p>search algorithm: "+diff.searchAlgorithm+"</p>"
  html += "<p>search term: "+diff.searchTerm+"</p>"

  html = $(html);
  activeReportBody.append(html);
  return html;
}
toptabs.diffRowTemplate = function (tag, code, diff) {
  var html = "";
  html +=   "  <tr>\n"+
            "    <td>"+tag+"</td>\n"+
            "    <td>"+code+"</td>\n";
  for (var i=0 ; i<diff.length ; i++) {
    var diffed = (diff[i]) ? '"'+diff[i]+'"' : '';
    html += "    <td>"+diffed+"</td>\n";
  }
  html +=   "  </tr>\n";
  return html;
}
toptabs.getReportFromREST = function (reportContainerId) {
    var showAllExceptions = BatchOverlay.isShowAllExceptions();
    $.ajax("/api/v1/reports/batchOverlays/"+reportContainerId+"/reports?showAllExceptions="+showAllExceptions,
        { "method": "get",
          "accepts": "application/json",
          "success": function (jqXHR, textStatus, errorThrown) {
            toptabs.showReport(reportContainerId, jqXHR); //Pass the reports-array
          },
          "error": function (jqXHR, textStatus, errorThrown) {
            var errorMsg;
            var errorCode = jqXHR.status;
            if (jqXHR.responseJSON && jqXHR.responseJSON.error) {
              errorMsg = jqXHR.responseJSON.error;
            }
            else if (jqXHR.responseJSON && jqXHR.responseJSON.errors && jqXHR.responseJSON.errors[0]) {
              errorMsg = jqXHR.responseJSON.errors[0].message;
            }
            else {
              errorMsg = errorThrown;
            }
            alert("toptabs.getReportFromREST("+reportContainerId+"):> "+errorMsg+", http status "+errorCode);
          }
        }
    );
}

BatchOverlay.isShowAllExceptions = function() {
  return $("input[name='showAllExceptions']:checked").length;
}

BatchOverlay.StatusesTester = {};
BatchOverlay.StatusesTester.getResults = function () {
  $.ajax("/cgi-bin/koha/cataloguing/batchOverlay.pl?op=test",
    { "method": "get",
      "accepts": "text/json",
      "success": function (jqXHR, textStatus, errorThrown) {
        BatchOverlay.StatusesTester.showResults(jqXHR); //Pass the statuses
      },
      "error": function (jqXHR, textStatus, errorThrown) {
        var errorMsg;
        var errorCode = jqXHR.status;
        if (jqXHR.responseJSON && jqXHR.responseJSON.error) {
          errorMsg = jqXHR.responseJSON.error;
        }
        else if (jqXHR.responseJSON && jqXHR.responseJSON.errors && jqXHR.responseJSON.errors[0]) {
          errorMsg = jqXHR.responseJSON.errors[0].message;
        }
        else {
          errorMsg = errorThrown;
        }
        alert("BatchOverlay.StatusesTester.getResults():> "+errorMsg+", http status "+errorCode);
      }
    }
  );
}
BatchOverlay.StatusesTester.showResults = function (statuses) {
  var rtc = $("#statusesContainer");
  statuses.remoteTargetStatuses.forEach(function(element, index, array){
    var html = "<div>"+
               "  Rule <span class='rtc-server'>"+element.ruleName+"</span> for "+
               "  remote <span class='rtc-server'>"+element.server+"</span>";
    if (element.errors) {
      html +=  "  <span class='error'>"+element.errors.join(', ')+"</span>";
    }
    else {
      html +=  "  <span class='rtc-ok'></span>";
    }
    html +=    "</div>";
    rtc.append(html);
  });

  statuses.dryRunStatuses.forEach(function(element, index, array){
    if (element.dryRun != "1") {
        return;
    }
    var html = "<div>"+
               "  Rule <span class='rtc-server'>"+element.ruleName+"</span> "+
               "  <span class='rtc-server'>dry-run enabled</span>"+
               "</div>";
    rtc.append(html);
  });
}


  $(".report > h3").click(function() {$(this).siblings(".report_content").toggle()});
  $(".report > h3").siblings(".report_hidden").toggle();
  $(".toggler").click(function() {$(this).siblings().toggle()});
  $(".toggler").siblings().toggle();

  function importResult( button ) {
    var stdId = $(button).val();
    var codesText = $("#codes").val();
    codesText = codesText + stdId + "\n";
    $("#codes").val( codesText );
  }
