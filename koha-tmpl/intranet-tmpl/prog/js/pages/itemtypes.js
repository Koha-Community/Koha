$(document).ready(function () {
    $("#table_item_type").kohaTable(
        {
            pagingType: "full",
        },
        table_settings
    );

    $("#itemtypeentry").validate({
        rules: {
            itemtype: { required: true },
            description: { required: true },
            rentalcharge: { number: true },
            rentalcharge_hourly: { number: true },
            defaultreplacecost: { number: true },
        },
    });
    $("#itemtype").on("blur", function () {
        toUC(this);
    });
    if ($("#icons .tab-pane.active").length < 1) {
        $("#icons a:first").tab("show");
    }

    if ($("#library_limitation").length > 0) {
        $("#library_limitation")[0].style.minWidth = "450px";
        $("#library_limitation").select2();
    }
    $("#remoteimage").on("mousedown", function () {
        document.getElementById("remote_image_check").checked = true;
    });
});
