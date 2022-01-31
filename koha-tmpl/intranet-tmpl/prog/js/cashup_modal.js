$(document).ready(function() {
    $('#cashupSummaryModal').on('show.bs.modal', function(e) {
        var button = $(e.relatedTarget);
        var cashup = button.data('cashup');
        var description = button.data('register');
        var summary_modal = $(this);
        summary_modal.find('#register_description').text(description);
        $.ajax({
            url: '/api/v1/cashups/' + cashup,
            headers: {
                'x-koha-embed': 'summary'
            },
            async: false,
            success: function(data) {
                let from_date = $datetime(data.summary.from_date);
                summary_modal.find('#from_date').text(from_date);
                let to_date = $datetime(data.summary.to_date);
                summary_modal.find('#to_date').text(to_date);
                var tbody = summary_modal.find('tbody')
                tbody.empty();
                for (out of data.summary.payout_grouped) {
                    if ( out.credit_type_code == 'REFUND' ) {
                        tbody.append('<tr><td>' + out.credit_type.description + ' ' + __("against") + ' ' + out.related_debit.debit_type.description + '</td><td>- ' + out.total + '</td></tr>');
                    } else {
                        tbody.append('<tr><td>' + out.credit_type.description + '</td><td>- ' + out.total + '</td></tr>');
                    }
                }

                for (income of data.summary.income_grouped) {
                    tbody.append('<tr><td>' + income.debit_type.description + '</td><td>' + income.total.format_price() + '</td></tr>');
                }

                var tfoot = summary_modal.find('tfoot');
                tfoot.empty();
                tfoot.append('<tr><td>Total</td><td>' + data.summary.total.format_price() + '</td></tr>');
                for (type of data.summary.total_grouped) {
                    if (type.total !== 0) {
                        tfoot.append('<tr><td>' + type.payment_type + '</td><td>' + type.total.format_price() + '</td></tr>');
                    }
                }
            }
        });
    });

    $('.modal.printable').on('shown.bs.modal', function() {
        $('.modal-dialog', this).addClass('focused');
        $('body').addClass('modalprinter');

        if ($(this).hasClass('autoprint')) {
            window.print();
        }
    }).on('hidden.bs.modal', function() {
        $('.modal-dialog', this).removeClass('focused');
        $('body').removeClass('modalprinter');
    });

    $('.printModal').click(function() {
        window.print();
    });
});
