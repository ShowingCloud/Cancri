/**
 * Created by huaxiukun on 16/5/31.
 */

function readURL(input, limit_types, file_size_limit) {
    var file_name = $(input).val();
    var file_type = get_file_type(file_name);
    var has_no_error = (check_file_type(input, limit_types, file_type) && check_file_size(input, file_size_limit, input.files[0].size));
    if (has_no_error) {
        var reader = new FileReader();
        reader.onload = function (e) {
            var photo_preview = $('.photo-preview');
            // photo_preview.css('background', 'url(' + e.target.result + ')');
            photo_preview.removeClass('hide');
            photo_preview.attr('src', e.target.result);
        };
        reader.readAsDataURL(input.files[0]);
    } else {
        return false;
    }
}

function get_file_type(file_name) {
    return file_name.substring(file_name.lastIndexOf(".") + 1).toLowerCase();
}

function check_file_type(input, limit_types, file_type) {
    if ($.inArray(file_type, limit_types) == -1) {
        alert('文件格式不规范,请上传 ' + limit_types.join('、') + ' 格式的文件');
        input.value = '';
        return false;
    } else {
        return true;
    }
}

function check_file_size(input, limit_size, file_size) {
    var size = file_size / 1024 / 1024;
    if (size > limit_size) {
        alert("文件大小不能大于" + limit_size + "M，请重新选择");
        input.value = '';
        return false;
    } else {
        return true;
    }
}

function multiple_check_type_size(input, limit_type, limit_size) {
    var has_no_error;
    $.each(input.files, function (k, v) {
        has_no_error = (check_file_type(input, limit_type, get_file_type(v.name)) && check_file_size(input, limit_size, v.size));
        if (!has_no_error) {
            return false;
        }
    });
    return !has_no_error;
}

//删除两边空格
function trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}

// change bs set cookie = 1
$('#select-area').on('change', function () {
    var area = $('#select-area').val();
    if (area == 1) {
        setCookie('area', area, '/');
    } else {
        $.removeCookie('area', {path: '/'});
    }
    window.location.reload();
});

function setCookie(key, value, path) {
    $.cookie(key, value, {path: path});
}

function checkIdcard(num) {
    num = num.toUpperCase();
    var identity_code_reg = /^(\d{6})(?:(?!0000)[0-9]{4}(?:(?:0[1-9]|1[0-2])(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)(\d{3})([0-9]|X)$/;
    return identity_code_reg.test(num);
}

function getAge(dateString) {
    var today = new Date();
    var birthDate = new Date(dateString);
    var age = today.getFullYear() - birthDate.getFullYear();
    var m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
}

function getGender(num){
  switch (num) {
    case 1:
      return "男";
    case 2:
      return "女";
    default:
      return "未知";
  }
}

function getGrade(num){
  var grades = ['一', '二', '三', '四', '五', '六(初中预备)', '七(初中一)', '八(初中二)', '九(初中三)', '高一', '高二', '高三'];
  var result = grades[parseInt(num) - 1];
  if(result){
    return result;
  }else{
    return "未知";
  }
}
