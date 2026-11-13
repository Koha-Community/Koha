// Helpers to print, copy or download a small table of values: the contents
// of a bundle, the items found missing from it.

/**
 * Open a printable page with a title and a table, and print it. Must be
 * called from a click handler, so the browser allows the new window.
 *
 * @param {Object} params
 * @param {string} params.title
 * @param {string[]} params.headers
 * @param {string[][]} params.rows
 * @returns {boolean} false if the window could not be opened
 */
export function printTable({ title, headers, rows }) {
    const win = window.open("", "_blank");
    if (!win) return false;
    const doc = win.document;
    doc.title = title;

    const style = doc.createElement("style");
    style.textContent =
        "body{font-family:sans-serif}h1{font-size:18px}" +
        "table{border-collapse:collapse;width:100%}" +
        "th,td{border:1px solid #999;padding:4px 8px;text-align:left}";
    doc.head.appendChild(style);

    const heading = doc.createElement("h1");
    heading.textContent = title;
    const table = doc.createElement("table");
    const headRow = doc.createElement("tr");
    headers.forEach(h => {
        const th = doc.createElement("th");
        th.textContent = h;
        headRow.appendChild(th);
    });
    const thead = doc.createElement("thead");
    thead.appendChild(headRow);
    const tbody = doc.createElement("tbody");
    rows.forEach(row => {
        const tr = doc.createElement("tr");
        row.forEach(cell => {
            const td = doc.createElement("td");
            td.textContent = String(cell ?? "");
            tr.appendChild(td);
        });
        tbody.appendChild(tr);
    });
    table.append(thead, tbody);
    doc.body.append(heading, table);

    win.focus();
    win.print();
    return true;
}

const csvCell = value => `"${String(value ?? "").replace(/"/g, '""')}"`;

/**
 * @returns {string} the table as CSV
 */
export function toCsv(headers, rows) {
    return [headers, ...rows].map(row => row.map(csvCell).join(",")).join("\n");
}

/**
 * @returns {string} the table as tab separated text, for the clipboard
 */
export function toTsv(headers, rows) {
    return [headers, ...rows]
        .map(row =>
            row.map(cell => String(cell ?? "").replace(/[\t\r\n]+/g, " "))
        )
        .map(row => row.join("\t"))
        .join("\n");
}

/**
 * Download the table as a CSV file.
 */
export function downloadCsv(filename, headers, rows) {
    const blob = new Blob([toCsv(headers, rows)], {
        type: "text/csv;charset=utf-8",
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
}

/**
 * Copy the table to the clipboard, as tab separated text.
 *
 * @returns {Promise<boolean>}
 */
export async function copyTable(headers, rows) {
    try {
        await navigator.clipboard.writeText(toTsv(headers, rows));
        return true;
    } catch {
        return false;
    }
}
