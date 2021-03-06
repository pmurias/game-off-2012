package game.pickable {
    import flash.geom.Vector3D;
    import game.CollisionComponent;
    import game.GameContext;
    import game.GameObject;
    import game.Hero;
    import game.HeroPlayer;
    import gremlin.materials.Material;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class Pickable extends GameObject {
        public var entity:ModelEntity;

        public function Pickable(gameCtx:GameContext) {
            super(gameCtx);
            gameCtx.pickables.push(this);
            gameCtx.pickablesById[id] = this;
            enableShadow();
            radius = 0.3;
        }

        public function enableCollision():void {
            collisionComponent = new CollisionComponent(node);
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d);
        }

        protected function pickCallback(hero:Hero):Boolean {
            return false;
        }

        private var dying:Boolean;
        public final function onPick(hero:Hero):void {
            if (dead == false && dying==false) {
                if (pickCallback(hero) == true) {
                    dying = true;
                    //gameCtx.ctx.tweener.tween(node.position, "x", node.position.x, node.position.x, 1, null);
                    //gameCtx.ctx.tweener.tween(node.position, "y", node.position.y, 0, 1, null);
                    gameCtx.ctx.tweener.tween(node.position, "y", node.position.y, 20, 1, function():void {
                        dead = true;
                    });
                }
            }
        }

        override public function tick():void {
            super.tick();
            node.getRotation().multiplyByAngleAxis(Vector3D.Y_AXIS, 0.02);
            node.getPosition().y = 0.8 + Math.sin(gameCtx.time*2) * 0.2;
            node.markAsDirty();
        }

        override public function destroy():void {
            super.destroy();
            entity.removeFromScene(gameCtx.layer0);

            gameCtx.pickables.splice(gameCtx.pickables.indexOf(this), 1);
            delete gameCtx.pickablesById[id];
        }

    }

}