package game {
    import flash.display.Bitmap;
    import flash.display.Sprite;
	/**
     * ...
     * @author mosowski
     */
    public class SplashEffect {
        public var bitmap:Bitmap;
        public var sprite:Sprite;
        public var startTime:Number;

        public function SplashEffect(_bitmap:Bitmap, _startTime:Number) {
            bitmap = _bitmap;
            startTime = _startTime;
            sprite = new Sprite();
            sprite.addChild(bitmap);
            bitmap.x = -bitmap.width / 2;
            bitmap.y = -bitmap.height / 2;
        }

    }

}