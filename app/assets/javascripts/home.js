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

        var clear_cookie = {
            init: function () {
                if ($('.apply-show').length < 1) {
                    $.cookie('lesson-selected', null, {path: '/'});
                }
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

        if ($('#comp-show').length > 0) {
            var space = $('#comp-show');
            var fold = space.find('.fold-head');
            fold.on('click', function () {
                $(this).siblings('.fold-body').toggleClass('active');
            });
        }

        if ($('#course_file_course_ware').length > 0) {
            $('#course_file_course_ware').off('change').on('change', function () {
                $('[for="course_file_course_ware"]').text('已选择文件').addClass('active');
            })
        }

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
            });
        }

        $('.school-tag').on('click', function (event) {
            event.preventDefault();
            school_handle();
        });

        $('.new-school').on('click', function (event) {
            event.preventDefault();
            school_handle();
        });


        $('#go-apply').on('click', function (event) {
                event.preventDefault();
                var cookie = $.cookie('lesson-selected');
                if (typeof cookie == 'string') {
                    console.log(cookie);
                    if (cookie == 'null' || cookie == '[]') {
                        alert_r('请先选择课程！');
                    } else {
                        window.location.href = '/courses/apply_show';
                    }
                } else {
                    alert_r('请先选择课程！');
                }
            }
        );

        $('.open-course-score').off('click').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            var space = _self.parents('tr');
            var list = space.find('.course-score-attrs-list');
            var ship_id = _self.attr('data-id');
            if (list.length > 0) {
                var attrs = list.find('.course-attr');
                var total = 0;
                $.each(attrs, function (k, v) {
                    var score = $(v).find('span').text();
                    $('#course-score').find('input[data-id="' + $(v).attr('data-id') + '"]').val(score);
                    if (!isNaN(score) && score != '') {
                        score = parseInt(score);
                        total += score;
                    }
                });
                $('#course-score').find('.total').text(total);
            }
            $('#course-score').modal('show');

            $('#course-score').find('.attr-input').on('keyup', function () {
                var total = 0;
                $.each($('#course-score').find('.attr-input'), function (k, v) {
                    var score = $(v).val();
                    if (!isNaN(score) && score != '') {
                        score = parseInt(score);
                        var max = parseInt($(v).attr('data-max'));
                        if (score >= max) {
                            score = max;
                            $(v).val(score);
                        }
                        total += score;
                    }
                });
                $('#course-score').find('.total').text(total);
            });

            $('#course-score').find('.btn-submit-course').off('click').on('click', {id: ship_id}, function (event) {
                event.preventDefault();

                var inputs = $('#course-score').find('.attr-input');
                var score_attrs = {};
                $.each(inputs, function (k, v) {
                    if (!isNaN($(v).val())) {
                        score_attrs[$(v).attr('data-id')] = $(v).val();
                    }
                });

                var data = {
                    course_ud: event.data.id
                };

                if (score_attrs['last_score']) {

                    data.last_score = score_attrs['last_score'];
                } else {
                    data.score_attrs = score_attrs;
                }

                var option = {
                    url: '/user/course_score',
                    dataType: 'json',
                    type: 'post',
                    data: data,
                    success: function (result) {
                        if (result[0]) {
                            alert_r(result[1], function () {
                                window.location.reload();
                            });
                        } else {
                            alert_r(result[1]);
                        }
                    }
                };

                ajax_handle(option);
            });
        });

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
                    alert_r('请填写正确的姓名！');
                    return;
                }
                var school = form.find('#school-id').val();
                var district = form.find('#district-id').val();
                if (!school) {
                    alert_r('请选择学校');
                    return;
                }
                var grade = form.find('#user-info-grade').val();
                if (grade == 0 || !grade) {
                    alert_r('请选择年级');
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
                            alert_r(result[1], function () {
                                window.location.reload();
                            });
                        } else {
                            alert_r(result[1]);
                        }
                    }
                };
                ajax_handle(option);
            });
        }

        if ($('.btn-confirm-apply').length > 0) {
            $('.btn-confirm-apply').on('click', function (event) {
                event.preventDefault();
                var form = $('#apply-lesson-form');
                var username = form.find('#user-info-username').val();
                var t = /[\u4e00-\u9fa5]{2,}/i;
                if (!t.test(username)) {
                    alert_r('请填写正确的姓名！');
                    return;
                }
                var school = form.find('#school-id').val();
                var district = form.find('#district-id').val();
                if (!school) {
                    alert_r('请选择学校');
                    return;
                }

                var grade = form.find('#user-info-grade').val();
                if (grade == 0 || !grade) {
                    alert_r('请选择年级');
                    return;
                }

                var c = $('.lesson-control');
                var cds = {};
                for (var i = 0; i < c.length; i++) {
                    var cd = $(c.get(i)).attr('data-course-id');
                    var name = $(c.get(i)).find('a').text().trim();
                    cds[cd] = name;
                }

                var option = {
                    url: '/courses/apply',
                    type: 'post',
                    data: {username: username, district: district, school: school, grade: grade, cds: cds},
                    dataType: 'json',
                    success: function (result) {
                        if (result[0]) {
                            alert_r(result[1], function () {
                                $.cookie('lesson-selected', null, {path: '/'});
                                window.location.href = '/user/apply';
                            });
                        } else {
                            alert_r(result[1]);
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
                                alert_r('该邮箱已被注册，请更换邮箱！');
                            }
                        }
                    };
                    ajax_handle(option)
                } else {
                    alert_r('请填写正确的邮箱');
                }
            })
        }

        lazyload.init();
        fix_height.init('#main');
        clear_cookie.init();

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

        if ($('.add-school').length > 0) {
            $('.add-school').off('click').on('click', function () {
                var dis = $('#district-select').val();
                console.log(dis);
                if (typeof dis != 'string' || dis.length < 1 || dis == '0' || dis == 0) {
                    alert_r('请选择区县！');
                } else {
                    $('#add-school').modal('show');
                }
            })
        }

        if ($('#demeanor-photo').length > 0) {
            var thumb = $('#demeanor-photo').find('.thumb');
            thumb.on('click', function (event) {
                event.preventDefault();
                var height = this.naturalHeight;
                var width = this.naturalWidth;
                for (var i = 1; i < 10; i += 0.01) {
                    if (height <= 550 && width <= 1000) {
                        var src = $(this).attr('src');
                        var win = $('#thumb-win');
                        var img = win.find('.inner-img');
                        img.height(height);
                        img.width(width);
                        lazyload.loading(img, src);
                        win.modal('show');
                        break;
                    }
                    height = height * (1.0 / i);
                    width = width * (1.0 / i);
                }
            });
        }
        if ($('#demeanor-video').length > 0) {
            var video = $('#demeanor-video').find('.video-tag');
            video.on('click', function (event) {
                event.preventDefault();
                var src = $(this).attr('data-video');
                $('#video-win').find('.audio-main').attr('src', src);
                $('#video-win').modal('show').off('hide.bs.modal').on('hide.bs.modal', function () {
                    $('#video-win').find('.audio-main').attr('src', '');
                });
            })
        }

        if ($('.btn-add-school').length > 0) {
            $('.btn-add-school').off('click').on('click', function (event) {
                event.preventDefault();
                var _self = $(this);
                var space = _self.parents('.school-modal-inner');
                var dis = $('#district-select').val();

                if (typeof dis != 'string' || dis.length < 1) {
                    alert_r('请选择区县！');
                    return;
                }
                var name = space.find('#add-school-input').val();
                if (typeof name != 'string' || name.length < 1) {
                    alert_r('请填写学校全称！');
                    return;
                }
                if (confirm('是否确认添加' + name + '学校?\n一旦添加学校则无法再次添加学校！\n必须等待管理员审核通过才可以继续添加！请慎重填写')) {
                    var option = {
                        url: '/user/add_school',
                        type: 'post',
                        dataType: 'json',
                        data: {district: dis, school: name},
                        success: function (data) {
                            if (data[0]) {
                                var p = $('.school-panel');
                                p.find('.selected-school').remove();
                                p.append('<span class="selected-school">' + name + '</span>');
                                p.find('.choice-school').text('更改学校');
                                $('#user-info-school').val(data[2]);
                                $('#add-school').modal('hide');
                            } else {
                                alert_r(data[1])
                            }
                        }
                    };
                    ajax_handle(option);
                }
            });
        }

        $('.gender-label').find('input[type="radio"]').on('click', function (event) {
            if ($(this).prop('checked') == true) {
                $('#gender').val($(this).val());
            }
        });

        $('.accept-invite-submit').on('click', function (event) {
            event.preventDefault();
            var username = $('#username-join').val();
            var gender = $('#gender').val();
            var district_id = $('#district-id').val();
            var school_id = $('#school-id').val();
            var birthday = $('#birthday-join').val();
            var identity_card = $('#identity_card-join').val();
            var grade = $('#grade-join').val();
            var student_code = $('#student_code-join').val();
            var td = $('#team-id').val();
            var ed = $('#event-id').val();

            $.ajax({
                url: '/competitions/player_agree_leader_invite',
                type: 'post',
                data: {
                    "username": username,
                    "gender": gender,
                    "district": district_id,
                    "school": school_id,
                    "birthday": birthday,
                    "identity_card": identity_card,
                    "grade": grade,
                    "student_code": student_code,
                    "td": td,
                    "ed": ed
                },
                success: function (data) {
                    if (data[0]) {
                        $('#update-user-info').modal('hide');
                        alert_r(data[1],function(){
                            window.location.reload();
                        });
                    } else {
                        alert_r(data[1]);
                    }
                }
            });
        });

        if ($('[data-lesson-cookie="true"]').length > 0) {
            var cookie = $.cookie('lesson-selected');
            if (cookie != undefined && cookie != '[]' && cookie != null) {
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
                            alert_r(data[1]);
                            if (_self.parents('.sub-content').find('.lesson-item').length == 1) {
                                _self.parents('.sub-content').text('您暂时没有报名任何课程。');
                            }
                            _self.parents('.lesson-item').remove();
                        } else {
                            alert_r(data[1])
                        }
                    },
                    complete: function () {

                    },
                    error: function () {
                        alert_r('ajax error');
                    }
                };
                ajax_handle(option);
            });
        }

        $('.btn-accept-invite').on('click', function () {
            $('#accept-invite').removeClass('hide');
        });

        function school_handle(dis) {
            var _modals = $('#school-modal');
            _modals.modal('show');
            get_district();
        }

        function get_district() {
            var option = {
                url: '/user/get_districts',
                type: 'get',
                success: function (result) {
                    if (result.length > 0) {
                        get_district_success(result);
                    } else {
                        alert_r('区县载入出错');
                        $('#district-select').empty();
                    }
                }
            };
            ajax_handle(option);
        }

        function get_school(dis) {
            var option = {
                url: '/user/get_schools',
                type: 'get',
                dataType: 'json',
                data: {district_id: dis},
                success: function (result) {
                    if (result.length > 0) {
                        get_school_success(result, dis);
                    } else {
                        alert_r('未找到合适条件的学校');
                        $('.school-list').empty();
                    }
                },
                complete: function () {

                },
                error: function (error) {
                    alert_r(error.responseText);
                }
            };
            ajax_handle(option);
        }

        function get_school_success(result, dis) {
            var s = $('.school-list');
            s.empty();
            for (var i = 0; i < result.length; i++) {
                var bean = $('<div class="item school-bean" data-id="' + result[i].id + '">' + result[i].name + '</div>');
                s.append(bean);
            }
            $('.school-bean').on('click', {dis: dis}, function (event) {
                event.preventDefault();
                var data = event.data;
                var _self = $(this);
                var text = _self.text();
                var sid = _self.attr('data-id');
                var dis = data.dis;
                $('#district-id').val(dis);
                $('#school-id').val(sid);
                var tag = $('.school-field').find('.school-tag');
                if (tag.length > 0) {
                    tag.text(text);
                } else {
                    $('.school-field').empty().append('<span class="change-school school-tag">' + text + '</span>');
                    $('.school-tag').off('click').on('click', function (event) {
                        event.preventDefault();
                        school_handle();
                    })
                }
                $('#school-modal').modal('hide');
                $('.school-list').empty();
            });
        }

        function get_district_success(result) {
            var s = $('#district-select');
            s.empty();
            s.append('<option value="0">请选择区县</option>');
            for (var i = 0; i < result.length; i++) {
                var option = $('<option value="' + result[i].id + '">' + result[i].name + '</option>');
                s.append(option);
            }
            s.on('change', function (event) {
                event.preventDefault();
                var dis = $(this).val();
                get_school(dis);
            });
        }


        function ajax_handle(option) {
            $.ajax(option);
        }
    }
);