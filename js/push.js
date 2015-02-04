;__Mkey__Push__ = (function(){

    var callback = [],
		__mkey__Push__ = 
    {
        pushCallback_Push :  function (id,fun,nokeep)
        {
            callback[id] = { fun:fun, nokeep:nokeep};
        },
        execCallback_Push : function (id,eventType,args)
        {
            if (callback[id] )
            {
                if (callback[id].fun)
                {                                                    
                    if(eventType == 'click')
                    {
                        //此时为pagewindow
                        callback[id].fun(args);
                    }
                    else
                    {
                        callback[id].fun(args);
                    }
                }
            }     
        },
    };
    return __mkey__Push__;
})();
(function(plus)
{
    var mkey = window.plus.bridge,
		tools = window.plus.tools,
		_PUSHG = "Push";
    plus.push = {
        getClientInfo:function()
        {
            var eaToken = mkey.execSync(_PUSHG, 'getClientInfo', []);
            //alert(eaToken);
            return eaToken;
        }, 
        createMessage:function( message, Payload, Option)
        {
            if(tools.platform == tools.IOS){
                mkey.exec(_PUSHG, 'createMessage', [message, Payload, Option]);
            }else{
                var message = new Message(message, Payload, Option);
                var uuid = mkey.execSync(_PUSHG, 'createMessage', [message]);
                message.__UUID__ = uuid;
            }  
        },
        clear:function()
        {
            mkey.exec(_PUSHG, 'clear',[]);
        },
        addEventListener:function( type, Listener, capture)
        {
            var Udid = tools.UUID(type);
            __Mkey__Push__.pushCallback_Push(Udid, Listener, capture);
            mkey.exec(_PUSHG, 'addEventListener', [window.__HtMl_Id__, Udid, type]);
        },
        remove:function(message)
        {
            mkey.exec(_PUSHG, 'remove', [message.__UUID__]);
        },
        getAllMessage:function()
        {
            return mkey.execSync(_PUSHG, 'getAllMessage', []);
        },
        setAutoNotification:function(auto){
            mkey.exec(_PUSHG, 'setAutoNotification', [auto]);
        },
    };
    function Message(message , Payload, options){
        this.__UUID__ = null;
        this.message = message;
        this.Payload = Payload;
        this.options = options
    }

})(window.plus);