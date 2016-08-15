/**
 * Created by huaxiukun on 16/8/15.
 */
function download_comp_voucher(user_info) {
    var user = eval('(' + user_info + ')');
    var user_gender = (user["gender"] == '1' ? "男" : (user["gender"] == '2' ? "女" : ""));
    $('#qrcodeCanvas').qrcode({
        width: 260,
        height: 260,
        text: utf16to8("姓名:" + user["username"] + "; 性别:" + user_gender + "; 学校:" + user["school_name"] + "; 队伍:" + user["identifier"] + "")
    });
    var canvas = document.getElementById("myCanvas");
    if (canvas.getContext) {
        var ctx = canvas.getContext("2d");
        ctx.font = "Normal 30px Arial";
        ctx.textAlign = "left";
        ctx.fillStyle = "black";

        var back_image = document.getElementById("use-voucher");
        ctx.drawImage(back_image, 0, 0);
        ctx.fillText(user["username"], 360, 180);
        ctx.fillText(user["age"], 930, 180);
        ctx.fillText(user_gender, 360, 270);
        ctx.fillText(user["student_code"], 930, 270);
        ctx.fillText(user["school_name"], 360, 360);
        ctx.fillText(user["bj"], 360, 450);
        ctx.fillText(user["comp_name"], 500, 900);
        ctx.fillText(user["event_name"], 380, 1320);
        ctx.fillText(user["identifier"], 380, 1430);
        ctx.fillText(user["teacher"], 380, 1540);
        ctx.fillText(user["teacher_mobile"], 380, 1642);

        var qrcode_canvas = $("#qrcodeCanvas").find("canvas")[0];
        var qrcode_image = new Image();
        qrcode_image.src = qrcode_canvas.toDataURL("image/jpeg");
        ctx.drawImage(qrcode_image, 850, 1400);
        var all_img = new Image();
        all_img.src = canvas.toDataURL("image/jpeg");

    }
    var doc = new jsPDF();
    var js_pdf_data = all_img.src;
    doc.addImage(js_pdf_data, 'JPEG', 0, 0, 210, 298);
    doc.setTextColor(255, 255, 255);
    doc.save('test.pdf');
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

