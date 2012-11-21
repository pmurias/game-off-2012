package game.effects {
    import game.GameContext;
    import game.GameObject;
    import gremlin.particles.BillboardParticlesEntity;
    import gremlin.particles.ParticlesEntity;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class ParticleExplosion extends GameObject {
        public var particles:BillboardParticlesEntity;
        public var duration:Number;

        public function ParticleExplosion(gameCtx:GameContext) {
            super(gameCtx);
        }

        public function explode(particles:BillboardParticlesEntity, duration:Number):void {
            this.particles = particles;
            particles.node = node;
            particles.addToScene(gameCtx.layer0);
            this.duration = duration;
            gameCtx.ctx.tweener.delayedCall(stopEmission, duration);
            gameCtx.ctx.tweener.delayedCall(end, duration + particles.maxLife);
        }

        private function stopEmission():void {
            particles.enabled = false;
        }

        private function end():void {
            dead = true;
        }

        override public function destroy():void {
            super.destroy();
            particles.removeFromScene(gameCtx.layer0);
            particles.dispose();
        }

    }

}