/**
 * Created by huaxiukun on 16/8/15.
 */
function download_comp_voucher(e,user_info) {
    if (!user_info) {
        return false;
    }
    var canvas = document.getElementById("myCanvas");
    if (canvas.getContext && canvas.getContext('2d')) {
        var user = user_info;
        user.age = getAge(user.age);
        user.gender = getGender(user.gender);
        user.group = getGroup(user.group);
        var $qrcodeCanvas = $('#qrcodeCanvas');
        var txt_position = {
          username: [300, 165],
          gender:[300, 250],
          school_name:[300, 338],
          event_name:[300, 1198],
          identifier:[300, 1308],
          teacher:[300, 1408],
          teacher_mobile:[300, 1505]
        };

        $qrcodeCanvas.qrcode({
            width: 260,
            height: 260,
            text: utf16to8("姓名:" + user.username + ";\n性别:" + user.gender + ";\n学校:" + user.school_name + ";\n项目:" + user.event_name + ";\n组别:" + user.group + ";\n队伍:" + user.identifier + "")
        });

        var ctx = canvas.getContext("2d");
        var back_image = document.getElementById("use-voucher");
        ctx.drawImage(back_image, 0, 0);
        ctx.font = "Normal 30px Arial";
        ctx.textAlign = "left";
        ctx.fillStyle = "black";
        for(var pro in txt_position){
          ctx.fillText((user_info[pro] || ""), txt_position[pro][0], txt_position[pro][1]);
        }

        ctx.font = "Normal 50px Arial";
        ctx.fillStyle = "white";
        ctx.fillText(user.comp_name, 380, 765);

        var qrcode_canvas = $qrcodeCanvas.find("canvas")[0];
        ctx.drawImage(qrcode_canvas, 785, 1266);

        var doc = new jsPDF();
        doc.addImage(canvas.toDataURL("image/jpeg"), 'JPEG', 0, 0, 210, 298);
        doc.setTextColor(255, 255, 255);
        e.preventDefault();
        doc.save(user.identifier + '_' + user.username + '_' + user.event_name + ".pdf");
    }
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
