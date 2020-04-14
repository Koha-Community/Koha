/* global borrowernumber MSG_YOUR_RATING MSG_AVERAGE_RATING */
// -----------------------------------------------------
// star-ratings code
// -----------------------------------------------------
// hide 'rate' button if javascript enabled

$(document).ready(function(){
    $("input[name='rate_button']").remove();

    var star_ratings = $(".star_rating");

    star_ratings.barrating({
        theme: 'fontawesome-stars',
        showSelectedRating: false,
        allowEmpty: true,
        deselectable: false,
        onSelect: function( value ) {
            var context = $("#" + this.$elem.data("context") );
            $(".rating-loading", context ).show();
            $.post("/cgi-bin/koha/opac-ratings-ajax.pl", {
                rating_old_value: $(".rating_value", context ).attr("value"),
                borrowernumber: borrowernumber,
                biblionumber: this.$elem.data('biblionumber'),
                rating_value: value,
                auth_error: value
            }, function (data) {
                $(".rating_value", context ).val(data.rating_value);
                if (data.rating_value) {
                    $(".rating_value_text", context ).text( MSG_YOUR_RATING.format(data.rating_value) );
                    $(".cancel_rating_text", context ).show();
                } else {
                    $(".rating_value_text", context ).text("");
                    $(".cancel_rating_text", context ).hide();
                }
                $(".rating_text", context ).text( MSG_AVERAGE_RATING.format(data.rating_avg, data.rating_total) );
                $(".rating-loading", context ).hide();
            }, "json");
        }
    });

    $("body").on("click", ".cancel_rating_text a", function(e){
        e.preventDefault();
        var context = "#" + $(this).data("context");
        $(context).barrating("set", "");
    });
});
