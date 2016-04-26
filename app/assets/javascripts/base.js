/**
 * Created by yaolin on 16/4/5.
 */
$(function () {
    var EVENT_DATA = {};
    var SCHOOL_DATA = [];
    var action = function () {
        lazyload.init();
        rucaptcha.init();
        //authenticity_token.init();
        match_info_toggle.init();
        event_select.init();
        //search_team.init();
        //school_select.init('.create-team');
        //send_confirm.init();
        //create_team.init();
        join_activity.init();
        join_volunteer.init();
        add_school.init();
        no_select.init();
        //window.setTimeout(function(){getInfo();},5000);
        fix_height.init('#main');
        $(window).on('resize', function () {
            fix_height.init('#main');
        });
    };

    var fix_height = {
        init: function (selector) {
            var max = document.body.clientHeight;
            var screen = window.innerHeight;
            if (screen > max) {
                $(selector).css({'min-height': screen - 140});
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

    //var authenticity_token = {
    //    init: function () {
    //        var a = $('[name="authenticity_token"]');
    //        if (a) {
    //            a.attr({'value': $('meta[name="csrf-token"]').attr('content')});
    //        }
    //    }
    //};

    var no_select = {
        init: function () {
            var s = $('select[data-select-target]');
            if (s.length > 0) {
                s.on('change', function () {
                    var _self = $(this);
                    _self.siblings('input[name="' + _self.attr('data-select-target') + '"]').val(_self.val());
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
                        if (EVENT_DATA[ed] == undefined) {
                            EVENT_DATA[ed] = {};
                            SCHOOL_DATA = [];
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
                        } else {
                            //in cache
                            if (EVENT_DATA[ed].is_apply) {
                                //已报名
                                show_apply_info(ed)
                            } else {
                                //未报名
                                no_apply(ed);
                            }
                        }
                    }
                });
            }
        }
    };

    var search_team = {
        init: function () {
            var b = $('.btn-search-team');
            if (b) {
                b.on('click', function () {
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
                            data: {ed: $('.selected-display').val(), team_name: $('.team-search-input').val()},
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
                                            join_team.init();
                                        })
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

    var school_select = {
        init: function (selector, space) {
            var select1 = $(selector).find('.group');
            var select2 = $(selector).find('.district');
            select1.on('change', function () {
                get_school(select1, select2, space);
            });

            select2.on('change', function () {
                get_school(select1, select2, space);
            });
        }
    };

    var send_confirm = {
        init: function () {
            $('.btn-send-confirm').on('click', function () {
                var _self = $(this);
                var old = _self.text();
                _self.text('提交中');
                _self.prop({'disabled': true});
                var data = $('#confirm_form').serialize();
                console.log(data);
                var option = {
                    url: 'update_apply_info',
                    dataType: 'json',
                    type: 'post',
                    data: data,
                    success: function (data) {
                        if (data[0]) {
                            alert(data[1]);
                            $('#confirm_info').removeClass('active');
                            $('.create-team').addClass('active');
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
            })
        }
    };

    var join_team = {
        init: function () {
            $('.btn-join-team').on('click', function () {
                var td = $(this).parents('tr').attr('data-td');
                $(this).parents('.team-panel').removeClass('active');
                var con = $('#confirm_info');
                con.addClass('active').find('.btn-send-confirm').css({display: 'none'});
                con.append('<button class="btn-join-confirm" >加入队伍</button>');
                con.find('.btn-join-confirm').on('click', function () {
                    var form = con.find('#confirm_form');
                    var ed = $('.selected-display').val();
                    var data = form.serialize();
                    data += '&join=1';
                    data += '&ed=' + ed;
                    data += '&td=' + td;
                    var option = {
                        url: 'update_apply_info',
                        dataType: 'json',
                        type: 'post',
                        data: data,
                        success: function (data) {
                            console.log(data[1]);
                            alert(data[1]);
                        }
                    };
                    $.ajax(option);
                })
            });
        }
    };

    var create_team = {
        init: function () {
            $('.btn-create-team').on('click', function () {
                $('.team-panel').removeClass('active');
                $('.create-team').addClass('active');
            });

            $('.btn-create-team-all').on('click', function () {
                var form = $('#create-team-form');
                var ed = $('.selected-display').val();
                var data = form.serialize();
                data += '&team_event=' + ed;
                data += '&group=' + 1;
                var option = {
                    url: 'leader_create_team',
                    dataType: 'json',
                    type: 'post',
                    data: data,
                    success: function (data) {
                        console.log(data);
                        if (data[0]) {
                            alert(data[1]);
                            window.location.reload();
                        } else {
                            alert(data[1]);
                        }
                    }
                };
                $.ajax(option);
            })
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
                b.on('click', function () {
                    alert('请去个人中心验证您的手机和邮箱');
                });
            }

            var a = $('.btn-join-volunteer');
            if (a.length > 0) {
                a.on('click', function () {
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
                b.on('click', function (event) {
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
        var space = $('.single-already-info');
        space.addClass('active');
        space.find('.event-name').text(EVENT_DATA[ed].eName);
        space.find('[data-name="username"]').text(EVENT_DATA[ed].team_info[0].username);
        space.find('[data-name="gender"]').text(EVENT_DATA[ed].team_info[0].gender == 1 ? '男' : '女');
        space.find('[data-name="school"]').text(EVENT_DATA[ed].team_info[0].school);
        space.find('[data-name="grade"]').text(EVENT_DATA[ed].team_info[0].grade);
        space.find('.btn-exit-event').on('click', function (event) {
            event.preventDefault();
            var _self = $(this);
            var old = _self.text();
            _self.text('提交中').prop({'disabled': true});
            if (confirm('确定退出比赛么？')) {
                exit_event(EVENT_DATA[ed].team_info[0].team_id, function (data) {
                    console.log(EVENT_DATA);
                    if (data[0]) {
                        alert('退出比赛成功！');
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

    //邀请队员
    function invitation_member(td, tName, ed, eName, obj, old) {
        var e = $('.invitation-email').val();
        var reg = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})+$/;
        if (reg.test(e)) {
            var option = {
                url: 'leader_invite_player',
                type: 'post',
                dataType: 'json',
                data: {team_name: tName, event_name: eName, td: td, ed: ed, invited_email: e},
                success: function (data) {
                    if (data[0]) {
                        alert(data[1]);
                    } else {
                        alert(data[1]);
                    }
                },
                complete: function () {
                    obj.text(old).prop({'disabled': false});
                }
            };
            $.ajax(option);
        } else {
            obj.text(old).prop({'disabled': false});
            alert('请输入正确的邮箱格式！');
        }
    }

    //获取学校
    function get_school(s1, s2, space) {
        var val1 = s1.val();
        var val2 = s2.val();
        var group = s1.find('option[value=' + val1 + ']').text();
        var district = s2.find('option[value=' + val2 + ']').text();
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
                        $('.choice-school').on('click', function () {
                            var _self = $(this);
                            var id = _self.attr('data-school-id');
                            console.log(SCHOOL_DATA);
                            console.log(id);
                            console.log($.inArray(id, SCHOOL_DATA));
                            if ($.inArray(id, SCHOOL_DATA) >= 0) {
                                alert('请不要重复选择！');
                            } else {
                                var text = group + '-' + district + '-' + _self.text();
                                space.find('.school-target').prepend('<div class="edit-school">' + text + '</div>');
                                SCHOOL_DATA.push(id);

                                $('#add-school').find('.items').empty();
                                $('#school-list').modal('hide');
                            }
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
            show_team_info(ed);
        }
    }

    function start_single_confirm(ed) {
        var space = $('.single-confirm');
        space.addClass('active');
        $('.open-school').on('click', function () {
            var length = $('.edit-school').length;
            if (length == 2) {
                alert('学校已满，无法继续添加！');
            } else {
                $('#school-list').modal('show');
            }
        });

        $('.add-other-school').on('click',function(){
            var length = $('.edit-school').length;
            if (length == 2) {
                alert('学校已满，无法继续添加！');
            } else {
                $('#add-other-school').modal('show');
            }
        });
        //开启学校选择
        school_select.init('#add-school', space);
    }

    function init_tag() {
        //取消所有版块显示
        $('.apply-part').removeClass('active');
    }

});