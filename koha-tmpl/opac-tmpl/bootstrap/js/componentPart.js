//Setting the height of the component part record container to prevent overflow
$(document).ready(function() {
    var containerHeight = $("#catalogue_detail_biblio").height();
    $(".componentPartRecordsContainer").height( containerHeight );
});
$(window).resize(function() {
    var containerHeight = $("#catalogue_detail_biblio").height();
    $(".componentPartRecordsContainer").height( containerHeight );
});