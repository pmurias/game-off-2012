package game.spawners {
    import flash.geom.Vector3D;
    import game.GameContext;
    import game.Tile;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class SharpItem {
        public var gameCtx:GameContext;
        public var position:Vector3D;
        public var direction:Vector3D;
        public var speed:Number;
        public var node:Node;
        public var homeTile:Tile;

        public var dead:Boolean;

        public function SharpItem(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            position = new Vector3D();
            direction = new Vector3D();
            speed = 0;
            node = new Node();
            gameCtx.ctx.rootNode.addChild(node);
            dead = false;
        }

        protected function customTick():void {

        }

        public final function tick():void {
            if (dead == false) {
                speed = 0.1;
                position.x += direction.x * speed;
                position.z += direction.z * speed;
                node.copyPositionFrom(position);

                customTick();

                var currentTile:Tile = gameCtx.level.getTileAtPosition(position, 0);
                if (currentTile.type.blocking && currentTile != homeTile) {
                    dead = true;
                }
            }
        }

        public function destroy():void {
            gameCtx.ctx.rootNode.removeChild(node);
        }

    }

}
