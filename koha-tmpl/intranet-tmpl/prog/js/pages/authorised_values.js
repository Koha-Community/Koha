$(document).ready(function () {
    $("#categoriest").kohaTable({
        order: [[0, "asc"]],
        pagingType: "full",
    });

    if ($("#branches option:selected").length < 1) {
        $("#branches option:first").attr("selected", "selected");
    }

    $(".delete").click(function () {
        return confirm(
            __("Are you sure you want to delete this authorized value?")
        );
    });
    $("#category_search").change(function () {
        $("#category").submit();
    });

    $("#delete_category").on("submit", function () {
        return confirm(
            __(
                "Are you sure you want to delete this authorized value category?"
            )
        );
    });

    if ($("#icons .tab-pane.active").length < 1) {
        $("#icons a:first").tab("show");
    }

    $("#Aform").submit(function () {
        if ($("#authorised_value").length) {
            if (!$("#authorised_value").get(0).checkValidity()) {
                alert(__("Authorised value should be numeric."));
                $("#authorised_value").focus();
                return false;
            }
        }
        return true;
    });

    if ($("#library_limitation").length > 0) {
        $("#library_limitation")[0].style.minWidth = "450px";
        $("#library_limitation").select2();
    }
    $("#remoteimage").on("mousedown", function () {
        document.getElementById("remote_image_check").checked = true;
    });
});
