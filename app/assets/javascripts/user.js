// 课程打分
$('.update-course-score,.create-course-score').on('click', function () {

    var username = $(this).attr('data-name');
    var cud = $(this).attr('data-id');
    var score = '';
    if ($(this).hasClass('update-course-score')) {
        score = document.getElementById(cud).innerHTML;
    }


    // 更改成绩窗口
    BootstrapDialog.show({
        title: username + '的分数为:',
        message: $('<input type="text" value="' + score + '" id="after-edit-score" class="form-control">'),
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
                        url: '/user/course_score',
                        type: 'post',
                        data: {"cud": cud, "score": after_edit_score},
                        success: function (data) {
                            if (data[0]) {
                                document.getElementById(cud).innerHTML = after_edit_score;
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


// selected course opus change event
var course_opus_input = $("#course_opu_cover");
course_opus_input.on('change', function () {
    readURL(this, ['jpeg', 'jpg', 'png', 'gif'], 1);
});

$('.upload-course-opus-submit').click(function (event) {
    event.preventDefault();
    var form = $("#new_course_opu");

    if (course_opus_input.val()) {
        $.ajax({
            url: form.attr('action'),
            type: "POST",
            dataType: "json",
            data: new FormData(form[0]),
            processData: false,
            contentType: false,
            success: function (data) {
                $.notify(data.message);
                if (data.status) {
                    $("#upload-course-opus-modal").modal('hide');
                    course_opus_input.val("");
                    $(".photo-preview").attr("src", "");
                }
            },
            error: function (data) {
                alert(data);
            }
        });
    } else {
        alert('请选择要上传的作品');
        course_opus_input.trigger('click');
        return false;
    }

});
