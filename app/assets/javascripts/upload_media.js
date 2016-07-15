$(function () {
    return $('#new_video').fileupload({
        dataType: "script",
        add: function (e, data) {
            var file, types, progress_bar_id;
            types = /(\.|\/)(gif|jpe?g|png|mp4)$/i; // regex
            file = data.files[0];
            progress_bar_id = new Date() / 1;
            if (types.test(file.type) || types.test(file.name)) {
                data.context = $(tmpl("template-upload", file, progress_bar_id));
                $('#new_video').append(data.context);
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
