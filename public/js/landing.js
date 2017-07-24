console.log(
    '%c+',
    'font-size: 1px;' +
    'padding: 60px 59.5px;' +
    'line-height: 120px;' +
    'background: url("' +
        location.protocol + '//' + location.hostname + (location.port ? ':' + location.port : '') +
        '/img/logo/120.png' +
    '");' +
    'background-size: 120px 120px;' +
    'color: transparent;'
);

console.log('CryptoStarter console >>');

// Hello 2007 :D
$(function () {
    setTimeout(initWowSlider, 250);
    initScrollToTop();

    function initWowSlider() {
        $('#wow-slider').show().revolution(
            {
                dottedOverlay: 'none',
                delay: 9000,
                startwidth: 1170,
                startheight: 700,
                hideThumbs: 200,
                thumbWidth: 100,
                thumbHeight: 50,
                thumbAmount: 1,
                navigationType: 'none',
                navigationArrows: 'solo',
                navigationStyle: 'round',
                touchenabled: 'on',
                onHoverStop: 'on',
                navigationHAlign: 'center',
                navigationVAlign: 'bottom',
                navigationHOffset: 0,
                navigationVOffset: 20,
                soloArrowLeftHalign: 'left',
                soloArrowLeftValign: 'center',
                soloArrowLeftHOffset: 20,
                soloArrowLeftVOffset: 0,
                soloArrowRightHalign: 'right',
                soloArrowRightValign: 'center',
                soloArrowRightHOffset: 20,
                soloArrowRightVOffset: 0,
                shadow: 0,
                fullWidth: 'on',
                fullScreen: 'off',
                spinner: 'spinner3',
                stopLoop: 'off',
                stopAfterLoops: -1,
                stopAtSlide: -1,
                shuffle: 'off',
                autoHeight: 'off',
                forceFullWidth: 'off',
                hideThumbsOnMobile: 'off',
                hideBulletsOnMobile: 'off',
                hideArrowsOnMobile: 'off',
                hideThumbsUnderResolution: 0,
                hideSliderAtLimit: 0,
                hideCaptionAtLimit: 0,
                hideAllCaptionAtLilmit: 0,
                startWithSlide: 0,
                videoJsPath: 'rs-plugin/videojs/',
                fullScreenOffsetContainer: ''
            }
        );

        $('#wow-fix-loader').hide();
    }

    function initScrollToTop() {
        var bodyAndHtml = $('body, html');
        var toTop = $('#to-top');
        var toTopEdge = 20;
        var toTopSpeed = 800;

        $(window).scroll(function() {
            if (bodyAndHtml.width() < 767) {
                toTop.fadeOut();
                return;
            }

            toTop.removeClass('hidden');

            if ($(this).scrollTop() > toTopEdge) {
                toTop.fadeIn();
            } else {
                toTop.fadeOut();
            }
        });

        toTop.click(function() {
            bodyAndHtml
                .stop(false, false)
                .animate({scrollTop: 0}, toTopSpeed);

            return false;
        });
    }
});