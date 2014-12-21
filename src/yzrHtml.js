/* *********************************************************** *
 * HTML
 * *********************************************************** */
/**
 * bHtml
 *
 * {tag:'',cls:[''],id:'',attr:{},contents:[''|['']] }
 * {tag:'',cls:null,id:null,attr:{},contents:'' }
 * {tag:'',cls:null,id:null,attr:{},contents:[${self},..] }
 */
function yzrHtml(){}
yzrHtml.prototype = new Yaezakura();
yzrHtml.prototype.gen = function(rec){

    if(rec==null) return '';
    if(this.type.stringp(rec)) return rec;
    if(this.type.numberp(rec)) return rec + '';

    var tmp = rec;
    if(this.type.objectp(tmp)) tmp = [tmp];

    var stmt = '';
    var me = this;
    $.each(tmp,function(){stmt+=me.genTag(this);});

    return stmt;
};
yzrHtml.prototype.genTag = function(rec){
    var tag  = rec.tag;
    var cls  = this.strKeyVal('class', this.genClass(rec));
    var id   = this.strKeyVal('id', rec.id);
    var attr = this.genAttribute( rec );
    var cnts = this.gen(rec.con);

    return '<' + tag + cls + id + attr +  '>' + cnts + '</' + tag + '>' ;
};
yzrHtml.prototype.genClass = function(rec){
    var lst = rec.cls;
    if(lst==null || lst.length==0 )
        return null;

    var out='';
    for(var i in lst)
        out += lst[i] + ' ';

    return $.trim(out);
};
yzrHtml.prototype.genAttribute = function(rec){
    var map = rec.attr;
    var out = '';
    for(var k in map )
        out += this.strKeyVal(k, map[k]) + ' ';

    if(out=='' || $.trim(out)=="")
        return '';

    return ' ' + $.trim(out);
};
yzrHtml.prototype.strKeyVal= function(key,val){
    if(val==null) return '';

    if(key==null) return ' ' + val;


    if(key=='selected'){
        if(val==null || val==false || $.trim(val).length==0)
            return '';
        else
            return 'selected';
    }
    if(key=='checked'){
        if(val==null || val==false || $.trim(val).length==0)
            return '';
        else
            return 'checked';
    }
    if(key=='disabled'){
        if(val==null || val==false || $.trim(val).length==0)
            return '';
        else
            return 'disabled';
    }

    if(this.type.numberp(val))
        return ' ' + $.trim(key) + '=' + val ;

    return ' ' + $.trim(key) + '="' + $.trim(val) + '"';
};

yzrHtml.prototype.uri = function(path,param){
    return "http://" + this.host + ':' + this.port + path;
};
yzrHtml.prototype.redirect = function(to){
    if(to=='google')
        $(location).attr("href", 'http://www.google.com');
};
