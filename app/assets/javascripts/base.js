/**
 * Created by yaolin on 16/4/5.
 */
$(function () {
    var action = function () {
        lazyload.init();
        rucaptcha.init();
        authenticity_token.init();
    };

    var lazyload = {
        init: function () {
            var tag = $('[data-src]');
            var default_src = '';
            $.each(tag, function (k, v) {
                var $self = $(v);
                if ($self[0].tagName === 'IMG') {
                    $self.attr({src: default_src});
                } else {
                    $self.css({"background-image": "url(" + default_src + ")"});//default image
                }
                lazyload.loading($self, $self.attr('data-src'));
            });
        },
        loading: function (jqObj, src) {
            var img = new Image();
            img.src = src;
            $(img).on('load', function () {
                if (jqObj[0].tagName === 'IMG') {
                    jqObj.attr({src: src});
                } else {
                    jqObj.css({"background-image": "url(" + src + ")"});//lazy load
                }
            });
        }
    };

    var rucaptcha = {
        init: function () {
            var r = $('[name="_rucaptcha"]');
            if (r) {
                //r.on('focus', function () {
                //    $('.rucaptcha-image').css({'display': 'inline'});
                //});
                //r.on('blur', function () {
                //    $('.rucaptcha-image').css({'display': 'none'});
                //});
            }
        }
    };

    var authenticity_token = {
        init: function () {
            var a = $('[name="authenticity_token"]');
            if (a) {
                a.attr({'value': $('meta[name="csrf-token"]').attr('content')});
            }
        }
    };


    action();

});