$(function () {
    $.html = new yzrHtml();

    var glide = $('#reports').glide({
        autoplay: false,
        circular: false,
        beforeTransition: function() {},
        afterTransition: function() {}
    });

    searchWWW();
    searchGithub();
});
function status(action){
    var background = $('section#background');

    if(action=='start')
        background.addClass('start');

    if(action=='end')
        background.removeClass('start');

};
function searchWWW(start){
    if(start==null)
        start = 1;

    status('start');
    $.ajax({
        url: $.format('http://%s/etirwemos/search/www/google/start/%s',location.host,start)
    }).done(function(data){
        if(data==null)
            data=[];
        addCards(data,start+10);
    }).fail(function(data){
        console.log('fail');
    }).always(function(data){
        status('end');
    });

};
function addCards(data,start){
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

    $('section#google > .pool').append($.html.gen(stmt));

    $('section#google > .pool article.born').fadeIn("slow").removeClass('born');

    $('section#google > .pool').append($.html.gen({tag:'article',
                                                   cls:['next-load'],
                                                   attr:{start:start},
                                                   con:[{tag:'div',con:'Next More'}]}));

    $('article.next-load').click(function(e){
        searchWWW($(this).attr('start')*1);
        $(this).remove();
    });

};

/**
 * Github
 */
function searchGithub(page){
    if(page==null)
        page = 1;

    status('start');
    $.ajax({
        url: $.format('http://%s/etirwemos/github/repogitory/search/page/%s',location.host,page)
    }).done(function(data){
        if(data==null)
            data=[];
        addGithubCards(data,page);
    }).fail(function(data){
        console.log('fail');
    }).always(function(data){
        status('end');
    });

};
function addGithubCards(data,page){
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
                                     con:$.format('%s @%s',this.name, this.language)}]},
                              {tag:'p',cls:['description'],
                               con:this.description},
                              {tag:'table',cls:['timestamp'],
                               con:{tag:'tobdy',con:[fmtDt(this,'updated_at',true),
                                                     fmtDt(this,'pushed_at'),
                                                     fmtDt(this,'created_at')]}}

                             ]}]});
    });

    pool.append($.html.gen(stmt));

    pool.find('article.born').fadeIn("slow").removeClass('born');

    pool.append($.html.gen({tag:'article',
                            cls:['next-load'],
                            attr:{page:page+1},
                            con:[{tag:'div',con:'Next More'}]}));

    pool.find('article.next-load').click(function(e){
        //TODO: これって重複する場合もあるんじゃろうな。。。
        searchGithub($(this).attr('page')*1);
        $(this).remove();
    });
};
