$('.refresh-captcha').on('click', function () {
    var src = $("img[alt='rucaptcha']").attr('src');
    $('.refresh-captcha').find('img').attr('src', src.split('cha/')[0] + 'cha/?' + (new Date()).getTime());
});