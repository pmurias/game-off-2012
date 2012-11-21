package game.modes {
    import game.CameraRotator;
    import game.commands.CommandSetHeroVelocity;
    import game.GameContext;
    import gremlin.events.KeyCodes;
	/**
     * ...
     * @author mosowski
     */
    public class FairMode extends Mode {
        public var rotator:CameraRotator;

        public function FairMode(gameCtx:GameContext) {
            super(gameCtx);
            rotator = new CameraRotator(gameCtx);
            rotator.node = gameCtx.hero.node;
        }

        override public function enter():void {
            super.enter();
            rotator.resetAlpha();
        }

        override public function processInput():void {
            super.processInput();

            var velocityX:Number = 0;
            var velocityZ:Number = 0;
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_DOWN)) {
                velocityZ = -0.08;
            }
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_UP)) {
                velocityZ = 0.08;
            }
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_LEFT)) {
                velocityX = -0.08;
            }
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_RIGHT)) {
                velocityX = 0.08;
            }

            if (velocityX != gameCtx.hero.velocity.x || velocityZ != gameCtx.hero.velocity.z) {
                var cmd:CommandSetHeroVelocity = new CommandSetHeroVelocity();
                cmd.heroId = gameCtx.hero.id;
                cmd.x = velocityX;
                cmd.z = velocityZ;
                gameCtx.commander.queueCommand(cmd);
            }
        }

        override public function render():void {
            super.render();
            ctx.rootNode.updateTransformation();
            rotator.tick();
            ctx.setCamera(rotator.camera);

            ctx.renderTargetMgr.defaultRenderTarget.activate();
            gameCtx.layer0.render();
            ctx.renderTargetMgr.defaultRenderTarget.finish();
        }

        override public function exit():void {
            super.exit();
            dispatch(Mode.MODE_EXITED);
        }

    }

}