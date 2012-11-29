package game {
    import flash.display.TriangleCulling;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import gremlin.core.Context;
    import gremlin.scene.Camera;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class CameraRotator {
        public var gameCtx:GameContext;
        public var camera:Camera;
        public var node:Node;

        // rotation-around speed
        public var alpha:Number;
        public var beta:Number;
        public var gamma:Number;

        public var alphaValue:Number;

        public var deadMode:Boolean;

        public function CameraRotator(gameCtx:GameContext, fixedWidth:int=-1, fixedHeight:int=-1) {
            this.gameCtx = gameCtx;
            camera = new Camera(gameCtx.ctx);
            if (fixedWidth == -1 || fixedHeight == -1) {
                gameCtx.ctx.addListener(Context.RESIZE, onResize);
                gameCtx.ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, gameCtx.stage.stageWidth / gameCtx.stage.stageHeight);
            } else {
                gameCtx.ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, fixedWidth / fixedHeight);
            }
            setAlpha(0.18);
            gamma = 30;
            beta = 13.5;
        }

        public function setAlpha(alpha:Number):void {
            this.alpha = alpha;
            resetAlpha();
        }

        public function resetAlpha():void {
            alphaValue = (alpha * gameCtx.time * gameCtx.levelConfig.alphaScale) % (Math.PI * 2);
            if (alphaValue < 0) {
                alphaValue += Math.PI * 2;
            }
        }

        public function tick():void {
            if (deadMode == false) {
                alphaValue = (alphaValue + alpha * gameCtx.timeStep * gameCtx.levelConfig.alphaScale * gameCtx.calmFactor) % (Math.PI * 2);
                if (alphaValue < 0) {
                    alphaValue += Math.PI * 2;
                }
            } else {
                beta += 2.0 * gameCtx.timeStep;
            }


            var pos:Vector3D = node.getPosition();
            camera.viewMatrix.identity();
            camera.viewMatrix.appendTranslation(-pos.x, -pos.y, -pos.z);
            camera.viewMatrix.appendRotation(-90 + Math.sin(alphaValue) * gamma, Vector3D.X_AXIS);
            camera.viewMatrix.appendRotation(Math.cos(alphaValue) * gamma, Vector3D.Z_AXIS);
            camera.viewMatrix.appendTranslation(0, 0, beta);
            camera.viewMatrix.appendRotation(alphaValue * 180/Math.PI, Vector3D.Z_AXIS);

            //var mapPosX:int = int(pos.x / 2);
            //var mapPosY:int = int(pos.z / 2);
            //for (var i:int = 0; i < gameCtx.level.width; ++i) {
                //for (var j:int = 0; j < gameCtx.level.height; ++j) {
                    //if (Math.abs(i-mapPosX) <= 8 && Math.abs(j-mapPosY) <= 5) {
                        //gameCtx.level.layers[0].tiles[i][j].node.setVisible(true);
                    //} else {
                        //gameCtx.level.layers[0].tiles[i][j].node.setVisible(false);
                    //}
                //}
            //}

        }

        public function clip():void {
            var out:Point = new Point();
            for (var i:int = 0; i < gameCtx.level.width; ++i) {
                for (var j:int = 0; j < gameCtx.level.height; ++j) {
                    var tile:Tile = gameCtx.level.layers[0].tiles[i][j];
                    if (tile != null) {
                        camera.getScreenPosition(tile.node.position, out);
                        tile.node.setVisible(out.x > -100 && out.y > -100 && out.x < gameCtx.stage.stageWidth +100 && out.y < gameCtx.stage.stageHeight + 100);
                    }
                }
            }
        }

        public function onResize(params:Object = null):void {
            gameCtx.ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, gameCtx.stage.stageWidth / gameCtx.stage.stageHeight);
        }

        public function destroy():void {
            gameCtx.ctx.removeListener(Context.RESIZE, onResize);
        }
    }


}