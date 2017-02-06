$(function () {
    if($("#comp-list").length){
      competition_tips.init();
    }

    $('.update-user-info-submit').on('click', function (event) {
        event.preventDefault();
        var username = $('#username').val();
        var gender = $('#gender').val();
        var district_id = $('#district-id').val();
        var school_id = $('#school-id').val();
        var birthday = $('#birthday').val();
        var identity_card = $('#identity_card').val();
        var grade = $('#grade').val();
        var student_code = $('#student_code').val();
        var team_group = $('#team-group').val();
        var team_teacher = $('#team-teacher').val();
        var teacher_mobile = $('#team-teacher-mobile').val();
        var ed = $('#event-identify').val();
        var chinese_english_reg = /^[a-zA-Z\u4e00-\u9fa5]{2,10}$/;

        if (!chinese_english_reg.test(username)) {
            alert_r('请填写姓名(2-10位的中文或英文字符)！');
            return false;
        }
        if (gender.length < 1) {
            alert_r('请选择性别！');
            return false;
        }
        if (birthday.length < 1) {
            alert_r('请填写生日！');
            return false;
        }
        if (school_id.length < 1) {
            alert_r('请选择学校！');
            return false;
        }
        if (student_code.length < 1) {
            alert_r('请填写学籍号！');
            return false;
        }
        if (grade.length < 1) {
            alert_r('请选择年级！');
            return false;
        }
        if (team_group.length < 1) {
            alert_r('请选择组别！');
            return false;
        }
        if (parseInt(grade) >= 10 && !/^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.test(identity_card)) {
            alert_r('由于您选择了高中年级，请正确填写身份证！');
            return false;
        }
        if (team_teacher.length < 1) {
            alert_r('请填写指导老师！');
            return false;
        }
        // if (teacher_mobile.length < 1) {
        //     alert_r('请填写指导老师电话！');
        //     return false;
        // }


        $.ajax({
            url: '/competitions/leader_create_team',
            type: 'post',
            data: {
                "username": username,
                "gender": gender,
                "district": district_id,
                "school": school_id,
                "birthday": birthday,
                "identity_card": identity_card,
                "grade": grade,
                "student_code": student_code,
                "team_group": team_group,
                "teacher_name": team_teacher,
                "teacher_mobile": teacher_mobile,
                "team_event": ed
            },
            success: function (data) {
                if (data[0]) {
                    $('#update-user-info').modal('hide');
                    var m = $('#max_num').val();
                    var msg = '队伍创建成功！';
                    if (m == 1) {
                        msg = '报名信息已完善，请于报名时间截止前提交';
                    }
                    alert_r(msg, function () {
                        window.location.reload();
                    });
                } else {
                    alert_r(data[1]);
                }
            }
        });
    });


    //创建队伍
    $('#step-for-new').on('click', function (event) {
        event.preventDefault();
        $('#step-for-update').removeClass('hide');
        $(this).parents('.first-step').addClass('hide');
    });

    //加入队伍
    $('#step-for-join').on('click', function (event) {
        event.preventDefault();
        $('#step-for-search').removeClass('hide');
        $(this).parents('.first-step').addClass('hide');
    });

    $('.join-team-submit').on('click', function (event) {
        event.preventDefault();
        var username = $('#username-join').val();
        var gender = $('#gender').val();
        var district_id = $('#district-id').val();
        var school_id = $('#school-id').val();
        var birthday = $('#birthday-join').val();
        var identity_card = $('#identity_card-join').val();
        var grade = $('#grade-join').val();
        var student_code = $('#student_code-join').val();
        var td = $('#join-team-id').val();

        if (username.length < 1) {
            alert_r('请填写姓名！');
            return false;
        }
        if (gender.length < 1) {
            alert_r('请选择性别！');
            return false;
        }
        if (birthday.length < 1) {
            alert_r('请填写生日！');
            return false;
        }
        if (school_id.length < 1) {
            alert_r('请选择学校！');
            return false;
        }
        if (student_code.length < 1) {
            alert_r('请填写学籍号！');
            return false;
        }
        if (grade.length < 1) {
            alert_r('请选择年级！');
            return false;
        }
        if (parseInt(grade) >= 10 && !/^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.test(identity_card)) {
            alert_r('由于您选择了高中年级，请正确填写身份证！');
            return false;
        }

        $.ajax({
            url: '/competitions/apply_join_team',
            type: 'post',
            data: {
                "username": username,
                "gender": gender,
                "district": district_id,
                "school": school_id,
                "birthday": birthday,
                "identity_card": identity_card,
                "grade": grade,
                "student_code": student_code,
                "td": td
            },
            success: function (data) {
                if (data[0]) {
                    $('#update-user-info').modal('hide');
                    alert_r(data[1], function () {
                        window.location.reload();
                    });
                } else {
                    alert_r(data[1]);
                }
            }
        });
    });

    // 搜索队伍
    $('.btn-search-team').on('click', function () {
        var team = $('.search-team-input').val();
        var space = $('.search-part');
        var ed = $('#event-identify').val();
        var reg = /[A-Z]+/i;
        if (reg.test(team)) {
            $.ajax({
                url: '/competitions/search_team',
                dataType: 'json',
                type: 'get',
                data: {ed: ed, team: team},
                success: function (data) {
                    if (data[0] && data[1].length > 0) {
                        var result = data[1][0];
                        space.find('.team-info').remove();
                        space.find('.accept').remove();
                        var info = $('<table class="team-info">' +
                            '<tr>' +
                            '<td>队伍编号</td>' +
                            '<td>' + result.identifier + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td>队长姓名</td>' +
                            '<td>' + result.username + '</td>' +
                            '</tr>' +
                            '<td>所属学校</td>' +
                            '<td>' + result.school_name + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td>指导老师</td>' +
                            '<td>' + result.teacher + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td>老师电话</td>' +
                            '<td>' + result.teacher_mobile + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td>队伍人数</td>' +
                            '<td>' + result.players + '</td>' +
                            '</tr>' +
                            '</table>');
                        space.append(info);
                        if (result.status == 0 && result.players < result.team_max_num) {
                            var btn = $('<div class="accept">' +
                                '<button data-id="' + result.id + '" class="btn-primary btn btn-block btn-join-team">加入该队</button>' +
                                '</div>');
                            space.append(btn);
                        }
                        $('.btn-join-team').on('click', function (event) {
                            event.preventDefault();
                            space.find('.team-info').remove();
                            space.find('.accept').remove();
                            var id = $(this).attr('data-id');
                            $('#step-for-search').addClass('hide');
                            $('#step-for-join-team').removeClass('hide').append('<input type="hidden" id="join-team-id" value="' + id + '">');

                        });
                    } else {
                        alert_r('未查询到该队伍');
                    }
                },
                error: function (data) {
                    alert_r('查询出错！请稍后重试！');
                }
            });
        } else {
            alert_r('请输入队伍编号');
        }
    });

    $('#search-player').on('click', function () {
        var invited_name = $('.search-player-input').val();
        if (invited_name) {
            $.ajax({
                url: '/competitions/search_user',
                dataType: 'json',
                type: 'get',
                data: {invited_name: invited_name},
                success: function (data) {
                    if (data[0]) {
                        if (data[1].length == 0) {
                            alert_r('未查询到相关用户');
                        } else {
                            var result = data[1];
                            $('.table-player-show').removeClass('hide');
                            var tbody = $(".table-player-show").find('tbody');
                            tbody.empty();
                            $('.search-player-input').val('');
                            $.each(result, function (k, v) {
                                var tr = $('<tr><td>' + v.nickname + '</td>' +
                                    '<td>' + v.username + '</td>' +
                                    '<td>' + v.school_name + '</td>' +
                                    '<td>' + v.grade + '</td>' +
                                    '<td><button class="btn btn-xs btn-info" onclick="invite_player(' + v.user_id + ')" data-user="' + v.user_id + '">邀请</button></td>' +
                                    '</tr>');
                                tbody.append(tr);
                            });
                        }
                    } else {
                        alert_r(data[1]);
                    }
                },
                error: function (data) {
                    alert_r(data["status"])
                }
            });
        } else {
            alert_r('请输入前两个名字')
        }
    });

    $('#grade-join').on('change', function (event) {
        event.preventDefault();
        var v = $(this).val();
        if (v >= 10) {
            $('.identity-group-join').removeClass('hide');
        }
    });

    $('#team-group').on('change', function () {
        var _self = $(this);
        var group = _self.val();
        var g = $('#grade');
        var icd = $('.identity-group');
        g.find('option').show();
        var a = [];
        switch (group) {
            case '0':
                //未选择
                g.prop('disabled', true);
                icd.addClass('hide');
                break;
            case '1':
                //小学组
                g.prop('disabled', false);
                a = [6, 7, 8, 9, 10, 11, 12];
                icd.addClass('hide');
                break;
            case '2':
                //中学组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5];
                icd.addClass('hide');
                break;
            case '3':
                //初中组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5, 10, 11, 12];
                icd.addClass('hide');
                break;
            case '4':
                //高中组
                g.prop('disabled', false);
                a = [1, 2, 3, 4, 5, 6, 7, 8, 9];
                icd.removeClass('hide');
                break;
        }

        if (a.length > 0) {
            for (var i = 0; i < a.length; i++) {
                $(g.find('option').get(a[i])).hide();
            }
            if ($.inArray(parseInt(g.val()), a) > -1) {
                g.val(0);
            }
        }
    })
});

function invite_player(user_id) {
    var team_id = $('#team-identify').val();
    if (confirm('确认邀请该用户?')) {
        $.ajax({
            url: '/competitions/leader_invite_player',
            dataType: 'json',
            type: 'post',
            data: {td: team_id, ud: user_id},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1]);
                    $('.table-player-show').addClass('hide');
                    var team_players_info = $('#team-players-info').find('tbody');
                    var tr_info = $('<tr id="team-player-' + user_id + '"><td>' + data[2] + '</td><td>' + data[3] + '</td>' +
                        '<td></td><td></td>' +
                        '<td>队员(待确认)</td><td><button class="btn btn-xs btn-info" onclick="leader_delete_player(' + user_id + ')">清退</button></td></tr>');
                    team_players_info.append(tr_info);
                } else {
                    alert_r(data[1]);
                }
            }
        });
    }
}

// 队长解散队伍
function leader_delete_team(team_id) {
    if (confirm('确定解散队伍?')) {
        $.ajax({
            url: '/competitions/leader_delete_team',
            dataType: 'json',
            type: 'post',
            data: {td: team_id},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1]);
                    window.location.reload();
                } else {
                    alert_r(data[1]);
                }
            }
        })
    }
}

// 队长清退队员
function leader_delete_player(ud) {
    var team_id = $('#team-identify').val();
    if (confirm('确定清退该队员?')) {
        $.ajax({
            url: '/competitions/leader_delete_player',
            dataType: 'json',
            type: 'post',
            data: {td: team_id, ud: ud},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1]);
                    $("#team-player-" + ud).addClass('hide');
                } else {
                    alert_r(data[1]);
                }
            }
        })
    }
}

//队长提交报名
function leader_submit_team(td) {
    if (confirm('确定提交报名信息?（提交后无法修改）')) {
        $.ajax({
            url: '/competitions/leader_submit_team',
            dataType: 'json',
            type: 'post',
            data: {td: td},
            success: function (data) {
                if (data[0]) {
                    alert_r(data[1], function () {
                        window.location.reload();
                    });
                } else {
                    alert_r(data[1]);
                }
            }
        })
    }
}

var competition_tips={
  status:{
    index:0
  },
  config:{
    tips:[
      {msg:"报名前请先阅读报名流程后，再根据流程进行操作",highlight:"#user-info-btn"},
      {msg:"选择报名的比赛和项目前，请先完善/更新选手信息",highlight:"#apply-flow-btn"},
      {msg:"完善/更新选手信息后，选择比赛和项目进行报名",highlight:".middle"},
      {msg:"多人项目需要等待所有队员加入后提交，单人项目选择项目即可提交。",highlight:null}
    ]
  },
  init: function(){
    Date.prototype.sameDay = function(d) {
      return this.getFullYear() === d.getFullYear() && this.getDate() === d.getDate() && this.getMonth() === d.getMonth();
    };
    var comp_tips_open = window.localStorage.getItem("comp_tips_open");
    if(!comp_tips_open || !new Date().sameDay(new Date(comp_tips_open)) ){
      competition_tips.open();
    }
  },
  open: function(){
    $(".main-overlay").css("width","100%");
    competition_tips.next();
  },
  next:function(){
    function show(target,msg,next_callback){
      $(".competition-tip").remove();
      var ele = $(target);
      var style;
      if(ele.length){
        style={
          position: "absolute",
          right: ($(window).width() - (ele.offset().left + ele.outerWidth()))+"px",
          top: (ele.position().top + ele.outerHeight() +50)+"px"
        };
      }else{
        style={
          position: "absolute",
          right: "50%",
          top: "60%",
          transform: "translate(50%, -50%)"
        };
      }

      var container = $(".main-overlay");
      var tip_ele = $('<div class="competition-tip"><span class="close">关闭</span><div class="msg">'+msg+'</div></div>');
      tip_ele.css(style);
      container.append(tip_ele);
      tip_ele.find('.close').click(function(){
        competition_tips.close();
      });
      if(competition_tips.status.index < competition_tips.config.tips.length - 1){
        if(next_callback){
          var next_btn = $('<div class="btn-next">下一步</div>');
          next_btn.click(function(){
            next_callback();
          });
          tip_ele.append(next_btn);
        }
      }
    }
    var index = competition_tips.status.index;
    var tip = competition_tips.config.tips[index];
    if(tip){
      if(tip.highlight){
        $(tip.highlight).css({"position":"relative","z-index":"2"});
      }
      show(tip.highlight,tip.msg,function(){
        $(tip.highlight).css({"position":"relative","z-index":"0"});
        competition_tips.status.index++;
        competition_tips.next();
      });
    }

  },
  close:function(){
    window.localStorage.setItem("comp_tips_open",new Date());
    $(".main-overlay").css('width',0);
    $(".competition-tip").remove();
  }
};
