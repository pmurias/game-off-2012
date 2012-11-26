package game {
    import flash.geom.Vector3D;
    import game.pickable.Pickable;
    import gremlin.animation.AnimationState;
    import gremlin.core.Context;
    import gremlin.particles.BillboardParticlesEntity;
    import gremlin.scene.AnimatedEntity;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class HeroReaper extends Hero {

        public var animatedEntity:AnimatedEntity;
        public var particlesDeath:BillboardParticlesEntity;
        public var particlesDeathNode:Node;
        public var idleAnim:AnimationState;
        public var walkAnim :AnimationState;
        public var attackAnim:AnimationState;
        public var isAttacking:Boolean;

        public function HeroReaper(gameCtx:GameContext) {
            super(gameCtx);
            entity = new AnimatedEntity(gameCtx.ctx.modelMgr.getModelResource("Reaper"), node);
            animatedEntity = entity as AnimatedEntity;
            idleAnim = animatedEntity.getAnimationState("Idle");
            walkAnim = animatedEntity.getAnimationState("Walk");
            attackAnim = animatedEntity.getAnimationState("Attack");
            animatedEntity.setAnimationState("Walk");
            walkAnim.gotoAndPlay();
            collisionComponent = new CollisionComponent(node);
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d[0]);
            entity.addToScene(gameCtx.layer0);
            collisionEnabled = false;
            shadow.node.setScale(1.5, 1, 1.5);
            radius = 0.5;
            speed = 0.015;
            isMortal = false;
            initParticles();
        }

        private function initParticles():void {
            particlesDeathNode = new Node();
            node.addChild(particlesDeathNode);
            particlesDeathNode.rotation.multiplyByAngleAxis(Vector3D.X_AXIS, Math.PI * 0.5);

            var p:BillboardParticlesEntity = particlesDeath = new BillboardParticlesEntity(gameCtx.ctx);
            p.minLife = 1.2;
            p.maxLife = 1.3;
            p.minStartSize = 1.1;
            p.maxStartSize = 1.1;
            p.minEndSize = 3.5;
            p.maxEndSize = 3.8;
            p.minVelocity = 4.5;
            p.maxVelocity = 4.5;
            p.minRotation = 0;
            p.maxRotation = Math.PI * 2;
            p.minOmega = Math.PI;
            p.maxOmega = Math.PI*2;
            p.minStartColor = 0xFFFF0022;
            p.maxStartColor = 0xFFFF0022;
            p.minEndColor = 0x00FF0022;
            p.maxEndColor = 0x00FF0022;
            p.spawnRate = 3;
            p.setQuota(15);
            p.setMaterial(gameCtx.ctx.materialMgr.getMaterial("ParticleDeath"));
            p.node = particlesDeathNode;
            p.addToScene(gameCtx.layer0);
        }

        override public function tick():void {
            super.tick();
            animatedEntity.currentAnimationState.advance(gameCtx.timeStep);

            if (collisionComponent.bounds.intersects(gameCtx.hero.collisionComponent.bounds) && gameCtx.hero.isDead == false) {
                if (animatedEntity.currentAnimationState != attackAnim) {
                    animatedEntity.setAnimationState("Attack");
                    attackAnim.addSingleTimeListener(AnimationState.ANIMATION_COMPELTED, onAttackCompleted);
                    attackAnim.playOnce();
                    isAttacking = true;
                    moveTargetSet = false;
                    velocity.setTo(0, 0, 0);
                    gameCtx.ctx.tweener.delayedCall(dealHit, 0.5);
                }
            }

            if (isAttacking == false) {
                if (moveTargetSet == false) {
                    if (Math.sqrt(Math.pow(gameCtx.hero.node.position.x - node.position.x, 2) + Math.pow(gameCtx.hero.node.position.z - node.position.z, 2)) > 0.1) {
                        animatedEntity.setAnimationState("Walk");
                        walkAnim.gotoAndPlay(1);
                        moveTo(gameCtx.hero.node.position.x, 0, gameCtx.hero.node.position.z );
                    } else {
                        animatedEntity.setAnimationState("Idle");
                        idleAnim.gotoAndPlay(1);
                    }

                }
            }
        }

        private function dealHit():void {
            if (collisionComponent.bounds.intersects(gameCtx.hero.collisionComponent.bounds)) {
                gameCtx.hero.die();
            }
        }

        private function onAttackCompleted(params:Object = null):void {
            isAttacking = false;
            animatedEntity.setAnimationState("Walk");
        }

        override public function destroy():void {
            super.destroy();
            particlesDeath.dispose();
            particlesDeath.removeFromAllScenes();
            entity.removeFromAllScenes();
        }
    }

}