package game {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import gremlin.core.Context;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class TipArea {
        public var gameCtx:GameContext;
        public var node:Node;
        public var sprite:Sprite;
        public var tipAnchor:Sprite;
        public var tipArea:Sprite;
        public var textArea:TextField;
        public var width:int;
        public var height:int;
        public var margin:int;
        public var maxAlpha:Number;

        private var visible:Boolean;
        private var tweening:Boolean;

        public static var glowFilter:Object;

        private function initStatic():void {
            if (glowFilter == null) {
                glowFilter = new GlowFilter(0xFFFFFFF, 0.6, 12, 12);
                //glowFilter = new DropShadowFilter(6, 45, 0, 1, 12, 12);
            }
        }

        public function TipArea(_gameCtx:GameContext) {
            initStatic();

            gameCtx = _gameCtx;
            margin = 10;
            sprite = new Sprite();
            tipAnchor = new Sprite();
            tipArea = new Sprite();
            textArea = new TextField();
            textArea.defaultTextFormat = new TextFormat("FontGhostWriter", 20, 0xFFFFFF);
            textArea.defaultTextFormat.align = TextFormatAlign.CENTER;
            textArea.embedFonts = true;
            textArea.wordWrap = true;
            tipArea.addChild(textArea);
            sprite.addChild(tipArea);
            sprite.addChild(tipAnchor);
            sprite.filters = [ glowFilter ];
            maxAlpha = 0.8;
        }

        public function show():void {
            if (visible == false && tweening == false ) {
                gameCtx.stage.addChild(sprite);
                gameCtx.ctx.addListener(Context.ENTER_FRAME, tick);
                visible = true;
                tweenIn();
            }
        }

        public function tweenIn():void {
            sprite.scaleX = 1;
            sprite.scaleY = 1;
            sprite.alpha = 0;
            tweening = true;
            gameCtx.ctx.tweener.tween(sprite, "alpha", 0, maxAlpha, 0.5, onShowComplete);
        }

        private function onShowComplete():void {
            tweening = false;
        }

        public function hide():void {
            if (visible == true && tweening == false) {
                tweenOut();
            }
        }

        private function tweenOut():void {
            tweening = true;
            gameCtx.ctx.tweener.tween(sprite, "alpha", maxAlpha, 0, 0.5, onHideComplete);
        }

        private function onHideComplete():void {
            gameCtx.stage.removeChild(sprite);
            gameCtx.ctx.removeListener(Context.ENTER_FRAME, tick);
            visible = false;
            tweening = false;
        }

        public function setSize(w:int, h:int):void {
            width = w;
            height = h;
            tipAnchor.graphics.clear();
            tipAnchor.graphics.beginFill(0x000000, 1);
            tipAnchor.graphics.moveTo( -10, -50);
            tipAnchor.graphics.lineTo(0, 0);
            tipAnchor.graphics.lineTo(10, -50);
            tipAnchor.graphics.lineTo( -10, -50);
            tipAnchor.graphics.endFill();

            tipArea.graphics.clear();
            tipArea.graphics.beginFill(0x000000, 1);
            tipArea.graphics.drawRoundRect( -w / 2, -h - 50, w, h, 20, 20);
            tipArea.graphics.endFill();
        }

        public function setText(text:String):void {
            textArea.width = width - 2 * margin;
            textArea.height = height - 2 * margin;
            textArea.text = text;
            textArea.width = textArea.textWidth + 10;
            textArea.height = textArea.textHeight + 10;
            textArea.x = -width /2 + (width - textArea.width)/2;
            textArea.y = -height - 50 + (height -textArea.height) / 2;
            tweenIn();
        }

        public function tick(params:Object = null):void {
            var outPosition:Point = new Point();
            gameCtx.ctx.activeCamera.getScreenPosition(node.derivedPosition, outPosition);
            sprite.x = outPosition.x;
            sprite.y = outPosition.y;
        }

        public function destroy():void {
            if (gameCtx.stage.contains(sprite)) {
                gameCtx.stage.removeChild(sprite);
                gameCtx.ctx.removeListener(Context.ENTER_FRAME, tick);
            }
            gameCtx.ctx.tweener.killAllTweensOf(sprite);
        }

    }

}