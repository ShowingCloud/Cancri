$('.refresh-captcha').on('click', function () {
    var src = $("img[alt='rucaptcha']").attr('src');
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
                alert(data[1]);
            },
            error: function (data) {
                alert(data[1]);
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