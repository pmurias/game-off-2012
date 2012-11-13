package game {
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

        public function CameraRotator(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            camera = new Camera();
            gameCtx.ctx.addListener(Context.RESIZE, onResize);
            gameCtx.ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, gameCtx.stage.stageWidth / gameCtx.stage.stageHeight);
        }

        public function tick():void {
            camera.viewMatrix.identity();
            var pos:Vector3D = node.getPosition();
            camera.viewMatrix.appendTranslation(-pos.x, -pos.y, -pos.z);
            camera.viewMatrix.appendRotation( -90 + Math.sin(gameCtx.ctx.time) * 10, Vector3D.X_AXIS);
            camera.viewMatrix.appendRotation(Math.cos(gameCtx.ctx.time)*10, Vector3D.Z_AXIS);
            camera.viewMatrix.appendTranslation(0, 0, 13.5 + Math.sin(gameCtx.ctx.time));

            var mapPosX:int = int(pos.x / 2);
            var mapPosY:int = int(pos.z / 2);
            for (var i:int = 0; i < gameCtx.level.width; ++i) {
                for (var j:int = 0; j < gameCtx.level.height; ++j) {
                    if (Math.abs(i-mapPosX) <= 6 && Math.abs(j-mapPosY) <= 6) {
                        gameCtx.level.layers[0].tiles[i][j].node.setVisible(true);
                    } else {
                        gameCtx.level.layers[0].tiles[i][j].node.setVisible(false);
                    }
                }
            }

        }

        public function onResize(params:Object = null):void {
            gameCtx.ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, gameCtx.stage.stageWidth / gameCtx.stage.stageHeight);
        }
    }


}