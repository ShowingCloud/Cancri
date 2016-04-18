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
                    $('.confirm-info').removeClass('active');
                    $('.confirm—info').removeClass('active');
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
                                if (data[0]) {
                                    //已报名
                                    $('.already-apply').addClass('active');

                                    show_apply_info(data, eName, max_num);
                                } else {
                                    //未报名
                                    if (is_single) {
                                        //单人项目
                                        $('.confirm—info').addClass('active');
                                    } else {
                                        //多人项目
                                        $('.team-panel').addClass('active');
                                    }
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
        init: function () {
            var b = $('.btn-search-team');
            if (b) {
                b.on('click', function () {
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
                                            var tr = $('<tr>');
                                            var tName = '<td>' + v.name + '</td>';
                                            var tLeader = '<td>' + v.leader + '</td>';
                                            var tTeacher = '<td>' + v.teacher + '</td>';
                                            var tSchool = '<td>' + v.school + '</td>';
                                            var tBtn = '<td>' + (v.players == v.max_num ? '队伍已满' : '<button class="btn-robodou btn-join-team">加入</button>') + '</td>';
                                            tr.append(tName).append(tLeader).append(tTeacher).append(tSchool).append(tBtn);
                                            target.append(tr);
                                        })
                                    }
                                } else {
                                    //参数错误 false
                                    alert(data);
                                }
                            }
                        };
                        $.ajax(option);
                    } else {
                        alert('请输入汉字、数字和字母');
                    }
                })
            }
        }
    };
    action();

    function show_apply_info(data, eName, max_num) {

        console.log(data);

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
});