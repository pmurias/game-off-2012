package game {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
	/**
     * ...
     * @author mosowski
     */
    public class TileSet {
        public var types:Dictionary;

        public function TileSet(ctx:Context) {
            types = new Dictionary();
            types["floor"] = new TileInfo(
                "floor",
                ctx.modelMgr.getModelResource("TileFloorNice"),
                ctx.modelMgr.getModelResource("TileFloorDep"),
                ctx.modelMgr.getModelResource("TileFloorHappy")
                );
            types["spikes"] = new TileInfo("spikes", ctx.modelMgr.getModelResource("TileSpikes"));
            types["wall"] = new TileInfo("wall", ctx.modelMgr.getModelResource("TileWall"));
            types["block"] = new TileInfo("block", ctx.modelMgr.getModelResource("TileBlock"));
        }

    }

}