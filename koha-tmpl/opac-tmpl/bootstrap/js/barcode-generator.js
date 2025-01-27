document.addEventListener("DOMContentLoaded", function () {
    const svgElement = document.getElementById("patron-barcode");
    var barcodeNumber = svgElement.dataset.barcode;
    var barcodeFormat = svgElement.dataset.barcodeFormat;

    try {
        // Generate the barcode SVG
        let svg = bwipjs.toSVG({
            bcid: barcodeFormat, // Barcode type
            text: barcodeNumber, // Text to encode
            padding: 0,
            height: 15,
        });
        // Add the generated SVG to the barcode container
        if (barcodeFormat == "qrcode") {
            document
                .getElementById("barcode-container")
                .classList.add("qrcode");
        }
        document.getElementById("barcode-container").innerHTML = svg;
    } catch (error) {
        console.error(error);

        const p_node = document.createElement("p");
        const strong_node = document.createElement("strong");
        strong_node.textContent = __("Error: ");
        const span_node = document.createElement("span");
        span_node.textContent = __("Unable to generate barcode");
        span_node.setAttribute("id", "barcode-gen-error");
        p_node.appendChild(strong_node);
        p_node.appendChild(span_node);
        document.getElementById("barcode-container").replaceChildren(p_node);
    }
});
