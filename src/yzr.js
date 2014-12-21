function dump(o){console.log(o)};

function Yaezakura() {
    $.findParent = function(cls,place){
        if(place==null)
            return null;

        if(place.hasClass(cls))
            return place;

        return this.findParent(cls,place.parent());
    };

};
Yaezakura.prototype.emptyIsError = function(name, v){
    if(this.undefinedP(v) || v==null || v=="")
        throw name + "が空です。必須入力です。";
    return this;
};
Yaezakura.prototype.notDateTimeIsError = function(name, v){
    if(v!=null)
        // フォーマットのチェック
        if( v.match(/^[0-9]+\/[0-9]+\/[0-9]+$/i)!=null ||
            v.match(/^[0-9]+\/[0-9]+\/[0-9]+ [0-9]+$/i)!=null ||
            v.match(/^[0-9]+\/[0-9]+\/[0-9]+ [0-9]+:[0-9]+$/i)!=null ||
            v.match(/^[0-9]+\/[0-9]+\/[0-9]+ [0-9]+:[0-9]+:[0-9]+$/i)!=null ||
            v.match(/^[0-9]+-[0-9]+-[0-9]+$/i)!=null ||
            v.match(/^[0-9]+-[0-9]+-[0-9]+ [0-9]+$/i)!=null ||
            v.match(/^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+$/i)!=null ||
            v.match(/^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+$/i)!=null)
            // のため moment でチェック
            if(moment(v).isValid())
                return this;

    throw name + "が日付フォーマットではありません。";
};
Yaezakura.prototype.notNumIsError = function(name, v){
    if(this.type.numberp(v))
        return;

    if(this.type.stringp(v))
        if(parseInt(v) || parseFloat(v))
            return;

    throw name + "が 数値ではありません。";
};
Yaezakura.prototype.dump = function(o){ dump(o); };
Yaezakura.prototype.undefinedP = function(v){
    if(v === void 0)
        return true;
    return false;
};
Yaezakura.prototype.fitCallbackMap = function(m){

    if(m==null) m = {success:null,fail:null,always:null};
    if(this.undefinedP(m.success)) m.success = null;
    if(this.undefinedP(m.fail))    m.fail    = null;
    if(this.undefinedP(m.always))  m.always  = null;

    return m;
};
Yaezakura.prototype.emptyP = function(v){
    if( this.undefinedP(v) ||
        v==null ||
        (this.type.stringp(v) && $.trim(v)==''))
        return true;

    return false;
};
Yaezakura.prototype.type = {
    objectp: function(v) {
        return (Object.prototype.toString.call(v) == "[object Object]");
    },
    functionp: function(v) {
        return (Object.prototype.toString.call(v) == "[object Function]");
    },
    arrayp: function(v) {
        return (Object.prototype.toString.call(v) == "[object Array]");
    },
    booleanp: function(v) {
        return (Object.prototype.toString.call(v) === "[object Boolean]");
    },
    stringp: function(v) {
        return (Object.prototype.toString.call(v) === "[object String]");
    },
    numberp: function(v) {
        return (Object.prototype.toString.call(v) === "[object Number]");
    },
    elementp: function(v) {
        var check = false;
        switch(Object.prototype.toString.call(v)) {
        case "[object Object]":
            if (v.length) check = true;
            break;
        case "[object Window]":
        case "[object HTMLParagraphElement]":
            if (! Type.isUndefined(v) && ! Type.nullp(v)) check = true;
            break;
        default:
            break;
        }
        return check;
    },
    elementCollectionp: function(v) {
        return (Object.prototype.toString.call(v) === "[object HTMLCollection]");
    },
    nullp: function(v) {
        return (v === null);
    },
    undefinedp: function(v) {
        return (v === 'undefined');
    },
    /**
     * @method getType
     * @param {Any} v The variable
     * @return {String} type of the variable
     */
    getType: function(v) {
        if (Type.isNull(v)) { return "null"; }
        if (Type.isUndefined(v)) { return "undefined"; }
        if (Type.isElement(v)) { return "HTMLElement"; }
        return Object.prototype.toString.call(v).split(" ")[1].replace("]", "");
    }
};
Yaezakura.prototype.utility = {
    fitHeightAtWindow:function(trg){
        this.fitHeightAt(trg,$(window));
    },
    fitHeightAt:function(trg,at){
        if(trg==null || trg.length==0)
            return;

        trg.height(at.height());
    }
};





