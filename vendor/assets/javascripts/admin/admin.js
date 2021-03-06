/**
 * Created by huaxiukun on 16/2/25.
 */
$(function () {
    // ======================== event_volunteers start   ==========================

    var $event_volunteer_type = $("#event_volunteer_event_type");
    if ($event_volunteer_type.length > 0) {
        var $event_vol_type_id = $("#event_volunteer_type_id");
        var $event_volunteer_name = $("#event_volunteer_name");
        $event_volunteer_type.on('change', function () {
            $event_volunteer_name.val('');
            $event_vol_type_id.empty();
            var _self = this;
            var event_type = _self.value;
            if (event_type) {
                var options = {
                    url: '/api/v1/competitions/get_obj_by_status',
                    type: 'get',
                    data: {event_type: event_type, status: 2},
                    success: function (result) {
                        if (result.length > 0) {
                            $event_vol_type_id.append($('<option>请选择所属项目</option>'));
                            $.each(result, function (k, v) {
                                var option = $('<option value="' + v.id + '" data-name="' + v.name + '">' + v.name + '</option>');
                                $event_vol_type_id.append(option);
                            })
                        } else {
                            admin_gritter_notice(false, '没有在显示的比赛或活动');
                        }
                    },
                    error: function (error) {
                        admin_gritter_notice(false, error.responseText);
                    }
                };
                ajax_handle(options);
            }
        });

        $event_vol_type_id.on('change', function () {
            var obj_name = $("#event_volunteer_type_id option:selected").attr('data-name');
            $event_volunteer_name.val(obj_name + '志愿者招募');
        });
    }

    var $volunteer_apply_time = $("#volunteer-apply-datetime");

    if ($("#news_type_checkbox").length > 0) {
        $('input:checkbox').click(function () {
            var _self = $(this);
            if (_self.attr('data-name') == '志愿者招聘' && _self.is(':checked')) {
                $volunteer_apply_time.removeClass('hide');
            } else {
                $volunteer_apply_time.addClass('hide');
            }

        });
    }

    // add event_volunteer_position
    $(".add-ev-position-submit").click(function () {
        var ev_id = $("#event-volunteer-id").val();
        var positions = $("#select-ev-position").val();
        var $write_position = $("#write-volunteer-position");
        var write_position = $write_position.val();
        if (write_position){
            positions = write_position.split('_');
        }
        if (ev_id && positions) {
            var options = {
                url: '/admin/event_vol_positions',
                type: 'post',
                dataType: 'json',
                data: {event_volunteer_id: ev_id, positions: positions},
                success: function (result) {
                    admin_gritter_notice(result.status, result.message);
                    if (result.status) {
                        $write_position.val('');
                        $("#add-ev-position").modal('hide');
                        var selector = '.evp-table';
                        $.get(location.href, function (html) {
                            var doc = $(html).find(selector);
                            $(selector).replaceWith(doc);
                        });
                    }
                },
                error: function (error) {
                    admin_gritter_notice(false, error.responseText);
                }
            };
            ajax_handle(options);
        } else {
            admin_gritter_notice(false, '职位不能为空')
        }
    });
    // ======================== event_volunteers end   ==========================


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

    // 创建特定项目决赛成绩纪录
    $('.check-last-score-exist').on('click', function () {
        var event_id = $(this).attr('data-event');
        if (event_id) {
            $.ajax({
                url: '/admin/events/create_last_score',
                type: 'post',
                data: {"id": event_id},
                success: function (data) {
                    admin_gritter_notice(data[0], data[1]);
                }
            });
        }
    });
    //计算特定项目决赛成绩
    $('.compute-last-score').on('click', function () {
        var event_id = $(this).attr('data-event');
        var schedule = $(this).attr('data-schedule');
        var group = $(this).attr('data-group');
        if (event_id && schedule && group) {
            $.ajax({
                url: '/admin/events/compute_last_score',
                type: 'post',
                data: {"id": event_id, "schedule": schedule, "group": group},
                success: function (data) {
                    admin_gritter_notice(data[0], data[1]);
                    if (data[0]) {
                        window.location = "/admin/events/scores?id=" + event_id + "&schedule=" + schedule + "&group=" + group
                    }
                }
            });
        }
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

    //
    var score_attribute_td = $('.score-attribute-td');
    score_attribute_td.mouseover(function (data) {
        $(this).css('background', '#ffb752');
        var tooltip = '<div class="tooltip-score-attribute" style="border-radius: 10px;width:400px;height:auto;background:#9fe1e7;position:absolute;z-index:10001;padding:0 10px ; line-height: 200%;">'
            + $(this).attr('data-title') + '</br>' +
            '</div>';
        $("body").append(tooltip);
        var tooltip_score_attribute = $('.tooltip-score-attribute');
        $(this).mouseover(function (e) {
            $(this).css('z-index', 10000);

            var topic_event = tooltip_score_attribute;
            topic_event.fadeIn('500');
            topic_event.fadeTo('10', 1.9);
        }).mousemove(function (e) {
            tooltip_score_attribute.css('top', e.pageY - 100);
            tooltip_score_attribute.css('left', e.pageX - 435);
        });
    });
    score_attribute_td.mouseout(function () {
        $(this).css('z-index', 8);
        $('.tooltip-score-attribute').remove();
        $(this).removeAttr('style');
    });
    // update event schedule is show or not in ipad
    $('.update-es-is-show').on('click', function () {
        var _self = $(this);
        var value = _self.is(':checked');
        var es_id = _self.attr('data-id');
        if (value == true || value == false) {
            $.ajax({
                url: '/admin/event_schedules/update_is_show',
                type: 'post',
                data: {"value": value, "esd": es_id},
                success: function (data) {
                    admin_gritter_notice(data["status"], data["message"]);
                }
            });
        } else {
            admin_gritter_notice(false, '值不规范')
        }
    });

    $('.delete-team-score').on('click', function () {
        var sd = $(this).attr('data-score');
        if (sd && confirm('确认删除该成绩?')) {
            $.ajax({
                url: '/admin/events/delete_score',
                type: 'post',
                data: {"sd": sd},
                success: function (data) {
                    admin_gritter_notice(data[0], data[1]);
                    if (data[0]) {
                        $('.score-identifier-' + sd).addClass('hide');
                    }
                }
            });
        } else {
            admin_gritter_notice(false, '成绩不存在')
        }

    });

    // =================================== events end ======================================


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

    // 志愿者审核
    $('.review-volunteer').on('click', function () {
        var user_role_id = $(this).attr('data-id');
        $('.volunteer-review-status-submit').on('click', function () {
            var status = $(".select-review-status [name='review-status']:checked").val();
            if (!status) {
                alert('请选择审核结果');
                return false;
            }

            $.ajax({
                url: '/admin/checks/review_volunteer',
                type: 'post',
                data: {
                    "status": status, "user_role_id": user_role_id
                },
                success: function (data) {
                    admin_gritter_notice(data.status, data.message);
                    if (data.status) {
                        $("#modal-form").modal('hide');
                        $("#volunteer-row-" + user_role_id).addClass('hide');
                    }
                }
            });
            $(".select-review-status [name='review-status']").prop('checked', false);
        });
    });

    $(".select-review-status [name='review-status']").on('click', function () {
        var status = $(".select-review-status [name='review-status']:checked").val();
        if (status == 1) {
            $("#volunteer-position-show").removeClass('hide');
        } else {
            $("#volunteer-position-show").addClass('hide');
        }
    });

    // 活动志愿者录用审核
    $('.open-audit-event-volunteer').on('click', function () {
        var _self = $(this);
        var volunteer_name = _self.attr('data-name');
        $('#volunteer-username').text(volunteer_name);
        var e_v_u_id = _self.attr('data-id');
        var event_type = _self.attr('data-type');

        $('.event-volunteer-status-submit').unbind('click').click(function () {
            var status = $(".select-review-status [name='review-status']:checked").val();
            if (!status) {
                admin_gritter_notice(false, '请选择审核结果');
                return false;
            }
            var data = {
                "status": status,
                "e_v_u_id": e_v_u_id
            };

            if (status == '1') {
                var $position = $("#volunteer-position");
                var position = $position.val();
                var position_name = $position.find("option:selected").text();
                $("#volunteer-position-show").removeClass('hide');
                var $event_id = $("#competition-event-id");
                var event_name = $event_id.find("option:selected").text();
                var event_id = $event_id.val();
                if (status && event_type == 'Competition') {
                    if (event_id) {
                        data.event_id = event_id;
                        data.event_name = event_name;
                    } else {
                        $event_id.focus();
                        admin_gritter_notice(false, '这里是比赛，请选择分配的项目');
                        return false;
                    }
                }
                if (position) {
                    data.position = position;
                } else {
                    $position.focus();
                    admin_gritter_notice(false, '请选择职位');
                    return false;
                }
            } else {
                $("#volunteer-position-show").addClass('hide');
            }

            $.ajax({
                url: '/admin/event_volunteers/audit_event_v_user',
                type: 'post',
                data: data,
                success: function (data) {
                    admin_gritter_notice(data.status, data.message);
                    if (data.status) {
                        $("#show-audit-event-volunteer").modal('hide');
                        document.getElementById("volunteer-user-" + e_v_u_id).innerHTML = '录用';
                        document.getElementById("volunteer-position-" + e_v_u_id).innerHTML = (event_name ? event_name + '<br>' : '') + position_name;
                        document.getElementById("joins-times-" + e_v_u_id).innerHTML = parseInt(document.getElementById("joins-times-" + e_v_u_id).innerHTML) + 1;
                    }
                }
            });
            $(".select-review-status [name='review-status']").prop('checked', false);
        });
    });

    $(".show-update-volunteer").unbind('click').click(function () {

        var e_v_u_id = $(this).attr('data-id');
        var origin_point = trim($("#volunteer-point-" + e_v_u_id).text());
        var origin_desc = trim($("#volunteer-desc-" + e_v_u_id).text());
        var $point_input = $("#update-volunteer-point");
        var $desc_input = $("#update-volunteer-desc");
        if (origin_point != '打分') {
            origin_point = parseFloat(origin_point);
            $point_input.val(origin_point);
        } else {
            origin_point = 0;
        }
        $desc_input.text(origin_desc);

        $(".update-volunteer-point-submit").unbind('click').click(function () {
            var point = $point_input.val();
            var desc = $("#update-volunteer-desc").val();
            if (/^[0-9]+$/.test(point)) {
                var options = {
                    url: '/admin/event_volunteers/update_e_v_u_info',
                    type: 'post',
                    data: {point: point, desc: desc, e_v_u_id: e_v_u_id},
                    success: function (result) {
                        admin_gritter_notice(result.status, result.message);
                        if (result.status) {
                            $("#open-write-point").modal("hide");
                            if (point != origin_point) {
                                var $origin_avg_point = $("#avg-point-" + e_v_u_id);
                                var origin_avg_point = parseFloat($origin_avg_point.text());
                                var joins_times = parseInt($("#joins-times-" + e_v_u_id).text());
                                var avg_point = parseFloat(((parseFloat(point) - origin_point) / joins_times).toFixed(2));
                                $origin_avg_point.text((origin_avg_point + avg_point).toFixed(2));
                            }
                            $("#volunteer-point-" + e_v_u_id).text(point);
                            $("#volunteer-desc-" + e_v_u_id).text(desc);
                        }
                    },
                    error: function (error) {
                        admin_gritter_notice(false, error.responseText);
                    }
                };
                ajax_handle(options);
            } else {
                admin_gritter_notice(false, '积分只能是非负整数！');
                $point_input.focus();
            }

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
                    admin_gritter_notice(data[0], data[1]);
                    if (data[0]) {
                        $('#modal-form-' + id).modal('hide');
                        $("#after-audit-" + id).addClass('hide');
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
        var form_search_toggle = $('.form-search-toggle');
        form_search_toggle.toggleClass('hide show');
        if (form_search_toggle.hasClass('show')) {
            $('#admin-search-input').focus();
        }
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
        var event_id = $('.event-id').val();
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
                        admin_gritter_notice(data[0], data[1]);
                        if (data[0]) {
                            $("#hide-team-" + team_id).addClass('hide');
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
        var selected_option = $("#select-create-team-leader option:selected");
        var user_id = selected_option.val();
        var leader_info = selected_option.text();

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
                        $("#add-team-form").modal('hide');
                        var team_max_num = $('#team-players-max').val();
                        var team_html = $('<div class="col-xs-12 col-sm-6 col-md-4" id="hide-team-' + data[2]['id'] + '"><div class="widget-box">' +
                            '<div class="widget-header widget-header-small"><h4><i class="icon-flag-alt orange"></i><span class="badge" id="' + data[2]['id'] + '" style="font-size: 15px;padding: 3px 6px 3px 6px">1</span>' + data[2]['identifier'] + '报名成功</h4>' +
                            '<div class="widget-toolbar action-buttons"><a class="pink admin-delete-team" onclick="admin_delete_team(' + data[2]['identifier'] + ',' + data[2]['id'] + ')" style="cursor: pointer" data-id="' + data[2]['id'] + '" data-name="' + data[2]['identifier'] + '"><i class="icon-trash" title="删除队伍"></i></a>' +
                            '</div></div><div class="widget-body"><div class="widget-main padding-8"><div class="event-team profile-feed"><div class="profile-activity clearfix" id="hide-player-' + data[2]['user_id'] + '"><div>' + leader_info + '</div><div class="tools action-buttons"> 队长' +
                            '<a href="#update-team-player" role="button" data-toggle="modal" class="blue update-team-player" style="cursor: pointer" title="换人" data-id="<%= team.id %>" data-user-id="' + data[2]['id'] + '" data-name="' + data[2]['identifier'] + '"><i class="icon-pencil bigger-125"></i></a>' +
                            '</div></div></div></div></div></div></div>');
                        $('.team-elements').prepend(team_html);
                        // window.location.reload();

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