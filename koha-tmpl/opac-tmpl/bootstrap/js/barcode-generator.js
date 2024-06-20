document.addEventListener("DOMContentLoaded", function() {
    var barcodeNumber = document.getElementById("patron-barcode").dataset.barcode;
    JsBarcode("#patron-barcode", barcodeNumber, {
        format: "CODE39",
        lineColor: "#000",
        width: 2,
        height: 100,
        displayValue: false,
        margin: 0
    });
});