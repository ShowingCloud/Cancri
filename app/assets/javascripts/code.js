// 点击接受邀请出现确认或更新报名信息
$('.agree-leader-invite').on('click', function () {
    $('.add-agree-invited-info').removeClass('hide');
});
// 提交接受邀请报名信息
$('.agree-invited-info-submit').click(function () {
    var username = trim($('#username').val());
    var school = trim($('#school').val());
    var grade = trim($('#grade').val());
    var ed = $(this).attr('data-name');
    var td = $(this).attr('data-id');
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
    //if (email_exp.test(invited_email)) {
    $.ajax({
        url: '/user/agree_invite_info',
        type: 'post',
        data: {
            "username": username, "school": school, "grade": grade, "td": td, "ed": ed
        },
        success: function (data) {
            alert(data[1]);

        },
        error: function (data) {
            alert(data[1]);
        }
    });

    //} else {
    //    alert("邮箱格式不正确");
    //}
});

$('.invite-player-submit').click(function () {
    var invited_email = $('#invited-email').val();
    var event_name = $(this).attr('data-event');
    var td = $(this).attr('data-name');
    var ed = $(this).attr('data-id');
    var team_name = $('.leader-team').text();
    if (email_exp.test(invited_email)) {
        $.ajax({
            url: '/competitions/leader_invite_player',
            type: 'post',
            data: {
                "invited_email": invited_email, "event_name": event_name, "team_name": team_name, "td": td, "ed": ed
            },
            success: function (data) {
                alert(data[1]);
            },
            error: function (data) {
                alert(data[1]);
            }
        });

    } else {
        alert("邮箱格式不正确");
    }
});

$('#btn_send_mobile_code').click(function () {
    var mobile, captcha, mobile_number, self;
    self = $(this);
    if (is_sending) {
        return;
    }
    mobile = $('#' + self.attr('data-key') + '_mobile');
    captcha = $('.ru_captcha').val();
    mobile_number = mobile.val();
    if (mobile_number === '' || mobile_number.length !== 11 || isNaN(mobile_number)) {
        alert('手机号码格式不正确');
        mobile.focus();
        return;
    }
    if (captcha == '' || captcha == null) {
        alert('请输入校验码');
        $('input[name="_rucaptcha"]').focus();
        return;
    } else {

        $.ajax({
            url: '/accounts/validate_captcha',
            type: 'POST',
            data: {"_rucaptcha": captcha},
            success: function (data) {

                if (data[0]) {
                    self.blur();
                    is_sending = true;
                    self.text('发送中...').addClass('disabled');
                    return $.ajax({
                        url: '/accounts/send_code',
                        type: 'POST',
                        data: {
                            "mobile": mobile_number,
                            "type": self.attr('data-type'),
                            "ip": 'ip_address'
                        },
                        success: function (data) {
                            return alert(data[1]);
                        },
                        error: function (data) {
                            return alert(data[1]);
                        },
                        complete: function () {
                            is_sending = false;
                            return self.text('获取验证码').removeClass('disabled');
                        }
                    });
                } else {
                    alert(data[1]);
                }
            }

        });
    }

});
// 密码失去焦点判断字符
$('#reset_password_password').blur(function () {
    var password = trim($('#reset_password_password').val());
    if (!pd_exp.test(password) || password.length > 30 || password.length < 6) {
        alert('密码只能为6-30位 可含数字、字母、特殊字符');

    }
});

$('.refresh-captcha').on('click', function () {
    var src = $("img.rucaptcha-image").attr('src');
    $('.refresh-captcha').find('img').attr('src', src.split('cha/')[0] + 'cha/?' + (new Date()).getTime());
});

var is_sending = false;
$('.user-add-email').on('click', function () {
    var self = $(this);
    if (is_sending) {
        return
    }
    var email = $('.email-value').val();
    var email_exp = /^(\w-*\.*)+@(\w-?)+(\.\w{2,})+$/;
    if (email_exp.test(email)) {
        is_sending = true;
        self.text('发送中...').addClass('disabled');
        $.ajax({
            url: '/user/send_email_code',
            type: 'post',
            data: {
                "email": email
            },
            success: function (data) {
                if (data[0]) {
                    alert(data[1]);
                } else {
                    alert(data[1]);
                }
            },
            error: function (data) {
                alert('发送失败');
            },
            complete: function () {
                is_sending = false;
                self.text('获取验证码').removeClass('disabled');
            }
        });
    } else {
        alert("邮箱格式不正确");
    }
});

$('.user-add-mobile').on('click', function () {
    var mobile = $('.mobile-value').val();
    var mobile_exp = /^1[34578][0-9]{9}$/;
    if (mobile_exp.test(mobile)) {
        $.ajax({
            url: '/user/send_add_mobile_code',
            type: 'post',
            data: {
                "mobile": mobile
            },
            success: function (data) {
                alert(data[1]);
            },
            error: function (data) {
                alert(data[1]);
            }
        });
    } else {
        alert("手机格式不正确");
    }
});

$('.show-update-mobile').on('click', function () {
    $(".update-user-mobile").slideToggle();
});