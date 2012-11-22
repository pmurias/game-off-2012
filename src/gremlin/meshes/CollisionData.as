package gremlin.meshes {
    import flash.geom.Point;
	/**
     * ...
     * @author mosowski
     */
    public class CollisionData {
        public var collision2d:Vector.<Vector.<Point>>;

        public function CollisionData() {
        }

        public function fromObject(object:Object):void {
            if (object.collision2d != null) {
                collision2d = new Vector.<Vector.<Point>>(object.collision2d.polygons.length, true);
                for (var i:int = 0; i < object.collision2d.polygons.length; ++i) {
                    var polygon:Vector.<Point> = collision2d[i] = new Vector.<Point>(object.collision2d.polygons[i].length, true);
                    for (var j:int = 0; j < object.collision2d.polygons[i].length; ++j) {
                        polygon[j] = new Point(object.collision2d.polygons[i][j][0], object.collision2d.polygons[i][j][1]);
                    }
                }
            }
        }

    }

}