$(function() {
    // 新手引导
    var competition_tips = {
      status:{
          index: 0
        },
        config: {
            tips: [{
                    msg: "报名前请先阅读报名流程后，再根据流程进行操作",
                    highlight: "#apply-flow-btn"
                },
                {
                    msg: "完善/更新选手信息后，选择比赛和项目进行报名",
                    highlight: ".middle"
                },
                {
                    msg: "多人项目需要等待所有队员加入后提交，单人项目选择项目即可提交。",
                    highlight: null
                }
            ],
            defalut_sytle: {
                position: "absolute",
                right: "50%",
                top: "60%",
                transform: "translate(50%, -50%)"
            }
        },
        init: function() {
            Date.prototype.sameDay = function(d) {
                return this.getFullYear() === d.getFullYear() && this.getDate() === d.getDate() && this.getMonth() === d.getMonth();
            };
            var comp_tips_open = window.localStorage.getItem("comp_tips_open");
            if (!comp_tips_open || !new Date().sameDay(new Date(comp_tips_open))) {
                competition_tips.open();
            }
        },
        open: function() {
            $(".main-overlay").css("display", "block");
            competition_tips.next();
        },
        next: function() {
            function show(target, msg, next_callback) {
                $(".competition-tip").remove();
                var ele = $(target);
                var style;
                if (ele.length) {
                    var top = ele.position().top + ele.outerHeight();
                    var height = $(window).height();
                    if (top < height / 2) {
                        style = {
                            position: "absolute",
                            right: ($(window).width() - (ele.offset().left + ele.outerWidth())) + "px",
                            top: (top + 50) + "px"
                        };
                    } else {
                        style = competition_tips.config.defalut_sytle;
                    }
                } else {
                    style = competition_tips.config.defalut_sytle;
                }

                var container = $(".main");
                var tip_ele = $('<div class="competition-tip"><span class="close">关闭</span><div class="msg">' + msg + '</div></div>');
                tip_ele.css(style);
                container.append(tip_ele);
                tip_ele.find('.close').click(function() {
                    competition_tips.close();
                });
                if (competition_tips.status.index < competition_tips.config.tips.length - 1) {
                    if (next_callback) {
                        var next_btn = $('<div class="btn-next">下一步</div>');
                        next_btn.click(function() {
                            next_callback();
                        });
                        tip_ele.append(next_btn);
                    }
                }
            }
            var index = competition_tips.status.index;
            var tip = competition_tips.config.tips[index];
            if (tip) {
                if (tip.highlight) {
                    $(tip.highlight).css({
                        "position": "relative",
                        "z-index": "2",
                        "pointer-events": "none"
                    });
                }
                show(tip.highlight, tip.msg, function() {
                    $(tip.highlight).css({
                        "z-index": "0",
                        "pointer-events": "auto"
                    });
                    competition_tips.status.index++;
                    competition_tips.next();
                });
            }
        },
        close: function() {
            window.localStorage.setItem("comp_tips_open", new Date());
            $(".main-overlay").css('display', 'none');
            $(".competition-tip").remove();
        }
    };

    // 报名前检查
    function before_apply(callback) {
        if ($("#signed-in").val() === "false") {
            alert_r("报名前请先登录", function() {
                window.location.href = '/account/sign_in';
            });
        } else {
            if ($("#mobile").text() === "") {
                alert_r("报名前请先登记你的手机号", function() {
                    window.location.href = '/user/mobile';
                });
            } else {
                callback();
            }
        }
    }

    // 邀请队员
    function invite_player(user_id) {
        var team_id = $("#viewTeamModal").data("team_id");
        BootstrapDialog.confirm("邀请用户",function(result) {
                if (result === true) {
                    $.ajax({
                        url: '/competitions/leader_invite_player',
                        dataType: 'json',
                        type: 'post',
                        data: {
                            td: team_id,
                            ud: user_id
                        },
                        success: function(data) {
                            if (data[0]) {
                                alert_r(data[1]);
                                $('#search-player-result').addClass('hidden');
                                var players_table = $('#players-table').find('tbody');
                                var tr_info = $('<tr id="team-player-' + user_id + '"><td>' + data[2] + '</td><td>' + data[3] + '</td>' +
                                    '<td></td><td></td>' +
                                    '<td>队员(待确认)</td><td><button class="btn btn-xs btn-info" onclick="leader_delete_player(' + user_id + ')">清退</button></td></tr>');
                                players_table.append(tr_info);
                            } else {
                                alert_r(data[1]);
                            }
                        }
                    });
                }
        });
    }

    // 队长解散队伍
    function leader_delete_team(team_id) {
        BootstrapDialog.confirm("确定解散队伍?",function(result) {
                if (result === true) {
                    $.ajax({
                        url: '/competitions/leader_delete_team',
                        dataType: 'json',
                        type: 'post',
                        data: {
                            td: team_id
                        },
                        success: function(data) {
                            if (data[0]) {
                                alert_r(data[1]);
                                window.location.reload();
                            } else {
                                alert_r(data[1]);
                            }
                        }
                    });
                }
        });
    }

    // 队长清退队员
    function leader_delete_player(ud) {
        var team_id = $("#viewTeamModal").data("team_id");
        BootstrapDialog.confirm("确定清退该队员?",function(result) {
                if (result === true) {
                    $.ajax({
                        url: '/competitions/leader_delete_player',
                        dataType: 'json',
                        type: 'post',
                        data: {
                            td: team_id,
                            ud: ud
                        },
                        success: function(data) {
                            if (data[0]) {
                                alert_r(data[1]);
                                $("#team-player-" + ud).addClass('hide');
                            } else {
                                alert_r(data[1]);
                            }
                        }
                    });
                }
        });
    }

    //队长提交报名
    function leader_submit_team(td) {
        BootstrapDialog.confirm("确定提交比赛信息?",function(result) {
                if (result === true) {
                    $.ajax({
                        url: '/competitions/leader_submit_team',
                        dataType: 'json',
                        type: 'post',
                        data: {
                            td: td
                        },
                        success: function(data) {
                            if (data[0]) {
                                alert_r(data[1], function() {
                                    window.location.reload();
                                });
                            } else {
                                alert_r(data[1]);
                            }
                        }
                    });
                }
            });
    }

    function player_status(status){
      switch (status) {
        case 0:
        //申请加入
          return "<a class='btn btn-xs btn-info'>同意加入</a>";
        case 1:
        //已加入
          return "已加入";
        case 2:
        //已被邀请
          return "已被邀请";
        default:
          return "未知";
      }
    }

    // 提交创建队伍表单
    $('#competition-apply-batch-submit').click(function() {
        var fields = [
            {
                "field": "username",
                "msg": "请填写姓名(2-10位的中文或英文字符)！",
                "validate": {
                    "rule": /^[a-zA-Z\u4e00-\u9fa5]{2,10}$/,
                    "msg": "请填写姓名(2-10位的中文或英文字符)！"
                }
            },
            {
                "field": "gender",
                "msg": "请选择性别！"
            },
            {
                "field": "school_id",
                "msg": "请选择学籍所在学校！"
            },
            {
                "field": "sk_station",
                "msg": "请选择报名学校！"
            },
            {
                "field": "grade",
                "msg": "请选择年级！"
            },
            {
                "field": "bj",
                "msg": "请选择年级！！"
            },
            {
                "field": "birthday",
                "msg": "请填写生日！"
            },
            {
                "field": "student_code",
                "msg": "请填写学籍号！"
            },
            {
                "field": "identity_card",
                "msg": "请填写身份证号！",
                "validate": {
                    "rule": checkIdcard,
                    "msg": "请填写正确的身份证号！"
                }
            },
            {
                "field": "group",
                "msg": "请选择组别！"
            },
            {
                "field": "teacher",
                "msg": "请填写指导老师！",
                "validate": {
                    "rule": /^[a-zA-Z\u4e00-\u9fa5]{2,10}$/,
                    "msg": "请填写指导老师(2-10位的中文或英文字符)！"
                }
            }
        ];

        function validate(rule, value) {
            if (rule instanceof RegExp) {
                if (rule.test(value)) {
                    return true;
                } else {
                    return false;
                }
            } else if (typeof rule === "function") {
                if (rule(value)) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        var form_error = [];
        var form_data = {};
        var form = $("#competition-apply-batch");
        $.each(fields, function(_index, field) {
            var field_name = field.field;
            var field_tag = form.find("[name='" + field_name + "']");
            var field_val = $.trim(field_tag.val());
            if (field_tag.attr("type") === "radio") {
                field_tag.each(function() {
                    var _this = $(this);
                    if (_this.prop("checked")) {
                        field_val = $.trim(_this.val());
                    }
                });
            }
            if (field_val.length) {
                if (field.validate) {
                    if (validate(field.validate.rule, field_val)) {
                        form_data[field_name] = field_val;
                    } else {
                        form_error.push(field);
                    }
                } else {
                    form_data[field_name] = field_val;
                }
            } else {
                if (field_tag.is(":visible")) {
                    form_error.push(field);
                } else {
                    if (field_tag.attr("type") === "hidden") {
                        form_error.push(field);
                    }
                }
            }
        });

        if (form_error.length) {
            var msg = "";
            $.each(form_error, function(_index, error) {
                msg = msg + "<br>" + error.msg;
            });
            alert_r(msg);
        } else {
            form_data.district = $("#district-id").val();
            var apply = $('#user-apply-info').data("apply");
            if (apply.team_id) {//加入队伍
                form_data.td = apply.team_id;
                $.ajax({
                    url: '/competitions/apply_join_team',
                    type: 'post',
                    data: form_data,
                    success: function(data) {
                        console.log(data);
                        if (data.status === true) {
                            $('#user-apply-info').modal('hide');
                        }
                        alert_r(data.message);
                    }
                });
            } else {//报名项目
                form_data.eds = apply.eds;
                $.ajax({
                    url: '/competitions/leader_batch_apply',
                    type: 'post',
                    data: form_data,
                    success: function(data) {
                        if (data.status === true) {
                            $('#user-apply-info').modal("hide");
                            if (apply.type === "one-event") {
                                alert_r(data.message);
                            }
                        } else {
                            alert_r(data.message);
                        }
                        if ($.isArray(data.success_teams)) {
                            $("#applied-events-wrapper").removeClass("hidden");
                            $("#empty").addClass("hidden");
                            $.each(data.success_teams, function(_index, st) {
                                if (apply.type === "one-event") {//单人项目
                                    $("#applied-events-wrapper tbody").append("<tr data-identifier='" + st.identifier + "'><td>" + st.event_name + "</td><td>单人</td><td>已提交</td></tr>");
                                    $("#one-event-" + st.event_id).remove();
                                } else {//多人项目
                                    $("#multiple_events").find("option[value='" + st.event_id + "']").remove();
                                    $("#applied-events-wrapper tbody").append("<tr data-identifier='" + st.identifier + "'><td>" + st.event_name + "</td><td>多人</td><td><a class='btn btn-lightblue'>提交</a><a class='btn btn-lightblue'>查看队伍</a></td></tr>");
                                    alert_r("你参加" + st.event_name + "的队伍已建立，快把队伍编号：" + st.identifier + "告诉你的小伙伴，让他们加入吧～");
                                }
                            });
                        }
                    }
                });
            }

        }
    });

    // 初始化新手引导
    if ($("#comp-list").length) {
        competition_tips.init();
    }

    // 多人项目最终报名提交
    $("#applied-events-wrapper").on("click", ".submit", function() {
        var identifier = $(this).parents("tr").data('identifier');
        leader_submit_team(identifier);
    });
    //查看队伍
    $("#applied-events-wrapper").on("click", ".view", function() {
        var identifier = $(this).parents("tr").data('identifier');
        $.ajax({
            url: "/api/v1/events/get_team_by_identifier",
            data: {
                identifier: identifier
            },
            success: function(data) {
                var school_name = data.school_name;
                var teacher = data.teacher;
                var modal = $("#viewTeamModal");
                modal.data("team_id",data.team_id);
                modal.find('.info').html(
                    "<div>项目：" + data.event_name + "</div>" +
                    "<div>编号：" + data.identifier + "</div>" +
                    "<div>人数：" + data.players.length + "</div>" +
                    "<div>组别：" + (data.group === 1 ? "小学" : "中学") + "</div>"
                );
                var tbody = modal.find("#players-table tbody");
                tbody.empty();
                $.each(data.players, function(_index, player) {
                    var tr = $("<tr><td>" + player.username + "</td><td>" + getGender(player.gender) + "</td><td>" + school_name + "</td><td>" + teacher + "</td><td>" + player_status(player.status) + "</td><td><a class='btn btn-xs btn-danger require_leader'>删除</a></td></tr>");
                    tbody.append(tr);
                });
                $("#viewTeamModal").modal();
            }
        });
    });
    // 搜索队伍
    $("#search-team-btn").click(function() {
        var identifier = $("#search-team-input").val();
        if ($.trim(identifier).length) {
            $.ajax({
                url: "/api/v1/events/get_team_by_identifier",
                data: {
                    identifier: $.trim(identifier)
                },
                success: function(data) {
                    $("#teams-table-wrapper").removeClass("hidden");
                    var tbody = $("#teams-table tbody");
                    var leader_id = data.leader_id;
                    var leader_name = "";
                    $.each(data.players, function(_index, player) {
                        if (player.user_id === leader_id) {
                            leader_name = player.username;
                        }
                    });
                    var tr = $("<tr><td>" + data.event_name + "</td><td>" + data.group + "</td><td>" + leader_name + "</td><td>" + data.school_name + "</td><td><a class='btn btn-lightblue'>加入</a></td></tr>");
                    tbody.html(tr);
                    tr.find(".btn").click(function() {
                        before_apply(function() {
                            $('#user-apply-info').data("apply", {
                                "team_id": data.team_id,
                                type: "join-team"
                            }).modal();
                        });
                    });
                }
            });
        } else {
            alert_r("请输入队伍编号");
        }
    });

    $("#user-apply-info").on('show.bs.modal', function() {
        var apply_data = $(this).data("apply");
        if (apply_data.type === "join-team") { //普通队员加入队伍时隐藏‘组别’和‘指导老师’
            $("#group-join").addClass('hidden');
            $("#teacher-join").addClass('hidden');
        }
    });
    $("#user-apply-info").on('hide.bs.modal', function() {
        $("#group-join").removeClass('hidden');
        $("#teacher-join").removeClass('hidden');
    });
    // 单人项目报名
    $('#one-event-apply').on('click', function() {
        before_apply(function() {
            if ($("input[name='one-event']:checked").length) {
                var eds = [];
                $("input[name='one-event']:checked").each(function() {
                    eds.push($(this).val());
                });
                $('#user-apply-info').data("apply", {
                    "eds": eds,
                    type: "one-event"
                }).modal();
            } else {
                alert_r('请至少选择一个比赛项目！');
            }
        });
    });
    // 多人项目报名
    $('#multi-event-apply').on('click', function() {
        before_apply(function() {
            var multi_event = $("#multiple_events").val();
            if ($.trim(multi_event).length) {
                $('#user-apply-info').data("apply", {
                    "eds": [multi_event],
                    type: "multi-event"
                }).modal();
            } else {
                alert_r('请选择一个多人比赛项目！');
            }
        });
    });

    $("#search-player-result").on('click','.invite',function(){
      var user_id = $(this).data('user');
      invite_player(user_id);
    });

    // 搜索队员
    $('#search-player-btn').on('click', function() {
        var invited_name = $('#search-player-input').val();
        if (invited_name) {
            $.ajax({
                url: '/competitions/search_user',
                dataType: 'json',
                type: 'get',
                data: {
                    invited_name: invited_name
                },
                success: function(data) {
                    if (data[0]) {
                        if (data[1].length === 0) {
                            alert_r('未查询到相关用户');
                        } else {
                            var result = data[1];
                            var player_result = $('#search-player-result');
                            player_result.removeClass('hidden');
                            var tbody = player_result.find('tbody');
                            tbody.empty();
                            $('.search-player-input').val('');
                            $.each(result, function(k, v) {
                                var tr = $('<tr><td>' + v.nickname + '</td>' +
                                    '<td>' + getGender(v.gender) + '</td>' +
                                    '<td>' + v.school_name + '</td>' +
                                    '<td>' + getGrade(v.grade) + '</td>' +
                                    '<td>' + v.bj + '</td>' +
                                    '<td><button class="btn btn-xs btn-info invite" data-user="' + v.user_id + '">邀请</button></td>' +
                                    '</tr>');
                                tbody.append(tr);
                            });
                        }
                    } else {
                        alert_r(data[1]);
                    }
                },
                error: function(data) {
                    alert_r(data.status);
                }
            });
        } else {
            alert_r('请输入名字的前两个字');
        }
    });

    $('#grade-join').on('change', function(event) {
        event.preventDefault();
        var v = $(this).val();
        if (v >= 10) {
            $('.identity-group-join').removeClass('hide');
        }
    });

    $('#team-group').on('change', function() {
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
                a = [6, 7, 8, 9, 10, 11, 12];
                icd.addClass('hide');
                break;
            case '2':
                //中学组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5];
                icd.addClass('hide');
                break;
            case '3':
                //初中组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5, 10, 11, 12];
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
    });
});
