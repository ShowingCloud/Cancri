/**
 * Created by huaxiukun on 16/8/15.
 */
function download_comp_voucher(user_info) {

    var user = JSON.parse(user_info);
    var age = getAge(user.age);
    var user_gender = getGender(user.gender);
    var group = getGroup(user.group);
    var $qrcodeCanvas = $('#qrcodeCanvas');

    $qrcodeCanvas.qrcode({
        width: 260,
        height: 260,
        text: utf16to8("姓名:" + user.username + ";\n性别:" + user_gender + ";\n学校:" + user.school_name + ";\n项目:" + user.event_name + ";\n组别:" + group + ";\n队伍:" + user.identifier + "")
    });
    var canvas = document.getElementById("myCanvas");
    if (canvas.getContext) {
        var ctx = canvas.getContext("2d");
        ctx.font = "Normal 30px Arial";
        ctx.textAlign = "left";
        ctx.fillStyle = "black";

        var back_image = document.getElementById("use-voucher");
        ctx.drawImage(back_image, 0, 0);
        ctx.fillText(user["username"], 300, 165);
        ctx.fillText(age, 880, 165);
        ctx.fillText(user_gender, 300, 250);
        ctx.fillText(user["school_name"], 300, 338);
        ctx.fillText(user["event_name"], 300, 1198);
        ctx.fillText(user["identifier"], 300, 1308);
        ctx.fillText(user["teacher"], 300, 1408);
        ctx.fillText(user["teacher_mobile"], 300, 1505);
        ctx.font = "Normal 50px Arial";
        ctx.fillStyle = "white";
        ctx.fillText(user["comp_name"], 380, 765);

        var qrcode_canvas = $qrcodeCanvas.find("canvas")[0];
        ctx.drawImage(qrcode_canvas, 785, 1266);
        var all_img = new Image();
        all_img.src = canvas.toDataURL("image/jpeg");

    }
    var doc = new jsPDF();
    var js_pdf_data = all_img.src;
    doc.addImage(js_pdf_data, 'JPEG', 0, 0, 210, 298);
    doc.setTextColor(255, 255, 255);
    doc.save(user["identifier"] + '_' + user["username"] + '_' + user["event_name"]);
}
function utf16to8(str) {
    var out, i, len, c;
    out = "";
    len = str.length;
    for (i = 0; i < len; i++) {
        c = str.charCodeAt(i);
        if ((c >= 0x0001) && (c <= 0x007F)) {
            out += str.charAt(i);
        } else if (c > 0x07FF) {
            out += String.fromCharCode(0xE0 | ((c >> 12) & 0x0F));
            out += String.fromCharCode(0x80 | ((c >> 6) & 0x3F));
            out += String.fromCharCode(0x80 | ((c >> 0) & 0x3F));
        } else {
            out += String.fromCharCode(0xC0 | ((c >> 6) & 0x1F));
            out += String.fromCharCode(0x80 | ((c >> 0) & 0x3F));
        }
    }
    return out;
}
