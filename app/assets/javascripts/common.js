/**
 * Created by huaxiukun on 16/5/31.
 */
//删除两边空格
function trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}
// change bs set cookie = 1
$('#select-area').on('change', function () {
    var area = $('#select-area').val();
    if (area == 1) {
        setCookie('area', area, '/');
    } else {
        $.removeCookie('area', {path: '/'});
    }
    window.location.reload();
});

function setCookie(key, value, path) {
    $.cookie(key, value, {path: path});
}