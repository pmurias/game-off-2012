package game.commands {
    import flash.geom.Vector3D;
    import game.GameContext;
    import game.Hero;
	/**
     * ...
     * @author mosowski
     */
    public class CommandSetHeroVelocity extends Command {
        public var heroId:uint;
        public var x:Number;
        public var y:Number;
        public var z:Number;

        public function CommandSetHeroVelocity() {
            x = y = z = 0;
        }

        override public function execute(gameCtx:GameContext):void {
            super.execute(gameCtx);
            var hero:Hero = gameCtx.heroesById[heroId];
            hero.setVelocity(x, y, z);
        }

    }

}