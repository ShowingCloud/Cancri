$(function () {

    add_score_attribute_init();
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
        //alert(0);
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
var sa_ids = new Array();
var ed = $("input[name='event-identifier']").val();
function list_score_attributes_init() {
    $.ajax({
        url: '/api/v1/scores',
        type: 'get',
        dataType: 'json',
        success: function (result) {
            var select_series = $('.select-series');
            var add_all_score_attribute = $('.add-all-score-attribute');
            var select_all_score_attribute = $('#select-all-score-attribute');
            score_attribute.before(select_all_score_attribute, add_all_score_attribute, select_series);
            $.each(result.score_attributes, function (key, val) {
                var list = $('<label class="brand-li">' + ' ' + '<input type="checkbox" name="score-attribute"  class="car-brand" value="' + val.id + '" autocomplete="off">' + '  ' + val.name + '</label>');
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
                    $('.car-brand').prop("checked", true);
                    select_series.addClass('hidden');
                    score_attribute.removeClass('hidden');
                } else {
                    $('.car-brand').prop("checked", false);
                    add_all_score_attribute.addClass('hidden');
                }
            });

            score_attribute.on('change', function () {
                var brand_checked_num = $("#score-attribute [name = 'score-attribute']:checked").length;
                var brand_all = $("#score-attribute [name = 'score-attribute']").length;
                if (brand_checked_num == 1) {
                    select_series.removeClass('hidden');
                    add_all_score_attribute.removeClass('hidden');
                } else if (brand_checked_num == 0) {
                    select_series.addClass('hidden');
                    add_all_score_attribute.addClass('hidden');
                } else if (brand_checked_num > 1 && brand_checked_num != brand_all) {
                    select_series.addClass('hidden');
                    add_all_score_attribute.removeClass('hidden');
                    $('.select-all-score-attribute').prop("checked", false);
                } else if (brand_checked_num == brand_all) {
                    $('.select-all-score-attribute').prop("checked", true);
                }
            });
        }
    });
}

function add_score_attribute_init() {
    $(".open-add-score-attribute").on('click', function () {
        $(".add-relation-car").slideToggle();
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
                        if (data.status == true) {
                            window.location.reload();
                        }
                        else {
                            window.location.reload();
                        }
                    }
                });
            }
        });
    });
}
