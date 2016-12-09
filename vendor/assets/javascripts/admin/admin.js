/**
 * Created by huaxiukun on 16/2/25.
 */
$(function () {
    // ============================== events start ==============================
    // add event schedule score attrs
    $('.add-schedule-attrs-modal').on('click', function () {
        var _self = $(this);
        var schedule_name = _self.attr('data-name');
        var event_id = _self.attr('data-event');
        var schedule_id = _self.attr('data-schedule');
        $('.added-schedule-name').text(schedule_name);
        $('.add-schedule-sa-submit').on('click', function () {
            var added_sa_ids = $('#event-schedule-sa-values').val();
            if (event_id != null && schedule_id != null && added_sa_ids != null) {
                $.ajax({
                    url: '/admin/events/add_score_attributes',
                    type: 'post',
                    data: {"ed": event_id, "schedule_id": schedule_id, "sa_ids": added_sa_ids},
                    success: function (data) {
                        admin_gritter_notice(data["status"], data["message"]);
                        if (data["status"]) {
                            $('#add-schedule-score-attrs').modal('hide');
                            window.location.reload();
                        }
                    }
                });
            } else {
                admin_gritter_notice(false, '参数不齐全');
            }
        });
    });

    // 选择相应比赛的项目
    $('#select-competition-events').on('change', function () {
        var comp_name = $(this).val();
        var params;
        if (comp_name == '') {
            params = ''
        } else {
            params = '?comp_name=' + comp_name
        }
        window.location = '/admin/events' + params;
    });

    // score_attr is in rounds
    $('.update-sa-in-rounds').on('click', function () {
        var _self = $(this);
        var value = _self.is(':checked');
        var sa_id = _self.attr('data-id');
        if (value == true || value == false) {
            $.ajax({
                url: '/admin/events/update_sa_in_rounds',
                type: 'post',
                data: {"value": value, "sa_id": sa_id},
                success: function (data) {
                    admin_gritter_notice(data["status"], data["message"]);
                }
            });
        } else {
            admin_gritter_notice(false, '值不规范')
        }
    });
    // ============================== events end ==============================

    // 活动打分
    $('.create-activity-score,.update-activity-score').on('click', function () {
        var username = $(this).attr('data-name');
        var aud = $(this).attr('data-id');
        var score = '';
        if ($(this).hasClass('update-activity-score')) {
            score = document.getElementById("activity-score-" + aud).innerHTML;
        }

        // 更改成绩窗口
        BootstrapDialog.show({
            title: username + '的分数为:',
            message: $('<input type="text" value="' + score + '" id="after-edit-score" autofocus class="form-control">'),
            cssClass: 'login-dialog',
            buttons: [
                {
                    label: '提交(enter)',
                    cssClass: 'btn-primary',
                    hotkey: 13, // 按 'enter' 键发送修改请求
                    // 点击更改按钮后的动作
                    action: function (dialogItself) {
                        var after_edit_score = $('#after-edit-score').val();
                        var begin_two_value = after_edit_score.substr(0, 2);
                        var begin_one_value = after_edit_score.substr(0, 1);

                        // 非法数字
                        if (begin_one_value == '0') {
                            if (begin_two_value != '0.') {
                                alert('非法数字');
                                $('#after-edit-score').focus();
                                return false;
                            }
                        }

                        // 必须为非负数
                        var positive_reg = /^\d+(\.\d+)?$/;
                        if (!positive_reg.test(after_edit_score)) {
                            alert('必须为非负数!');
                            $('#after-edit-score').focus();
                            return false;
                        }
                        // 不能超过100分
                        if (parseInt(after_edit_score) > 100) {
                            alert('不能超过100分!');
                            $('#after-edit-score').focus();
                            return false;
                        }

                        // 输入的小数位数不能超过2位
                        var integer = parseInt(after_edit_score);
                        var flt = after_edit_score - parseInt(after_edit_score);
                        var fltln = (after_edit_score.toString()).length - (integer.toString()).length - 1;
                        var fltint = (flt.toString()).substring(2, (fltln + 2));
                        if (fltint.toString().length > 2) {
                            alert('请四舍五入保留两位小数');
                            $('#after-edit-score').focus();
                            return false;
                        }
                        // 更改请求
                        $.ajax({
                            url: '/admin/activities/update_user_score',
                            type: 'post',
                            data: {"aud": aud, "score": after_edit_score},
                            success: function (data) {
                                if (data[0]) {
                                    if ($('.create-activity-score').length > 0) {
                                        var _self = $("#activity-score-" + aud);
                                        _self.removeClass('btn-info');
                                        _self.addClass('btn-warning');
                                    }
                                    document.getElementById("activity-score-" + aud).innerHTML = after_edit_score;
                                    // 更改成功提示信息
                                    BootstrapDialog.show({
                                        title: username + '的成绩',
                                        cssClass: 'login-dialog',
                                        message: '成功更新为：' + after_edit_score,
                                        buttons: [
                                            {
                                                label: 'OK(enter)',
                                                hotkey: 13, // 按 'enter' 键关掉提示信息
                                                action: function (dialogItself) {
                                                    dialogItself.close();
                                                }
                                            }
                                        ]
                                    });
                                }
                                else {
                                    alert(data[1]);
                                }
                            }
                        });
                        dialogItself.close();
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

    });


    // 裁判审核
    $('.update-cw-id').on('click', function () {
        var ckd = $(this).attr('data-id');
        $('.review-referee-info-submit').on('click', function () {
            var status = $(".referee-apply-status [name='referee-apply']:checked").val();
            var comp_wd = $(".comp-worker-" + ckd).val();
            if (ckd) {
                if (!status) {
                    alert('请选择审核结果');
                    return false;
                }
                $.ajax({
                    url: '/admin/checks/review_referee',
                    type: 'post',
                    data: {
                        "status": status, "comp_wd": comp_wd
                    },
                    success: function (data) {
                        if (data[0]) {
                            alert(data[1]);
                            window.location.reload();
                        } else {
                            alert(data[1]);
                        }
                    }
                });
                $(".referee-apply-status [name='referee-apply']").prop('checked', false);
            } else {
                alert('审核对象不存在');
            }
        });

    });
    // 学校审核
    $('.review-user-add-school').on('click', function () {
        var school_id = $(this).attr('data-id');
        $('.school-review-status-submit').on('click', function () {
            var status = $(".select-review-status [name='review-status']:checked").val();
            if (!status) {
                alert('请选择审核结果');
                return false;
            }
            $.ajax({
                url: '/admin/checks/review_school',
                type: 'post',
                data: {
                    "status": status, "school_id": school_id
                },
                success: function (data) {
                    if (data[0]) {
                        alert(data[1]);
                        window.location.reload();
                    } else {
                        alert(data[1]);
                    }
                }
            });
            $(".select-review-status [name='review-status']").prop('checked', false);
        });
    });
    // 积分审核
    $('.audit-user-point').on('click', function () {
        var upd = $(this).attr('data-id');
        $('.audit-point-submit').on('click', function () {
            var status = $(".audit-point-status [name='audit-point']:checked").val();
            if (upd) {
                if (!status) {
                    alert('请选择审核结果');
                    return false;
                }
                $.ajax({
                    url: '/admin/checks/audit_point',
                    type: 'post',
                    data: {
                        "status": status, "upd": upd
                    },
                    success: function (data) {
                        if (data[0]) {
                            alert(data[1]);
                            window.location.reload();
                        } else {
                            alert(data[1]);
                        }
                    }
                });
                $(".audit-point-status [name='audit-point']").prop('checked', false);
            } else {
                alert('审核对象不存在');
            }
        });

    });
    //切换积分审核状态
    $('#change-point-list').on('change', function () {
        var audit_status = $('#change-point-list option:selected').val();
        window.location = '/admin/checks/point_list?audit_status=' + audit_status;
    });
    // 家庭创客审核
    $('.review-hacker-info-submit').on('click', function () {
        var status = $(".hacker-apply-status [name='hacker-apply']:checked").val();
        var id = $(this).attr('data-id');

        if (status) {
            $.ajax({
                url: '/admin/checks/review_hacker',
                type: 'post',
                data: {
                    "status": status, "id": id
                },
                success: function (data) {
                    if (data[0]) {
                        $('#modal-form-' + id).modal('hide');
                        $("#after-audit-" + id).addClass('hide');
                        alert(data[1]);
                    } else {
                        alert(data[1]);
                    }
                }
            });
        } else {
            alert('请选择审核结果');
        }

        $(".hacker-apply-status [name='hacker-apply']").prop("checked", false);
    });

    // 教师审核
    $(".teacher-apply-status [name='teacher-apply']").on('click', function () {
        var status = $(".teacher-apply-status [name='teacher-apply']:checked").val();
        if (status == 1) {
            $(".teacher-apply-level").removeClass('hide');
        } else {
            $(".teacher-apply-level").addClass('hide');
        }
    });
    $('.review-teacher-info-submit').on('click', function () {
        var level;
        var status = $(".teacher-apply-status [name='teacher-apply']:checked").val();
        var ud = $(this).attr('data-id');

        if (status) {
            level = $(".teacher-apply-level [name='teacher-apply-level']:checked").val();
            if (!level && status == 1) {
                alert('请选择老师级别');
                return false;
            }
            $.ajax({
                url: '/admin/checks/review_teacher',
                type: 'post',
                data: {
                    "status": status, "level": level, "ud": ud
                },
                success: function (data) {
                    if (data[0]) {
                        alert(data[1]);
                        window.location.reload();
                    } else {
                        alert(data[1]);
                    }
                }
            });
        } else {
            alert('请选择审核结果');
        }

        $(".teacher-apply-status [name='teacher-apply']").prop("checked", false);
        $(".teacher-apply-level [name='teacher-apply-level']").prop("checked", false);
    });
    $('.btn-search-toggle').on('click', function () {
        $('.form-search-toggle').toggleClass('hide show');
    });
    //编辑大赛进程
    $(".edit-schedule-submit").on('click', function (e) {
        e.preventDefault();
        var sd = $(this).attr('data-id');
        var name = trim($('#schedule-name-' + sd).val());
        var start_time = trim($('#schedule-start-time-' + sd).val());
        var end_time = trim($('#schedule-end-time-' + sd).val());

        if (name == '') {
            alert('名称不能为空！');
            $('#schedule-name-' + sd).focus();
            return false;
        }
        if (start_time == '') {
            alert('开始时间不能为空！');
            return false;
        }
        $.ajax({
            url: '/admin/competition_schedules/update_cs',
            type: 'post',
            data: {
                "name": name, "sd": sd, "start_time": start_time, "end_time": end_time
            },
            success: function (data) {
                admin_gritter_notice(data["status"], data["message"]);
                if (data["status"]) {
                    end_time = data["end_time"] == null ? '' : ' -- ' + data["end_time"];
                    $("#comp-schedule-tr-" + sd).children('td').eq(1)[0].innerHTML = start_time + end_time;
                    $("#edit-schedule-" + sd).modal('hide');
                }
            },
            error: function (data) {
                alert(data[1]);
            }
        });
    });

    // 选择队伍状态
    $('#select-team-status').on('change', function () {
        var event_id = $('.event-id').text();
        var status = $(this).val();
        var status_params;
        if (status == '') {
            status_params = ''
        } else {
            status_params = '&status=' + status
        }
        window.location = '/admin/events/teams?id=' + event_id + status_params;
    });

    // 编辑赛程评分／对抗
    $(".edit-event-schedule-submit").on('click', function (e) {
        e.preventDefault();
        var esd = $(this).attr('data-id');
        var kind = $("input[name='schedule-kind']:checked").val();
        if (!kind) {
            alert('请选择该赛程模式');
            return false;
        }
        $.ajax({
            url: '/admin/event_schedules/update',
            type: 'PUT',
            data: {
                "kind": kind, "esd": esd
            },
            success: function (data) {
                alert(data[1]);
                if (data[0]) {
                    window.location.reload();
                }
            },
            error: function (data) {
                alert(data[1]);
            }
        });
    });
    var dd = $('.dd');
    if (dd.length > 0) {
        dd.nestable();

        $('.update-event-score-sort').on('click', function () {
            var schedule_id = $(this).attr('data-id');
            var event_id = $('#event-id').val();
            var schedule_attr_target_dds = '#update-event-score-sort-' + schedule_id + ' .dd';
            var serialize_json = $(schedule_attr_target_dds).nestable('serialize');
            var ids = [];
            $.each(serialize_json, function (k, v) {
                ids.push(v["id"]);
            });
            if (ids != []) {
                $.ajax({
                    url: '/admin/events/update_score_attrs_sort',
                    type: 'post',
                    data: {
                        ids: ids, event_id: event_id, schedule_id: schedule_id
                    },
                    success: function (data) {
                        admin_gritter_notice(data["status"], data["message"]);
                    },
                    error: function (data) {
                        admin_gritter_notice(false, '更新失败');
                    }
                });
            }

        })
    }

    var max_num = $('.team-max-num').text();
    if (max_num == 1) {
        $('.event-team').slimScroll({
            height: '42px',
            alwaysVisible: true
        });
    } else if (max_num == 2) {
        $('.event-team').slimScroll({
            height: '85px',
            alwaysVisible: true
        });
    } else if (max_num == 3) {
        $('.event-team').slimScroll({
            height: '123px',
            alwaysVisible: true
        });
    } else {
        $('.event-team').slimScroll({
            height: '163px',
            alwaysVisible: true
        });
    }

    // check comp time_schedule and detail_rule
    var rule_detail = $('#check-detail-rule');
    var time_schedule = $('#check-time-schedule');
    if (rule_detail.length > 0) {
        rule_detail.bind('change', function () {
            multiple_check_type_size(rule_detail, ['pdf', 'zip', 'rar'], 10);
        });
    }
    if (time_schedule.length > 0) {
        time_schedule.bind('change', function () {
            multiple_check_type_size(time_schedule, ['pdf', 'zip', 'rar'], 10);
        });
    }
    $('.event-formula-select').change(function () {
        var _self = $(this);
        var index = _self.attr('data-index');
        var sa_value = $("#selected-formula-element-" + index).find("option:selected").text();
        var sa_id = $(this).val();
        var input_symbol = $('<p class="formula-' + sa_id + '"><select class="symbol-' + sa_id + '" name="formula[][symbol]"><option value="">请选择符号</option><option value="1" selected>加</option><option value="2">减</option><option value="3">乘</option><option value="4">除</option></select>&nbsp;&nbsp;&nbsp;' + '' +
            '<input  style="width:90px" class="molecule-' + sa_id + '" type="text" value="1" placeholder="分子(正整数)" name="formula[][molecule]" />&nbsp;&nbsp;&nbsp;' +
            '<input  style="width:90px" class="denominator-' + sa_id + '" type="text" value="1" placeholder="分母(正整数)" name="formula[][denominator]" /><input type="hidden" name="formula[][id]" value="' + sa_id + '" /><input type="hidden" name="formula[][name]" value="' + sa_value + '" />&nbsp;' + sa_value + '&nbsp;<button title="取消该项" class="btn btn-xs btn-info" style="line-height: 10px" onclick="cancel_formula_element(' + sa_id + ',' + index + ')">x</button></p>');
        $('#event-formula-input-' + index).append(input_symbol);

    });
    $('#selected-orders').on('change', function () {
        var select_orders = $('#selected-orders');
        var orders = select_orders.val();
        if (orders != null && orders.length > 1) {
            var selected_option = [];
            for (var i = 0; i < orders.length; i++) {
                selected_option[i] = orders[i].split('++')[0];
            }
            if (is_repeat_array(selected_option)) {
                admin_gritter_notice(false, '同一属性的(升序/降序)只能选择一个');
                select_orders.find('option:selected').removeAttr('selected');
                select_orders.trigger('chosen:updated');
                return false;
            }
        }
    });
    $('.update-event-formula-submit').on('click', function () {
        var sa_id = $(this).attr('data-id');
        var ls_by_name = $('#last-score-by-' + sa_id).find('option:selected').text();
        var trigger_attr_name = $('#trigger-attr-id-' + sa_id).find('option:selected').text();
        $('#last-score-name-' + sa_id).val(ls_by_name);
        $('#trigger-attr-name-' + sa_id).val(trigger_attr_name);
        var form = $("#event-formula-form-" + sa_id);
        var data = form.serializeArray();
        // var formula_sa_id = data[0].value;
        var rounds = $('#formula-rounds-' + sa_id);
        var orders = $('#selected-orders-' + sa_id).val();
        if (['1', '2', '3'].indexOf(rounds.val()) == -1) {
            admin_gritter_notice(false, '请选择轮数');
            rounds.focus();
            return false;
        }
        if (orders == null) {
            admin_gritter_notice(false, '请选择排序');
            return false;
        }

        if (!(orders[0].indexOf("最终成绩") >= 0)) {
            admin_gritter_notice(false, '成绩排序中最终成绩的排序要放在第一位');
            return false;
        }

        var orders_elements = [];
        for (var i = 0; i < orders.length; i++) {
            orders_elements[i] = orders[i].split('++')[0];
        }
        if (is_repeat_array(orders_elements)) {
            admin_gritter_notice(false, '成绩排序中有同一属性出现两次');
            return false;
        }
        var has_no_error = true;
        var orders_length = orders.length;
        var use_formula = false;
        $.each(data, function (k, v) {
            if (k > (orders_length + 2)) {
                var input_name = v.name;
                // var input_id = v.name.split(']')[0].substr(8);
                var input_value = parseInt(v.value);
                if (input_name.indexOf("symbol") >= 0 && ([1, 2, 3, 4].indexOf(input_value)) == -1) {
                    admin_gritter_notice(false, '请正确选择符号');
                    // $("#symbol-" + input_id).focus();
                    has_no_error = false;
                    return has_no_error;
                }

                if (input_name.indexOf("molecule") >= 0 && (input_value == 0 || isNaN(input_value))) {
                    admin_gritter_notice(false, '分子不能为空或0');
                    // $('#molecule-' + input_id).focus();
                    has_no_error = false;
                    return has_no_error;
                }
                if (input_name.indexOf("denominator") >= 0 && (input_value == 0 || isNaN(input_value))) {
                    admin_gritter_notice(false, '分母不能为空或0');
                    // $('#denominator-' + input_id).focus();
                    has_no_error = false;
                    return has_no_error;
                }
                if (input_name == "last_score_by[id]" && input_value == '0') {
                    use_formula = true;
                }
            }

        });

        if (use_formula == true && data[data.length - 1].name != 'formula[][name]') {
            admin_gritter_notice(false, '用公式计算为最终成绩时,公式内容不能为空');
            return false;
        }
        if (!has_no_error) {
            return false;
        }
        if (data.length > (2 + orders_length)) {
            $.ajax({
                url: '/admin/events/update_formula',
                type: 'post',
                dataType: "JSON",
                data: data,
                success: function (data) {
                    admin_gritter_notice(data["status"], data["message"]);
                    if (data["status"]) {
                        $('#edit-formula-' + sa_id).modal('hide');
                        window.location.reload();
                    }
                }
            });
        } else {
            admin_gritter_notice(false, '公式内容不能为空')
        }

    });

    // 添加队员
    $('.open-add-player,.update-team-player').on('click', function () {
        var team_id = $(this).attr('data-id');
        var team_name = $(this).attr('data-name');
        var user_id = $(this).attr('data-user-id');
        $('#add-player-team-id').val(team_id);
        $('.team-name').text(team_name);
        $('#player-old-user-id').val(user_id);
    });

    $('.add-player-submit').on('click', function () {
        var user_id = $("#select-team-player").val();
        var team_id = $('#add-player-team-id').val();
        var event_id = $('.event-id').val();
        $.ajax({
            url: '/admin/events/add_team_player',
            type: 'post',
            data: {
                "team_id": team_id,
                "user_id": user_id,
                "event_id": event_id
            },
            success: function (data) {
                admin_gritter_notice(data[0], data[1]);
                if (data[0]) {
                    window.location.reload();
                }
            }
        });
    });

    // 更换队员
    $('.update-team-player-submit').on('click', function () {
        var old_user_id = $('#player-old-user-id').val();
        var new_user_id = $("#select-update-team-player").val();
        var team_id = $('#add-player-team-id').val();
        var event_id = $('.event-id').val();
        $.ajax({
            url: '/admin/events/update_team_player',
            type: 'post',
            data: {
                "team_id": team_id,
                "new_user_id": new_user_id,
                "old_user_id": old_user_id,
                "event_id": event_id
            },
            success: function (data) {
                admin_gritter_notice(data[0], data[1]);
                if (data[0]) {
                    window.location.reload();
                }
            }
        });
    });

    //删除队员
    $('.delete-team-player').on('click', function () {
        var player = $(this).attr('data-text');
        var user_id = $(this).attr('data-name');
        var team_id = $(this).attr('data-id');
        bootbox.confirm('确认删除队员 —— ' + player + '?', function (result) {
            if (result) {

                $.ajax({
                    url: '/admin/events/delete_team_player',
                    type: 'post',
                    data: {
                        "team_id": team_id,
                        "user_id": user_id
                    },
                    success: function (data) {
                        admin_gritter_notice(data[0], data[1]);
                        if (data[0]) {
                            $('#after-delete-player-show').removeClass('hidden');
                            $("#hide-player-" + user_id).addClass('hide');
                        }
                    }
                });
            }
        });
    });

    //删除队伍
    $('.admin-delete-team').on('click', function () {
        var team_name = $(this).attr('data-name');
        var team_id = $(this).attr('data-id');
        bootbox.confirm('确认删除' + team_name + '?', function (result) {
            if (result) {

                $.ajax({
                    url: '/admin/events/delete_team',
                    type: 'post',
                    data: {
                        "team_id": team_id
                    },
                    success: function (data) {
                        if (data[0]) {
                            $("#hide-team-" + team_id).addClass('hide');
                            bootbox.dialog({

                                message: data[1],
                                buttons: {
                                    "success": {
                                        "label": "OK",
                                        "className": "btn-sm btn-primary"
                                    }
                                }
                            });
                        } else {
                            alert(data[1]);
                        }
                    }
                });
            }
        });
    });
    // 创建队伍
    $('.create-team-submit').on('click', function () {
        var event_id = $('.event-id').val();
        var group = $('#select-team-group').val();
        var teacher = trim($(".team-info [name='team-teacher']").val());
        var user_id = $("#select-create-team-leader option:selected").val();

        if (user_id == '') {
            alert('请选择队长');
            $("＃select-create-team-leader").focus();
            return false;
        }
        if (event_id != null) {
            $.ajax({
                url: '/admin/events/create_team',
                type: 'post',
                data: {
                    "event_id": event_id,
                    "group": group,
                    "user_id": user_id,
                    "teacher": teacher
                },
                success: function (data) {
                    admin_gritter_notice(data[0], data[1]);
                    if (data[0]) {
                        window.location.reload();
                    }
                }
            });
        }
    });
    // 比赛change后选择对应分组
    $('#event_competition_id').on('change', function () {
        var comp_id = $(this).val();
        if (comp_id) {
            $.ajax({
                url: '/api/v1/competitions/get_parent_group',
                data: {comp_id: comp_id},
                type: 'get',
                success: function (data) {
                    var event_parent_select = $('#event_parent_id');
                    event_parent_select.empty();
                    var first_option = $('<option value=""> &nbsp;请选择所属项目</option>');
                    event_parent_select.append(first_option);
                    $.each(data, function (k, v) {
                        var option = $('<option value="' + v.id + '">' + v.comp_name + ' -- ' + v.name + '</option>');
                        event_parent_select.append(option);
                    })
                }
            })
        }

        // $('#event_parent_id')

    });

});
function trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}

function get_file_type(file_name) {
    return file_name.substring(file_name.lastIndexOf(".") + 1);
}

function check_file_type(obj, limit_type, file_type) {
    if ($.inArray(file_type, limit_type) == -1) {
        alert('文件格式不规范,请上传 ' + limit_type.join('、') + ' 格式的文件');
        obj[0].value = '';
        return false;
    } else {
        return true;
    }
}

function check_file_size(obj, limit_size, file_size) {
    var size = file_size / 1024 / 1024;
    if (size > limit_size) {
        alert("文件大小不能大于" + limit_size + "M，请重新选择");
        obj[0].value = '';
        return false;
    } else {
        return true;
    }
}

function multiple_check_type_size(obj, limit_type, limit_size) {
    var has_no_error;
    $.each(obj[0].files, function (k, v) {
        has_no_error = (check_file_type(obj, limit_type, get_file_type(v.name)) && check_file_size(obj, limit_size, v.size));
        if (!has_no_error) {
            return false;
        }
    });
    return !has_no_error;
}

function cancel_formula_element(formula_id, score_attr_id) {
    var selector = "#event-formula-form-" + score_attr_id + ' ' + ".formula-" + formula_id;
    $(selector).remove();
}
// 判断数组是否有重复元素
function is_repeat_array(arr) {
    var hash = {};
    for (var i in arr) {
        if (hash[arr[i]]) {
            return true;
        }
        // 不存在该元素，则赋值为true，可以赋任意值，相应的修改if判断条件即可
        hash[arr[i]] = true;
    }
    return false;
}