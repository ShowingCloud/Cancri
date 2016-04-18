/**
 * Created by yaolin on 16/4/5.
 */
$(function () {
    var CURRENT_USER_ID = $('.login-info').attr('data-current-user');
    var action = function () {
        lazyload.init();
        rucaptcha.init();
        //authenticity_token.init();
        match_info_toggle.init();
        event_select.init();
        search_team.init();
        school_select.init('#confirm_info');
        school_select.init('.create-team');
        send_confirm.init();
        create_team.init();
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
            var s = $('.selected-display');
            if (s) {
                s.on('change', function () {
                    var _self = $(this);
                    var ed = _self.val();
                    var choice = _self.find('option[data-val="' + ed + '"]');
                    $('.team-panel').removeClass('active');
                    $('.already-apply').removeClass('active');
                    $('.create-team').removeClass('active');
                    $('.confirm_info').removeClass('active');
                    if (ed != 0) {
                        var max_num = choice.attr('data-max-num');
                        var eName = choice.attr('data-name');
                        var is_single = max_num == 1;
                        var option = {
                            url: 'already_apply',
                            type: 'post',
                            dateType: 'json',
                            data: {'ed': ed},
                            success: function (data) {
                                console.log(data);
                                if (data[0]) {
                                    //已报名
                                    $('.already-apply').addClass('active');

                                    show_apply_info(data, eName, max_num);
                                } else {
                                    //未报名
                                    if (is_single) {
                                        //单人项目
                                        $('.confirm_info').addClass('active');
                                    } else {
                                        //多人项目
                                        $('.team-panel').addClass('active');
                                    }
                                }
                                console.log(data[3]);
                            }
                        };
                        $.ajax(option);
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
        init: function (selector) {
            var select1 = $(selector).find('.level');
            var select2 = $(selector).find('.districts');
            select1.on('change', function () {
                get_school(select1, select2, selector);
            });

            select2.on('change', function () {
                get_school(select1, select2, selector);
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
                    }
                };
                $.ajax(option);
            })
        }
    };

    action();

    function show_apply_info(data, eName, max_num) {
        //项目信息
        $('.apply-event-name').text(eName);
        //.append('<div class="add">该项目最多报名人数为' + max_num + '人</div>')
        var tName = data[1][0].name;
        $('.apply-team-name').text(tName);
        var num = data[1].length;
        $('.apply-member-num').text(num + '名');
        if (num < max_num && data[2] != 0) {
            $('.apply-member-num').append('<button class="btn-robodou btn-add-member">添加</button>');
        }
        //队员信息
        var target = $('.apply-member').find('tbody');
        target.empty();
        $.each(data[1], function (k, v) {
            var tr = $('<tr>');
            var tName = '<td>' + v.username + '</td>';
            var tGender = '<td>' + (v.gender == 1 ? '男' : '女') + '</td>';
            var tSchool = '<td>' + v.school + '</td>';
            var tGrade = '<td>' + v.grade + '</td>';
            var tBtn = '<td></td>';
            if (CURRENT_USER_ID != data[1][0].user_id) {
                if (CURRENT_USER_ID != v.id) {
                    tBtn = '<td><button class="btn-robodou btn-remove-member">删除</button></td>';
                }
            }
            tr.append(tName).append(tGender).append(tSchool).append(tGrade).append(tBtn);
            target.append(tr);
        })
    }

    function get_school(s1, s2, selector) {
        var val1 = s1.val();
        var val2 = s2.val();
        var school = $(selector).find('.target-school');
        if (val1 != 0 && val2 != 0) {
            var option = {
                url: '/api/v1/users/school',
                dataType: 'json',
                data: {school_type: val1, district: val2},
                success: function (data) {
                    if (data.schools) {
                        school.empty();
                        $.each(data.schools, function (k, v) {
                            var id = v.id;
                            var name = v.name;
                            var option = $('<option value="' + id + '">' + name + '</option>');
                            school.append(option);
                        })
                    }
                }
            };
            $.ajax(option);
        }
    }

});