package game {
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class Doodad {
        public var gameCtx:GameContext;
        public var node:Node;
        public var entity:ModelEntity;

        public function Doodad(gameCtx:GameContext, caster:Node) {
            this.gameCtx = gameCtx;
            node  = new Node();
            gameCtx.ctx.rootNode.addChild(node);
            node.setPosition(caster.derivedPosition.x, 0.1, caster.derivedPosition.z);
            node.copyRotationFrom(caster.rotation);
        }

        public function destroy():void {
            node.removeFromParent();
            entity.removeFromAllScenes();
        }

    }

}