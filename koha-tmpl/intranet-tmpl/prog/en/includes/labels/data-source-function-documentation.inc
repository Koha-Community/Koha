[%# Add translateable documentation for label data source processing functions here. %]
[%# Strictly maintain the same documentation format. Everything under span.class can be modified as needed.%]
[%# root div id must be the documented data source functions function name with prepended text 'dsfd-'%]
<h4>Available data source functions</h4>


<div class="dsfd-doc" id="dsfd-contentDescription">
    <span class="title">Content description</span>
    <span class="comment">
        Selects all 300$a instances and one 300$e if available.
    </span>
</div>
<div class="dsfd-doc" id="dsfd-itemtype">
    <span class="title">Item type</span>
    <span class="comment">
        Item type as human readable. Not "BK", but "Books".
    </span>
</div>
<div class="dsfd-doc" id="dsfd-location">
    <span class="title">Location</span>
    <span class="comment">
        Location as human readable. Not "NEW", but "New Materials Shelf".
        Prioritizes item.permanent_location, but if that is not available falls back to item.location.
    </span>
</div>
<div class="dsfd-doc" id="dsfd-oplibLabel">
    <span class="title">KohaSuomi shelving label / department code</span>
    <span class="comment">
        Selects the short branch+location code mapped by the "shelving label mapper"
    </span>
</div>
<div class="dsfd-doc" id="dsfd-signum">
    <span class="title">Signum</span>
    <span class="comment">
        Selects the signum.
    </span>
</div>
<div class="dsfd-doc" id="dsfd-signumVaara">
    <span class="title">Signum Vaara-kirjastot style</span>
    <span class="comment">
        Selects the signum from the Item's itemcallnumber-field's first token.
    </span>
</div>
<div class="dsfd-doc" id="dsfd-title">
    <span class="title">Title</span>
    <span class="comment">
        Selects the complete title 245$abnp. If there is no title, selects 111$a or 130$a.
    </span>
</div>
<div class="dsfd-doc" id="dsfd-yklVaara">
    <span class="title">ykl-code, Vaara-kirjastot</span>
    <span class="comment">
        Selects the second element in the item's callnumber-column. In Vaara-kirjastot this must contain the Item-specific ykl-classification.
    </span>
</div>
<div class="dsfd-doc" id="dsfd-yklKyyti">
    <span class="title">ykl-code, Kyyti-kirjastot</span>
    <span class="comment">
        Selects the first element in the item's callnumber-column. In Kyyti-kirjastot this must contain the Item-specific ykl-classification.
    </span>
</div>


<div id="dsfd-errors" style="display: none">
    <span class="dsfd-undefined-function-error error">This function doesn't exist!</span>
    <span class="dsfd-undocumented-function-error error">This function isn't documented!</span>
</div>
