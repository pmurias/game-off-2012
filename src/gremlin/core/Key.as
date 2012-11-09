package gremlin.core {
    import flash.utils.Dictionary;

    /**
     * ...
     * @author ...
     */
    public final class Key {
        private static var globalKeys:Dictionary;

        {
            globalKeys = new Dictionary(true);
        }

        public function Key(lock:Object = null) {
            if (lock != globalKeys) {
                throw "Key should be initialized using Key.of()";
            }
        }

        public static function of(value:String):Key {
            var key:Key = globalKeys[value];
            if (key == null) {
                key = new Key(globalKeys);
                globalKeys[value] = key;
            }
            return key;
        }

        public function get value():String {
            for (var keyValue:String in globalKeys) {
                if (globalKeys[keyValue] == this) {
                    return keyValue;
                }
            }
            return "undefined";
        }

    }

}