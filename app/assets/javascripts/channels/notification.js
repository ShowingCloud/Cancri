App.notification = App.cable.subscriptions.create("NotificationChannel", {
    connected: function () {
    },
    disconnected: function () {
    },
    received: function (data) {
        notify("消息提示", data["message"].content);
    }
});

function notify(title, content) {
    if (!title && !content) {
        title = "桌面提醒";
        content = "您看到此条信息桌面提醒设置成功";
    }
    var iconUrl = "/assets/icon.png";
    if (window.webkitNotifications) {
        //chrome老版本
        if (window.webkitNotifications.checkPermission() == 0) {
            var notif = window.webkitNotifications.createNotification(iconUrl, title, content);
            notif.display = function () {
            };
            notif.onerror = function () {
            };
            notif.onclose = function () {
            };
            notif.onclick = function () {
                this.cancel();
            };
            notif.replaceId = 'Meteoric';
            notif.show();
        } else {
            window.webkitNotifications.requestPermission($jy.notify);
        }
    }
    else if ("Notification" in window) {
        // 判断是否有权限
        if (Notification.permission === "granted") {
            var notification = new Notification(title, {
                "icon": iconUrl,
                "body": content
            });
        }
        //如果没权限，则请求权限
        else if (Notification.permission !== 'denied') {
            Notification.requestPermission(function (permission) {
                // Whatever the user answers, we make sure we store the
                // information
                if (!('permission' in Notification)) {
                    Notification.permission = permission;
                }
                //如果接受请求
                if (permission === "granted") {
                    var notification = new Notification(title, {
                        "icon": iconUrl,
                        "body": content
                    });
                }
            });
        }
    }
}
