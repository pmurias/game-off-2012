package game {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.meshes.ModelResource;
	/**
     * ...
     * @author mosowski
     */
    public class TileSet {
        private var ctx:Context;
        public var types:Dictionary;

        public function TileSet(_ctx:Context) {
            ctx = _ctx;
            types = new Dictionary();
            addTile("TileFloorNice");
            addTile("TileFloorDep");
            addTile("TileFloorHappy");
            addTile("TileSpikes");
            addTile("TileWall");
            addTile("TileBlock");
            addTile("TileFade");
            addTile("TileFadeCorner");
            addTile("TileFadeOuterCorner");
            addTile("TileSpikesCorner");
            addTile("TileSpikesOuterCorner");
            addTile("TileGrass");
            addTile("TileGrassSlot");

            types["TileFade"].blocking = true;
            types["TileFadeCorner"].blocking = true;
            types["TileFadeOuterCorner"].blocking = true;
        }

        public function addTile(name:String, modelResourceName:String = ""):void {
            if (modelResourceName == "") {
                modelResourceName = name;
            }
            types[name] = new TileInfo(name, ctx.modelMgr.getModelResource(modelResourceName));
        }

    }

}