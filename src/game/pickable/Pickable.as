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
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d[0]);
        }

        protected function pickCallback(hero:Hero):Boolean {
            return false;
        }

        public final function onPick(hero:Hero):void {
            if (dead == false) {
                if (pickCallback(hero) == true) {
                    dead = true;
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