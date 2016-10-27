$(function () {

    var chosen_select = $(".chosen-select");
    chosen_select.chosen();
    $('.open-add-player').on('click', function () {
        var event_id = $(this).attr('data-id');
        var event_name = $(this).attr('data-name');
        $('#added-event-id').val(event_id);
        $('.event-name').text(event_name);
    });

    $('#modal-form,#add-team-form').on('shown.bs.modal', function () {
        $(this).find('.chosen-container').each(function () {
            $(this).find('a:first-child').css('width', '420px');
            $(this).find('.chosen-drop').css('width', '420px');
            $(this).find('.chosen-search input').css('width', '410px');

        });
        $(this).find('.chosen-container-multi').css('width', '420px');
        $(this).find('.team-name-foc').focus();
    });
    // 分配裁判到项目
    $('.add-event-worker-submit').on('click', function () {
        var user_ids = $("#window-select-event-worker").val();
        var event_id = $('#added-event-id').val();
        console.log(user_ids);
        if (user_ids != null) {
            $.ajax({
                url: '/admin/competitions/add_event_worker',
                type: 'post',
                data: {
                    "ed": event_id,
                    "user_ids": user_ids
                },
                success: function (data) {
                    if (data[0]) {
                        if (data[1].indexOf('添加失败') >= 0) {
                            alert(data[1]);
                        } else {
                            alert('所选裁判添加成功');
                        }
                        window.location.reload();
                    } else {
                        alert(data[1]);
                    }
                }
            });
        } else {
            alert('请选择裁判');
        }


    });


    add_score_attribute_init();

    $('.select-tl-sa').on("click", function () {
        var esd = $("#score-attribute [name='score-attribute']:checked").val();
        var sa_name = $("#score-attribute [name='score-attribute']:checked").attr('data-id');
        get_tl_sa(esd, sa_name);
        score_attribute.addClass('hidden');
        two_level_sa.removeClass('hidden');
        $('.select-tl-sa').addClass('hidden');
        $('.add-all-score-attribute').addClass('hidden');
        $('#select-all-score-attribute').addClass('hidden');
        select_all_tl_sa.removeClass('hidden');
    });

    $('.delete-event-sa').on("click", function () {
        var sa_id = $(this).attr('data-id');
        if (sa_id && confirm('确认删除?')) {
            $.ajax({
                url: '/admin/events/delete_score_attribute',
                type: 'post',
                data: {"sa_id": sa_id},
                success: function (data) {
                    if (data[0]) {
                        $(".hide-tr" + sa_id).addClass('hide');
                        alert(data[1]);
                    }
                    else {
                        alert(data[1]);
                    }
                }
            });
        }
    });

    $('.edit-event-sa-desc').on('click', function () {
        var name = $(this).attr('data-text');
        var sa_id = $(this).attr('data-id');
        var desc = document.getElementById("sa-desc" + sa_id).innerHTML;

        // 更改窗口
        BootstrapDialog.show({
            title: name + ' 的备注编辑为:',
            message: ' <input type="text" value="' + desc + '" id="after-edit-desc"  class="form-control">',
            cssClass: 'login-dialog ',
            buttons: [
                {
                    label: '更改(enter)',
                    cssClass: 'btn-primary',
                    hotkey: 13, // 按 'enter' 键发送修改请求
                    // 点击更改按钮后的动作
                    action: function (dialogItself) {
                        var after_edit_desc = $('#after-edit-desc').val();

                        // 更改请求
                        $.ajax({
                            url: '/admin/events/edit_event_sa_desc',
                            type: 'post',
                            data: {"sa_id": sa_id, "desc": after_edit_desc},
                            success: function (data) {
                                if (data[0]) {
                                    document.getElementById("sa-desc" + sa_id).innerHTML = after_edit_desc;
                                    // 更改成功提示信息
                                    BootstrapDialog.show({
                                        title: data[1],
                                        cssClass: 'login-dialog',
                                        message: '成功修改为：' + after_edit_desc,
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

    //删除两边空格
    function trim(str) {
        return str.replace(/(^\s*)|(\s*$)/g, "");
    }

    //删除左边的空格
    function ltrim(str) {
        return str.replace(/(^\s*)/g, "");
    }

    //删除右边的空格
    function rtrim(str) {
        return str.replace(/(\s*$)/g, "");
    }

    //操作状态提示框
    if ($('#notice').length > 0) {
        $.gritter.add({
            title: '操作状态:',
            text: $('#notice').text(),
            time: '5000'
        });
    }
    if ($.cookie('menu-min') == 1) {
        $('.sidebar').addClass('menu-min');
    } else {
        $('.sidebar').removeClass('menu-min');
    }
    $('#sidebar-collapse').on('click', function () {
        if ($('.sidebar').hasClass('menu-min')) {
            $.cookie('menu-min', 1, {path: '/'});
        } else {
            $.cookie('menu-min', 0, {path: '/'});
        }
    });


    //时间控件
    $('input[data-control="dateForm"]').datepicker({
        autoclose: true
    });
    $('input[data-control="timeForm"]').timepicker({
        minuteStep: 1,
        showSeconds: false,
        showMeridian: false
    });
    //时间组件合并
    var dateMerge = $('[data-date-merge]');
    if (dateMerge.length > 0) {
        $.each(dateMerge, function () {
            var self = $(this);
            var date = self.find('input[data-date-merge-date]');
            var time = self.find('input[data-date-merge-time]');
            var result = self.find('input[data-date-merge-result]');
            date.on('change', function () {
                var d = date.val();
                var t = time.val();
                result.val(d + ' ' + t);
            });
            time.on('change', function () {
                var d = date.val();
                var t = time.val();
                result.val(d + ' ' + t);
            });
        })
    }

    //search select init
    var searchControl = $('[data-search]');
    if (searchControl.length > 0) {
        $.each(searchControl, function () {
            var self = $(this);
            var target = self.attr('data-search');
            var targetInput = self.find('[name="' + target + '"]');
            var option = self.find('[data-search-option]');
            option.on('click', function () {
                var val = $(this).attr('data-search-option');
                targetInput.val(val);
                self.find('[data-search-text]').text($(this).text());
            });
            var initVal = targetInput.val();
            if (initVal.length > 0) {
                self.find('[data-search-text]').text(self.find('[data-search-option="' + initVal + '"]').text());
            }
        })
    }
});
// event_show
var score_attribute = $('#score-attribute');
var two_level_sa = $('#two-level-sa');
var select_all_tl_sa = $('#select-all-tl-sa');
var sa_ids = [];
var two_level_sa_ids = [];
var ed = $("input[name='event-identifier']").val();
function list_score_attributes_init() {
    $.ajax({
        url: '/api/v1/scores',
        type: 'get',
        dataType: 'json',
        success: function (result) {
            var select_tl_sa = $('.select-tl-sa');
            var add_all_score_attribute = $('.add-all-score-attribute');
            var select_all_score_attribute = $('#select-all-score-attribute');
            score_attribute.before(select_all_score_attribute, add_all_score_attribute, select_tl_sa);
            $.each(result, function (key, val) {
                var list = $('<label class="brand-li">' + ' ' + '<input type="checkbox" name="score-attribute"  class="sa-label" value="' + val.id + '" data-id="' + val.name + '" autocomplete="off">' + '  ' + val.name + '--' + (val.write_type == 1 ? '手动' : val.write_type == 2 ? 'app' : '赛道' ) + '</label>');
                list.on("mouseover", function () {
                    $(this).css({color: "#5bc0de"})
                });
                list.on("mouseout", function () {
                    $(this).removeAttr("style");
                });
                score_attribute.append(list);
            });

            $('.select-all-score-attribute').on("click", function () {

                if ($(this).is(':checked')) {
                    $('.sa-label').prop("checked", true);
                    select_tl_sa.addClass('hidden');
                    add_all_score_attribute.removeClass('hidden');
                } else {
                    $('.sa-label').prop("checked", false);
                    add_all_score_attribute.addClass('hidden');
                }
            });

            score_attribute.on('change', function () {
                var sa_checked_num = $("#score-attribute [name = 'score-attribute']:checked").length;
                var brand_all = $("#score-attribute [name = 'score-attribute']").length;
                if (sa_checked_num == 1) {

                    select_tl_sa.removeClass('hidden');
                    add_all_score_attribute.removeClass('hidden');
                } else if (sa_checked_num == 0) {
                    select_tl_sa.addClass('hidden');
                    add_all_score_attribute.addClass('hidden');
                } else if (sa_checked_num > 1 && sa_checked_num != brand_all) {
                    select_tl_sa.addClass('hidden');
                    add_all_score_attribute.removeClass('hidden');
                    $('.select-all-score-attribute').prop("checked", false);
                } else if (sa_checked_num == brand_all) {
                    $('.select-all-score-attribute').prop("checked", true);
                }
            });
        }
    });
}

function back_select(show) {
    if (show == 0) {
        $('.selected-mark').remove();
        $('.selected-mark:gt(0)').css('display', 'none');
        select_all_tl_sa.remove();
        $('#select-all-score-attribute').removeClass('hidden');
        $("#score-attribute [name='score-attribute']").attr('checked', false);//返回时默认选中0个
        $("#two-level-sa [name='two-level-sa']").attr('checked', false);
        $('.select-all-tl-sa').attr('checked', false);
        score_attribute.removeClass('hidden');
        $('#two-level-sa').empty();
        $('.add-selected-sa').addClass('hidden');
    }
}

function get_tl_sa(esd, sa_name) {

    $.ajax({
        url: '/api/v1/scores?except=' + esd,
        type: 'get',
        dataType: 'json',
        success: function (result) {
            var brand_show = $('<span class="selected-mark" data-id="' + esd + '">' + sa_name + '<span onclick="back_select(0);" title="返回上一级" >x</span></span>');

            $('.selected-info').append(brand_show);
            var add_selected_sa = $('.add-selected-sa');

            two_level_sa.before(select_all_tl_sa, add_selected_sa);
            $.each(result.score_attributes, function (key, val) {
                var list = $('<label class="series-li">' + '<input type="checkbox" name="two-level-sa" class="tl-sa-label" autocomplete="off" value="' + val.id + '">' + ' ' + val.name + '</label>');
                list.on("mouseover", function () {
                    $(this).css({color: "lightskyblue"})
                });
                list.on("mouseout", function () {
                    $(this).removeAttr("style");
                });

                two_level_sa.append(list);
            });

            $('.select-all-tl-sa').on("click", function () {

                if ($(this).is(':checked')) {
                    $('.tl-sa-label').prop("checked", true);
                    add_selected_sa.removeClass('hidden');
                } else {
                    $('.tl-sa-label').prop("checked", false);
                    add_selected_sa.addClass('hidden');
                }
            });
            two_level_sa.on('change', function () {
                var tl_sa_checked_num = $("#two-level-sa [name = 'two-level-sa']:checked").length;
                var sa_all = $("#two-level-sa [name = 'two-level-sa']").length;
                if (tl_sa_checked_num == 1) {
                    add_selected_sa.removeClass('hidden');
                    if (sa_all == 1) {
                        $('.select-all-tl-sa').prop("checked", true);
                    } else {
                        $('.select-all-tl-sa').prop("checked", false);
                    }
                } else if (tl_sa_checked_num == 0) {
                    add_selected_sa.addClass('hidden');
                    if (sa_all == 1) {
                        $('.select-all-tl-sa').prop("checked", false);
                    }
                } else if (tl_sa_checked_num > 1) {
                    add_selected_sa.removeClass('hidden');
                    if (sa_all == 2) {
                        $('.select-all-tl-sa').prop("checked", true);
                    }
                    else {
                        if (tl_sa_checked_num != sa_all) {
                            $('.select-all-tl-sa').prop("checked", false);
                        } else {
                            $('.select-all-tl-sa').prop("checked", true);
                        }
                    }
                }
            });
        }
    });
}

function add_score_attribute_init() {
    $(".open-add-score-attribute").on('click', function () {
        $(".add-score-attribute").slideToggle();
        var checkbox_num = $("#score-attribute [name='score-attribute']").length;
        if (checkbox_num == 0) {
            list_score_attributes_init();
        }
        $('.add-all-score-attribute').on("click", function () {
            var checked_num = $("#score-attribute [name='score-attribute']:checked");
            if (score_attribute) {
                for (var i = 0; i < checked_num.length; i++) {
                    sa_ids[i] = checked_num[i].value;
                }
                $.ajax({
                    url: '/admin/events/add_score_attributes',
                    type: 'post',
                    data: {"ed": ed, "sa_ids": sa_ids},
                    success: function (data) {
                        if (data) {
                            window.location.reload();
                        }
                        else {
                            alert('添加失败');
                        }
                    }
                });
            }
        });
        $('.add-selected-sa').on("click", function () {
            var parent_sa_id = $(".selected-mark").attr('data-id');
            var checked_num = $("#two-level-sa [name='two-level-sa']:checked");
            for (var i = 0; i < checked_num.length; i++) {
                two_level_sa_ids[i] = checked_num[i].value;
            }
            $.ajax({
                url: '/admin/events/add_score_attributes',
                type: 'post',
                data: {"sa_ids": two_level_sa_ids, "parent_id": parent_sa_id, "ed": ed},
                success: function (data) {
                    if (data) {
                        window.location.reload();
                    }
                    else {
                        alert('添加失败');
                    }
                }
            });
        });
    });
}

function delete_event_worker(ud, ed) {
    if (ud && ed) {
        $.ajax({
            url: '/admin/competitions/delete_event_worker',
            type: 'post',
            dataType: 'json',
            data: {"ud": ud, "ed": ed},
            success: function (result) {
                if (result[0]) {
                    $('.hide' + ud + ed).addClass('hide');
                    var worker_c_n = document.getElementById('worker-count-' + ed).innerHTML;
                    document.getElementById('worker-count-' + ed).innerHTML = (worker_c_n - 1);
                    if (worker_c_n - 1 == 0) {
                        $("#worker-count-" + ed).addClass('hide');
                    }
                } else {
                    alert(result[1])
                }

            }
        });
    }

}