$(function () {
    $.html = new yzrHtml();

    $('title').text('WCLR: Google');

    var glide = $('#reports').glide({
        autoplay: false,
        circular: false,
        beforeTransition: function() {},
        afterTransition: function() {
            if(this.currentSlide==0)
                $('title').text('WCLR: Google');

            if(this.currentSlide==-1)
                $('title').text('WCLR: Twitter');

            if(this.currentSlide==-2)
                $('title').text('WCLR: Github');
        }
    });

    searchGoogle();
    searchGithub();
});

function status(action){
    var background = $('section#background');

    if(action=='start')
        background.addClass('start');

    if(action=='end')
        background.removeClass('start');

};


/**
 * utility
 */
function getSearchFunc(type){
    if(type=='google')
        return searchGoogle;

    if(type=='github')
        return searchGithub;

    throw new Error('対応しとらんよ。type='+type);
};
function addCards(type,pool,stmt,name,val){
    pool.append($.html.gen(stmt));

    pool.find('article.born').fadeIn("slow").removeClass('born');

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
        var search = getSearchFunc($(this).attr('type'));
        search($(this).attr('start')*1);
        pool.find('article.operator').remove();
    });


    pool.find('article.clear-load').click(function(e){
        pool.find('article.report').remove();
        var search = getSearchFunc($(this).attr('type'));
        search(1);
        pool.find('article.operator').remove();
    });
};


/**
 * Google
 */
function searchGoogle(start){
    if(start==null)
        start = 1;

    status('start');
    $.ajax({
        //url: $.format('http://%s/etirwemos/search/www/google/start/%s',location.host,start)
        url: 'http://'+location.host+'/etirwemos/search/www/google/start/'+start
    }).done(function(data){
        if(data==null)
            data=[];
        addGoogleCards(data,start+10);
    }).fail(function(data){
        console.log('fail');
    }).always(function(data){
        status('end');
    });

};
function addGoogleCards(data,nextStart){
    var pool = $('section#google > .pool');
    var stmt = [];
    $.each(data,function(){
        stmt.push({tag:'article',
                   cls:['report','born'],
                   attr:{style:'display:none;'},
                   con:[{tag:'div',
                         con:[{tag:'a',attr:{href:this.link},
                               con:[{tag:'p',cls:['title'],con:this.htmlTitle}]},
                              {tag:'p',cls:['snippet'],con:this.htmlSnippet}]}]});
    });

    addCards('google',pool,stmt,'start',nextStart);

};

/**
 * Github
 */
function searchGithub(start){
    if(start==null)
        start = 1;

    status('start');
    $.ajax({
        //url: $.format('http://%s/etirwemos/github/repogitory/search/page/%s',location.host,start)
        url: 'http://'+location.host+'/etirwemos/github/repogitory/search/page/'+start
    }).done(function(data){
        if(data==null)
            data=[];
        addGithubCards(data,start+1);
    }).fail(function(data){
        console.log('fail');
    }).always(function(data){
        status('end');
    });

};
function addGithubCards(data,nextStart){
    var pool = $('section#github > section.pool');
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
        tds.push({tag:'td',con:key.replace('_at', ' : ')});
        tds.push({tag:'td',con:moment(val).format('YYYY-MM-DD HH:mm:ss (dddd)')});

        return {tag:'tr',con:tds};
    };

    var stmt = [];
    $.each(data,function(){
        stmt.push({tag:'article',
                   cls:['report','github','born'],
                   attr:{style:'display:none;'},
                   con:[{tag:'div',
                         con:[{tag:'a',attr:{href:this.html_url,target:'_blank'},
                               con:[{tag:'p',cls:['title'],
                                     //con:$.format('%s @%s',this.name, this.language)}]},
                                     con:this.name + ' @' + this.language}]},
                              {tag:'p',cls:['description'],
                               con:this.description},
                              {tag:'table',cls:['timestamp'],
                               con:{tag:'tobdy',con:[fmtDt(this,'updated_at',true),
                                                     fmtDt(this,'pushed_at'),
                                                     fmtDt(this,'created_at')]}}

                             ]}]});
    });

    addCards('github',pool,stmt,'start',nextStart);
};
