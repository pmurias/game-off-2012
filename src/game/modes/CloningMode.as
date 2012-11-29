package game.modes {
    import game.CameraRotator;
    import game.commands.CommandSetHeroVelocity;
    import game.GameContext;
    import gremlin.core.Context;
    import gremlin.events.KeyCodes;
    import gremlin.gremlin2d.Quad2d;

    /**
     * ...
     * @author mosowski
     */
    public class CloningMode extends Mode {
        private var quad:Quad2d;
        public var mainRotator:CameraRotator;
        public var cloneRotator:CameraRotator;
        public var cloneAlpha:Number;
        public var cloneTransparency:Number;
        public var exiting:Boolean;
        public var returningSpeed:Number;

        public function CloningMode(gameCtx:GameContext) {
            super(gameCtx);
            mainRotator = new CameraRotator(gameCtx);
            cloneRotator = new CameraRotator(gameCtx);
            mainRotator.node = gameCtx.hero.node;
            cloneRotator.node = gameCtx.hero.node;
            mainRotator.tick();
            cloneRotator.tick();

            quad = new Quad2d();
            quad.transformation.identity();
            quad.transformation.scale(ctx.stage.stageWidth, ctx.stage.stageHeight);
            quad.transformation.translate(ctx.stage.stageWidth / 2, ctx.stage.stageHeight / 2);
            quad.setMaterial(ctx.materialMgr.getMaterial("CloningMode"));
            ctx.addListener(Context.RESIZE, function(params:Object):void {
                    quad.transformation.identity();
                    quad.transformation.scale(ctx.stage.stageWidth, ctx.stage.stageHeight);
                    quad.transformation.translate(ctx.stage.stageWidth / 2, ctx.stage.stageHeight / 2);
                });
        }

        override public function enter():void {
            super.enter();
            quad.setScene(gameCtx.layerPostprocess);
            gameCtx.splasher.splashBitmap(new gameCtx.staticEmbeded.cloning_mode());
        }

        override public function exit():void {
            exiting = true;
            returningSpeed = Math.abs(gameCtx.ctx.mathUtils.getAngleDistance(cloneRotator.alphaValue, mainRotator.alphaValue)) * gameCtx.timeStep;
        }

        override public function destroy():void {
            quad.setScene(null);
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
            mainRotator.tick();
            cloneRotator.tick();
            cloneRotator.alpha += (( -0.18) - cloneRotator.alpha) * 0.005;

            if (exiting == true) {
                cloneRotator.alpha = 0;

                cloneRotator.alphaValue = gameCtx.ctx.mathUtils.getShiftedAngle(cloneRotator.alphaValue, mainRotator.alphaValue, returningSpeed);

                if (Math.abs(gameCtx.ctx.mathUtils.getAngleDistance(cloneRotator.alphaValue, mainRotator.alphaValue)) < 0.02) {
                    quad.setScene(null);
                    dispatch(Mode.MODE_EXITED);
                }
            } else {
                if (cloneRotator.alpha < mainRotator.alpha + cloneAlpha) {
                    cloneRotator.alpha += (cloneAlpha) / 60;
                }
            }
        }

        override public function render():void {
            super.render();

            ctx.rootNode.updateTransformation();

            ctx.setCamera(cloneRotator.camera);
            cloneRotator.clip();
            ctx.renderTargetMgr.renderTargets["bigRT2"].activate();
            gameCtx.layer0.render();
            ctx.renderTargetMgr.renderTargets["bigRT2"].finish();

            ctx.setCamera(mainRotator.camera);
            mainRotator.clip();
            ctx.renderTargetMgr.defaultRenderTarget.activate();
            gameCtx.layer0.render();
            gameCtx.layerPostprocess.render();
            gameCtx.layerGUI.render();
            ctx.renderTargetMgr.defaultRenderTarget.finish();
        }

    }

}