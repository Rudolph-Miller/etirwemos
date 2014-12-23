$(function () {
    $.html = new yzrHtml();

    // var slides = $('.content_article-img');

    var glide = $('.slider').glide({
        autoplay: false,
        circular: false,
        beforeTransition: function() {},
        afterTransition: function() {}
    });
});
