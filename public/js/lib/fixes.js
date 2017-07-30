// Opal JSON fix
JSON.parseOrig = JSON.parse;
JSON.parse = function () {
    try {
        return JSON.parseOrig.apply(this, arguments);
    } catch (e) {
        return {success: false, message: 'Bad JSON'};
    }
};