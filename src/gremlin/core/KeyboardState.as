package gremlin.core {
	/**
     * ...
     * @author mosowski
     */
    public class KeyboardState {
        private var keyDown:Array;

        public function KeyboardState() {
            keyDown = new Array();
        }

        public function setKeyDown(k:uint):void {
            keyDown[k] = true;
        }

        public function setKeyUp(k:uint):void {
            keyDown[k] = false;
        }

        public function isKeyDown(k:uint):Boolean {
            return keyDown[k];
        }

    }

}