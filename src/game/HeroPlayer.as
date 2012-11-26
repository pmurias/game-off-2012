package game {
    import flash.geom.Vector3D;
    import game.pickable.Pickable;
    import gremlin.animation.AnimationState;
    import gremlin.core.Context;
    import gremlin.scene.AnimatedEntity;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class HeroPlayer extends Hero {


        public function HeroPlayer(gameCtx:GameContext) {
            super(gameCtx);
            entity = new AnimatedEntity(gameCtx.ctx.modelMgr.getModelResource("Beholder"), node);
            var idleAnim:AnimationState = (entity as AnimatedEntity).setAnimationState("Idle");
            idleAnim.gotoAndPlay();
            collisionComponent = new CollisionComponent(node);
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d[0]);
            entity.addToScene(gameCtx.layer0);
            shadow.node.setScale(1.5, 1, 1.5);
            radius = 0.5;
            isMortal = true;
        }

        override public function tick():void {
            super.tick();
            (entity as AnimatedEntity).currentAnimationState.advance(gameCtx.timeStep);

            if (isDead == false) {
                node.position.y = 1.5 + Math.sin(gameCtx.time) * 0.5;
            } else {
                node.position.y += (0.5 - node.position.y) * 0.3;
            }

            for (var i:int = 0; i < gameCtx.pickables.length; ++i) {
                var pickable:Pickable = gameCtx.pickables[i];
                if (collisionComponent.bounds.intersects(pickable.collisionComponent.bounds)) {
                    pickable.onPick(this);
                }
            }
        }

        override public function die():void {
            var animState:AnimationState = (entity as AnimatedEntity).setAnimationState("Death");
            var bloodSpatter:BloodSpatter = new BloodSpatter(gameCtx, node);
            animState.playOnce();
            gameCtx.die();
            isDead = true;
        }

        public function checkSpikesCollision():void {

        }

        override public function destroy():void {
            super.destroy();
            entity.removeFromAllScenes();
        }
    }

}