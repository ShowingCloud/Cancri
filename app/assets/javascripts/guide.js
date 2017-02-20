(function($) {
    $.fn.guide = function(options) {
        var opts = $.extend({}, $.fn.guide.defaults, options);
        var container = $(this);
        var status = {
            index: 0
        };
        if (opts.before_check) {
            if (opts.before_check()) {
                init();
            }
        } else {
            init();
        }

        function init() {
            $(".guide-overlay").css("display", "block");
            open();
        }

        function close() {
            $(".guide-overlay").css('display', 'none');
            $(".guide-tip").remove();
            if (opts.callback) {
                opts.close_callback();
            }
        }

        function open() {
            var tip = opts.tips[status.index];
            if (tip) {
                if (tip.highlight) {
                  var highlight = $(tip.highlight);
                    highlight.css({
                        "z-index": "2",
                        "pointer-events": "none"
                    });
                    if(highlight.css('position') !== 'absolute'){
                      highlight.css("position", "relative");
                    }
                }
                show(tip.highlight, tip.msg, function() {
                    $(tip.highlight).css({
                        "z-index": "0",
                        "pointer-events": "auto"
                    });
                    status.index++;
                    open();
                });
            }
        }

        function show(target, msg, next_callback) {
            $(".guide-tip").remove();
            var ele = $(target);
            var style = opts.default_sytle;
            if (ele.length) {
                var top = ele.position().top + ele.outerHeight();
                var height = $(window).height();
                if (top < height / 2) {
                    style = {
                        position: "absolute",
                        right: ($(window).width() - (ele.offset().left + ele.outerWidth())) + "px",
                        top: (top + 50) + "px"
                    };
                }
            }
            var tip_ele = $('<div class="guide-tip"><span class="close">关闭</span><div class="msg">' + msg + '</div></div>');
            tip_ele.css(style);
            container.append(tip_ele);
            tip_ele.find('.close').click(function() {
                close();
            });
            if (status.index < opts.tips.length - 1) {
                if (next_callback) {
                    var next_btn = $('<div class="btn-next">下一步</div>');
                    next_btn.click(function() {
                        next_callback();
                    });
                    tip_ele.append(next_btn);
                }
            }
        }
    };

    $.fn.guide.defaults = {
        default_sytle: {
            position: "absolute",
            right: "50%",
            top: "60%",
            transform: "translate(50%, -50%)"
        }
    };
}(jQuery));
