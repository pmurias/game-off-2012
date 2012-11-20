package game {
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class GameObject {
        public var id:uint;
        public var gameCtx:GameContext;
        public var dead:Boolean;
        public var node:Node;
        public var shadow:Shadow;
        public var radius:Number;

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
    }
}