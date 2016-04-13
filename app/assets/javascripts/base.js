/**
 * Created by yaolin on 16/4/5.
 */
$(function () {
    var action = function () {
        lazyload.init();
        rucaptcha.init();
        authenticity_token.init();
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

    var authenticity_token = {
        init: function () {
            var a = $('[name="authenticity_token"]');
            if (a) {
                a.attr({'value': $('meta[name="csrf-token"]').attr('content')});
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
            var s = $('.selected-display');
            if (s) {
                s.on('change', function () {
                    $('.team-panel').addClass('active')
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
                    }else{
                        alert('请输入汉字、数字和字母');
                    };
                })
            }
        }
    };

    action();

});