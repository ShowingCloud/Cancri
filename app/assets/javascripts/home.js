$(function() {
    $(".btn-login-link,.btn-register-link").click(function() {
        $(".loading").removeClass('hidden');
    });

    $('#logout').on('confirm:complete', function(e, response) {
        $(".loading").removeClass('hidden');
    });
    var lazyload = {
        init: function() {
            var tag = $('[data-src]');
            var default_src = '';
            $.each(tag, function(k, v) {
                var $self = $(v);
                if ($self[0].tagName === 'IMG') {
                    $self.attr({
                        src: default_src
                    });
                } else {
                    $self.css({
                        // "background-image": "url(" + default_src + ")"
                        "background-image": ""
                    }); //default image
                }

                lazyload.loading($self, $self.attr('data-src'));
            });
        },
        loading: function(jqObj, src) {
            var img = new Image();
            img.src = src;
            $(img).on('load', function() {
                if (jqObj[0].tagName === 'IMG') {
                    jqObj.attr({
                        src: src
                    });
                } else {
                    if (jqObj.hasClass('main')) {
                        if ($.cookie('area') == 1) {
                            src = $('#bs-pg').attr('data-bk');
                        }
                    }
                    jqObj.css({
                        "background-image": "url(" + src + ")"
                    }); //lazy load
                }
            });
        }
    };

    var clear_cookie = {
        init: function() {
            if ($('.apply-show').length < 1) {
                $.cookie('lesson-selected', null, {
                    path: '/'
                });
            }
        }
    };

    var fix_height = {
        init: function(selector) {
            var max = document.body.clientHeight;
            var screen = window.innerHeight;
            if (screen > max) {
                $(selector).css({
                    'min-height': screen - 134
                });
            }
        }
    };

    if ($('#comp-show').length > 0) {
        var space = $('#comp-show');
        var fold = space.find('.fold-head');
        fold.on('click', function() {
            $(this).siblings('.fold-body').toggleClass('active');
        });
    }

    if ($('#course_file_course_ware').length > 0) {
        $('#course_file_course_ware').off('change').on('change', function() {
            $('[for="course_file_course_ware"]').text('已选择文件').addClass('active');
        })
    }

    if ($('.go-apply').length > 0) {
        $('.go-apply').off('click').on('click', function(event) {
            event.preventDefault();
            $('.apply').addClass('active');
        });
    }

    if ($('.apply-cancel').length > 0) {
        $('.apply-cancel').off('click').on('click', function() {
            event.preventDefault();
            $('.apply').removeClass('active');
        })
    }

    if ($('.choice-school').length > 0) {
        $('.choice-school').off('click').on('click', function(event) {
            event.preventDefault();
            var _self = $(this);
            var dis = _self.parents('form').find('#district-select').val();
            school_handle(_self, dis, function(text, id) {
                _self.parent().find('.selected-school').remove();
                _self.parent().append('<span class="selected-school">' + text + '</span>');
                _self.text('更改学校');
                _self.parents('form').find('#user-info-school').val(id);
                _self.parents('form').find('#user_profile_school_id').val(id);
            });
        });
    }

    $('.school-tag').on('click', function(event) {
        event.preventDefault();
        school_handle();
    });

    $('.new-school').on('click', function(event) {
        event.preventDefault();
        school_handle();
    });

    $("#user_profile_district_id").on('change', function () {
        var district_id = $(this).val();
        var school_district_id = document.getElementById("change_district_id").value;
        if (district_id != school_district_id) {
            $(".select-user-school").text('请选择学校');
            $("#user_profile_school_id").val(null).change();
        }
    });

    var cities_select = $("#select-city");
    var districts_select = $("#select-district");
    // province option change
    $('#select-province').on('change', function () {
        var province_id = $(this).val();
        if (province_id != '') {
            $.ajax({
                url: '/api/v1/districts/get_cities',
                type: 'get',
                data: {"province_id": province_id},
                success: function (data) {
                    var data_length = data.length;
                    cities_select.empty();
                    districts_select.empty();
                    districts_select.append($('<option value="">请先选择城市</option>'));
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择城市</option>');
                        cities_select.append(first_option);
                        $.each(data, function (k, v) {
                            var option = $('<option value="' + v.id + '">' + v.name + '</option>');
                            cities_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该省市暂无城市</option>');
                        cities_select.append(first_option);
                    }
                }
            });
        } else {
            alert_r(false, '省市不存在')
        }
    });


    // cities option change
    cities_select.on('change', function () {
        var city_id = $(this).val();
        if (city_id != '') {
            $.ajax({
                url: '/api/v1/districts/get_districts',
                type: 'get',
                data: {"city_id": city_id},
                success: function (data) {
                    var data_length = data.length;
                    districts_select.empty();
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择区县</option>');
                        districts_select.append(first_option);
                        $.each(data, function (k, v) {
                            var option = $('<option value="' + v.id + '" data-province="' + v.province_name + '" data-city="' + v.city_name + '">' + v.name + '</option>');
                            districts_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该城市暂无区县</option>');
                        districts_select.append(first_option);
                    }
                }
            });
        } else {
            alert_r(false, '城市不存在')
        }
    });

    // districts change
    districts_select.on('change', function () {
        var _self = $(this);
        var selected_district = _self.find("option:selected");
        var district_id = _self.val();
        //console.log("district_id:"+district_id);
        var province_name = selected_district.attr('data-province');
        var city_name = selected_district.attr('data-city');
        var district_name = selected_district.text();
        document.getElementById("user_profile_district_id").value = district_id;
        document.getElementById("change_district_id").value = district_id;
        $(".select-user-district").text(province_name + ' -- ' + city_name + ' -- ' + district_name);
        $("#select-district-modal").modal('hide');
            if (district_id) {
                $.ajax({
                    url: '/api/v1/schools/get_by_district',
                    type: 'get',
                    data: {"district_id": district_id},
                    success: function (data) {
                        var data_length = data.length;
                        var schools_select = $("#select-user-school");
                        schools_select.empty();
                        var first_option;
                        if (data_length > 0) {
                            first_option = $('<option value="">请选择学校</option>');
                            schools_select.append(first_option);
                            $.each(data, function (k, v) {
                                var option = $('<option value="' + v.id + '">' + v.name + '</option>');
                                schools_select.append(option);
                            });
                        } else {
                            first_option = $('<option>该区县暂无学校</option>');
                            schools_select.append(first_option);
                        }
                        schools_select.trigger('chosen:updated');
                    }
                });
            } else {
                alert_r(false, '非有效区县');
            }

    });

    var select_user_school = $("#select-user-school");
    select_user_school.on('change', function () {
        var school_id = $(this).val();
        var district_id = districts_select.val();
        var school_name = select_user_school.find("option:selected").text();
        if (district_id > 0 && school_id > 0) {
            document.getElementById("user_profile_district_id").value = district_id;
            $("#user_profile_school_id").val(school_id).change();
            document.getElementById("change_district_id").value = district_id;
            $('.select-user-school').text(school_name);
            $("#select-school-modal").modal('hide');
        } else {
            alert_r(false, '参数不规范')
        }
    });

    $('#user-profile-form').submit(function(){
      var idcard = $('#user_profile_identity_card').val();
      var birthday = $('#user_profile_birthday').val();
      if(idcard){
        if(checkIdcard(idcard)){
          if(birthday){
            if(birthday.replace(/-/g, "")!==idcard.substring(6,14)){
                alert_r("生日与身份证不一致");
                return false;
              }
          }
        }else{
          alert_r("身份证不合法");
          return false;
        }
      }
    });

    $('#go-apply').on('click', function(event) {
        event.preventDefault();
        var cookie = $.cookie('lesson-selected');
        if (typeof cookie == 'string') {
            //console.log(cookie);
            if (cookie == 'null' || cookie == '[]') {
                alert_r('请先选择课程！');
            } else {
                window.location.href = '/courses/apply_show';
            }
        } else {
            alert_r('请先选择课程！');
        }
    });

    $('.open-course-score').off('click').on('click', function(event) {
        event.preventDefault();
        var _self = $(this);
        var space = _self.parents('tr');
        var list = space.find('.course-score-attrs-list');
        var ship_id = _self.attr('data-id');
        if (list.length > 0) {
            var attrs = list.find('.course-attr');
            var total = 0;
            $.each(attrs, function(k, v) {
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

        $('#course-score').find('.attr-input').on('keyup', function() {
            var total = 0;
            $.each($('#course-score').find('.attr-input'), function(k, v) {
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

        $('#course-score').find('.btn-submit-course').off('click').on('click', {
            id: ship_id
        }, function(event) {
            event.preventDefault();

            var inputs = $('#course-score').find('.attr-input');
            var score_attrs = {};
            $.each(inputs, function(k, v) {
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
                success: function(result) {
                    if (result[0]) {
                        alert_r(result[1], function() {
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
        $('#user_profile_birthday').birthdayPicker();
    }

    if ($('.apply-lesson').length > 0) {
        $('.apply-lesson').off('click').on('click', function(event) {
            event.preventDefault();
            var form = $(this).parents('form');
            var username = form.find('#user-info-username').val();
            var t = /[\u4e00-\u9fa5]{2,}/i;
            if (!t.test(username)) {
                alert_r('请填写正确的姓名！');
                return;
            }
            var school = form.find('#user_profile_school_id').val();
            var district = form.find('#user_profile_district_id').val();
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
                data: {
                    username: username,
                    district: district,
                    school: school,
                    grade: grade,
                    cds: cds
                },
                dataType: 'json',
                success: function(result) {
                    if (result[0]) {
                        alert_r(result[1], function() {
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
        $('.btn-confirm-apply').on('click', function(event) {
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
                data: {
                    username: username,
                    district: district,
                    school: school,
                    grade: grade,
                    cds: cds
                },
                dataType: 'json',
                success: function(result) {
                    if (result[0]) {
                        alert_r(result[1], function() {
                            $.cookie('lesson-selected', null, {
                                path: '/'
                            });
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
        $('#register-email').on('blur', function() {
            var $this = $(this);
            var em = $this.val();
            var reg = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i;
            if (reg.test(em)) {
                var option = {
                    url: '/accounts/register_email_exists',
                    type: 'post',
                    data: {
                        email: em
                    },
                    success: function(result) {
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

    $(window).on('resize', function() {
        fix_height.init('#main');
    });

    $('.lesson').find('.lesson-item').on('click', function() {
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
            $.cookie('lesson-selected', json_lessons, {
                path: '/'
            });
        }
    });

    if ($('.add-school').length > 0) {
        $('.add-school').off('click').on('click', function() {
            var dis = $('#district-select').val();
            //console.log(dis);
            if (typeof dis != 'string' || dis.length < 1 || dis == '0' || dis == 0) {
                alert_r('请选择区县！');
            } else {
                $('#add-school').modal('show');
            }
        })
    }

    if ($('#demeanor-photo').length > 0) {
        var thumb = $('#demeanor-photo').find('.thumb');
        thumb.on('click', function(event) {
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
        video.on('click', function(event) {
            event.preventDefault();
            var src = $(this).attr('data-video');
            $('#video-win').find('.audio-main').attr('src', src);
            $('#video-win').modal('show').off('hide.bs.modal').on('hide.bs.modal', function() {
                $('#video-win').find('.audio-main').attr('src', '');
            });
        })
    }

    if ($('.btn-add-school').length > 0) {
        $('.btn-add-school').off('click').on('click', function(event) {
            event.preventDefault();
            var _self = $(this);
            var dis = $('#select-district').val();

            if (typeof dis != 'string' || dis.length < 1) {
                alert_r('请选择区县！');
                return;
            }
            var name = $('#add-school-input').val();
            if (typeof name != 'string' || name.length < 1) {
                alert_r('请填写学校全称！');
                return;
            }
            if (confirm('是否确认添加' + name + '学校?\n一旦添加学校则无法再次添加学校！\n必须等待管理员审核通过才可以继续添加！请慎重填写')) {
                var option = {
                    url: '/user/add_school',
                    type: 'post',
                    dataType: 'json',
                    data: {
                        district: dis,
                        school: name
                    },
                    success: function(data) {
                        if (data[0]) {
                            $('#select-school-modal').modal('hide');
                            alert_r(data[1]);
                        } else {
                            alert_r(data[1]);
                        }
                    }
                };
                ajax_handle(option);
            }
        });
    }

    $('.gender-label').find('input[type="radio"]').on('click', function(event) {
        if ($(this).prop('checked') == true) {
            $('#gender').val($(this).val());
        }
    });

    $('.control-idc').on('change', function(event) {
        event.preventDefault();
        var v = $(this).val();
        //console.log(v);
        if (v >= 10) {
            $('.idc-form').removeClass('hide');
        }
    });

    $('.accept-invite-submit').on('click', function(event) {
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

        if (username.length < 1) {
            alert_r('请填写姓名！');
            return false;
        }
        if (gender.length < 1) {
            alert_r('请选择性别！');
            return false;
        }
        if (birthday.length < 1) {
            alert_r('请填写生日！');
            return false;
        }
        if (school_id.length < 1) {
            alert_r('请选择学校！');
            return false;
        }
        if (student_code.length < 1) {
            alert_r('请填写学籍号！');
            return false;
        }
        if (grade.length < 1) {
            alert_r('请选择年级！');
            return false;
        }
        if (parseInt(grade) >= 10 && !/^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.test(identity_card)) {
            alert_r('由于您选择了高中年级，请正确填写身份证！');
            return false;
        }

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
            success: function(data) {
                if (data[0]) {
                    $('#update-user-info').modal('hide');
                    alert_r(data[1], function() {
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
            $.each(lessons, function(k, v) {
                var div = $('<div class="lesson-control" data-course-id="' + v.id + '">' +
                    '<a href="/courses/' + v.id + '">' + v.name + '</a>' +
                    '<i class="glyphicon glyphicon-remove-circle remove-lesson"></i>' +
                    '</div>');
                $('.apply-lessons').find('.content').append(div);
                div.find('.remove-lesson').on('click', function(event) {
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
                            $.cookie('lesson-selected', json_lessons, {
                                path: '/'
                            });
                        }
                    }
                });
            });
        } else {
            alert_r('请先选择课程！');
        }
    }


    $('select[data-target]').off('change').on('change', function() {
        var _self = $(this);
        $(_self.attr('data-target')).val(_self.val());
    });

    $('.fieldset-label>input').on('change', function() {
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

    $('.change-avatar').on('click', function() {
        $('#change-avatar').modal('show');
    });

    $('.un-do').on('click', function(event) {
        event.preventDefault();
        alert_r('功能开发中，敬请期待！');
    });

    if ($('.error-notice').length > 0) {
        alert_r($('.error-notice').text());
    }

    if ($('.btn-abort-lesson').length > 0) {
        $('.btn-abort-lesson').off('click').on('click', function(event) {
            event.preventDefault();
            var _self = $(this);
            var option = {
                url: _self.attr('href'),
                type: 'post',
                dataType: 'json',
                success: function(data) {
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
                complete: function() {

                },
                error: function() {
                    alert_r('ajax error');
                }
            };
            ajax_handle(option);
        });
    }

    $('.btn-accept-invite').on('click', function() {
        $('#accept-invite').removeClass('hide');
    });

    //报名活动
    if ($('#activity-show').length > 0) {
        var space = $('#activity-show');
        var go = space.find('.go-activity');
        var _id = space.attr('data-id');

        //var mob_b = space.find('.activity-no-mobile');
        //
        //mob_b.on('click', function (event) {
        //    event.preventDefault();
        //    alert_r('请先验证手机', function () {
        //        window.location.href = '/user/mobile';
        //    })
        //});


        go.on('click', function(event) {
            event.preventDefault();
            $('.content').removeClass('hide');
        });

        var apply = space.find('.apply-activity');
        apply.on('click', function(event) {
            event.preventDefault();
            var username = $('#username').val();
            var district_id = $('#district-id').val();
            var school_id = $('#school-id').val();
            var birthday = $('#birthday').val();
            var grade = $('#grade').val();
            var mobile = $('#mobile').val();

            var option = {
                url: '/activities/apply_activity',
                type: 'post',
                data: {
                    username: username,
                    school: school_id,
                    district: district_id,
                    birthday: birthday,
                    grade: grade,
                    act_d: _id,
                    mobile: mobile
                },
                success: function(result) {
                    if (result[0]) {
                        alert_r(result[1], function() {
                            window.location.reload();
                        });
                    } else {
                        alert_r(result[1]);
                    }
                }
            };
            ajax_handle(option)
        });
    }

    //教师创客认证申请
    $(".edit_role_btn").click(function(){
      $(".role_form").removeClass('hidden');
      $(this).parents(".user_role").addClass('hidden');
    });

    $('#teacher_role_type').change(function(){
      var role_type = $(this).val();
      var user_certificate = $("#user_certificate");
      var user_role_type = $("#user_role_type");
      var user_role_type_hidden = $('#user_role_type_hidden');
      if(role_type === 'zb'){
        user_certificate.prop( "disabled", false ).parents(".form-group").removeClass('hidden');
        user_role_type.prop( "disabled", false ).parents(".form-group").removeClass('hidden');
        user_role_type_hidden.prop( "disabled", true );
      }else{
        user_certificate.prop( "disabled", true ).parents(".form-group").addClass('hidden');
        user_role_type.prop( "disabled", true ).parents(".form-group").addClass('hidden');
        user_role_type_hidden.prop( "disabled", false );
      }
    });

    $("#role-nav .sub-menu-item").click(function(){
      var _this = $(this);
      var role = _this.data("role");
      var items = $("#role-nav .sub-menu-item");
      items.removeClass("active");
      _this.addClass("active");
      $("#hacker_type").val(role);
      role_form_switch(role);
    });

    $("#hacker_create_way").change(function(){
      if($(this).val() === "1"){
        $(".hacker_create_with").addClass("hidden");
      }else{
        $(".hacker_create_with").removeClass("hidden");
      }
    });

    var role = $("#hacker_type").val();
    if(role){
      role_form_switch(role);
    }

    function role_form_switch(role){
      if(role == "1"){
        $(".only-role1").removeClass("hidden");
        $(".only-role2").addClass("hidden");
      }else{
        var mobile = $("#user-mobile").text();
        if(!mobile.length){
          alert_r("请先去认证手机号",function(){
            window.location = '/user/mobile';
          });
          return;
        }else{
          $("#user_family_mobile").val(mobile);
        }
        $(".only-role2").removeClass("hidden");
        $(".only-role1").addClass("hidden");
      }
    }

    //老师创客身份审核
    $("#hacker-audit").click(function(e){
      e.preventDefault();
      $.ajax({
        url: $(this).attr('href'),
        type: 'post',
        success: function(data){
          if(data.message) alert_r(data.message,function(){
            if(data.status === true) window.location.replace("/user/hacker_audit");
          });
        },
        error:function(data){
          //console.log(data);
        }
      });
    });
    $("#teacher-audit").click(function(e){
      e.preventDefault();
      var url = $(this).attr('href');
      var role_type = $(this).data('role_type');
      $("#teacher-audit-modal").modal();
      $("#submit-teacher-role").off('click').click(
        function(){
          $.ajax({
            url: url,
            type: 'post',
            success: function(data){
              if(data.message) alert_r(data.message,function(){
                if(data.status === true) window.location.replace("/user/teacher_audit");
              });
            },
            error:function(data){
              //console.log(data);
            }
          });
        }
      );

    });

    // 修改老师信息

    function teacher_edit_save($ele){
      var tr = $ele.parents('tr');
      var role_type_select = tr.find('.role-type-select');
      var school_id = tr.find('.school-name').data("id");
      var role_type = role_type_select.val();
      if(role_type == $ele.data("role-type")){
        alert_r('请修改后再保存');
      }else{
        var post_data = {role_type: role_type};
        if(school_id){
          post_data.school_id = school_id;
        }

        $.ajax({
          url: $ele.data("url"),
          data: post_data,
          type: 'post',
          success: function(data){
            if(data.message) {
              alert_r(data.message);
            }
            if(data.status === true){
              tr.find('.role-type').removeClass('hidden').text(role_type_select.find('option:selected').html());
              role_type_select.remove();
              $ele.text("修改").off('click').click(function(){
                teacher_edit_click($(this));
              });
            }
          },
          error:function(data){
            //console.log(data);
            alert_r('提交失败');
          }
        });
      }
    }

    function teacher_edit_click($ele){
      var tr = $ele.parents('tr');
      tr.find('.role-type').after('<select class="role-type-select"><option value="6">外聘校级普通</option><option value="5">在编校级普通</option><option value="3">在编校级高级</option></select>').addClass('hidden');
      $(".role-type-select").val($ele.data("role-type"));
      tr.find('.school-name').addClass('underline').click(function(){
        $("#teacher-edit-table .school-name").removeClass('active');
        $(this).addClass('active');
        $("#select-school-modal").modal();
      });
      $ele.text("保存").off('click').click(function(){
        teacher_edit_save($(this));
      });
    }
    if($("#teacher-edit-table").length){
      $("#user_profile_school_id").change(function(){
        var id =$(this).val();
        $('.school-name.active').data("id",id);
      });
    }

    $(".teacher-edit").click(function(){
      teacher_edit_click($(this));
    });

    //参赛学生列表

    if ($('#comp-stu').length > 0) {
        var space = $('#comp-stu');
        var comp = space.find('.comp-sel');
        var es = space.find('.event-sel');
        var sta = space.find('.status-sel');
        var sub = space.find('.submit-team-many');

        var s_sel = space.find('#select-school-by-dis');
        if (s_sel.length > 0) {
            var _s_sel = s_sel;
            var option = {
                url: '/user/get_schools',
                type: 'get',
                dataType: 'json',
                data: {
                    district_id: space.find('.teacher-info').attr('data-district-id')
                },
                success: function(result) {
                    if (result.length > 0) {
                        $.each(result, function(k, v) {
                            var id = v.id;
                            var name = v.name;
                            var op = $('<option value="' + id + '">' + name + '</option>');
                            _s_sel.append(op);
                            _s_sel.addClass('active');
                        });
                    }
                },
                complete: function() {

                },
                error: function(error) {
                    alert_r(error.responseText);
                }
            };
            ajax_handle(option);
        }

        s_sel.on('change', {
            space: space
        }, function(event) {
            event.preventDefault();
            var data = event.data;
            var space = data.space;
            var _self = $(this);
            var val = _self.val();
            var com = space.find('.comp-sel').val();
            var ed = space.find('.event-sel').val();
            var status = space.find('.status-sel').val();
            space.find('.team-list').empty();
            space.find('.comp-info').empty();
            var _space = space;
            if (_self.hasClass('active') && val != -1) {
                student_control_handle(com, ed, status, _space, val);
            }
        });

        comp.on('change', {
            space: space
        }, function(event) {
            event.preventDefault();
            var data = event.data;
            var space = data.space;
            var _self = $(this);
            var val = _self.val();
            var es = space.find('.event-sel');
            var status = space.find('.status-sel');
            es.empty().removeClass('active');
            es.append($('<option value="-1">请选择项目</option>'));
            es.append($('<option value="0">所有项目</option>'));
            space.find('.team-list').empty();
            if (val != 0) {
                var option = {
                    url: '/user/get_events',
                    type: 'get',
                    data: {
                        cd: val
                    },
                    success: function(result) {
                        if (result.length > 0) {
                            $.each(result, function(k, v) {
                                var o = $('<option value="' + v.id + '">' + v.name + '</option>');
                                es.append(o);
                            });
                            es.addClass('active');
                            status.addClass('active');
                        }
                    }
                };
                ajax_handle(option);
            }
        });

        es.on('change', {
            space: space
        }, function(event) {
            event.preventDefault();
            var data = event.data;
            var space = data.space;
            var _self = $(this);
            var val = _self.val();
            var com = space.find('.comp-sel').val();
            var sd = space.find('#select-school-by-dis').val();
            var status = space.find('.status-sel').val();
            var _space = space;
            _space.find('.team-list').empty();
            _space.find('.comp-info').empty();
            if (_self.hasClass('active') && val != -1) {
                student_control_handle(com, val, status, _space, sd);
            }
        });

        sta.on('change', {
            space: space
        }, function(event) {
            event.preventDefault();
            var data = event.data;
            var space = data.space;
            var _self = $(this);
            var val = _self.val();
            var com = space.find('.comp-sel').val();
            var ed = space.find('.event-sel').val();
            var sd = space.find('#select-school-by-dis').val();
            var _space = space;
            _space.find('.team-list').empty();
            _space.find('.comp-info').empty();
            if (_self.hasClass('active') && val != -1) {
                student_control_handle(com, ed, val, _space, sd)
            }
        });

        sub.on('click', {
            space: space
        }, function(event) {
            event.preventDefault();
            var data = event.data;
            var space = data.space;
            var l = space.find('.team-item').length;

            if (l < 1) {
                alert_r('请先选择队伍！');
            } else {
                var c = space.find('.selected-mark');
                var arr = [];
                var obj = [];
                var cd = c.parents('.team-item').attr('data-cd');
                $.each(c, function(k, v) {
                    var t = $(v);
                    if (t.prop('checked')) {
                        arr.push(t.parents('.team-item').attr('data-td'));
                        obj.push(t.parents('.team-item').find('.item-control'));
                    }
                });

                //console.log(arr);

                var url = '/competitions/district_submit_teams';
                var option = {
                    url: url,
                    type: 'post',
                    data: {
                        tds: arr,
                        comd: cd
                    },
                    success: function(result) {
                        if (result[0]) {
                            alert_r('批量操作成功');
                            $.each(obj, function(k, v) {
                                $(v).empty().text('审核已通过');
                            })
                        } else {
                            alert_r(result[1]);
                        }
                    }
                };
                ajax_handle(option);
            }
        })
    }

    function student_control_handle(com, ed, status, _space, s_id, page_num) {
        var data = {
            com: com,
            ed: ed
        };
        if (status != 100) {
            data['status'] = status;
        }
        if (s_id != 0) {
            data['s'] = s_id;
        }
        if (page_num) {
            data.page = page_num;
        }
        var option = {
            url: '/user/get_comp_students',
            type: 'get',
            data: data,
            success: function(result) {
                $('.team-list').empty();
                $('.comp-info').empty();


                if (result[0] == true) {
                    var players = result[1];
                    var comp_info = result[3];
                    _space.find('.comp-info').append($('<h3>' + comp_info.name + '比赛</h3>' +
                        '<p class="label label-default"> 报名截止: ' + comp_info.apply_end_time.substr(0, 10) + '</p>' +
                        '<p class="label label-info"> 学校审核截至: ' + comp_info.school_audit_time.substr(0, 10) + '</p>' +
                        '<p class="label label-warning"> 区县审核截止: ' + comp_info.district_audit_time.substr(0, 10) + '</p>'
                    ));

                    if (players.length > 0) {
                        _space.find('.comp-info').append($('<a href="/user/get_comp_students.xls?com=' + com + '&ed=' + ed + '&status=' + status + '" class="btn btn-robodou" title="下载名单">下载名单</a>'))
                    }

                    var team_count = {};
                    $.each(players, function(k, v) {
                        var id = v.identifier;
                        if (team_count[id]) {
                            team_count[id].push(v);
                        } else {
                            team_count[id] = [v];
                        }
                    });
                    var control_str = '<button class="btn-robodou team-control" data-type="refuse">取消参赛</button><button class="btn-robodou team-control" data-type="submit">同意参赛</button>';
                    if (status == 0) {
                        control_str = '审核未通过';
                    } else if (status == 1) {
                        control_str = '审核已通过';
                    }
                    $.each(team_count, function(k, v) {
                        var item = $('<div data-td=' + v[0].team_id + ' data-cd=' + com + ' class="team-item ' + k + '">' +
                            '<div class="item-title">' +
                            '<div class="label label-info">' +
                            '队伍编号：' + k +
                            '</div>' +
                            '<div class="selected-div "><input class="selected-mark" type="checkbox"></div>' +
                            '</div>' +
                            '<div class="item-table">' +
                            '队员列表' +
                            '<table class="table">' +
                            '<tr>' +
                            '<th>姓名</th>' +
                            '<th>性别</th>' +
                            '<th>年级</th>' +
                            '<th>项目</th>' +
                            '</tr>' +
                            '</table>' +
                            '</div>' +
                            '<div class="item-control">' +
                            control_str +
                            '</div>' +
                            '</div>');
                        $('.team-list').append(item);
                        item.find('.team-control').off('click').on('click', function(event) {
                            event.preventDefault();
                            var _self = $(this);
                            var role = '';
                            var r = $('[data-role]').attr('data-role');
                            if (r == 2) {
                                role = 'district'
                            } else if (r == 3) {
                                role = 'school'
                            } else {
                                alert_r('您没有该权限');
                                return false;
                            }
                            var type = $(this).attr('data-type');
                            var url = '/competitions/' + role + '_' + type + '_teams';
                            var p = $(this).parents('.team-item');
                            var td = p.attr('data-td');
                            var cd = p.attr('data-cd');
                            var option = {
                                url: url,
                                type: 'post',
                                data: {
                                    tds: [td],
                                    comd: cd
                                },
                                success: function(result) {
                                    if (result[0]) {
                                        alert_r(result[1], function(param) {
                                            var str = (param[1] == 'submit') ? '该队伍已通过审核' : '该队伍未通过审核';
                                            param[0].parents('.item-control').empty().text(str);
                                        }, [_self, type]);
                                    } else {
                                        alert_r(result[1]);
                                    }
                                }
                            };

                            ajax_handle(option);
                        });
                        var _k = k;
                        $.each(v, function(i, val) {
                            var player = $('<tr>' +
                                '<th>' + val.username + '</th>' +
                                '<th>' + (val.gender == 1 ? '男' : '女') + '</th>' +
                                '<th>' + (val.grade ? val.grade : '空') + '</th>' +
                                '<th>' + val.event_name + '</th>' +
                                '</tr>');
                            $('.' + _k).find('.table').append(player);
                        });
                    })
                } else {
                    alert_r(result[1]);
                }

                var page_size = 10;
                var total_count = result[2];
                var page_count;
                if (total_count > page_size) {
                    page_count = Math.ceil(total_count / page_size);
                    //console.log("page_count:" + page_count);
                    var current_page = page_num || 1;
                    var prev_page = $('<li><a href="#" data-page="' + (parseInt(current_page) - 1) + '">上一页</a></li>');
                    var next_page = $('<li><a href="#" data-page="' + (parseInt(current_page) + 1) + '">下一页</a></li>');
                    var pager = $('<ul class="pager"></ul>');
                    if (current_page > 1) {
                        pager.append(prev_page);
                    }
                    pager.append('<li><select></select></li>');
                    if (current_page < page_count) {
                        pager.append(next_page);
                    }
                    var selectList = pager.find('select');
                    for (var i = 1; i <= page_count; i++) {
                        var option = document.createElement("option");
                        option.value = i;
                        option.text = i;
                        selectList.append(option);
                    }
                    selectList.val(current_page);

                    $('.team-list').append(pager);
                    $(".pager a").click(function(e) {
                        e.preventDefault();
                        var target_page = $(this).data("page");
                        //console.log(target_page);
                        student_control_handle(com, ed, status, _space, s_id, target_page);
                    });

                    $('.pager select').on('change', function() {
                        var target_page = $(this).val();
                        //console.log(target_page);
                        student_control_handle(com, ed, status, _space, s_id, target_page);
                    });

                }
            }
        };
        ajax_handle(option);
    }

    function school_handle() {
        var _modals = $('#school-modal');
        _modals.modal('show');
        get_district();
    }

    function get_district() {
        var option = {
            url: '/user/get_districts',
            type: 'get',
            success: function(result) {
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
            data: {
                district_id: dis
            },
            success: function(result) {
                if (result.length > 0) {
                    get_school_success(result, dis);
                } else {
                    alert_r('未找到合适条件的学校');
                    $('.school-list').empty();
                }
            },
            complete: function() {

            },
            error: function(error) {
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
        $('.school-bean').on('click', {
            dis: dis
        }, function(event) {
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
                $('.school-tag').off('click').on('click', function(event) {
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
        s.on('change', function(event) {
            event.preventDefault();
            var dis = $(this).val();
            get_school(dis);
        });
    }

    function ajax_handle(option) {
        $.ajax(option);
    }
});
