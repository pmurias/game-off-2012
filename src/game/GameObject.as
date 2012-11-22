package game {
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class GameObject implements ICollisionComponent {
        public var id:uint;
        public var gameCtx:GameContext;
        public var dead:Boolean;
        public var node:Node;
        public var shadow:Shadow;
        public var radius:Number;

        public var collisionComponent:CollisionComponent;

        public function GameObject(gameCtx:GameContext) {
            this.gameCtx = gameCtx;
            gameCtx.gameObjects.push(this);
            id = gameCtx.getUniqueId();
            node = new Node();
            gameCtx.ctx.rootNode.addChild(node);
            dead = false;
            radius = 0;
        }

        public function enableShadow():void {
            shadow = new Shadow(gameCtx, node);
        }

        public function tick():void {
            if (collisionComponent != null) {
                collisionComponent.updateBounds();
            }
            if (shadow != null) {
                shadow.tick();
            }
        }

        public function destroy():void {
            gameCtx.ctx.rootNode.removeChild(node);
            if (shadow != null) {
                shadow.destroy();
            }
        }

        public function getCollisionComponent():CollisionComponent {
            return collisionComponent;
        }
    }
}