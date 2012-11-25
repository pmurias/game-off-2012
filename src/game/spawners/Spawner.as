package game.spawners {
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import game.GameContext;
	/**
     * ...
     * @author mosowski
     */
    public class Spawner {
        public var gameCtx:GameContext;
        public var position:Vector3D;
        public var direction:Vector3D;
        public var speed:Number;
        public var delay:Number;
        public var spawnedType:Class;

        public var lastSpawnTime:Number;

        private static var spawnedTypeByName:Dictionary;

        public function Spawner(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            position = new Vector3D();
            direction = new Vector3D();
            speed = 0;
            delay = 0;
            lastSpawnTime = gameCtx.time;

            if (spawnedTypeByName == null) {
                spawnedTypeByName = new Dictionary();
                spawnedTypeByName["blade"] = Blade;
                spawnedTypeByName["fork"] = Fork;
            }
        }

        public function fromObject(object:Object):void {
            speed = object.speed;
            delay = object.delay;
            direction.setTo(Math.sin(object.rotation), 0, Math.cos(object.rotation));
            position.setTo(object.position[0]+1, object.position[1]+0.5, object.position[2]);

            spawnedType = spawnedTypeByName[object.type];
        }

        public function tick():void {
            if (gameCtx.time > lastSpawnTime + delay) {
                var sharpItem:SharpItem = new spawnedType(gameCtx);
                sharpItem.homeTile = gameCtx.level.getTileAtPosition(position, 0);
                sharpItem.direction.copyFrom(direction);
                sharpItem.node.position.copyFrom(position);
                sharpItem.speed = speed;
                lastSpawnTime = gameCtx.time;
            }
        }

    }

}