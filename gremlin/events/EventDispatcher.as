package gremlin.events {
    import flash.utils.Dictionary;
    /**
     * ...
     * @author mosowski
     */
    public class EventDispatcher {
        private var infiniteListeners:Dictionary
        private var singleTimeListeners:Dictionary;

        public function EventDispatcher() {
            infiniteListeners = new Dictionary();
            singleTimeListeners = new Dictionary();
        }

        public function addListener(type:String, fun:Function):void {
            var listeners:Vector.<Function> = infiniteListeners[type];
            if (listeners == null) {
                listeners = infiniteListeners[type] = new Vector.<Function>();
            }
            if (listeners.indexOf(fun) == -1) {
                listeners.push(fun);
            }
        }

        public function addSingleTimeListener(type:String, fun:Function):void {
            var listeners:Vector.<Function> = singleTimeListeners[type];
            if (listeners == null) {
                listeners =  singleTimeListeners[type] = new Vector.<Function>();
            }
            if (listeners.indexOf(fun) == -1) {
                listeners.push(fun);
            }
        }

        public function removeListener(type:String, fun:Function):void {
            var listeners:Vector.<Function> = infiniteListeners[type];
            if (listeners) {
                var i:int = listeners.indexOf(fun);
                if (i != -1) {
                    listeners.splice(i, 1);
                }
            }
        }

        public function removeSingleTimeListener(type:String, fun:Function):void {
            var listeners:Vector.<Function> = singleTimeListeners[type];
            if (listeners) {
                var i:int = listeners.indexOf(fun);
                if (i != -1) {
                    listeners.splice(i, 1);
                }
            }
        }

        public function removeAllListeners(type:String):void {
            var listeners:Vector.<Function> = infiniteListeners[type];
            if (listeners) {
                listeners.length = 0;
            }

            listeners = singleTimeListeners[type];
            if (listeners) {
                listeners.length = 0;
            }
        }

        public function dispatch(type:String, params:Object = null):void {
            var listeners:Vector.<Function> = infiniteListeners[type];
            if (listeners) {
                for (var i:int = 0; i < listeners.length; ++i) {
                    listeners[i](params);
                }
            }
            listeners = singleTimeListeners[type];
            if (listeners) {
                for (i = 0; i < listeners.length; ++i) {
                    listeners[i](params);
                }
                listeners.length = 0;
            }
        }

    }

}