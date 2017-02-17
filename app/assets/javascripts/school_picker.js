$(function() {
    var $school_input = $(".school_input");
    var $school_tag = $('.school-tag');
    $('.school-tag').on('click', function(event) {
        event.preventDefault();
        $school_tag = $(this);
        $school_input = $(this).siblings(".school_input");
        if(!$school_input.length){
          $school_input=$(this).parent().siblings(".school_input");
        }
        school_handle();
    });

    $('.new-school').on('click', function(event) {
        event.preventDefault();
        school_handle();
    });

    $(".district_input").on('change', function() {
        var district_id = $(this).val();
        var school_district_id = document.getElementById("change_district_id").value;
        if (district_id != school_district_id) {
            $school_tag.text('请选择学校');
            $school_input.val(null).change();
        }
    });

    var cities_select = $("#select-city");
    var districts_select = $("#select-district");
    // province option change
    $('#select-province').on('change', function() {
        var province_id = $(this).val();
        if (province_id != '') {
            $.ajax({
                url: '/api/v1/districts/get_cities',
                type: 'get',
                data: {
                    "province_id": province_id
                },
                success: function(data) {
                    var data_length = data.length;
                    cities_select.empty();
                    districts_select.empty();
                    districts_select.append($('<option value="">请先选择城市</option>'));
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择城市</option>');
                        cities_select.append(first_option);
                        $.each(data, function(k, v) {
                            var option = $('<option value="' + v.id + '">' + v.name + '</option>');
                            cities_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该省市暂无城市</option>');
                        cities_select.append(first_option);
                    }
                }
            });
        } else {
            alert_r('省市不存在');
        }
    });


    // cities option change
    cities_select.on('change', function() {
        var city_id = $(this).val();
        if (city_id != '') {
            $.ajax({
                url: '/api/v1/districts/get_districts',
                type: 'get',
                data: {
                    "city_id": city_id
                },
                success: function(data) {
                    var data_length = data.length;
                    districts_select.empty();
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择区县</option>');
                        districts_select.append(first_option);
                        $.each(data, function(k, v) {
                            var option = $('<option value="' + v.id + '" data-province="' + v.province_name + '" data-city="' + v.city_name + '">' + v.name + '</option>');
                            districts_select.append(option);
                        });
                    } else {
                        first_option = $('<option>该城市暂无区县</option>');
                        districts_select.append(first_option);
                    }
                }
            });
        } else {
            alert_r('城市不存在');
        }
    });

    // districts change
    districts_select.on('change', function() {
        var _self = $(this);
        var selected_district = _self.find("option:selected");
        var district_id = _self.val();
        var province_name = selected_district.attr('data-province');
        var city_name = selected_district.attr('data-city');
        var district_name = selected_district.text();
        $(".district_input").val(district_id).change();
        document.getElementById("change_district_id").value = district_id;
        $(".select-user-district").text(province_name + ' -- ' + city_name + ' -- ' + district_name);
        $("#select-district-modal").modal('hide');
        if (district_id) {
            $.ajax({
                url: '/api/v1/schools/get_by_district',
                type: 'get',
                data: {
                    "district_id": district_id
                },
                success: function(data) {
                    var data_length = data.length;
                    var schools_select = $("#select-user-school");
                    schools_select.empty();
                    var first_option;
                    if (data_length > 0) {
                        first_option = $('<option value="">请选择学校</option>');
                        schools_select.append(first_option);
                        $.each(data, function(k, v) {
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
            alert_r('非有效区县');
        }

    });

    var select_user_school = $("#select-user-school");
    select_user_school.on('change', function() {
        var school_id = $(this).val();
        var district_id = districts_select.val();
        var school_name = select_user_school.find("option:selected").text();
        if (district_id > 0 && school_id > 0) {
            $(".district_input").val(district_id);
            $school_input.val(school_id).change();
            document.getElementById("change_district_id").value = district_id;
            $school_tag.text(school_name);
            $("#select-school-modal").modal('hide');
        } else {
            alert_r('参数不规范');
        }
    });

    function school_handle() {
        var _modals = $('#select-school-modal');
        _modals.modal('show');
        get_district();
    }

    function get_district() {
        var option = {
            url: '/user/get_districts',
            type: 'get',
            success: function(result) {
                if (result.length > 0) {
                    get_district_success(result);
                } else {
                    alert_r('区县载入出错');
                    $('#district-select').empty();
                }
            }
        };
        ajax_handle(option);
    }

    function get_school(dis) {
        var option = {
            url: '/user/get_schools',
            type: 'get',
            dataType: 'json',
            data: {
                district_id: dis
            },
            success: function(result) {
                if (result.length > 0) {
                    get_school_success(result, dis);
                } else {
                    alert_r('未找到合适条件的学校');
                    $('.school-list').empty();
                }
            },
            complete: function() {

            },
            error: function(error) {
                alert_r(error.responseText);
            }
        };
        ajax_handle(option);
    }

    function get_school_success(result, dis) {
        var s = $('.school-list');
        s.empty();
        for (var i = 0; i < result.length; i++) {
            var bean = $('<div class="item school-bean" data-id="' + result[i].id + '">' + result[i].name + '</div>');
            s.append(bean);
        }
        $('.school-bean').on('click', {
            dis: dis
        }, function(event) {
            event.preventDefault();
            var data = event.data;
            var _self = $(this);
            var text = _self.text();
            var sid = _self.attr('data-id');
            var dis = data.dis;
            $('#district-id').val(dis);
            $('#school-id').val(sid);
            var tag = $('.school-field').find('.school-tag');
            if (tag.length > 0) {
                tag.text(text);
            } else {
                $('.school-field').empty().append('<span class="change-school school-tag">' + text + '</span>');
                $('.school-tag').off('click').on('click', function(event) {
                    event.preventDefault();
                    school_handle();
                });
            }
            $('#school-modal').modal('hide');
            $('.school-list').empty();
        });
    }

    function get_district_success(result) {
        var s = $('#district-select');
        s.empty();
        s.append('<option value="0">请选择区县</option>');
        for (var i = 0; i < result.length; i++) {
            var option = $('<option value="' + result[i].id + '">' + result[i].name + '</option>');
            s.append(option);
        }
        s.on('change', function(event) {
            event.preventDefault();
            var dis = $(this).val();
            get_school(dis);
        });
    }

    function ajax_handle(option) {
        $.ajax(option);
    }

});
