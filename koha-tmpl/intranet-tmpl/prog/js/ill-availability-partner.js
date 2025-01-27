$(document).ready(function () {
    var enabled_names = [];
    $("#partners option").each(function () {
        var partner = $(this);
        var partner_id = partner.data("partner-id");
        if (isEnabled(partner_id)) {
            enabled_names.push(partner.text().trim());
        }
    });
    $("#generic_confirm_enabled").text(enabled_names.join(", "));

    $("#partners").change(function () {
        var selected = [];
        $("#partners option:selected").each(function () {
            var partner_id = $(this).data("partner-id");
            if (isEnabled(partner_id)) {
                selected.push(partner_id);
            }
        });
        if (selected.length > 0) {
            $("#generic_confirm_search").css("visibility", "initial");
        } else {
            $("#generic_confirm_search").css("visibility", "hidden");
        }
        $("#service_id_restrict").attr(
            "data-service_id_restrict_ids",
            selected.join("|")
        );
    });
    $("#generic_confirm_search").click(function (e) {
        $("#partnerSearch").modal("show");
    });
    $("#partnerSearch").on("show.bs.modal", function () {
        doSearch();
    });
    $("#partnerSearch").on("hide.bs.modal", function () {
        $.fn.dataTable.tables({ api: true }).destroy();
    });

    function isEnabled(id) {
        return services[0].enabled.indexOf(id.toString()) > -1;
    }
});
