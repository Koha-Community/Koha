document.addEventListener("DOMContentLoaded", function() {
    const svgElement = document.getElementById('patron-barcode');
    var barcodeNumber = svgElement.dataset.barcode;
    var barcodeFormat = svgElement.dataset.barcodeFormat;

    try {
        // Generate the barcode SVG
        let svg = bwipjs.toSVG({
            bcid:        barcodeFormat,  // Barcode type
            text:        barcodeNumber,  // Text to encode
            padding:     0,
            height:      15,
        });
        // Add the generated SVG to the barcode container
        if (barcodeFormat == "qrcode") {
            document.getElementById('barcode-container').classList.add('qrcode');
        }
        document.getElementById('barcode-container').innerHTML = svg
    } catch (error) {
        // Use regex to find error message
        const match = error.message.match(/: (.+)$/);
        const errorMessage = match ? match[1] : error.message;

        console.error(error);
        document.getElementById('barcode-container').innerHTML = "<p><strong>" + __("Error:") + " </strong>${errorMessage}</p>";
    }
});
