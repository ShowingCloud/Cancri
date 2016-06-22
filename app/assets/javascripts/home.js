$(function () {
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
                    if (jqObj.hasClass('main')) {
                        if ($.cookie('area') == 1) {
                            src = $('#bs-pg').attr('data-bk');
                        }
                    }
                    jqObj.css({"background-image": "url(" + src + ")"});//lazy load
                }
            });
        }
    };

    var fix_height = {
        init: function (selector) {
            var max = document.body.clientHeight;
            var screen = window.innerHeight;
            if (screen > max) {
                $(selector).css({'min-height': screen - 134});
            }
        }
    };

    if ($('.go-apply').length > 0) {
        $('.go-apply').off('click').on('click', function (event) {
            event.preventDefault();
            $('.apply').addClass('active');
        });
    }

    if ($('.choice-school').length > 0) {
        $('.choice-school').off('click').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            var dis = _self.parents('form').find('#district-select').val();
            school_handle(_self, dis, function (text, id) {
                _self.parent().find('.selected-school').remove();
                _self.parent().append('<span class="selected-school">' + text + '</span>');
                _self.text('更改学校');
                _self.parents('form').find('#user-info-school').val(id);
                _self.parents('form').find('#user_profile_school_id').val(id);
            });
        })
    }

    if ($('#user_profile_birthday').length > 0) {
        $('#user_profile_birthday').datepicker({
            format: 'yyyy-mm-dd'
        });
    }

    if ($('.apply-lesson').length > 0) {
        $('.apply-lesson').off('click').on('click', function (event) {
            event.preventDefault();
            var form = $(this).parents('form');
            var username = form.find('#user-info-username').val();
            var t = /[\u4e00-\u9fa5]{2,}/i;
            if (!t.test(username)) {
                alert('请填写正确的姓名！');
                return;
            }
            var district = form.find('#district-select').val();
            if (district == 0 || !district) {
                alert('请选择区县！');
                return;
            }

            var school = form.find('#user-info-school').val();
            if (!school) {
                alert('请选择学校');
                return;
            }

            var grade = form.find('#user-info-grade').val();
            if (grade == 0 || !grade) {
                alert('请选择年级');
                return;
            }

            var cd = $('#lesson-id').attr('data-id');

            var option = {
                url: '/courses/apply',
                type: 'post',
                data: {username: username, district: district, school: school, grade: grade, cd: cd},
                dataType: 'json',
                success: function (result) {
                    if (result[0]) {
                        alert(result[1]);
                        window.location.reload();
                    } else {
                        alert(result[1]);
                    }
                }
            };

            ajax_handle(option);
        });
    }


    lazyload.init();
    fix_height.init('#main');

    $(window).on('resize',function(){
        fix_height.init('#main');
    });

    $('select[data-target]').off('change').on('change', function () {
        var _self = $(this);
        $(_self.attr('data-target')).val(_self.val());
    });

    $('select#user_profile_grade').off('change').on('change', function () {
        var _self = $(this);
        if (_self.val() > 9) {
            $('.user_profile_identity_card').addClass('active');
        } else {
            $('.user_profile_identity_card').removeClass('active');
        }
    });

    $('.fieldset-label>input').on('change', function () {
        var text = $(this).parent().text().trim();
        var index = $(this).prop('checked');
        if (!index) {
            if (text == '教师') {
                $('.teacher-part').addClass('hide');
            } else if (text == '家庭创客') {
                $('.ck-part').addClass('hide');
            }
        } else {
            if (text == '教师') {
                $('.teacher-part').removeClass('hide');
            } else if (text == '家庭创客') {
                $('.ck-part').removeClass('hide');
            }
        }
    });

    $('.change-avatar').on('click', function () {
        $('#change-avatar').modal('show');
    });

    $('.un-do').on('click', function (event) {
        event.preventDefault();
        alert_r('功能开发中，敬请期待！');
    });

    if ($('.error-notice').length > 0) {
        alert_r($('.error-notice').text());
    }


    function school_handle(_target, dis, cb) {
        var _modals = $('#school-modal');
        _modals.find('#selected-dis').val(dis);
        _modals.modal('show');
        _modals.find('#school-group').off('change').on('change', function (event) {
            event.preventDefault();
            var _dis = _modals.find('#selected-dis').val();
            var _group = $(this).val();
            var option = {
                url: '/user/get_school',
                type: 'get',
                dataType: 'json',
                data: {district_id: _dis, school_type: _group},
                success: function (result) {
                    var _cb = cb;
                    if (result.length > 0) {
                        $('.school-list').empty();
                        for (var i = 0; i < result.length; i++) {
                            var bean = $('<div class="item school-bean" data-id="' + result[i].id + '">' + result[i].name + '</div>');
                            $('.school-list').append(bean);
                        }
                        $('.school-bean').off('click').on('click', function (event) {
                            event.preventDefault();
                            var _self = $(this);
                            var text = _self.text();
                            var sid = _self.attr('data-id');
                            $('#school-modal').modal('hide');
                            cb(text, sid);
                        });
                    } else {
                        alert('未找到合适条件的学校');
                    }
                },
                complete: function () {

                },
                error: function (error) {
                    alert(error.responseText);
                }
            };
            ajax_handle(option)
        });
    }


    function ajax_handle(option) {
        $.ajax(option);
    }
});