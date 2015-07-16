# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  is_sending = false
  $('#btn_send_mobile_code').click ->
    self = $(this)
    if is_sending
      return
    mobile = $('#' + self.attr('data-key') + '_mobile')
    mobile_number = mobile.val()
    if mobile_number == '' || mobile_number.length != 11 || isNaN(mobile_number)
      alert('手机号码格式不正确')
      mobile.focus()
      return
    self.blur()
    is_sending = true
    self.text('发送中...').addClass('disabled')
    $.ajax({
      url: '/accounts/send_code',
#      url: '/api/v1/sms/send_code',
      type: 'POST',
      data: {"mobile": mobile_number, "type": self.attr('data-type'), "ip": 'ip_address'},
      success: (data) ->
        alert(data[1])
      error: (data) ->
        alert(data[1])
      complete: ->
        is_sending = false
        self.text('获取验证码').removeClass('disabled')
    })