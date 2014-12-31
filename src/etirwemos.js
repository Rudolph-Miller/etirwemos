$(function () {
    $.html = new yzrHtml();

    fitBackgroundFont();
    $(window).resize(function() {
        fitBackgroundFont();
    });

    $('button#start-button').click(function(){
        $('#start-page').remove();
        start();
    });
});
function fitBackgroundFont(){
    var place = $('section#background > p');
    var h = place.height();
    var fontSize = 222;
    if(h>=fontSize*3){
        place.css('line-height',h/3+'px');
        place.css('font-size',h/3+'px');
    }else{
        //三行入らん場合。
        place.parent().css('padding','55px');
        h = place.height();
        place.css('line-height',h/3+'px');
        place.css('font-size',h/3+'px');
    }
};
function start(){
    var glide = $('#reports').glide(
        { autoplay: false,
          circular: false,
          beforeTransition: function() {},
          afterTransition: function() {
              if(this.currentSlide==0)
                  $('title').text('CLWR: Google');

              if(this.currentSlide==-1)
                  $('title').text('CLWR: Twitter');

              if(this.currentSlide==-2)
                  $('title').text('CLWR: Github');
          }});

    // 一度は背景見せようか。
    setTimeout(function(){
        drawClouds(88);

        $('title').text('WCLR: Google');
        callWepApi('google');
        callWepApi('github');
        callWepApi('tweet');

        setInterval("jojo()",1000);
    },300);
};
function status(action){
    var background = $('section#background');

    if(action=='start')
        background.addClass('start');

    if(action=='end')
        background.removeClass('start');

};


/**
 * WebApi
 */
function genReportCard(type,con){
    return {tag:'article',
            cls:['report',type,'born'],
            attr:{style:'display:none;'},
            con:con};
}
function getCallWepApiData(type){
    if(type=='google')
        return {uri:'http://'+location.host+'/etirwemos/search/www/google/start/',
                counter:function(count,data){
                    var tmp = data;
                    if(tmp==null)
                        return count;
                    return count + data.length;
                },
                drower:addGoogleCards};

    if(type=='github')
        return {uri:'http://'+location.host+'/etirwemos/github/repogitory/search/page/',
                counter:function(page,data){
                    var tmp = data;
                    if(tmp==null)
                        return page;
                    return page + 1;
                },
                drower:addGithubCards};

    if(type=='tweet')
        return {uri:'http://'+location.host+'/etirwemos/search/tweet/start/',
                counter:function(page,data){
                    var tmp = data;
                    if(tmp==null)
                        return page;
                    return page + 1;
                },
                drower:addTweetCards};
};
function callWepApi(type,start){
    if(start==null)
        start = 1;

    var api = getCallWepApiData(type);
    status('start');
    $.ajax({
        url: api.uri + start
    }).done(function(data){
        setLoadTime();
        if(data==null)
            data=[];
        api.drower(data,api.counter(start,data));
    }).fail(function(data){
        api.func([],start);
    }).always(function(data){
        status('end');
    });
};


/**
 * Drower
 */
function addCards(type,pool,stmt,name,val){
    pool.append($.html.gen(stmt));

    var cards = pool.find('article.born');
    pool.find('article.report.born > div').click(function(e){
        if(e.ctrlKey)
            $(this).parent().fadeOut();
        else
            $(this).toggleClass('weak');
    });
    cards.fadeIn("slow").removeClass('born');

    var attr = {type:type};
    attr[name]=val;
    pool.append($.html.gen(
        {tag:'article',
         cls:['operator','next-load'],
         attr:attr,
         con:[{tag:'div',con:'Next More'}]}));


    pool.append($.html.gen(
        {tag:'article',
         cls:['operator','clear-load'],
         attr:attr,
         con:[{tag:'div',con:'Clear Load'}]}));


    pool.find('article.next-load').click(function(e){
        callWepApi($(this).attr('type'),$(this).attr('start')*1);
        pool.find('article.operator').remove();
    });

    pool.find('article.clear-load').click(function(e){
        pool.find('article.report').remove();
        callWepApi($(this).attr('type'),1);
        pool.find('article.operator').remove();
    });
};
function addGoogleCards(data,nextStart){
    var pool = $('section#google .pool');
    var stmt = [];
    $.each(data,function(){
        stmt.push(genReportCard(
            'google',
            [{tag:'div',
              con:[{tag:'a',attr:{href:this.link},
                    con:[{tag:'p',cls:['title'],con:this.htmlTitle}]},
                   {tag:'p',cls:['snippet'],con:this.htmlSnippet}]}]));
    });

    addCards('google',pool,stmt,'start',nextStart);
};
function addGithubCards(data,nextStart){
    var pool = $('section#github section.pool');
    var fmtDt = function(data,key,imagep){
        var val = data[key];
        var tds = [];

        if(imagep)
            tds.push({tag:'td',attr:{rowspan:3},
                      con:{tag:'a',
                           attr:{href:data.owner.html_url,target:'_blank'},
                           con:{tag:'img',cls:['icon'],
                                attr:{src:data.owner.avatar_url,
                                      width:55,height:55,
                                      alt:data.owner.login,
                                      title:data.owner.login}}}});
        tds.push({tag:'td',cls:['title'],con:key.replace('_at', ' : ')});
        tds.push({tag:'td',con:moment(val).format('YYYY-MM-DD HH:mm:ss (dddd)')});

        return {tag:'tr',con:tds};
    };

    var stmt = [];
    $.each(data,function(){
        stmt.push(genReportCard(
            'github',
            [{tag:'div',
              con:[{tag:'a',attr:{href:this.html_url,target:'_blank'},
                    con:[{tag:'p',cls:['title'],
                          con:this.name + ' @' + this.language}]},
                   {tag:'p',cls:['description'],
                    con:this.description},
                   {tag:'table',cls:['timestamp'],
                    con:{tag:'tobdy',con:[fmtDt(this,'updated_at',true),
                                          fmtDt(this,'pushed_at'),
                                          fmtDt(this,'created_at')]}}]}]));
    });

    addCards('github',pool,stmt,'start',nextStart);
};
function addTweetCards(data,nextStart){
    var pool = $('section#twitter section.pool');

    var fmtDt = function(data,key,imagep){
        var val = data[key];
        var tds = [];

        if(imagep){
            tds.push({tag:'td',attr:{rowspan:3},
                      con:{tag:'a',
                           attr:{href:data.profile_image_url,target:'_blank'},
                           con:{tag:'img',cls:['icon'],
                                attr:{src:data.profile_image_url,
                                      width:55,height:55,
                                      alt:data.name,
                                      title:data.description}}}});
        }
        tds.push({tag:'td',cls:['title'],con:key.replace('_at','')+' : '});
        tds.push({tag:'td',con:val});
        return {tag:'tr',con:tds};
    };

    var stmt = [];
    $.each(data,function(){
        stmt.push(genReportCard(
            'tweet',
            [{tag:'div',
              con:[{tag:'a',attr:{href:null,target:'_blank'},
                    con:[{tag:'p',cls:['text'],con:this.text}]},
                   {tag:'table',cls:['timestamp'],
                    con:{tag:'tobdy',con:[fmtDt(this.user,'name',true),
                                          fmtDt(this.user,'location'),
                                          fmtDt(this,'created_at')]}}
                  ]}]));
    });

    addCards('tweet',pool,stmt,'start',nextStart);
};


/**
 * 蛇足
 */
function drawClouds(count){
    var sky = $('section#sky');
    var w = sky.width(), h = sky.height();
    var width = 231, height = 141;
    for(var i=0 ;i<count;i++)
        sky.append($.html.gen(
            {tag:'img',
             attr:{src:'/img/cloud.png',
                   style:'position:fixed;'
                   + 'left:' + (Math.floor( Math.random() * w ) - width/2) + 'px;'
                   + 'top:'  + (Math.floor( Math.random() * h ) - height/2) + 'px;',
                   width:width ,
                   height:height}}));

};
var loadTime = null;
function setLoadTime(){
    loadTime = moment().add('M',15);
};
var jojoMode = 'gogo';
function jojo(){
    if(loadTime==null || loadTime > moment()){
        jojoMode=null;
        return;
    }

    if(jojoMode==null){
        var mode = Math.floor(Math.random()*10%2);
        jojoMode = [{name:'dodo', w:453, h:473},
                    {name:'gogo', w:270, h:474}][mode];
    }

    var body = $('body');
    var w = body .width(), h = body.height();

    var gain = (100 - Math.random()*77)/100;
    body.append($.html.gen(
        {tag:'img',
         cls:['born','gion'],
         attr:{src:'/img/'+jojoMode.name+'.png',
               style:'position:fixed;z-index:9999;'
               + 'top:'  + Math.floor( Math.random() * h ) + 'px; '
               + 'left:' + Math.floor( Math.random() * w ) + 'px;',
               width:jojoMode.w*gain ,
               height:jojoMode.h*gain}}));

    body.find('img.born.gion')
        .mouseover(function () {$(this).remove();})
        .removeClass('born');
};