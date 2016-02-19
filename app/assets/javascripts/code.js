$('.refresh-captcha').on('click', function () {
    var src = $("img[alt='rucaptcha']").attr('src');
    $('.refresh-captcha').find('img').attr('src', src.split('cha/')[0] + 'cha/?' + (new Date()).getTime());
});

$('.user-add-email').on('click', function () {
    var email = $('.email-value').val();
    var exp = /^(\w-*\.*)+@(\w-?)+(\.\w{2,})+$/;
    if (exp.test(email)) {
        //alert("邮箱格式不正确1214");
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
            }
        });
    } else {
        alert("邮箱格式不正确");
    }
});