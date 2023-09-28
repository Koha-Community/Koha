$(document).ready(function() {

        $(".cancel_recall").click(function(e){
            if (confirmDelete(__("Are you sure you want to remove this recall?"))){
                var $self = $(this);
                var $recall_id = $(this).data('id');
                var $action = $(this).data('action');
                var ajaxData = {
                    'recall_id': $recall_id,
                    'action'   : $action,
                };

                $.ajax({
                    url: '/cgi-bin/koha/svc/recall',
                    type: 'POST',
                    dataType: 'json',
                    data: ajaxData,
                })
                .done(function(data) {
                    var message = "";
                    if(data.success == 0) {
                        message = __("The recall may have already been cancelled. Please refresh the page.");
                    } else {
                        message = __("Cancelled");
                    }
                    $self.parent().parent().parent().parent().html(message);
                });
            }
        });

        $(".expire_recall").click(function(e){
            if (confirmDelete(__("Are you sure you want to expire this recall?"))){
                var $self = $(this);
                var $recall_id = $(this).data('id');
                var $action = $(this).data('action');
                var ajaxData = {
                    'recall_id': $recall_id,
                    'action'   : $action,
                };

                $.ajax({
                    url: '/cgi-bin/koha/svc/recall',
                    type: 'POST',
                    dataType: 'json',
                    data: ajaxData,
                })
                .done(function(data) {
                    var message = "";
                    if(data.success == 0) {
                        message = __("The recall may have already been expired. Please refresh the page.");
                    } else {
                        message = __("Expired");
                    }
                    $self.parent().parent().parent().parent().html(message);
                });
            }
        });

        $(".revert_recall").click(function(e){
            if (confirmDelete(__("Are you sure you want to revert the waiting status of this recall?"))){
                var $self = $(this);
                var $recall_id = $(this).data('id');
                var $action = $(this).data('action');
                var ajaxData = {
                    'recall_id': $recall_id,
                    'action'   : $action,
                };

                $.ajax({
                    url: '/cgi-bin/koha/svc/recall',
                    type: 'POST',
                    dataType: 'json',
                    data: ajaxData,
                })
                .done(function(data) {
                    var message = "";
                    if(data.success == 0) {
                        message = __("The recall waiting status may have already been reverted. Please refresh the page.");
                    } else {
                        message = __("Waiting status reverted");
                    }
                    $self.parent().parent().parent().parent().html(message);
                });
            }
        });

        $(".overdue_recall").click(function(e){
            if (confirmDelete(__("Are you sure you want to mark this recall as overdue?"))){
                var $self = $(this);
                var $recall_id = $(this).data('id');
                var $action = $(this).data('action');
                var ajaxData = {
                    'recall_id': $recall_id,
                    'action'   : $action,
                };

                $.ajax({
                    url: '/cgi-bin/koha/svc/recall',
                    type: 'POST',
                    dataType: 'json',
                    data: ajaxData,
                })
                .done(function(data) {
                    var message = "";
                    if(data.success == 0) {
                        message = __("The recall may have already been marked as overdue. Please refresh the page.");
                    } else {
                        message = __("Marked overdue");
                    }
                    $self.parent().parent().parent().parent().html(message);
                });
            }
        });

        $(".transit_recall").click(function(e){
            if (confirmDelete(__("Are you sure you want to remove this recall and return the item to it's home library?"))){
                var $self = $(this);
                var $recall_id = $(this).data('id');
                var $action = $(this).data('action');
                var ajaxData = {
                    'recall_id': $recall_id,
                    'action'   : $action,
                };

                $.ajax({
                    url: '/cgi-bin/koha/svc/recall',
                    type: 'POST',
                    dataType: 'json',
                    data: ajaxData,
                })
                .done(function(data) {
                    var message = "";
                    if(data.success == 0) {
                        message = __("The recall may have already been removed. Please refresh the page.");
                    } else {
                        message = __("Cancelled");
                    }
                    $self.parent().parent().parent().parent().html(message);
                });
            }
        });

        $("#recalls-table").dataTable($.extend(true, {}, dataTablesDefaults, {
            "columnDefs":  [
                { "orderable":  false, "targets":  [ 'nosort' ] },
                { "type":  "title-string", "targets":  [ "title-string" ] },
                { "type":  "anti-the", "targets":  [ "anti-the" ] }
            ],
            "pagingType":  "full_numbers"
        }));

        $("#cancel_selected").click(function(e){
            if ($("input[name='recall_ids']:checked").length > 0){
                return confirmDelete(__("Are you sure you want to remove the selected recall(s)?"));
            } else {
                alert(__("Please make a selection."));
            }
        });

        $("#select_all").click(function(){
            if ($("#select_all").prop("checked")){
                $("input[name='recall_ids']").prop("checked", true);
            } else {
                $("input[name='recall_ids']").prop("checked", false);
            }
        });

        $("#hide_old").click(function(){
            if ($("#hide_old").prop("checked")){
                $(".old").show();
            } else {
                $(".old").hide();
            }
        });
});
