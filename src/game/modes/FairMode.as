package game.modes {
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import game.CameraRotator;
    import game.commands.CommandSetHeroVelocity;
    import game.GameContext;
    import game.Tile;
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

        override public function tick():void {
            super.tick();
            rotator.tick();
        }

        override public function render():void {
            super.render();
            ctx.rootNode.updateTransformation();
            gameCtx.level.updateTileBounds();
            ctx.setCamera(rotator.camera);

            if (gameCtx.debugInfo.visible) {
                gameCtx.level.drawTileBounds(rotator.camera);
                gameCtx.graphics.lineStyle(1, 0xFFFF00);
                for (var i:int = 0; i < gameCtx.gameObjects.length; ++i) {
                    if (gameCtx.gameObjects[i].collisionComponent != null) {
                        gameCtx.gameObjects[i].collisionComponent.debugDraw(gameCtx.graphics, rotator.camera);
                    }
                }
            }


            ctx.renderTargetMgr.defaultRenderTarget.activate();
            gameCtx.layer0.render();
            ctx.renderTargetMgr.defaultRenderTarget.finish();
        }

        override public function enter():void {
            super.enter();
            rotator.resetAlpha();
            rotator.tick();
        }

        override public function exit():void {
            super.exit();
            dispatch(Mode.MODE_EXITED);
        }

    }

}