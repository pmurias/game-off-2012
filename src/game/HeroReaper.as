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
        public var isActive:Boolean;
        public var range:Number;
        public var speedScale:Number;

        public var shoutTip:TipArea;
        public var shoutFlag:Boolean;
        public var previousQuote:int;

        public static const quotes:Array = [
            "Hello, hello!",
            "Hello, my friend!",
            "Come over here, my friend!",
            "What do we have here?",
            "Greetings!",
            "Can I help you?",
            "Hello, my little friend!",
            "Stay a while and listen",
            "Not event death can save you from me!",
            "Need medical attention?",
            "What IS your major malfunction?"
        ];

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
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d);
            entity.addToScene(gameCtx.layer0);
            collisionEnabled = false;
            shadow.node.setScale(1.5, 1, 1.5);
            radius = 0.5;
            setSpeedScale(1.0);
            isMortal = false;
            initParticles();
            previousQuote = -1;
            shoutTip = new TipArea(gameCtx);
            shoutTip.fitArea = true;
            shoutTip.setSize(250, 150);
            shoutTip.node = new Node();
            shoutTip.node.setPosition(0, 2.5, 0);
            node.addChild(shoutTip.node);
        }

        public function setSpeedScale(scale:Number):void {
            speedScale = scale;
            speed = 0.015 * speedScale;
            walkAnim.fps = 30 * speedScale;
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

            if (collisionComponent.intersects(gameCtx.hero.collisionComponent) && gameCtx.hero.isDead == false) {
                if (animatedEntity.currentAnimationState != attackAnim) {
                    animatedEntity.setAnimationState("Attack");
                    attackAnim.addSingleTimeListener(AnimationState.ANIMATION_COMPELTED, onAttackCompleted);
                    attackAnim.playOnce();
                    isAttacking = true;
                    moveTargetSet = false;
                    var attackDirection:Vector3D = gameCtx.hero.node.position.subtract(node.position);
                    attackDirection.normalize();
                    rotation = Math.atan2( -attackDirection.x, -attackDirection.z);
                    velocity.setTo(0, 0, 0);
                    gameCtx.ctx.tweener.delayedCall(dealHit, 0.5, this);
                }
            }

            if (isAttacking == false) {
                if (isActive == false) {
                    if (Math.sqrt(Math.pow(gameCtx.hero.node.position.x - node.position.x, 2) + Math.pow(gameCtx.hero.node.position.z - node.position.z, 2)) <= range && gameCtx.hero.isDead == false) {
                        isActive = true;
                    }
                }
                if (isActive == true) {
                    if (shoutFlag == false) {
                        shoutFlag = true;
                        var quoteId:int;
                        do {
                            quoteId = int(Math.random() * quotes.length);
                        } while (quoteId == previousQuote);
                        previousQuote = quoteId;
                        say(quotes[quoteId]);
                    }
                    if (moveTargetSet == false) {
                        if (Math.sqrt(Math.pow(gameCtx.hero.node.position.x - node.position.x, 2) + Math.pow(gameCtx.hero.node.position.z - node.position.z, 2)) > 0.1) {
                            animatedEntity.setAnimationState("Walk");
                            walkAnim.gotoAndPlay(1);
                            moveTo(gameCtx.hero.node.position.x, 0, gameCtx.hero.node.position.z );
                        }  else {
                            animatedEntity.setAnimationState("Idle");
                            idleAnim.gotoAndPlay(1);
                        }
                    }
                } else {
                    animatedEntity.setAnimationState("Idle");
                    idleAnim.gotoAndPlay(1);
                }
            }
        }

        public function say(text:String):void {
            shoutTip.setText(text);
            shoutTip.show();
            gameCtx.ctx.tweener.delayedCall(function():void {
                shoutTip.hide();
                gameCtx.ctx.tweener.delayedCall(function():void {
                    shoutFlag = false;
                }, 8, this)
            }, 4, this);
        }

        private function dealHit():void {
            if (collisionComponent.intersects(gameCtx.hero.collisionComponent)) {
                gameCtx.hero.die();
                say("Gottcha!");
                isActive = false;
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
            shoutTip.destroy();
            gameCtx.ctx.tweener.killAllTweensOf(this);
        }

        override public function fromObject(object:Object):void {
            range = object.range;
            if ("speed" in object) {
                setSpeedScale(object.speed);
            }
        }
    }

}