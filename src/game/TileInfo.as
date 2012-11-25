package game {
    import gremlin.meshes.ModelResource;
    import gremlin.scene.ModelEntity;
	/**
     * ...
     * @author mosowski
     */
    public class TileInfo {
        public var modelResources:Vector.<ModelResource>;
        public var name:String;
        public var blocking:Boolean;
        public var isLethal:Boolean;

        public function TileInfo(_name:String, ...resources) {
            name = _name;
            modelResources = new Vector.<ModelResource>();
            if (resources.length > 0) {
                for (var i:int = 0; i < resources.length; ++i) {
                    modelResources.push(resources[i]);
                }
            }
        }

    }

}