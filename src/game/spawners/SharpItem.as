package game.spawners {
    import flash.geom.Vector3D;
    import game.GameContext;
    import game.GameObject;
    import game.Tile;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class SharpItem extends GameObject {
        public var direction:Vector3D;
        public var speed:Number;
        public var homeTile:Tile;

        public function SharpItem(gameCtx:GameContext) {
            super(gameCtx);
            direction = new Vector3D();
            speed = 0;
        }

        protected function customTick():void {

        }

        override public function tick():void {
            super.tick();
            if (dead == false) {
                speed = 0.1;
                node.position.x += direction.x * speed;
                node.position.z += direction.z * speed;
                node.markAsDirty();

                customTick();

                var currentTile:Tile = gameCtx.level.getTileAtPosition(node.position, 0);
                if (currentTile.type.blocking && currentTile != homeTile) {
                    dead = true;
                }
            }
        }

    }

}