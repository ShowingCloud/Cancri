/**
 * Created by yaolin on 16/4/5.
 */
$(function () {
    var EVENT_DATA = {};
    var SCHOOL_DATA = {};
    SCHOOL_DATA.school_list = [];
    var action = function () {
        lazyload.init();
        match_info_toggle.init();
        event_select.init();
        join_activity.init();
        join_volunteer.init();
        add_school.init();
        no_select.init();
        join_v_school.init();
        //window.setTimeout(function(){getInfo();},5000);
        fix_height.init('#main>.container');
        add_other_school.init();
        invitation.init();
        $(window).on('resize', function () {
            fix_height.init('#main>.container');
        });
        avatar_control.init('#change-avatar');
        qr.init();
        download_select.init();
        change_role.init();
    };

    var change_role = {
        init:function(){
            if($('.user_profile_roles').length>0){
                var space = $('.user_profile_roles');
                space.find('input[type="checkbox"]').off('change').on('change',function(){
                    var _self = $(this);
                    var a = _self.val();
                    if(a=='教师'&&_self.prop('checked')){
                        space.parents('.user-panel').find('.teacher-part').removeClass('hide');
                    }else if(a=='教师'&& !(_self.prop('checked')) ){
                        space.parents('.user-panel').find('.teacher-part').addClass('hide');
                    }
                });
            }
        }
    };


    var qr = {
        init: function () {
            if ($('.card-avatar').length > 0) {
                $.each($('.card-avatar'), function (k, v) {
                    $(v).qrcode({
                        width: 70,
                        height: 70,
                        text: $(v).attr('data-q')
                    })
                });
            }
        }
    };

    var download_select = {
        init: function () {
            if ($('#download').length > 0) {
                var space = $('#download');
                space.find('select[name="year"]').on('change', function () {
                    space.find('select[name="event"]').parents('.download-item').addClass('active');
                });
                space.find('select[name="event"]').on('change', function () {
                    space.find('select[name="table"]').parents('.download-item').addClass('active');
                });
                space.find('select[name="table"]').on('change', function () {
                    space.find('select[name="download-district"]').parents('.download-item').addClass('active');
                    space.find('select[name="download-school"]').parents('.download-item').addClass('active');
                });
            }
        }
    };

    var authenticity_token = {
        init: function (space) {
            var a = space.find('[name="authenticity_token"]');
            if (a) {
                a.attr({'value': $('meta[name="csrf-token"]').attr('content')});
            }
        }
    };

    var avatar_control = {
        init: function (select) {
            var space = $(select);
            $('.avatar-img').on('click', function () {
                $('#change-avatar').modal('show');
            });
            space.find('#changeAvatar').on('change', function () {
                $('.avatar-btn').text('已选择图片！');
            });
            space.find('.btn-submit-avatar').on('click', function (event) {
                event.preventDefault();
                authenticity_token.init(space);
                space.find('form').submit();
                //var _self = $(this);
                //var old = _self.text();
                //var data = _self.parents('#change-avatar').find('form').serialize();
                //console.log(data);
                //var option = {
                //    url: 'update_avatar',
                //    data: data,
                //    dataType: 'json',
                //    type: 'post',
                //    success: function (result) {
                //        console.log(result);
                //    },
                //    complete: function () {
                //        _self.text(old).prop({'disabled': false});
                //    }
                //};
                //_self.text('提交中').prop({'disabled':true});
                //$.ajax(option);
            })
        }
    };

    var fix_height = {
        init: function (selector) {
            var max = document.body.clientHeight;
            var screen = window.innerHeight;
            if (screen > max) {
                $(selector).css({'min-height': screen - 180});
            }
        }
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

    var no_select = {
        init: function () {
            var s = $('select[data-select-target]');
            if (s.length > 0) {
                s.on('change', function () {
                    var _self = $(this);
                    _self.siblings('input[name="' + _self.attr('data-select-target') + '"]').val(_self.val());
                    if (_self.hasClass('group-choice')) {
                        var p = _self.parents('.apply-part');
                        if (_self.val() == 3) {
                            p.find('.input-row.idc-row').removeClass('hide');
                        } else {
                            p.find('.input-row.idc-row').addClass('hide');
                            p.find('.input-row.idc-row').find('input').val('');
                        }
                    }
                });
            }
        }
    };

    var match_info_toggle = {
        init: function () {
            var b = $('.match-toggle');
            b.parent().on('click', function () {
                $(this).parent().find('.item-c').slideToggle(300);
            });
        }
    };

    var event_select = {
        init: function () {
            var s = $('#event-select');
            if (s) {
                s.on('change', function () {
                    var _self = $(this);
                    var ed = _self.val();
                    init_tag();
                    if (ed != 0) {
                        EVENT_DATA[ed] = {};
                        SCHOOL_DATA = {};
                        SCHOOL_DATA.school_list = [];
                        EVENT_DATA[ed].id = ed;
                        var choice = _self.find('option[data-val="' + EVENT_DATA[ed].id + '"]');
                        EVENT_DATA[ed].max_num = choice.attr('data-max-num');
                        EVENT_DATA[ed].eName = choice.attr('data-name');
                        var option = {
                            url: 'already_apply',
                            type: 'post',
                            dateType: 'json',
                            data: {'ed': EVENT_DATA[ed].id},
                            success: function (data) {
                                if (data[0]) {
                                    //已报名
                                    EVENT_DATA[ed].is_apply = true;
                                    EVENT_DATA[ed].team_info = data[1];
                                    EVENT_DATA[ed].group_limit = data[2];
                                    show_apply_info(ed);
                                } else {
                                    //未报名
                                    no_apply(ed);
                                }
                            }
                        };
                        $.ajax(option);
                    }
                });
            }
        }
    };

    var search_team = {
        init: function (ed) {
            var b = $('.btn-search-team');
            if (b) {
                b.off('click').on('click', function () {
                    var old = b.text();
                    b.text('查询中');
                    b.prop({'disabled': true});
                    var target = $('.team-list').find('tbody');
                    target.empty();
                    var team_name = $('.team-search-input').val();
                    var reg = /[\u4e00-\u9fa5a-zA-Z0-9]+/i;
                    if (reg.test(team_name)) {
                        var option = {
                            url: $(this).attr('data-ajax-get'),
                            dataType: 'json',
                            data: {ed: ed, team_name: $('.team-search-input').val()},
                            type: 'get',
                            success: function (data) {
                                if (data[0]) {
                                    if (data[1].length == 0) {
                                        //未查询到有关队伍
                                        alert('未查询到相关队伍');
                                    } else {
                                        var result = data[1];
                                        $.each(result, function (k, v) {
                                            var tr = $('<tr data-td="' + v.id + '">');
                                            var tName = '<td>' + v.name + '</td>';
                                            var tLeader = '<td>' + v.leader + '</td>';
                                            var tTeacher = '<td>' + v.teacher + '</td>';
                                            var tSchool = '<td>' + v.school + '</td>';
                                            var tBtn = '<td>' + (v.players == v.max_num ? '队伍已满' : '<button class="btn-robodou btn-join-team">加入</button>') + '</td>';
                                            tr.append(tName).append(tLeader).append(tTeacher).append(tSchool).append(tBtn);
                                            target.append(tr);
                                        });
                                        join_team.init(ed);
                                    }
                                } else {
                                    //参数错误 false
                                    alert(data);
                                }
                            },
                            complete: function () {
                                b.text(old);
                                b.prop({'disabled': false});
                            }
                        };
                        $.ajax(option);
                    } else {
                        alert('请输入汉字、数字和字母');
                        b.text(old);
                        b.prop({'disabled': false});
                    }
                })
            }
        }
    };

    var join_team = {
        init: function (ed) {
            $('.btn-join-team').off('click').on('click', function () {
                $('.search-team').removeClass('active');
                var td = $(this).parents('tr').attr('data-td');
                $(this).parents('.team-panel').removeClass('active');
                var space = $('.team-confirm-join');
                space.addClass('active');
                space.find('.open-school').off('click').on('click', function () {
                    SCHOOL_DATA.type = space.find('input[name="group"]').val();
                    if (!SCHOOL_DATA.type) {
                        return alert('请选择组别');
                    }
                    SCHOOL_DATA.typeName = space.find('select[data-select-target="group"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                    SCHOOL_DATA.district = space.find('input[name="district"]').val();
                    if (!SCHOOL_DATA.district) {
                        return alert('请选择区县');
                    }
                    SCHOOL_DATA.districtName = space.find('select[data-select-target="district"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                    var length = space.find('.edit-school').length;
                    if (length == 2) {
                        alert('学校已满，无法继续添加！');
                    } else {
                        get_school(space);
                        $('#school-list').modal('show');
                    }
                });

                space.find('.add-other-school').off('click').on('click', function () {
                    SCHOOL_DATA.type = space.find('input[name="group"]').val();
                    if (!SCHOOL_DATA.type) {
                        return alert('请选择组别');
                    }
                    SCHOOL_DATA.typeName = space.find('select[data-select-target="group"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                    SCHOOL_DATA.district = space.find('input[name="district"]').val();
                    if (!SCHOOL_DATA.district) {
                        return alert('请选择区县');
                    }
                    SCHOOL_DATA.districtName = space.find('select[data-select-target="district"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                    var length = space.find('.edit-school').length;
                    if (length == 2) {
                        alert('学校已满，无法继续添加！');
                    } else {
                        $('#add-other-school').modal('show');
                    }
                });

                //开启添加学校
                add_other_school.init(space);

                space.find('.apply-submit').off('click').on('click', function (event) {
                    event.preventDefault();
                    var _self = $(this);
                    var form = space.find('#team-confirm-form');
                    var data = form.serialize();
                    data += '&join=1';
                    data += '&ed=' + ed;
                    data += '&td=' + td;
                    if (SCHOOL_DATA.school_list[0]) {
                        data += '&school1=' + SCHOOL_DATA.school_list[0].id;
                        if (SCHOOL_DATA.school_list[1]) {
                            data += '&school2=' + SCHOOL_DATA.school_list[1].id;
                        }
                    }

                    var group = space.find('input[name="group"]').val();
                    var identity_card = space.find('input[name="identity_card"]').val();
                    var reg = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/;
                    if (!reg.test(identity_card) && group == 3) {
                        alert('请输入正确的身份证号！');
                        _self.text(old).prop({'disabled': false});
                    } else {
                        var new_data = space.find('form').serializeArray();
                        if (confirm('请确认您的参赛信息：\n' + format_data(space, new_data))) {
                            var option = {
                                url: 'update_apply_info',
                                dataType: 'json',
                                type: 'post',
                                data: data,
                                success: function (data) {
                                    alert(data[1]);
                                    if (data[0]) {
                                        window.location.reload();
                                    }
                                }
                            };
                            $.ajax(option);
                        }
                    }
                })
            });
        }
    };

    var join_activity = {
        init: function () {
            var b = $('.alert-info');
            if (b.length > 0) {
                b.on('click', function () {
                    alert('请去个人中心验证您的邮箱');
                });
            }
            var a = $('.btn-join-activity');
            if (a.length > 0) {
                a.on('click', function () {
                    var form = $('#activity-form');
                    var option = {
                        url: '/activities/apply_activity',
                        dataType: 'json',
                        type: 'post',
                        data: form.serialize(),
                        success: function (data) {
                            if (data[0]) {
                                alert(data[1]);
                                window.location.reload();
                            } else {
                                alert(data[1]);
                            }
                        }
                    };
                    $.ajax(option);
                });
            }
        }
    };

    var join_volunteer = {
        init: function () {
            var b = $('.alert-info-2');
            if (b.length > 0) {
                b.off('click').on('click', function () {
                    alert('请去个人中心验证您的手机和邮箱');
                });
            }

            var a = $('.btn-join-volunteer');
            if (a.length > 0) {
                a.off('click').on('click', function () {
                    var form = $('#volunteer-form');
                    var option = {
                        url: '/volunteers/apply_comp_volunteer',
                        dataType: 'json',
                        type: 'post',
                        data: form.serialize(),
                        success: function (data) {
                            if (data[0]) {
                                alert(data[1]);
                                window.location.reload();
                            } else {
                                alert(data[1]);
                            }
                        }
                    };
                    $.ajax(option);
                });
            }
        }
    };

    var add_school = {
        init: function () {
            var b = $('.btn-add-school');
            if (b.length > 0) {
                b.off('click').on('click', function (event) {
                    event.preventDefault();
                    var _self = $(this);
                    var type = _self.parent().find('.add-school-type').val();
                    var dis = _self.parent().find('.add-school-district').val();
                    var text = _self.parent().find('.add-school-text').val();
                    if (type != 0 && dis != 0) {
                        if (text.trim().length > 0) {
                            var old = _self.text();
                            _self.prop({'disabled': true});
                            _self.text('提交中');
                            var option = {
                                url: '/user/add_school',
                                dataType: 'json',
                                type: 'post',
                                data: {type: type, district: dis, school: text},
                                success: function (data) {
                                    if (data[0]) {
                                        alert('学校添加成功！');
                                        var sid = data[2];
                                        _self.parents('form').find('.school-condition').prop({'disabled': true});
                                        _self.parent().find('.add-school-text').prop({'disabled': true});
                                        _self.parents('form').find('input[name="school"]').val(sid);
                                        _self.parents('form').find('input[name="district"]').val(dis);
                                    } else {
                                        alert(data[1]);
                                    }
                                },
                                complete: function () {
                                    _self.text(old);
                                    _self.prop({'disabled': false});
                                }
                            };

                            $.ajax(option);
                        } else {
                            alert('请填写学校名称');
                        }
                    } else {
                        alert('请选择组别和区县');
                    }
                });
            }
        }
    };

    var join_v_school = {
        init: function () {
            var space = $('#join-volunteer');
            space.find('.open-school').off('click').on('click', function () {
                var length = $('.edit-school').length;
                if (length == 2) {
                    alert('学校已满，无法继续添加！');
                } else {
                    $('#school-list').modal('show');
                }
            });

            space.find('.add-other-school').off('click').on('click', function () {
                var length = $('.edit-school').length;
                if (length == 2) {
                    alert('学校已满，无法继续添加！');
                } else {
                    $('#add-other-school').modal('show');
                }
            });
        }
    };

    var add_other_school = {
        init: function (space) {
            $('#add-other-school').find('.apply-submit').off('click').on('click', function (event) {
                var _self = $(this);
                var text = $('#add-other-school').find('input').val();
                var option = {
                    url: '/user/add_school',
                    dataType: 'json',
                    type: 'post',
                    data: {type: SCHOOL_DATA.type, district: SCHOOL_DATA.districtName, school: text},
                    success: function (data) {
                        if (data[0]) {
                            alert('学校添加成功！');
                            $('#add-other-school').modal('hide');
                            var inner_text = SCHOOL_DATA.typeName + '-' + SCHOOL_DATA.districtName + '-' + text;
                            space.find('.school-target').prepend('<div data-id="' + data[2] + '" class="edit-school">' + inner_text + '<i class="glyphicon glyphicon-remove-circle"></i></div>');
                            space.find('.school-target').find('i').off('click').on('click', function () {
                                var p = $(this).parent();
                                var id = p.attr('data-id');
                                if (confirm('是否删除' + inner_text + '学校')) {
                                    remove_school(id);
                                    p.remove();
                                }
                            });
                            SCHOOL_DATA.school_list.push({'id': data[2], 'name': text});
                            $('#add-school').find('.items').empty();
                            $('#school-list').modal('hide');
                            console.log(SCHOOL_DATA);
                        } else {
                            alert(data[1]);
                        }
                    },
                    complete: function () {
                        _self.prop({'disabled': false});
                    }
                };
                $.ajax(option);
            });
        }
    };

    var invitation = {
        init: function () {
            var a = $('.btn-invitation');
            if (a.length > 0) {
                a.off('click').on('click', function () {
                    var e = $('.invitation-email').val();
                    var tName = $('.apply-team-name').text();
                    var eName = $('.event-name').text();
                    var td = $('.apply-team-name').attr('data-team-id');
                    var reg = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})+$/;
                    if (reg.test(e)) {
                        var option = {
                            url: 'leader_invite_player',
                            type: 'post',
                            dataType: 'json',
                            data: {
                                team_name: tName,
                                event_name: eName,
                                td: td,
                                ed: EVENT_DATA.ed,
                                invited_email: e
                            },
                            success: function (data) {
                                if (data[0]) {
                                    alert(data[1]);
                                } else {
                                    alert(data[1]);
                                }
                            },
                            complete: function () {
                            }
                        };
                        $.ajax(option);
                    } else {
                        alert('请输入正确的邮箱格式！');
                    }
                })
            }
            var b = $('.invitation-text');
            if (b.length > 0) {
                b.off('click').on('keyup', function () {
                    var _self = $(this);
                    var name = _self.val();
                    var reg = /[\u4e00-\u9fa5]{2,}/;
                    var p = _self.parent();
                    if (reg.test(name)) {
                        var option = {
                            url: 'search_user',
                            dataType: 'json',
                            data: {invited_name: name},
                            type: 'get',
                            success: function (result) {
                                p.find('.user-list').remove();
                                if (result[0]) {
                                    var div = $('<div class="user-list"></div>');
                                    console.log(result);
                                    $.each(result[1], function (k, v) {
                                        var s = '';
                                        if (v.gender == 1) {
                                            s = '男';
                                        } else {
                                            s = '女';
                                        }
                                        div.append('<div class="user-info" data-id="' + v.email + '">' + v.username + ' - ' + v.name + ' - ' + v.grade + '年级' + v.bj + '班 - ' + s + ' - ' + v.nickname + '</div>')
                                    });
                                    p.append(div);
                                    $('.user-info').on('click', function () {
                                        var text = $(this).text();
                                        p.find('.user-list').remove();
                                        $('.hidden-invitation-id').val($(this).attr('data-id'));
                                        b.val(text);
                                    });
                                } else {
                                    alert(result[1]);
                                }
                            }
                        };
                        $.ajax(option);
                    } else {
                        p.find('.user-list').remove();
                    }
                })
            }
            var c = $('.btn-add-team-member');
            if (c.length > 0) {
                c.off('click').on('click', function () {
                    var e = $('.hidden-invitation-id').val();
                    if (e) {
                        var tName = $('.apply-team-name').text();
                        var eName = $('.event-name').text();
                        var td = $('.apply-team-name').attr('data-team-id');
                        var option = {
                            url: 'leader_invite_player',
                            type: 'post',
                            dataType: 'json',
                            data: {
                                team_name: tName,
                                event_name: eName,
                                td: td,
                                ed: EVENT_DATA.ed,
                                invited_email: e
                            },
                            success: function (data) {
                                if (data[0]) {
                                    alert(data[1]);
                                } else {
                                    alert(data[1]);
                                }
                            },
                            complete: function () {
                            }
                        };
                        $.ajax(option);
                    } else {
                        alert('请选择用户！');
                    }
                })
            }
        }
    };

    action();

    //显示已报名信息
    function show_apply_info(ed) {
        if (EVENT_DATA[ed].max_num == 1) {
            //单人
            show_single_info(ed);
        } else {
            //多人
            show_team_info(ed);
        }
    }

    //显示已报名的单人信息
    function show_single_info(ed) {
        console.log(EVENT_DATA);
        var space = $('.single-already-info');
        space.addClass('active');
        space.find('.event-name').text(EVENT_DATA[ed].eName);
        space.find('[data-name="username"]').text(EVENT_DATA[ed].team_info[0].username);
        space.find('[data-name="gender"]').text(EVENT_DATA[ed].team_info[0].gender == 1 ? '男' : '女');
        space.find('[data-name="school"]').text(EVENT_DATA[ed].team_info[0].school);
        space.find('[data-name="grade"]').text(EVENT_DATA[ed].team_info[0].grade + '年级' + EVENT_DATA[ed].team_info[0].bj + '班');
        space.find('[data-name="code"]').text(EVENT_DATA[ed].team_info[0].identifier);
        space.find('[data-name="teacher"]').text(EVENT_DATA[ed].team_info[0].teacher);
        space.find('[data-name="teacher_mobile"]').text(EVENT_DATA[ed].team_info[0].teacher_mobile);
        space.find('[data-name="qrcode"]').qrcode({
            width: 64,
            height: 64,
            text: EVENT_DATA[ed].team_info[0].identifier
        });
        space.find('.btn-exit-event').off('click').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            if (confirm('确定退出比赛么？')) {
                var old = _self.text();
                _self.text('提交中').prop({'disabled': true});
                exit_event(EVENT_DATA[ed].team_info[0].team_id, function (data) {
                    console.log(EVENT_DATA);
                    if (data[0]) {
                        alert('退出比赛成功！');
                        window.location.reload();
                    } else {
                        alert('退出失败！');
                    }
                }, function () {
                    _self.text(old).prop({'disabled': false});
                });
            }
        })
    }

    //显示已报名的队伍信息
    function show_team_info(ed) {
        var space = $('.team-already-info');
        space.addClass('active');
        space.find('.event-name').text(EVENT_DATA[ed].eName);
        space.find('.apply-team-name').text(EVENT_DATA[ed].team_info[0].name).attr({'data-team-id': EVENT_DATA[ed].team_info[0].team_id});
        space.find('.apply-member-num').text(EVENT_DATA[ed].team_info.length + '人');
        var user_id = $('#currentUser').attr('data-userId');
        var target = $('.apply-member').find('tbody');
        target.empty();

        $.each(EVENT_DATA[ed].team_info, function (k, v) {
            var tr = $('<tr>');
            var tName = '<td>' + v.username + '</td>';
            var tGender = '<td>' + (v.gender == 1 ? '男' : '女') + '</td>';
            var tSchool = '<td>' + v.school + '</td>';
            var tGrade = '<td>' + v.grade + '</td>';
            var tBtn = '<td></td>';
            //leader
            if (user_id == v.id) {
                //leader-row
                if (user_id == v.user_id) {
                    target.parent().find('.col-o').append('<button class="delete-team">解散队伍</button>');
                } else {
                    tBtn = '<td><button data-id="' + v.user_id + '" class="delete-member">删除队员</button></td>';
                }
            }
            tr.append(tName).append(tGender).append(tSchool).append(tGrade).append(tBtn);
            if (user_id == v.id) {
                target.prepend(tr);
            } else {
                target.append(tr);
            }
        });

        //解散队伍
        target.parent().find('.delete-team').off('click').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            if (confirm('确定退出比赛么？')) {
                var old = _self.text();
                _self.text('提交中').prop({'disabled': true});
                exit_event(EVENT_DATA[ed].team_info[0].team_id, function (data) {
                    if (data[0]) {
                        alert('解散队伍成功！');
                        window.location.reload();
                    } else {
                        alert('解散失败！');
                    }
                }, function () {
                    _self.text(old).prop({'disabled': false});
                });
            }
        });

        //删除队员
        target.find('.delete-member').off('click').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            if (confirm('确定将该队员删除么？')) {
                var old = _self.text();
                _self.text('提交中').prop({'disabled': true});
                delete_member(_self.attr('data-id'), EVENT_DATA[ed].team_info[0].team_id, function (data) {
                    if (data[0]) {
                        var index = _self.parents('tr').index();
                        _self.parents('tr').remove();
                        EVENT_DATA[ed].team_info.splice(index);
                        space.find('.apply-member-num').text(EVENT_DATA[ed].team_info.length + '人');
                        alert('删除队员成功！');
                    } else {
                        alert('删除失败！');
                    }
                }, function () {
                    _self.text(old).prop({'disabled': false});
                });
            }
        });

    }

    //解散队伍接口
    function exit_event(td, cb1, cb2) {
        var option = {
            url: 'delete_team',
            dataType: 'json',
            type: 'post',
            data: {id: td},
            success: function (data) {
                cb1(data);
            },
            complete: function () {
                cb2();
            }
        };
        $.ajax(option);
    }

    //删除队员接口
    function delete_member(md, td, cb1, cb2) {
        var option = {
            url: 'leader_delete_player',
            dataType: 'json',
            type: 'post',
            data: {user_id: md, team_id: td},
            success: function (data) {
                cb1(data);
            },
            complete: function () {
                cb2();
            }
        };
        $.ajax(option);
    }

    //获取学校
    function get_school(space) {
        var val1 = SCHOOL_DATA.type;
        var val2 = SCHOOL_DATA.district;
        var group = SCHOOL_DATA.typeName;
        var district = SCHOOL_DATA.districtName;
        if (val1 != 0 && val2 != 0) {
            var option = {
                url: '/api/v1/users/school',
                dataType: 'json',
                data: {school_type: val1, district: val2},
                success: function (data) {
                    $('#add-school').find('.items').empty();
                    if (data.schools) {
                        $.each(data.schools, function (k, v) {
                            var id = v.id;
                            var name = v.name;
                            var html = $('<li class="item"><div data-school-id="' + id + '" class="choice-school">' + name + '</div></li>');
                            $('#add-school').find('.items').append(html);
                        });
                        $('.choice-school').off('click').on('click', function () {
                            var _self = $(this);
                            var id = _self.attr('data-school-id');
                            for (var i = 0; i < SCHOOL_DATA.school_list.length; i++) {
                                if (id == SCHOOL_DATA.school_list[i].id) {
                                    alert('请不要重复选择！');
                                    return;
                                }
                            }
                            var text = group + '-' + district + '-' + _self.text();
                            space.find('.school-target').prepend('<div data-id="' + id + '" class="edit-school">' + text + '<i class="glyphicon glyphicon-remove-circle"></i></div>');
                            space.find('.school-target').find('i').off('click').on('click', function () {
                                var p = $(this).parent();
                                var id = p.attr('data-id');
                                if (confirm('是否删除' + text + '学校')) {
                                    remove_school(id);
                                    p.remove();
                                }
                            });
                            SCHOOL_DATA.school_list.push({'id': id, 'name': _self.text()});
                            $('#add-school').find('.items').empty();
                            $('#school-list').modal('hide');
                        });
                    }
                }
            };
            $.ajax(option);
        }
    }

    function getInfo() {
        var s = "";
        s = "\n网页可见区域宽：" + document.body.clientWidth;
        s += "\n网页可见区域高：" + document.body.clientHeight;
        s += "\n网页可见区域宽：" + document.body.offsetWidth + " (包括边线和滚动条的宽)";
        s += "\n网页可见区域高：" + document.body.offsetHeight + " (包括边线的宽)";
        s += "\n网页正文全文宽：" + document.body.scrollWidth;
        s += "\n网页正文全文高：" + document.body.scrollHeight;
        s += "\n网页被卷去的高(ff)：" + document.body.scrollTop;
        s += "\n网页被卷去的高(ie)：" + document.documentElement.scrollTop;
        s += "\n网页被卷去的左：" + document.body.scrollLeft;
        s += "\n网页正文部分上：" + window.screenTop;
        s += "\n网页正文部分左：" + window.screenLeft;
        s += "\n屏幕分辨率的高：" + window.screen.height;
        s += "\n屏幕分辨率的宽：" + window.screen.width;
        s += "\n屏幕可用工作区高度：" + window.screen.availHeight;
        s += "\n屏幕可用工作区宽度：" + window.screen.availWidth;
        s += "\n你的屏幕设置是：" + window.screen.colorDepth + "位彩色";
        s += "\nwindow.innerHeight：" + window.innerHeight;
        alert(s);
    }

    //未报名
    function no_apply(ed) {
        if (EVENT_DATA[ed].max_num == 1) {
            //单人
            start_single_confirm(ed);
        } else {
            //多人
            start_team_step(ed);
            console.log(EVENT_DATA);
        }
    }

    //团队报名开始
    function start_team_step(ed) {
        var space = $('.search-team');
        space.addClass('active');
        search_team.init(ed);

        //团队创建队伍
        $('.btn-create-team').off('click').on('click', function (event) {
            event.preventDefault();
            space.removeClass('active');
            space = $('.create-team');
            space.addClass('active');
            space.find('.open-school').off('click').on('click', function () {
                SCHOOL_DATA.type = space.find('input[name="group"]').val();
                if (!SCHOOL_DATA.type) {
                    return alert('请选择组别');
                }
                SCHOOL_DATA.typeName = space.find('select[data-select-target="group"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                SCHOOL_DATA.district = space.find('input[name="district"]').val();
                if (!SCHOOL_DATA.district) {
                    return alert('请选择区县');
                }
                SCHOOL_DATA.districtName = space.find('select[data-select-target="district"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                var length = space.find('.edit-school').length;
                if (length == 2) {
                    alert('学校已满，无法继续添加！');
                } else {
                    get_school(space);
                    $('#school-list').modal('show');
                }
            });

            space.find('.add-other-school').off('click').on('click', function () {
                SCHOOL_DATA.type = space.find('input[name="group"]').val();
                if (!SCHOOL_DATA.type) {
                    return alert('请选择组别');
                }
                SCHOOL_DATA.typeName = space.find('select[data-select-target="group"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                SCHOOL_DATA.district = space.find('input[name="district"]').val();
                if (!SCHOOL_DATA.district) {
                    return alert('请选择区县');
                }
                SCHOOL_DATA.districtName = space.find('select[data-select-target="district"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
                var length = space.find('.edit-school').length;
                if (length == 2) {
                    alert('学校已满，无法继续添加！');
                } else {
                    $('#add-other-school').modal('show');
                }
            });

            //开启添加学校
            add_other_school.init(space);

            space.find('.apply-submit').off('click').on('click', function (event) {
                event.preventDefault();
                var _self = $(this);
                var old = _self.text();
                _self.text('提交中').prop({'disabled': true});
                var data = space.find('form').serialize();
                if (SCHOOL_DATA.school_list[0]) {
                    data += '&school1=' + SCHOOL_DATA.school_list[0].id;
                    if (SCHOOL_DATA.school_list[1]) {
                        data += '&school2=' + SCHOOL_DATA.school_list[1].id;
                    }
                }
                var group = space.find('input[name="group"]').val();
                var identity_card = space.find('input[name="identity_card"]').val();
                var reg = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/;
                if (!reg.test(identity_card) && group == 3) {
                    alert('请输入正确的身份证号！');
                    _self.text(old).prop({'disabled': false});
                } else {
                    var new_data = space.find('form').serializeArray();
                    if (confirm('请确认您的参赛信息：\n' + format_data(space, new_data))) {
                        send_confirm(data, function (result) {
                            if (result[0]) {
                                var data = space.find('form').serialize();
                                data += '&team_event=' + ed;
                                data += '&team_district=' + space.find('input[name="district"]').val();
                                if (SCHOOL_DATA.school_list[0]) {
                                    data += '&sd=' + SCHOOL_DATA.school_list[0].id;
                                    if (SCHOOL_DATA.school_list[1]) {
                                        data += '&skd=' + SCHOOL_DATA.school_list[1].id;
                                    }
                                }
                                create_team(data, function (result) {
                                    if (result[0]) {
                                        alert('报名成功！');
                                        window.location.reload();
                                    } else {
                                        alert(result[1]);
                                    }
                                }, function () {
                                    _self.text(old).prop({'disabled': false});
                                });
                            } else {
                                alert(result[1]);
                            }
                        }, function () {
                            _self.text(old).prop({'disabled': false});
                        });
                    } else {
                        _self.text(old).prop({'disabled': false});
                    }
                }
            });
        });
    }

    //确定单人信息
    function start_single_confirm(ed) {
        var space = $('.single-confirm');
        space.addClass('active');
        space.find('.open-school').off('click').on('click', function () {
            SCHOOL_DATA.type = space.find('input[name="group"]').val();
            if (!SCHOOL_DATA.type) {
                return alert('请选择组别');
            }
            SCHOOL_DATA.typeName = space.find('select[data-select-target="group"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
            SCHOOL_DATA.district = space.find('input[name="district"]').val();
            if (!SCHOOL_DATA.district) {
                return alert('请选择区县');
            }
            SCHOOL_DATA.districtName = space.find('select[data-select-target="district"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
            var length = space.find('.edit-school').length;
            if (length == 2) {
                alert('学校已满，无法继续添加！');
            } else {
                get_school(space);
                $('#school-list').modal('show');
            }
        });

        space.find('.add-other-school').off('click').on('click', function () {
            SCHOOL_DATA.type = space.find('input[name="group"]').val();
            if (!SCHOOL_DATA.type) {
                return alert('请选择组别');
            }
            SCHOOL_DATA.typeName = space.find('select[data-select-target="group"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
            SCHOOL_DATA.district = space.find('input[name="district"]').val();
            if (!SCHOOL_DATA.district) {
                return alert('请选择区县');
            }
            SCHOOL_DATA.districtName = space.find('select[data-select-target="district"]').find('option[value="' + SCHOOL_DATA.type + '"]').text();
            var length = space.find('.edit-school').length;
            if (length == 2) {
                alert('学校已满，无法继续添加！');
            } else {
                $('#add-other-school').modal('show');
            }
        });

        //开启添加学校
        add_other_school.init(space);

        //提交
        space.find('.apply-submit').off('click').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            var old = _self.text();
            _self.text('提交中').prop({'disabled': true});
            var data = space.find('form').serialize();
            if (SCHOOL_DATA.school_list[0]) {
                data += '&school1=' + SCHOOL_DATA.school_list[0].id;
                if (SCHOOL_DATA.school_list[1]) {
                    data += '&school2=' + SCHOOL_DATA.school_list[1].id;
                }
            }
            var group = space.find('input[name="group"]').val();
            var identity_card = space.find('input[name="identity_card"]').val();
            var reg = /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/;
            if (!reg.test(identity_card) && group == 3) {
                alert('请输入正确的身份证号！');
                _self.text(old).prop({'disabled': false});
            } else {
                var new_data = space.find('form').serializeArray();
                if (confirm('请确认您的参赛信息：\n' + format_data(space, new_data))) {
                    send_confirm(data, function (result) {
                        if (result[0]) {
                            var data = space.find('form').serialize();
                            data += '&team_name=' + $('#currentUser').attr('data-userName');
                            data += '&team_event=' + ed;
                            data += '&team_district=' + space.find('input[name="district"]').val();
                            if (SCHOOL_DATA.school_list[0]) {
                                data += '&sd=' + SCHOOL_DATA.school_list[0].id;
                                if (SCHOOL_DATA.school_list[1]) {
                                    data += '&skd=' + SCHOOL_DATA.school_list[1].id;
                                }
                            }
                            create_team(data, function (result) {
                                if (result[0]) {
                                    alert('报名成功！');
                                    window.location.reload();
                                } else {
                                    alert(result[1]);
                                }
                            }, function () {
                                _self.text(old).prop({'disabled': false});
                            });
                        } else {
                            alert(result[1]);
                        }
                    }, function () {
                        _self.text(old).prop({'disabled': false});
                    });
                } else {
                    _self.text(old).prop({'disabled': false});
                }
            }
        });
    }

    //标签初始化
    function init_tag() {
        //取消所有版块显示
        $('.apply-part').removeClass('active');
    }

    //提交确认信息
    function send_confirm(data, success, complete) {
        var option = {
            url: 'update_apply_info',
            dataType: 'json',
            type: 'post',
            data: data,
            success: function (data) {
                success(data);
            },
            complete: function () {
                complete();
            }
        };
        $.ajax(option);
    }

    //创建队伍
    function create_team(data, success, complete) {
        var option = {
            url: 'leader_create_team',
            dataType: 'json',
            type: 'post',
            data: data,
            success: function (data) {
                success(data);
            },
            complete: function () {
                complete();
            }
        };
        $.ajax(option);
    }

    //格式化信息显示
    function format_data(space, arr, is_team) {
        var username = '';
        var student_code = '';
        var gender = '';
        var group = '';
        var district = '';
        var grade = '';
        var bj = '';
        var teacher = '';
        var teacher_mobile = '';
        var school = '';
        var birthday = '';
        var identity_card = '';
        if (SCHOOL_DATA.school_list[0]) {
            school = SCHOOL_DATA.school_list[0].name;
        }
        if (SCHOOL_DATA.school_list[1]) {
            school += '\n      ' + SCHOOL_DATA.school_list[1].name
        }
        var teamname = '';
        for (var i = 0; i < arr.length; i++) {
            var name = arr[i].name;
            var val = arr[i].value;
            if (name == 'username') {
                username = val;
            } else if (name == 'student_code') {
                student_code = val;
            } else if (name == 'gender') {
                gender = val == 1 ? '男' : '女';
            } else if (name == 'group') {
                group = space.find('select[data-select-target="group"]').find('option[value="' + val + '"]').text();
            } else if (name == 'district') {
                district = space.find('select[data-select-target="district"]').find('option[value="' + val + '"]').text();
            } else if (name == 'grade') {
                grade = val;
            } else if (name == 'bj') {
                bj = val;
            } else if (name == 'team_teacher') {
                teacher = val;
            } else if (name == 'teacher_mobile') {
                teacher_mobile = val;
            } else if (name == 'team_name') {
                teamname = val;
                if(teamname.length>5 || teamname.length<2){
                    alert('队伍名长度在2-5个字符之间！');
                    return false;
                }
            } else if (name == 'birthday') {
                birthday = val;
            } else if (name == 'identity_card') {
                identity_card = val;
            }
        }
        var text = '真实姓名：' + username + '\n' +
            '学籍号：' + student_code + '\n' +
            '性别：' + gender + '\n' +
            '生日：' + birthday + '\n' +
            '组别：' + group + '\n' +
            '身份证：' + identity_card + '\n' +
            '区县：' + district + '\n' +
            '学校：' + school + '\n' +
            '班级：' + grade + '年级' + bj + '班' + '\n' +
            '指导老师：' + teacher + '\n' +
            '老师电话：' + teacher_mobile + '\n';

        if (is_team) {
            text += '队伍名称：' + teamname
        }
        return text;
    }

    function remove_school(id) {
        for (var i = 0; i < SCHOOL_DATA.school_list.length; i++) {
            if (id == SCHOOL_DATA.school_list[i].id) {
                SCHOOL_DATA.school_list.splice(i, 1);
                return;
            }
        }
    }
});