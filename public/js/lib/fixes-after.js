// Opal reCaptcha integration
$(function () {
    var captcha = $('#g-recaptcha');
    var opalArrayPrototypeSafe = {};

    captcha.mouseenter(function () {
        clearArrayPrototypeForRecaptcha();
    });

    captcha.mouseleave(function () {
        restoreArrayPrototypeForRecaptcha();
    });

    function clearArrayPrototypeForRecaptcha () {
        for (let key in Array.prototype) {
            if (key[0] == '$') {
                opalArrayPrototypeSafe[key] = Array.prototype[key];
                delete Array.prototype[key];
            }
        }
    }

    function restoreArrayPrototypeForRecaptcha () {
        for (let key in opalArrayPrototypeSafe) {
            Array.prototype[key] = opalArrayPrototypeSafe[key];
        }
    }
});