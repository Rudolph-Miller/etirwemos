$(function () {	
    $.html = new yzrHtml();

    searchWWW();
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
	url: "http://localhost:5000/etirwemos/search/www/google/start/"+start
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

    $('section#reports').append($.html.gen(stmt));

    $('section#reports article.born').fadeIn("slow").removeClass('born');

    $('section#reports').append($.html.gen({tag:'article',
	       cls:['next-load'],
	       attr:{start:start},
	       con:[{tag:'div',con:'Next More'}]}));

    $('article.next-load').click(function(e){
	searchWWW($(this).attr('start')*1);
	$(this).remove();
    });

};
