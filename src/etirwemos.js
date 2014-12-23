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
        // TODO: format4js
        url: 'http://'+location.host+'/etirwemos/search/www/google/start/'+start
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
        // cacheId: "Ddwf5R0JRisJ"
        //--------------
        // title: "The Common Lisp Cookbook"
        // htmlTitle: "The <b>Common Lisp</b> Cookbook"
        //--------------
        // displayLink: "cl-cookbook.sourceforge.net"
        // htmlSnippet: "Collaborative project; goal: write for CL a work similar to O&#39;Reilly Media&#39;s Perl <br>↵Cookbook."
        // kind: "customsearch#result"
        // snippet: "Collaborative project; goal: write for CL a work similar to O'Reilly Media's Perl ↵Cookbook."
        // link: "http://cl-cookbook.sourceforge.net/"
        // formattedUrl: "cl-cookbook.sourceforge.net/"
        // htmlFormattedUrl: "cl-cookbook.sourceforge.net/"
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
        // TODO: format4js
        url: 'http://'+location.host+'/etirwemos/github/repogitory/search/page/'+page
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
                                     // TODO: format4js
                                     con:this.name + ' @' + this.language}]},
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


    // html_url: "https://github.com/robert-strandh/SICL"
    // name: "SICL"
    // description: "A fresh implementation of Common Lisp"
    // language: "Common Lisp"
    // created_at: "2012-10-24T04:37:36Z"
    // updated_at: "2014-12-23T09:45:21Z"
    // pushed_at: "2014-12-23T09:45:21Z"
    // owner:
    // -> id: 1449025
    // -> login: "robert-strandh"
    // -> html_url: "https://github.com/robert-strandh"
    // -> avatar_url: "https://avatars.githubusercontent.com/u/1449025?v=3"

    // archive_url: "https://api.github.com/repos/robert-strandh/SICL/{archive_format}{/ref}"
    // assignees_url: "https://api.github.com/repos/robert-strandh/SICL/assignees{/user}"
    // blobs_url: "https://api.github.com/repos/robert-strandh/SICL/git/blobs{/sha}"
    // branches_url: "https://api.github.com/repos/robert-strandh/SICL/branches{/branch}"
    // clone_url: "https://github.com/robert-strandh/SICL.git"
    // collaborators_url: "https://api.github.com/repos/robert-strandh/SICL/collaborators{/collaborator}"
    // comments_url: "https://api.github.com/repos/robert-strandh/SICL/comments{/number}"
    // commits_url: "https://api.github.com/repos/robert-strandh/SICL/commits{/sha}"
    // compare_url: "https://api.github.com/repos/robert-strandh/SICL/compare/{base}...{head}"
    // contents_url: "https://api.github.com/repos/robert-strandh/SICL/contents/{+path}"
    // contributors_url: "https://api.github.com/repos/robert-strandh/SICL/contributors"
    // default_branch: "master"
    // downloads_url: "https://api.github.com/repos/robert-strandh/SICL/downloads"
    // events_url: "https://api.github.com/repos/robert-strandh/SICL/events"
    // fork: null
    // forks: 16
    // forks_count: 16
    // forks_url: "https://api.github.com/repos/robert-strandh/SICL/forks"
    // full_name: "robert-strandh/SICL"
    // git_commits_url: "https://api.github.com/repos/robert-strandh/SICL/git/commits{/sha}"
    // git_refs_url: "https://api.github.com/repos/robert-strandh/SICL/git/refs{/sha}"
    // git_tags_url: "https://api.github.com/repos/robert-strandh/SICL/git/tags{/sha}"
    // git_url: "git://github.com/robert-strandh/SICL.git"
    // has_downloads: true
    // has_issues: true
    // has_pages: null
    // has_wiki: true
    // homepage: null
    // hooks_url: "https://api.github.com/repos/robert-strandh/SICL/hooks"
    // id: 6364653
    // issue_comment_url: "https://api.github.com/repos/robert-strandh/SICL/issues/comments/{number}"
    // issue_events_url: "https://api.github.com/repos/robert-strandh/SICL/issues/events{/number}"
    // issues_url: "https://api.github.com/repos/robert-strandh/SICL/issues{/number}"
    // keys_url: "https://api.github.com/repos/robert-strandh/SICL/keys{/key_id}"
    // labels_url: "https://api.github.com/repos/robert-strandh/SICL/labels{/name}"
    // languages_url: "https://api.github.com/repos/robert-strandh/SICL/languages"
    // merges_url: "https://api.github.com/repos/robert-strandh/SICL/merges"
    // milestones_url: "https://api.github.com/repos/robert-strandh/SICL/milestones{/number}"
    // mirror_url: null
    // notifications_url: "https://api.github.com/repos/robert-strandh/SICL/notifications{?since,all,participating}"
    // open_issues: 2
    // open_issues_count: 2
    // owner:
    // -> events_url: "https://api.github.com/users/robert-strandh/events{/privacy}"
    // -> followers_url: "https://api.github.com/users/robert-strandh/followers"
    // -> following_url: "https://api.github.com/users/robert-strandh/following{/other_user}"
    // -> gists_url: "https://api.github.com/users/robert-strandh/gists{/gist_id}"
    // -> gravatar_id: ""
    // -> organizations_url: "https://api.github.com/users/robert-strandh/orgs"
    // -> received_events_url: "https://api.github.com/users/robert-strandh/received_events"
    // -> repos_url: "https://api.github.com/users/robert-strandh/repos"
    // -> site_admin: null
    // -> starred_url: "https://api.github.com/users/robert-strandh/starred{/owner}{/repo}"
    // -> subscriptions_url: "https://api.github.com/users/robert-strandh/subscriptions"
    // -> type: "User"
    // -> url: "https://api.github.com/users/robert-strandh"
    // private: null
    // pulls_url: "https://api.github.com/repos/robert-strandh/SICL/pulls{/number}"
    // releases_url: "https://api.github.com/repos/robert-strandh/SICL/releases{/id}"
    // score: 1
    // size: 18417
    // ssh_url: "git@github.com:robert-strandh/SICL.git"
    // stargazers_count: 192
    // stargazers_url: "https://api.github.com/repos/robert-strandh/SICL/stargazers"
    // statuses_url: "https://api.github.com/repos/robert-strandh/SICL/statuses/{sha}"
    // subscribers_url: "https://api.github.com/repos/robert-strandh/SICL/subscribers"
    // subscription_url: "https://api.github.com/repos/robert-strandh/SICL/subscription"
    // svn_url: "https://github.com/robert-strandh/SICL"
    // tags_url: "https://api.github.com/repos/robert-strandh/SICL/tags"
    // teams_url: "https://api.github.com/repos/robert-strandh/SICL/teams"
    // trees_url: "https://api.github.com/repos/robert-strandh/SICL/git/trees{/sha}"
    // url: "https://api.github.com/repos/robert-strandh/SICL"
    // watchers: 192
    // watchers_count: 192
};
