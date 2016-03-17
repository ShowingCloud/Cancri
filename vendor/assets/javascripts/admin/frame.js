$(function () {
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