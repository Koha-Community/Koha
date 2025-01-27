// -----------------------------------------------------
// star-ratings code
// -----------------------------------------------------
// hide 'rate' button if javascript enabled

$(document).ready(function () {
    $("input[name='rate_button']").remove();

    var star_ratings = $(".star_rating");

    star_ratings.barrating({
        theme: "fontawesome-stars",
        showSelectedRating: false,
        allowEmpty: true,
        deselectable: false,
        readonly: !is_logged_in,
        onSelect: function (value) {
            var context = $("#" + this.$elem.data("context"));
            $(".rating-loading", context).show();
            let biblionumber = this.$elem.data("biblionumber");
            if (value == "") value = null;
            fetch("/api/v1/public/biblios/" + biblionumber + "/ratings", {
                method: "POST",
                body: JSON.stringify({ rating: value }),
                headers: {
                    "Content-Type": "application/json;charset=utf-8",
                },
            })
                .then(checkError)
                .then(data => {
                    $(".rating_value", context).val(data.rating);
                    console.log(data);
                    console.log($(".cancel_rating_text", context));
                    if (data.rating) {
                        console.log(data.rating);
                        $(".rating_value_text", context).text(
                            __("Your rating: %s.").format(data.rating)
                        );
                        $(".cancel_rating_text", context).show();
                    } else {
                        $(".rating_value_text", context).text("");
                        $(".cancel_rating_text", context).hide();
                    }
                    console.log($(".rating_text", context));
                    $(".rating_text", context).text(
                        __("Average rating: %s (%s votes)").format(
                            data.average,
                            data.count
                        )
                    );
                    $(".rating-loading", context).hide();
                });
        },
    });

    $("body").on("click", ".cancel_rating_text a", function (e) {
        e.preventDefault();
        var context = "#" + $(this).data("context");
        $(context).barrating("set", "");
    });
});
