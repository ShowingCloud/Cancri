$(function () {

    $('.update-user-info-submit').on('click', function (event) {
        event.preventDefault();
        var username = $('#username').val();
        var gender = $('#gender').val();
        var district_id = $('#district-id').val();
        var school_id = $('#school-id').val();
        var birthday = $('#birthday').val();
        var identity_card = $('#identity_card').val();
        var grade = $('#grade').val();
        var student_code = $('#student_code').val();
        var team_group = $('#team-group').val();
        var team_teacher = $('#team-teacher').val();
        var teacher_mobile = $('#team-teacher-mobile').val();
        var ed = $('#event-identify').val();

        $.ajax({
            url: '/competitions/leader_create_team',
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
                "team_group": team_group,
                "teacher_name": team_teacher,
                "teacher_mobile": teacher_mobile,
                "team_event": ed
            },
            success: function (data) {
                if (data[0]) {
                    $('#update-user-info').modal('hide');
                    alert_r(data[1], function () {
                        window.location.reload();
                    });
                } else {
                    alert_r(data[1]);
                }
            }
        });
    });


    //创建队伍
    $('#step-for-new').on('click', function (event) {
        event.preventDefault();
        $('#step-for-update').removeClass('hide');
        $(this).parents('.first-step').addClass('hide');
    });

    //加入队伍
    $('#step-for-join').on('click', function (event) {
        event.preventDefault();
        $('#step-for-search').removeClass('hide');
        $(this).parents('.first-step').addClass('hide');
    });

    $('.join-team-submit').on('click', function (event) {
        event.preventDefault();
        var username = $('#username-join').val();
        var gender = $('#gender').val();
        var district_id = $('#district-id').val();
        var school_id = $('#school-id').val();
        var birthday = $('#birthday-join').val();
        var identity_card = $('#identity_card-join').val();
        var grade = $('#grade-join').val();
        var student_code = $('#student_code-join').val();
        var td = $('#join-team-id').val();

        $.ajax({
            url: '/competitions/apply_join_team',
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
                "td": td
            },
            success: function (data) {
                if (data[0]) {
                    $('#update-user-info').modal('hide');
                    alert_r(data[1], function () {
                        window.location.reload();
                    });
                } else {
                    alert_r(data[1]);
                }
            }
        });
    });

    // 搜索队伍
    $('.btn-search-team').on('click', function () {
        var team = $('.search-team-input').val();
        var space = $('.search-part');
        var ed = $('#event-identify').val();
        var reg = /[A-Z]+/i;
        if (reg.test(team)) {
            $.ajax({
                url: '/competitions/search_team',
                dataType: 'json',
                type: 'get',
                data: {ed: ed, team: team},
                success: function (data) {
                    if (data[0] && data[1].length > 0) {
                        var result = data[1][0];
                        space.find('.team-info').remove();
                        space.find('.accept').remove();
                        var info = $('<table class="team-info">' +
                        '<tr>' +
                        '<td>队伍编号</td>' +
                        '<td>' + result.identifier + '</td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td>队长姓名</td>' +
                        '<td>' + result.username + '</td>' +
                        '</tr>' +
                        '<td>所属学校</td>' +
                        '<td>' + result.school_name + '</td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td>指导老师</td>' +
                        '<td>' + result.teacher + '</td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td>老师电话</td>' +
                        '<td>' + result.teacher_mobile + '</td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td>队伍人数</td>' +
                        '<td>' + result.players + '</td>' +
                        '</tr>' +
                        '</table>');
                        space.append(info);
                        if (result.status == 0 && result.players < result.team_max_num) {
                            var btn = $('<div class="accept">' +
                            '<button data-id="' + result.id + '" class="btn-primary btn btn-block btn-join-team">加入该队</button>' +
                            '</div>');
                            space.append(btn);
                        }
                        $('.btn-join-team').on('click', function (event) {
                            event.preventDefault();
                            space.find('.team-info').remove();
                            space.find('.accept').remove();
                            var id = $(this).attr('data-id');
                            $('#step-for-search').addClass('hide');
                            $('#step-for-join-team').removeClass('hide').append('<input type="hidden" id="join-team-id" value="' + id + '">');

                        });
                    } else {
                        alert_r('未查询到该队伍');
                    }
                },
                error: function (data) {
                    alert_r('查询出错！请稍后重试！');
                }
            });
        } else {
            alert_r('请输入队伍编号');
        }
    });

    $('#search-player').on('click', function () {
        var invited_name = $('.search-player-input').val();
        if (invited_name) {
            $.ajax({
                url: '/competitions/search_user',
                dataType: 'json',
                type: 'get',
                data: {invited_name: invited_name},
                success: function (data) {
                    if (data[0]) {
                        if (data[1].length == 0) {
                            alert_r('未查询到相关用户');
                        } else {
                            var result = data[1];
                            $('.table-player-show').removeClass('hide');
                            var tbody = $(".table-player-show").find('tbody');
                            tbody.empty();
                            $('.search-player-input').val('');
                            $.each(result, function (k, v) {
                                var tr = $('<tr><td>' + v.nickname + '</td>' +
                                '<td>' + v.username + '</td>' +
                                '<td>' + v.school_name + '</td>' +
                                '<td>' + v.grade + '</td>' +
                                '<td><button class="btn btn-xs btn-info" onclick="invite_player(' + v.user_id + ')" data-user="' + v.user_id + '">邀请</button></td>' +
                                '</tr>');
                                tbody.append(tr);
                            });
                        }
                    } else {
                        alert_r(data[1]);
                    }
                },
                error: function (data) {
                    alert_r(data["status"])
                }
            });
        } else {
            alert_r('请输入前两个名字')
        }
    });

    $('#team-group').on('change', function () {
        var _self = $(this);
        var group = _self.val();
        var g = $('#grade');
        var icd = $('.identity-group');
        g.find('option').show();
        var a = [];
        switch (group) {
            case '0':
                //未选择
                g.prop('disabled', true);
                icd.addClass('hide');
                break;
            case '1':
                //小学组
                g.prop('disabled', false);
                a = [7, 8, 9, 10, 11, 12];
                icd.addClass('hide');
                break;
            case '2':
                //中学组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5, 6];
                icd.addClass('hide');
                break;
            case '3':
                //初中组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5, 6, 10, 11, 12];
                icd.addClass('hide');
                break;
            case '4':
                //高中组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5, 6, 7, 8, 9];
                icd.removeClass('hide');
                break;
        }

        if (a.length > 0) {
            for (var i = 0; i < a.length; i++) {
                $(g.find('option').get(a[i])).hide();
            }
            if ($.inArray(parseInt(g.val()), a) > -1) {
                g.val(0);
            }
        }
    })
});

function invite_player(user_id) {
    var team_id = $('#team-identify').val();
    if (confirm('确认邀请该用户?')) {
        $.ajax({
            url: '/competitions/leader_invite_player',
            dataType: 'json',
            type: 'post',
            data: {td: team_id, ud: user_id},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1]);
                    $('.table-player-show').addClass('hide');
                    var team_players_info = $('#team-players-info').find('tbody');
                    var tr_info = $('<tr id="team-player-' + user_id + '"><td>' + data[2] + '</td><td>' + data[3] + '</td>' +
                    '<td></td><td></td>' +
                    '<td>队员(待确认)</td><td><button class="btn btn-xs btn-info" onclick="leader_delete_player(' + user_id + ')">清退</button></td></tr>');
                    team_players_info.append(tr_info);
                } else {
                    alert_r(data[1]);
                }
            }
        });
    }
}

// 队长解散队伍
function leader_delete_team(team_id) {
    if (confirm('确定解散队伍?')) {
        $.ajax({
            url: '/competitions/leader_delete_team',
            dataType: 'json',
            type: 'post',
            data: {td: team_id},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1]);
                    window.location.reload();
                } else {
                    alert_r(data[1]);
                }
            }
        })
    }
}

// 队长清退队员
function leader_delete_player(ud) {
    var team_id = $('#team-identify').val();
    if (confirm('确定清退该队员?')) {
        $.ajax({
            url: '/competitions/leader_delete_player',
            dataType: 'json',
            type: 'post',
            data: {td: team_id, ud: ud},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1]);
                    $("#team-player-" + ud).addClass('hide');
                } else {
                    alert_r(data[1]);
                }
            }
        })
    }
}

//队长提交报名
function leader_submit_team(td) {
    if (confirm('确定提交报名信息?（提交后无法修改）')) {
        $.ajax({
            url: '/competitions/leader_submit_team',
            dataType: 'json',
            type: 'post',
            data: {td: td},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1], function () {
                        window.location.reload();
                    });
                } else {
                    alert_r(data[1]);
                }
            }
        })
    }
}