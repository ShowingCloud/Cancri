/**
 * Created by huaxiukun on 16/8/15.
 */
// function download_comp_voucher() {
$('#download-voucher').on('click', function () {

    $('#qrcodeCanvas').qrcode({
        width: 260,
        height: 260,
        text: utf16to8("姓名:花修坤;性别：男；学校：宝山中学；队伍：ZHHHHABC")
    });
    var canvas = document.getElementById("myCanvas");
    if (canvas.getContext) {
        var ctx = canvas.getContext("2d");
        ctx.font = "Normal 25px Arial";
        ctx.textAlign = "left";
        ctx.fillStyle = "black";

        // var back_image = new Image();
        // back_image.src='images/15.jpg';
        var back_image = document.getElementById("use-voucher");
        ctx.drawImage(back_image, 0, 0);
        ctx.fillText("温家宝", 360, 180);
        ctx.fillText("19", 930, 180);
        ctx.fillText("男", 360, 270);
        ctx.fillText("123456789", 930, 270);
        ctx.fillText("宝山中学", 360, 360);
        ctx.fillText("6", 360, 450);
        ctx.fillText("机器人大赛", 500, 900);
        ctx.fillText("足球", 380, 1320);
        ctx.fillText("ZHHHABC", 380, 1430);
        ctx.fillText("李白", 380, 1540);
        ctx.fillText("15388888888", 380, 1642);


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
});

// }

