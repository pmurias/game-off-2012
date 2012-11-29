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
            addTile("TileGrassCorner");
            addTile("TileGrassWalled");
            addTile("TileVortal");
            addTile("TileVortalWalled");
            addTile("TileBranch");
            addTile("TileBranchCorner");
            addTile("TileBranchOuterCorner");

            types["TileBlock"].blocking = true;
            types["TileFade"].blocking = true;
            types["TileFadeCorner"].blocking = true;
            types["TileFadeOuterCorner"].blocking = true;

            types["TileSpikes"].isLethal = true;
            types["TileSpikesCorner"].isLethal = true;
            types["TileSpikesOuterCorner"].isLethal = true;
            types["TileBranch"].isLethal = true;
            types["TileBranchCorner"].isLethal = true;
            types["TileBranchOuterCorner"].isLethal = true;

            types["TileVortal"].isGoal = true;
            types["TileVortalWalled"].isGoal = true;
        }

        public function addTile(name:String, modelResourceName:String = ""):void {
            if (modelResourceName == "") {
                modelResourceName = name;
            }
            types[name] = new TileInfo(name, ctx.modelMgr.getModelResource(modelResourceName));
        }

    }

}