(function () {
    $(document).ready(function () {
        $("#additional_fields_form_section").on(
            "click",
            ".clone_attribute",
            function (e) {
                e.preventDefault();
                clone_entry(this);
            }
        );

        $("#additional_fields_form_section").on(
            "click",
            ".clear_attribute",
            function (e) {
                e.preventDefault();
                clear_entry(this);
            }
        );

        $("#additional_fields_form_section")
            .parents("form ")
            .submit(function () {
                $(".marcfieldget").prop("disabled", false);
                return true;
            });
    });

    function clone_entry(node) {
        var original = $(node).parent();
        var clone = $(node).parent().clone();
        $(original).after(clone);
        return false;
    }

    function clear_entry(node) {
        var original = $(node).parent();
        $("input", original).val("");
    }
})();
