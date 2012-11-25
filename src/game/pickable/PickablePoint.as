package game.pickable {
    import flash.geom.Vector3D;
    import game.effects.ParticleExplosion;
    import game.GameContext;
    import game.Hero;
    import gremlin.particles.BillboardParticlesEntity;
    import gremlin.scene.ModelEntity;
	/**
     * ...
     * @author mosowski
     */
    public class PickablePoint extends Pickable {

        public function PickablePoint(gameCtx:GameContext) {
            super(gameCtx);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("PickablePoint"), node);
            entity.addToScene(gameCtx.layer0);
            shadow.node.setScale(1.2, 1, 0.6);
            enableCollision();
        }

        override protected function pickCallback(hero:Hero):Boolean {
            var p:BillboardParticlesEntity = new BillboardParticlesEntity(gameCtx.ctx);
            p.minLife = 1;
            p.maxLife = 3;
            p.minStartSize = 3.8;
            p.maxStartSize = 5.2;
            p.minEndSize = 1;
            p.maxEndSize = 1.5;
            p.minVelocity = 2;
            p.maxVelocity = 4;
            p.minStartColor = 0xFF225555;
            p.maxStartColor = 0xFF225555;
            p.minEndColor = 0x00FFFFFF;
            p.maxEndColor = 0x00FFFFFF;
            p.spawnRate = 10;
            p.setQuota(100);
            p.setMaterial(gameCtx.ctx.materialMgr.getMaterial("Particle1"));
            var explosion:ParticleExplosion = new ParticleExplosion(gameCtx);
            explosion.node.position.copyFrom(node.position);
            explosion.node.rotation.multiplyByAngleAxis(Vector3D.X_AXIS, Math.PI * 0.5);
            explosion.explode(p, 0.5);
            gameCtx.addPoints(1);
            return true;
        }

        override public function tick():void {
            super.tick();
            shadow.node.rotation.copyFrom(node.rotation);
            shadow.node.markAsDirty();
        }



    }

}