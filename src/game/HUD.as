package game {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
	/**
     * ...
     * @author mosowski
     */
    public class HUD {
        private var gameCtx:GameContext;
        public var sprite:Sprite;
        public var pointsTextField:TextField;
        public var deathsTextField:TextField;

        public function HUD(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            sprite = new Sprite();
            gameCtx.stage.addChild(sprite);

            pointsTextField = new TextField();
            sprite.addChild(pointsTextField);
            pointsTextField.x = 20;
            pointsTextField.y = 20;
            pointsTextField.textColor = 0xFFFFFF;
            pointsTextField.alpha = 0.5;
            pointsTextField.defaultTextFormat = new TextFormat("Decade", 20);
            pointsTextField.text = "Points: 0";

            deathsTextField = new TextField();
            sprite.addChild(deathsTextField);
            deathsTextField.x = 20;
            deathsTextField.y = 45;
            deathsTextField.textColor = 0xFFFFFF;
            deathsTextField.alpha = 0.5;
            deathsTextField.defaultTextFormat = new TextFormat("Decade", 15);
            deathsTextField.text = "Deaths: 0";
        }

    }

}