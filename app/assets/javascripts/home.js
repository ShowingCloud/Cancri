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

        if ($('.apply-cancel').length > 0) {
            $('.apply-cancel').off('click').on('click', function () {
                event.preventDefault();
                $('.apply').removeClass('active');
            })
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

        if ($('#district-select').length > 0) {
            $('#district-select').off('change').on('change', function () {
                var _self = $(this);
                var space = _self.parents('form');
                var selected_school = _self.parents('form').find('.school-hidden-input').val();
                if (typeof selected_school == 'string' && selected_school.length > 0) {
                    alert('由于您更换了区县，请重新选择学校！');
                    space.find('.selected-school').remove();
                    space.find('.school-hidden-input').val(null);
                    space.find('.choice-school').text('选择学校');
                }
                $('#school-group').val(0);
                $('.school-list').empty();
                if (typeof _self.attr('data-target-special') != 'undefined') {
                    $(_self.attr('data-target-special')).val(_self.val());
                }
            });
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
                var name = $('#lesson-id').text().trim();

                var cds = {};
                cds[cd] = name;

                var option = {
                    url: '/courses/apply',
                    type: 'post',
                    data: {username: username, district: district, school: school, grade: grade, cds: cds},
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

        if ($('.btn-confirm-apply').length > 0) {
            $('.btn-confirm-apply').on('click', function () {
                event.preventDefault();
                var form = $('#apply-lesson-form');
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

                var c = $('.lesson-control');
                var cds = {};
                for (var i = 0; i < c.length; i++) {
                    var cd = $(c.get(i)).attr('data-course-id');
                    var name = $(c.get(i)).find('a').text().trim();
                    cds[cd] = name;
                }

                console.log(cds);

                var option = {
                    url: '/courses/apply',
                    type: 'post',
                    data: {username: username, district: district, school: school, grade: grade, cds: cds},
                    dataType: 'json',
                    success: function (result) {
                        if (result[0]) {
                            alert(result[1]);
                            $.cookie('lesson-selected', null, {path: '/'});
                            window.location.href = '/user/apply';
                        } else {
                            alert(result[1]);
                        }
                    }
                };
                ajax_handle(option);
            })
        }

        if ($('#register-email').length > 0) {
            $('#register-email').on('blur', function () {
                var $this = $(this);
                var em = $this.val();
                var reg = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i;
                if (reg.test(em)) {
                    var option = {
                        url: '/accounts/register_email_exists',
                        type: 'post',
                        data: {email: em},
                        success: function (result) {
                            if (result) {
                                alert('该邮箱已被注册，请更换邮箱！');
                            }
                        }
                    };
                    ajax_handle(option)
                } else {
                    alert('请填写正确的邮箱');
                }
            })
        }

        lazyload.init();
        fix_height.init('#main');

        $(window).on('resize', function () {
            fix_height.init('#main');
        });


        $('.lesson').find('.lesson-item').on('click', function () {

            var $this = $(this);

            if (!$this.hasClass('overtime') && !$this.hasClass('disable')) {
                $this.toggleClass('selected');
                var lessons = [];
                var length = $('.lesson-item.selected').length;
                for (var i = 0; i < length; i++) {
                    var v = $('.lesson-item.selected').get(i);
                    var l = {};
                    l.id = $(v).attr('data-course-id');
                    l.name = $(v).find('.title').text().trim();
                    lessons.push(l);
                }
                var json_lessons = JSON.stringify(lessons);
                $.cookie('lesson-selected', json_lessons, {path: '/'});
            }
        });

        if ($('[data-lesson-cookie="true"]').length > 0) {
            var cookie = $.cookie('lesson-selected');
            if (cookie != undefined && cookie != '{}' && cookie != null) {
                var lessons = JSON.parse(cookie);
                $.each(lessons, function (k, v) {
                    var div = $('<div class="lesson-control" data-course-id="' + v.id + '">' +
                    '<a href="/courses/' + v.id + '">' + v.name + '</a>' +
                    '<i class="glyphicon glyphicon-remove-circle remove-lesson"></i>' +
                    '</div>');
                    $('.apply-lessons').find('.content').append(div);
                    div.find('.remove-lesson').on('click', function (event) {
                        event.preventDefault();
                        var _self = $(this);
                        if ($('.remove-lesson').length == 1) {
                            alert_r('课程无法删除');
                        } else {
                            if (confirm('是否删除课程：' + _self.parent().find('a').text().trim())) {
                                _self.parent().remove();
                                var lessons = [];
                                var length = $('.lesson-control').length;
                                for (var i = 0; i < length; i++) {
                                    var v = $('.lesson-control').get(i);
                                    var l = {};
                                    l.id = $(v).attr('data-course-id');
                                    l.name = $(v).find('a').text().trim();
                                    lessons.push(l);
                                }
                                var json_lessons = JSON.stringify(lessons);
                                $.cookie('lesson-selected', json_lessons, {path: '/'});
                            }
                        }
                    });
                });
            } else {
                alert_r('请先选择课程！');
            }
        }


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

        if ($('.btn-abort-lesson').length > 0) {
            $('.btn-abort-lesson').off('click').on('click', function (event) {
                event.preventDefault();
                var _self = $(this);
                var option = {
                    url: _self.attr('href'),
                    type: 'post',
                    dataType: 'json',
                    success: function (data) {
                        if (data[0]) {
                            alert(data[1]);
                            if (_self.parents('.sub-content').find('.lesson-item').length == 1) {
                                _self.parents('.sub-content').text('您暂时没有报名任何课程。');
                            }
                            _self.parents('.lesson-item').remove();

                        } else {
                            alert(data[1])
                        }
                    },
                    complete: function () {

                    },
                    error: function () {
                        alert('ajax error');
                    }
                };
                ajax_handle(option);
            });
        }


        function school_handle(_target, dis, cb) {
            var _modals = $('#school-modal');
            var d = _modals.find('#selected-dis');
            var g = _modals.find('#school-group');
            d.val(dis);
            _modals.modal('show');
            g.off('change').on('change', function (event) {
                event.preventDefault();
                var dis = _modals.find('#selected-dis').val();
                var group = $(this).val();
                if (group != 0) {
                    get_school(dis, group, cb);
                } else {
                    $('.school-list').empty();
                }
            });
            d.off('change').on('change', function (event) {
                event.preventDefault();
                var dis = $(this).val();
                var group = g.val();
                if (group != 0) {
                    get_school(dis, group, cb);
                } else {
                    $('.school-list').empty();
                }
                $('#district-select').val(dis);
            })
        }

        function get_school(dis, group, get_school_callback) {
            var option = {
                url: '/user/get_school',
                type: 'get',
                dataType: 'json',
                data: {district_id: dis, school_type: group},
                success: function (result) {
                    if (result.length > 0) {
                        get_school_success(result, get_school_callback);
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
            ajax_handle(option);
        }

        function get_school_success(result, get_school_success_callback) {
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
                get_school_success_callback(text, sid);
            });
        }


        function ajax_handle(option) {
            $.ajax(option);
        }
    }
)
;