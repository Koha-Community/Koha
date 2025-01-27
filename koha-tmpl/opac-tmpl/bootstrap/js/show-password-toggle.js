function create_show_password_toggle(loop_counter) {
    const container = document.createElement("div");
    container.className = "show-password-toggle";

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.className = "show-password-toggle-checkbox";
    checkbox.id = `show-password-toggle-checkbox-${loop_counter}`;

    const label = document.createElement("label");
    label.className = "show-password-toggle-label";
    label.htmlFor = checkbox.id;
    label.textContent = " " + __("Show password");

    container.appendChild(checkbox);
    container.appendChild(label);

    return container;
}

document.addEventListener("DOMContentLoaded", function () {
    const local_logins = document.querySelectorAll(".local-login");
    local_logins.forEach((local_login, i) => {
        let show_password_toggle_node = create_show_password_toggle(i);
        local_login
            .querySelector("input[type='password']")
            .after(show_password_toggle_node);
        const password_field = local_login.querySelector(
            "#password,#mpassword"
        );
        const toggle_box = local_login.querySelector(
            "input.show-password-toggle-checkbox"
        );
        if (password_field && toggle_box) {
            toggle_box.addEventListener("click", function (ev) {
                if (password_field.type === "password") {
                    password_field.type = "text";
                } else {
                    password_field.type = "password";
                }
            });
        }
    });
});
