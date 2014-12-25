$(function () {
    $.html = new yzrHtml();
    settingEvents();
});
function settingEvents(){
    $('article.twitter button[func="sing-in"]').click(function(){
        getOAuthProviderUri();
    });
};

function getOAuthProviderUri(){
    $.ajax({
        url: $.format('/etirwemos/oauth/%s/uri',"twitter"),
        data:{'callback-uri':'http://localhost:5000/me.html'}
    }).done(function(data){
        $(location).attr("href", data);
    }).fail(function(data){
        console.log('fail');
    }).always(function(data){
    });
};

//http://localhost:5000/me.html/?
// oauth_searvice=TWITTER
// oauth_token=PhDntDdacUge9b9xqGVwsj2TwgCB1USt    <-- これリクエストトークンのキーじゃって。 あぁ、このためにリクエストトークンを保管しとかんとイケンのんじゃ。
// oauth_verifier=O8G3UPMUdVWLstGw6YJ8wBX4sBZvR6NG
