const wrap_ctx = ctx => {
    return {
        c: ctx,
        m(...args) {this.c.moveTo(...args); return this;},
        l(...args) {this.c.lineTo(...args); return this;},
        a(...args) {this.c.arcTo(...args); return this;}
    };
};

const draw_dark = (ctx, l, t, r, b, rad, nw, ne, se, sw) => {
    if (nw) {
        ctx.m(l + rad, t);
    } else {
        ctx.m(l, t);
    }

    if (ne) {
        ctx.l(r - rad, t).a(r, t, r, b, rad);
    } else {
        ctx.l(r, t);
    }

    if (se) {
        ctx.l(r, b - rad).a(r, b, l, b, rad);
    } else {
        ctx.l(r, b);
    }

    if (sw) {
        ctx.l(l + rad, b).a(l, b, l, t, rad);
    } else {
        ctx.l(l, b);
    }

    if (nw) {
        ctx.l(l, t + rad).a(l, t, r, t, rad);
    } else {
        ctx.l(l, t);
    }
};

const draw_light = (ctx, l, t, r, b, rad, nw, ne, se, sw) => {
    if (nw) {
        ctx.m(l + rad, t).l(l, t).l(l, t + rad).a(l, t, l + rad, t, rad);
    }

    if (ne) {
        ctx.m(r - rad, t).l(r, t).l(r, t + rad).a(r, t, r - rad, t, rad);
    }

    if (se) {
        ctx.m(r - rad, b).l(r, b).l(r, b - rad).a(r, b, r - rad, b, rad);
    }

    if (sw) {
        ctx.m(l + rad, b).l(l, b).l(l, b - rad).a(l, b, l + rad, b, rad);
    }
};

const draw_mod = (qr, ctx, settings, width, row, col) => {
    const left = col * width;
    const top = row * width;
    const right = left + width;
    const bottom = top + width;
    const radius = settings.rounded * 0.005 * width;

    const isDark = qr.isDark;
    const rowT = row - 1;
    const rowB = row + 1;
    const colL = col - 1;
    const colR = col + 1;
    const dC = isDark(row, col);
    const dNW = isDark(rowT, colL);
    const dN = isDark(rowT, col);
    const dNE = isDark(rowT, colR);
    const dE = isDark(row, colR);
    const dSE = isDark(rowB, colR);
    const dS = isDark(rowB, col);
    const dSW = isDark(rowB, colL);
    const dW = isDark(row, colL);

    ctx = wrap_ctx(ctx);

    if (dC) {
        draw_dark(ctx, left, top, right, bottom, radius, !dN && !dW, !dN && !dE, !dS && !dE, !dS && !dW);
    } else {
        draw_light(ctx, left, top, right, bottom, radius, dN && dW && dNW, dN && dE && dNE, dS && dE && dSE, dS && dW && dSW);
    }
};

module.exports = draw_mod;
