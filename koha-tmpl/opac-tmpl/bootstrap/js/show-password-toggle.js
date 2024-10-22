document.addEventListener("DOMContentLoaded", function() {
    const local_logins = document.querySelectorAll('.local-login');
    local_logins.forEach( (local_login) => {
        const password_field = local_login.querySelector('#password,#mpassword');
        const toggle_box = local_login.querySelector('input.show-password-toggle-checkbox');
        if (password_field && toggle_box){
            toggle_box.addEventListener('click',function(ev){
                if (password_field.type === 'password'){
                    password_field.type = 'text';
                }
                else {
                    password_field.type = 'password';
                }
            });
        }
    });
});
