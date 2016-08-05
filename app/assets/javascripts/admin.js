//= require jquery
//= require bootstrap.min
//= require admin/ace.min
//= require admin/ace-elements.min
//= require admin/ace-extra.min
//= require jquery_ujs
//= require admin/jquery.cookie
//= require admin/jquery.gritter.min
//= require admin/frame
//= require admin/bootstrap-datepicker.min
//= require admin/bootstrap-timepicker.min
//= require admin/bootbox.min
//= require admin/jquery.slimscroll.min
//= require admin/admin
//= require admin/chosen.jquery.min
//= require admin/jquery.nestable.min
//= require bootstrap-dialog
//= require admin/jquery.colorbox-min
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require kindeditor
//= require upload_media
$(function () {
    return $('#new_photo').fileupload({
        dataType: "script",
        add: function (e, data) {
            var file, types, progress_bar_id;
            types = /(\.|\/)(gif|jpe?g|png)$/i; // regex
            file = data.files[0];
            progress_bar_id = new Date() / 1;
            if (types.test(file.type) || types.test(file.name)) {
                data.context = $(tmpl("template-upload", file, progress_bar_id));
                $('#new_photo').append(data.context);
                return data.submit();
            } else {
                return alert(file.name + "格式不支持");
            }
        },
        progress: function (e, data) {
            var progress;
            if (data.context) {
                progress = parseInt(data.loaded / data.total * 100, 10);
                return data.context.find('.bar').css('width', progress + '%'); // width: 50%;
            }
        },
        done: function (e, data) {
            // removing the progress bar
            $(data.context).remove();
        }
    });
});