const win = global.window;
const doc = win.document;
const dpr = win.devicePixelRatio || 1;
const create = name => doc.createElement(name);
const get_attr = (el, key) => el.getAttribute(key);
const set_attr = (el, key, value) => el.setAttribute(key, value);

const create_canvas = (size, ratio) => {
    const canvas = create('canvas');
    set_attr(canvas, 'width', size * ratio);
    set_attr(canvas, 'height', size * ratio);
    canvas.style.width = `${size}px`;
    canvas.style.height = `${size}px`;
    return canvas;
};

const canvas_to_img = canvas => {
    const img = create('img');
    set_attr(img, 'crossorigin', 'anonymous');
    set_attr(img, 'src', canvas.toDataURL('image/png'));
    set_attr(img, 'width', get_attr(canvas, 'width'));
    set_attr(img, 'height', get_attr(canvas, 'height'));
    img.style.width = canvas.style.width;
    img.style.height = canvas.style.height;
    return img;
};

module.exports = {
    create_canvas,
    canvas_to_img,
    dpr
};
