$(function () {
    var admin_cities_select = $("#admin-select-city");
    var admin_districts_select = $("#admin-select-district");

    // province option change
    $('#admin-select-province').on('change', function () {
        var province_id = $(this).val();
        if (province_id != '') {
            $.ajax({
                url: '/api/v1/districts/get_cities',
                type: 'get',
                data: {"province_id": province_id},
                success: function (data) {
                    var data_length = data.length;
                    admin_cities_select.empty();
                    admin_districts_select.empty();
                    admin_districts_select.append($('<option value="">请先选择城市</option>'));
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择城市</option>');
                        admin_cities_select.append(first_option);
                        $.each(data, function (k, v) {
                            var option = $('<option value="' + v.id + '">' + v.name + '</option>');
                            admin_cities_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该省市暂无城市</option>');
                        admin_cities_select.append(first_option);
                    }
                }
            });
        } else {
            admin_gritter_notice(false, '省市不存在')
        }
    });


    // cities option change
    admin_cities_select.on('change', function () {
        var city_id = $(this).val();
        if (city_id != '') {
            $.ajax({
                url: '/api/v1/districts/get_districts',
                type: 'get',
                data: {"city_id": city_id},
                success: function (data) {
                    var data_length = data.length;
                    admin_districts_select.empty();
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择区县</option>');
                        admin_districts_select.append(first_option);
                        $.each(data, function (k, v) {
                            var option = $('<option value="' + v.id + '" data-province="' + v.province_name + '" data-city="' + v.city_name + '">' + v.name + '</option>');
                            admin_districts_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该城市暂无区县</option>');
                        admin_districts_select.append(first_option);
                    }
                }
            });
        } else {
            admin_gritter_notice(false, '城市不存在')
        }
    });

    // districts change
    admin_districts_select.on('change', function () {
        var _self = $(this);
        var selected_district = _self.find("option:selected");
        var district_id = _self.val();
        var province_name = selected_district.attr('data-province');
        var city_name = selected_district.attr('data-city');
        var district_name = selected_district.text();
        document.getElementById("user_profile_district_id").value = district_id;
        $(".select-user-district").text(province_name + ' -- ' + city_name + ' -- ' + district_name);
        var school_district_id = document.getElementById("change_district_id").value;
        if (district_id != school_district_id) {
            $(".select-user-school").text('请选择学校');
            document.getElementById("user_profile_school_id").value = null;
        }
        $("#admin-select-district-modal").modal('hide');
        if ($('#select-school-modal').hasClass('in')) {
            if (district_id != '') {
                $.ajax({
                    url: '/api/v1/schools/get_by_district',
                    type: 'get',
                    data: {"district_id": district_id},
                    success: function (data) {
                        var data_length = data.length;
                        var schools_select = $("#select-user-school");
                        schools_select.empty();
                        var first_option;
                        if (data_length > 0) {
                            first_option = $('<option value="">请选择学校(' + data_length + '所)</option>');
                            schools_select.append(first_option);
                            $.each(data, function (k, v) {
                                var option = $('<option value="' + v.id + '">' + v.name + '</option>');
                                schools_select.append(option);
                            });
                        } else {
                            first_option = $('<option>该区县暂无学校</option>');
                            schools_select.append(first_option);
                        }
                        schools_select.trigger('chosen:updated');
                    }
                });
            } else {
                admin_gritter_notice(false, '非有效区县')
            }
        }

    });

    $('#select-school-modal').on('show.bs.modal', function () {
        var district_id = $("#user_profile_district_id").val();
        var district_name = $("#select-user-district").text();
        if (district_name) {
            $('.select-user-district').text(district_name);
        }
        if (district_id != '') {
            $.ajax({
                url: '/api/v1/schools/get_by_district',
                type: 'get',
                data: {"district_id": district_id},
                success: function (data) {
                    var data_length = data.length;
                    var schools_select = $("#select-user-school");
                    schools_select.empty();
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择学校(' + data_length + '所)</option>');
                        schools_select.append(first_option);
                        $.each(data, function (k, v) {
                            var option = $('<option value="' + v.id + '">' + v.name + '</option>');
                            schools_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该区县暂无学校</option>');
                        schools_select.append(first_option);
                    }
                    schools_select.trigger('chosen:updated');
                }
            });
        }
    });

    var select_user_school = $("#select-user-school");
    select_user_school.on('change', function () {
        var school_id = $(this).val();
        var district_id = document.getElementById("user_profile_district_id").value;
        var school_name = select_user_school.find("option:selected").text();
        if (district_id > 0 && school_id > 0) {
            document.getElementById("user_profile_school_id").value = school_id;
            document.getElementById("change_district_id").value = district_id;
            $('.select-user-school').text(school_name);
            $("#select-school-modal").modal('hide');
        } else {
            admin_gritter_notice(false, '参数不规范')
        }
    });

    // add school

    $(".add-school-submit").on('click', function () {
        var district_id = parseInt($("#user_profile_district_id").val());
        if (district_id > 0) {
            var school_name = $("#added-school-name").val();
            var match_school_name = school_name.match(/[\u4e00-\u9fa5]/g);
            // 至少包含四个中文
            if (match_school_name != null && match_school_name.length > 3) {
                $.ajax({
                    url: '/api/v1/schools',
                    type: 'post',
                    data: {"district_id": district_id, name: school_name},
                    success: function (data) {
                        admin_gritter_notice(data['status'], data['message']);
                        if (data['status']) {
                            document.getElementById("user_profile_school_id").value = data["school_id"];
                            document.getElementById("change_district_id").value = district_id;
                            $('.select-user-school').text(school_name);
                            $("#select-school-modal").modal("hide");
                        } else {
                            $("#added-school-name").focus();
                        }
                    }
                });
            } else {
                admin_gritter_notice(false, '至少输入四个中文')
            }
        } else {
            admin_gritter_notice(false, '请先选择区县');
            return false;
        }
    })
});
