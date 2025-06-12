const mysql = require("mysql2/promise");

const connectionConfig = {
    host: "db",
    user: "koha_kohadev",
    password: "password",
    database: "koha_kohadev",
};

async function query(sql, params = []) {
    const connection = await mysql.createConnection(connectionConfig);
    const [rows] = await connection.execute(sql, params);
    await connection.end();
    return rows;
}

module.exports = { query };
