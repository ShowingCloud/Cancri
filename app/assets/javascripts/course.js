$('#user-apply-course').on('click', function () {
    var username = $('#user-info-username').val();
    var district = $('#user-info-district').val();
    var school = $('#user-info-school').val();
    var grade = $('#user-info-grade').val();
    var cd = $("#apply-course").val();

    $.ajax({
        url: '/courses/apply',
        type: 'post',
        data: {"username": username, "district": district, "school": school, "grade": grade, "cd": cd},
        success: function (data) {
            if (data[0]) {
                $('#course-user-info').modal('hide');
                alert(data[1]);
            }
            else {
                alert(data[1]);
            }
        }
    })
});