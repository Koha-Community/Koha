$(document).ready(function () {
    function modalPrint() {
        let title = $(".modal-dialog.focused .modal-title").html();
        let contents = $(".modal-dialog.focused .modal-body").html();
        let win = window.open("", "");
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
        `);
        win.document.write(title);
        win.document.write(contents);
        win.print();
        win.close();
    }

    // Set focused on printable modals on open and autoprint if required
    $(".modal.printable")
        .on("shown.bs.modal", function () {
            $(".modal-dialog", this).addClass("focused");

            if ($(this).hasClass("autoprint")) {
                modalPrint();
            }
        })
        .on("hidden.bs.modal", function () {
            $(".modal-dialog", this).removeClass("focused");
        });

    // Trigger print on button click
    $(".printModal").click(function () {
        modalPrint();
    });
});
