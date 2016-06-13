/**
 * Created by huaxiukun on 16/5/31.
 */
//删除两边空格
function trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}
$('#select-area').on('change', function () {
    var area = $('.select-area').val();
    if (area == 1) {
        setCookie('area', 1);
    } else {
        setCookie('area', 0);
    }
    alert($.cookie('area'));
    window.location.reload();
});

function setCookie(key, value) {
    document.cookie = key + "=" + value
}