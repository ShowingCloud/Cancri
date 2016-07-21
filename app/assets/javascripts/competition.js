$(function () {
    $('.update-user-info-submit').on('click', function () {
        var username = $('#username').val();
        var gender = $('#gender').val();
        var district_id = $('#district_id').val();
        var school_id = $('#school_id').val();
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
                    alert(data[1]);
                    window.location.reload();
                } else {
                    alert(1);
                }
            }
        });
    });

});

