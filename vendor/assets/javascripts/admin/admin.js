/**
 * Created by huaxiukun on 16/2/25.
 */
$(function () {

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

        $('#update-event-score-sort').on('click', function () {
            var event_id = $('#event-id').val();
            var serialize_json = $('.dd').nestable('serialize');
            var ids = [];
            $.each(serialize_json, function (k, v) {
                ids.push(v["id"]);
            });
            if (ids != []) {
                $.ajax({
                    url: '/admin/events/update_score_attrs_sort',
                    type: 'post',
                    data: {
                        ids: ids, event_id: event_id
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
    $('#event-formula-select').on('change', function () {
        var event_formula = document.getElementById("event-formula-select");
        var sa_value = event_formula.options[event_formula.selectedIndex].text;
        var sa_id = $(this).val();
        var input_symbol = $('<p id="formula-' + sa_id + '"><select name="' + sa_id + '[symbol]"><option value="">请选择符号</option><option value="1" selected>加号</option><option value="0">减号</option></select>&nbsp;&nbsp;' + '' +
            '<input  style="width:100px" type="text" placeholder="分子(正整数)" name="' + sa_id + '[molecule]" />&nbsp;&nbsp;' +
            '<input  style="width:100px" type="text" placeholder="分母(正整数)" name="' + sa_id + '[denominator]" />&nbsp;' + sa_value + '<button title="取消该项" onclick="cancel_formula_element(' + sa_id + ')">x</button></p>');
        $('.event-formula-input').append(input_symbol);

    });
    $('.update-event-formula-submit').on('click', function () {
        var form = $("#event-formula-form");
        var data = form.serializeArray();
        var has_no_error = true;
        $.each(data, function (k, v) {
            var input_name = v.name;
            var input_value = parseInt(v.value);
            if (input_name.indexOf("symbol") >= 0 && input_value != 1 && input_value != 0) {
                admin_gritter_notice(false, '请正确选择符号');
                has_no_error = false;
                return has_no_error;
            }

            if (input_name.indexOf("molecule") >= 0 && (input_value == 0 || isNaN(input_value))) {
                admin_gritter_notice(false, '分子不能为空或0');
                has_no_error = false;
                return has_no_error;
            }
            if (input_name.indexOf("denominator") >= 0 && (input_value == 0 || isNaN(input_value))) {
                admin_gritter_notice(false, '分母不能为空或0');
                has_no_error = false;
                return has_no_error;
            }
        });
        if (!has_no_error) {
            return false;
        }
        if (data.length > 1) {
            $.ajax({
                url: '/admin/events/update_formula',
                type: 'post',
                dataType: "JSON",
                data: data,
                success: function (data) {
                    admin_gritter_notice(data["status"], data["message"])
                }
            });
        } else {
            admin_gritter_notice(false, '请编辑公式')
        }

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

function cancel_formula_element(formula_id) {
    $('#formula-' + formula_id).remove();
}