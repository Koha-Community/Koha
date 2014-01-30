//package Labels.PrintLabelsList
//Package Labels
if (typeof Labels == "undefined") {
    this.Labels = {}; //Set the global package
}
Labels.PrintLabelsList = {};
Labels.PrintLabelsList.createFlushButton = function (element, targetingFunction) {
    $(element).click(function (event) {
        var listContent = targetingFunction();

        Labels.PrintLabelsList.removeListContentFromREST({
            listname: listContent.listname,
            biblionumber: parseInt(listContent.biblionumber),
            borrowernumber: parseInt(listContent.borrowernumber),
            itemnumber: parseInt(listContent.itemnumber)
        });
        event.preventDefault();
    });
}
Labels.PrintLabelsList.createAddButton = function (element, targetingFunction) {
    $(element).click(function (event) {
        var listContent = targetingFunction();

        Labels.PrintLabelsList.putListContentToREST({
            listname: listContent.listname,
            biblionumber: parseInt(listContent.biblionumber),
            borrowernumber: parseInt(listContent.borrowernumber),
            itemnumber: parseInt(listContent.itemnumber)
        });
        event.preventDefault();
    });
}
Labels.PrintLabelsList.putListContentToREST = function (listContent) {
    $.ajax("/api/v1/lists/"+listContent.listname+"/contents",
        { "method": "POST",
          "accepts": "application/json",
          "contentType": "application/json; charset=utf8",
          "processData": false,
          "data": JSON.stringify(listContent),
          "success": function (jqXHR, textStatus, errorThrown) {
            var listContent = jqXHR;
            alert(textStatus);
          },
          "error": function (jqXHR, textStatus, errorThrown) {
            var errorObject = jqXHR.responseJSON.errors[0];
            alert(JSON.stringify(errorObject) || textStatus);
          },
        }
    );
}
Labels.PrintLabelsList.removeListContentFromREST = function (listContent) {
    $.ajax("/api/v1/lists/"+listContent.listname+"/contents",
        { "method": "DELETE",
          "accepts": "application/json",
          "contentType": "application/json; charset=utf8",
          "processData": false,
          "data": JSON.stringify(listContent),
          "success": function (jqXHR, textStatus, errorThrown) {
            var listContent = jqXHR;
            $("#barcodes").val('');
            alert(textStatus);
          },
          "error": function (jqXHR, textStatus, errorThrown) {
            var errorObject = jqXHR.responseJSON.errors[0];
            alert(JSON.stringify(errorObject) || textStatus);
          },
        }
    );
}