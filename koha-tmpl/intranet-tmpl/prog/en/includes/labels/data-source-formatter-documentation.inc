[%# Add translateable documentation for label data source formatter functions here. %]
[%# Strictly maintain the same documentation format. Everything under span.comment can be modified as needed.%]
[%# root div id must be the documented data source formatter function name with prepended text 'dsfod-'%]

<div class="dsfod-doc" id="dsfod-barcode39">
    <span class="title">Barcode39</span>
    <span class="comment">
        Prints a barcode of format Code 39 from the source data including the barcode value as text.
        Barcode128 is recommended over this as it is a newer standard.
        Supported characters are uppercase letters (A through Z), numeric digits (0 through 9) and a number of special characters (-, ., $, /, +, %, and space).
        Lower case characters are automatically uppercased.<br/>
        Custom attributes:<br/>
        <b>x-scale=1.0</b><br/>
        <b>y-scale=1.0</b><br/>
        <b>showtext=1</b><br/>
        Example:<br/>
        <em>x-scale=1.0, y-scale=0.75, showtext=0</em>
    </span>
</div>
<div class="dsfod-doc" id="dsfod-barcode128">
    <span class="title">Barcode128</span>
    <span class="comment">
        Prints a barcode of format Code 128 from the source data including the barcode value as text.
        Supported characters are uppercase letters (A through Z), numeric digits (0 through 9) and a number of special characters (-, ., $, /, +, %, and space).
        Lower case characters are automatically uppercased.<br/>
        Custom attributes:<br/>
        <b>x-scale=1.0</b><br/>
        <b>y-scale=1.0</b><br/>
        <b>showtext=1</b><br/>
        Example:<br/>
        <em>x-scale=1.0, y-scale=0.75, showtext=0</em>
    </span>
</div>
<div class="dsfod-doc" id="dsfod-barcodeEAN13">
    <span class="title">BarcodeEAN13</span>
    <span class="comment">
        Prints a barcode of format EAN13 from the source data including the barcode value as text.
        The data source value must be exactly 13 characters long, with the checksum overwritten by the 13th character.
        EAN13 accepts only digits.<br/>
        Custom attributes:<br/>
        <b>x-scale=1.0</b><br/>
        <b>y-scale=1.0</b><br/>
        <b>showtext=1</b><br/>
        Example:<br/>
        <em>x-scale=1.0, y-scale=0.75, showtext=0</em>
    </span>
</div>
<div class="dsfod-doc" id="dsfod-barcodeEAN13checksum">
    <span class="title">BarcodeEAN13 with checksum</span>
    <span class="comment">
        Prints a barcode of format EAN13 from the source data including the barcode value as text.
        The data source value must be exactly 12 characters long, and the 13th character, aka. the checksum is calculated automatically.
        EAN13 accepts only digits.<br/>
        Custom attributes:<br/>
        <b>x-scale=1.0</b><br/>
        <b>y-scale=1.0</b><br/>
        <b>showtext=1</b><br/>
        Example:<br/>
        <em>x-scale=1.0, y-scale=0.75, showtext=0</em>
    </span>
</div>
<div class="dsfod-doc" id="dsfod-oneLiner">
    <span class="title">One-liner</span>
    <span class="comment">
        Prints the given data elements as one line, removing characters that wouldn't fit to the given width.
    </span>
</div>
<div class="dsfod-doc" id="dsfod-oneLinerShrinkText">
    <span class="title">Shrinking one-liner</span>
    <span class="comment">
        Prints the given data elements as one line, shrinking the text by a maximum of 50% of the original size,
        removing characters that still wouldn't fit to the given width.
    </span>
</div>
<div class="dsfod-doc" id="dsfod-twoLiner">
    <span class="title">Two-liner</span>
    <span class="comment">
        Tries to print the given data elements as one line.<br/>
        If that fails, formatter splits the text to two lines,
        removing characters that still wouldn't fit to the given width.
    </span>
</div>
<div class="dsfod-doc" id="dsfod-twoLinerShrink">
    <span class="title">Shrinking two-liner</span>
    <span class="comment">
        Tries to print the given data elements as one line.<br/>
        If that fails, shrinks the font size by a maximum 30% and splits the text to two lines,
        removing characters that still wouldn't fit to the given width.
    </span>
</div>



<div id="dsfod-errors" style="display: none">
    <span class="dsfod-undefined-function-error error">This function doesn't exist!</span>
    <span class="dsfod-undocumented-function-error error">This function isn't documented!</span>
</div>