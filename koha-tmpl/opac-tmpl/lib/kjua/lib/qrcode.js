const RE_CODE_LENGTH_OVERFLOW = /code length overflow/i;

const qr_gen = require('qrcode-generator');
qr_gen.stringToBytes = qr_gen.stringToBytesFuncs['UTF-8'];

const min_qrcode = (text, level, min_ver = 1) => {
    min_ver = Math.max(1, min_ver);

    for (let version = min_ver; version <= 40; version += 1) {
        try {
            const qr = qr_gen(version, level);
            qr.addData(text);
            qr.make();
            const moduleCount = qr.getModuleCount();
            const isDark = (row, col) => {
                return row >= 0 &&
                    row < moduleCount &&
                    col >= 0 &&
                    col < moduleCount &&
                    qr.isDark(row, col);
            };
            return {text, level, version, moduleCount, isDark};
        } catch (err) {
            if (!(version < 40 && RE_CODE_LENGTH_OVERFLOW.test(err))) {
                throw new Error(err);
            }
        }
    }
    return null;
};

const quiet_qrcode = (text = '', level = 'L', min_ver = 1, quiet = 0) => {
    const qr = min_qrcode(text, level, min_ver);
    if (qr) {
        const prev_is_dark = qr.isDark;
        qr.moduleCount += 2 * quiet;
        qr.isDark = (row, col) => prev_is_dark(row - quiet, col - quiet);
    }
    return qr;
};

module.exports = quiet_qrcode;
