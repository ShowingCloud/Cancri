// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require bootstrap-dialog
//= require jquery.soulmate
//= require competitions
//= require message-bus
//= require code
//= require notify
//= //require turbolinks
$(document).ready(function () {
    render = function (term, data, type) {
        return term;
    };
    select = function (term, data, type) {
        console.log("Selected " + term);
    };
    $('#search').soulmate({
        url: '/sm/search',
        types: ['user'],
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults: 5
    });
    //MessageBus.start(); // call once at startup

    // how often do you want the callback to fire in ms
    MessageBus.callbackInterval = 500;
    channel = '/channel';
    if (window.roomid) {
        channel = channel + '/' + window.roomid
    }
    MessageBus.subscribe(channel, function (data) {
        $("#chats-content").append("<tr><td>" + data.content + "</td><td>" + data.time + "</td></tr>");
        $("#content").val('');
        // data shipped from server
    });
});
