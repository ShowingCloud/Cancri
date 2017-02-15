$('#user-apply-course').on('click', function() {
    var username = $('#user-info-username').val();
    var district = $('#user-info-district').val();
    var school = $('#user-info-school').val();
    var grade = $('#user-info-grade').val();
    var cd = $("#apply-course").val();

    $.ajax({
        url: '/courses/apply',
        type: 'post',
        data: {
            "username": username,
            "district": district,
            "school": school,
            "grade": grade,
            "cd": cd
        },
        success: function(data) {
            if (data[0]) {
                $('#course-user-info').modal('hide');
                alert(data[1]);
                window.location.reload();
            } else {
                if (data[1] === '请先在个人中心添加手机') {
                    BootstrapDialog.alert(data[1], function() {
                        window.location = '/user/mobile';
                    });
                } else {
                    alert(data[1]);
                }
            }
        }
    });
});
$('.alert-add-mobile').on('click', function() {
    alert('请先在个人中心添加手机');
    window.location = '/user/mobile';
});

//  create course select date init
$('input[data-type="select-date"]').datepicker({
    autoclose: true
});
