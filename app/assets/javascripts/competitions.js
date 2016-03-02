// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
// 补全确认报名所需信息
var chinese = /^[\u4E00-\u9FA5]+$/; // 汉字
var z_s = /^[a-zA-Z0-9]+$/; // 字母数字
var pd_exp = /^[\x21-\x7e]+$/; //数字、字母、特殊字符
var email_exp = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})+$/;
$('.update-apply-info-submit').on('click', function (event) {
    event.preventDefault();
    var username = trim($('#username').val());
    var school = trim($('#school').val());
    var grade = trim($('#grade').val());

    if ((username.length > 4) || (username.length < 2)) {
        alert('请输入2-4位的真实姓名');
        $("#username").focus();
        return false;
    }
    //if (age) {
    //    alert('请正确输入年龄');
    //    $("#age").focus();
    //    return false;
    //}
    if (school == '') {
        alert('学校不能为空');
        $("#school").focus();
        return false;
    }
    if (grade == '') {
        alert('年级不能为空');
        $("#grade").focus();
        return false;
    }
    $.ajax({
        url: '/competitions/update_apply_info',
        type: 'post',
        data: {"username": username, "school": school, "grade": grade},
        success: function (data) {
            if (data[0]) {
                alert(data[1]);
                $('.update-user-profile').addClass('hide');
                $('.create-team-show').removeClass('hide');
            } else {
                alert(data[1]);
            }
        }
    });
});


// 队长创建队伍
// 队伍名称（2-5），教师名称（2-4）只能为汉字，秘钥（4-6），只能为数字和字母
$('.leader-create-team-submit').on('click', function (event) {
    event.preventDefault();
    var team_name = trim($('#team-name').val());
    var team_teacher = trim($('#team-teacher').val());
    var team_code = trim($('#team-code').val());
    var team_event = $(this).attr('data-id');
    var team_district = $("#team-district").val();

    if ((team_name.length > 5) || (team_name.length < 2) || !chinese.test(team_name)) {
        alert('请输入2-5位的中文队伍名称');
        $("#team-name").focus();
        return false;
    }

    if (team_teacher.length > 4 || team_teacher.length < 2 || !chinese.test(team_teacher)) {
        alert('请输入2-4位的中文教师名称');
        $("#team-teacher").focus();
        return false;
    }
    if (team_district == '') {
        alert('请选择队伍所属区县');
        $("#team-district").focus();
        return false;
    }
    if (team_code.length > 4 || team_code.length < 2 || !z_s.test(team_code)) {
        alert('请输入4-6位包含数字或字母的队伍秘钥');
        $("#team-code").focus();
        return false;
    }
    $.ajax({
        url: '/competitions/leader_create_team',
        type: 'post',
        data: {
            "team_name": team_name,
            "team_teacher": team_teacher,
            "team_code": team_code,
            "team_event": team_event,
            "team_district": team_district
        },
        success: function (data) {
            if (data[0]) {
                alert(data[1]);
                window.location.reload();
            } else {
                alert(data[1]);
            }
        }
    });
});

//删除两边空格
function trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}