/**
 * Created by jason on 15-9-28.
 */
$(function () {
        if ($('body').height() < $(window).height()) {
            $('.floor').height($(window).height());
        }

        if ($('#competition')) {
            $('#competition-items').find('.item').on('click', function () {
                $('.competitions-tab').removeClass('active').eq($(this).index()).addClass('active');
            })
        }

        if ($('.apply-menu-sub')) {
            $('.apply-menu-sub').on('click', function () {
                $(this).parent().find('.apply-menu-sub').removeClass('active');
                $(this).addClass('active');
                $('.apply-content-sub').removeClass('active');
                $('.apply-content-sub').eq($(this).index()).addClass('active');
            });
        }

        if ('#create_team') {
            $('#create_team').on('click', function () {
                var form_data = {
                    event_id: $('.competitions-tab.active').attr('data-id'),
                    team_name: $("input[name='team-name']").val(),
                    team_code: $("input[name='team-code']").val(),
                    teacher: $("input[name='team-teacher']").val()
                };
                var option = {
                    url: '/competitions/valid_create_team',
                    type: 'post',
                    data: form_data,
                    success: function (data) {
                        if (data[0]) {
                            alert(data[1]);
                            window.location.reload();

                        } else {
                            alert(data[1]);
                        }
                    }
                };
                ajaxHandle(option);
            })
        }

        if ('#check_profile') {
            $('.btn-save-profile').on('click', function (event) {
                event.preventDefault();
                var form = $(this).parents('form');
                var option = {
                    url: form.attr('data-url'),
                    type: form.attr('data-method'),
                    data: form.serialize(),
                    success: function (data) {
                        if (data[0]) {
                            alert(data[1]);
                            $('#check_profile').modal('hide');
                            $('#apply_in_competition').modal('show');
                            $('.apply-menu-sub').on('click', function () {
                                get_teams(1, 2)
                            });


                            //$("#page").page({
                            //    remote: {
                            //        url: '/competitions/event_teams',  //请求地址
                            //        params: { id: $('.competitions-tab.active').attr('data-id')},       //自定义请求参数
                            //        success: function (data, pageIndex) {
                            //            //回调函数
                            //            //result 为 请求返回的数据，呈现数据
                            //            console.log(data);
                            //        },
                            //        pageIndexName: 'page',     //请求参数，当前页数，索引从0开始
                            //        pageSizeName: 'per',       //请求参数，每页数量
                            //        totalName: 'total'
                            //    },
                            //    pageSize:9
                            //});


                        } else {
                            alert(data[1]);
                        }
                    }
                };
                ajaxHandle(option);
            })
        }
    }
);

function get_teams(page, num) {
    var data = {
        id: $('.competitions-tab.active').attr('data-id'),
        page: page,
        num: num
    };
    var option = {
        url: '/competitions/event_teams',
        type: 'get',
        data: data,
        success: function (result) {
            console.log(result);
            //替换dom
            replaceDom('.team-list', result[0]);
        }
    };
    ajaxHandle(option);
}

function replaceDom(selector, data) {
    $(selector).empty();
    // name 队伍名称
    // team_players 队伍已有人数
    // team_leader 队长昵称
    // cover 队伍头像
    if (data.length > 0) {
        for (var i = 0; i < data.length; i++) {

            var _dom = '<div class="team-item">' +
                '<div class="team-pic">' +
                '<img src="' + data[i].cover + '" alt=""/>' +
                '</div>' +
                '<div class="team-dec">' +
                '<p class="t-16 blue">' + data[i].name + ' ' + data[i].team_players + '</p>' +
                '<p class="t-14">' + data[i].team_leader + '</p>' +
                '<button data-id="' + data[i].id + '" class="btn-join-team">加入战队</button>' +
                '</div></div>';
            $(_dom).appendTo(selector);
        }
    } else {
        var _dom1 = '<div class="team-item">' +
            '没有相关队伍</div>';
        $(_dom1).appendTo(selector);
    }

    $('.btn-join-team').on('click', function () {
        var team_id = $(this).attr('data-id');
        BootstrapDialog.show({
            title: '请输入该队队长设置的密钥:',
            message: ' <input type="text" value="" id="valid_team_code"  class="form-control">',
            cssClass: 'login-dialog',
            buttons: [
                {
                    label: '提交(enter)',
                    cssClass: 'btn-primary',
                    hotkey: 13, // 按 'enter' 键发送修改请求
                    // 点击提交按钮后的动作
                    action: function () {
                        var team_code = $('#valid_team_code').val();
                        // 提交请求
                        $.ajax({
                            url: '/competitions/valid_team_code',
                            type: 'post',
                            data: {
                                "team_code": team_code,
                                "team_id": team_id
                            },
                            success: function (data) {
                                if (data[0]) {
                                    // 申请成功提示信息
                                    alert(data[1]);
                                }
                                else {
                                    alert(data[1]);
                                }
                            }
                        });

                    }
                },
                // 取消更改按钮
                {
                    label: '取消(esc)',
                    hotkey: 27, // 按 'esc' 键取消修改
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            ]
        });
        //console.log(team_id);
    });
}

$('#select-team-action').on('click', function () {
    var data = {
        id: $('.competitions-tab.active').attr('data-id'),
        page: 1,
        num: 2,
        team_name: $('#search-team-name').val()
    };
    var option = {
        url: '/competitions/event_teams',
        type: 'get',
        data: data,
        success: function (result) {
            //替换dom
            replaceDom('.team-list', result[0]);
        }
    };
    ajaxHandle(option);
});
function ajaxHandle(option) {
    $.ajax(option);
}


/*   /competitions/event_teams?id=<%eventid%>&page=<%page%>    */