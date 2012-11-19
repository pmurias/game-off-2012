package game.commands {
    import game.GameContext;
    import game.Hero;
	/**
     * ...
     * @author mosowski
     */
    public class CommandSetHeroPosition extends Command {
        public var heroId:uint;
        public var x:Number;
        public var y:Number;
        public var z:Number;

        public function CommandSetHeroPosition() {
            x = y = z = 0;
        }

        override public function execute(gameCtx:GameContext):void {
            super.execute(gameCtx);
            var hero:Hero = gameCtx.heroes[heroId];
            hero.setPosition(x, y, z);
        }
    }

}