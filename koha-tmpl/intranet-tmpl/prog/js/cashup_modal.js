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
                    if (out.credit_type_code == 'REFUND') {
                        tbody.append('<tr><td>' + __x('{credit_type_description} against {debit_type_description}', { 'credit_type_description': escape_str(out.credit_type.description), 'debit_type_description': escape_str(out.related_debit.debit_type.description) }) + '</td><td>- ' + out.total.format_price() + '</td></tr>');
                    } else {
                        tbody.append('<tr><td>' + escape_str(out.credit_type.description) + '</td><td>- ' + out.total.format_price() + '</td></tr>');
                    }
                }

                for (income of data.summary.income_grouped) {
                    tbody.append('<tr><td>' + escape_str(income.debit_type.description) + '</td><td>' + income.total.format_price() + '</td></tr>');
                }

                var tfoot = summary_modal.find('tfoot');
                tfoot.empty();
                tfoot.append('<tr><td>Total</td><td>' + data.summary.total.format_price() + '</td></tr>');
                for (type of data.summary.total_grouped) {
                    if (type.total !== 0) {
                        tfoot.append('<tr><td>' + escape_str(type.payment_type) + '</td><td>' + type.total.format_price() + '</td></tr>');
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

        let contents = $('#cashupSummaryModal .modal-body').html();
        let win = window.open('','');
        win.document.write(`
            <style>
                table {
                    background-color: #FFFFFF;
                    border-bottom: 1px solid #CCCCCC;
                    border-collapse: collapse;
                    border-left: 1px solid #CCCCCC;
                    margin: 3px 0 5px 0;
                    padding: 0;
                    width: 99%;
                }

                td {
                    background-color: #FFF;
                    border-bottom: 1px solid #CCCCCC;
                    border-left: 0;
                    border-right: 1px solid #CCCCCC;
                    border-top: 0;
                    font-size: 12px;
                    padding: 5px 5px 5px 5px;
                }

                th {
                    background-color: #E9E9E9;
                    border-bottom: 1px solid #CCCCCC;
                    border-left: 0;
                    border-right: 1px solid #CCCCCC;
                    border-top: 0;
                    font-size: 14px;
                    font-weight: bold;
                    padding: 5px 5px 5px 5px;
                    text-align: left;
                }
            </style>
        `)
        win.document.write( contents );
        win.print();
        win.close();
    });
});
