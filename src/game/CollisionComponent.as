package game {
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import gremlin.scene.Camera;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class CollisionComponent {
        public var node:Node;

        public var collisionPoly:Vector.<Point>;
        public var bounds:Rectangle;
        public var translationOnly:Boolean;

        public function CollisionComponent(node:Node) {
            this.node = node;
            translationOnly = false;
        }

        public function setBounds(points:Vector.<Point>):void {
            collisionPoly = points;
            bounds = new Rectangle();
            updateBounds();
        }

        public function updateBounds():void {
            bounds.setTo(0, 0, 0, 0);
            var px:Number, py:Number;
            var transform:Vector.<Number> = node.getTransformationMatrix().rawData;
            // 0 4 8 C
            // 1 5 9 D
            // 2 6 A E
            // 3 7 B F
            for (var i:int = 0; i < collisionPoly.length; ++i) {
                if (translationOnly == true) {
                    px = collisionPoly[i].x + transform[12];
                    py = collisionPoly[i].y + transform[14];
                } else {
                    px = collisionPoly[i].x * transform[0] + collisionPoly[i].y * transform[8] + transform[12];
                    py = collisionPoly[i].x * transform[2] + collisionPoly[i].y * transform[10] + transform[14];
                }

                if (i == 0) {
                    bounds.left = bounds.right = px;
                    bounds.top = bounds.bottom = py;
                } else {
                    if (px < bounds.left) {
                        bounds.left = px;
                    }
                    if (px > bounds.right) {
                        bounds.right = px;
                    }
                    if (py < bounds.top) {
                        bounds.top = py;
                    }
                    if (py > bounds.bottom) {
                        bounds.bottom = py;
                    }
                }
            }
        }

        private static var debugVector:Vector3D = new Vector3D();
        private static var debugPoint:Point = new Point();
        public function debugDraw(graphics:Graphics, camera:Camera):void {
            debugVector.setTo(bounds.left, 0, bounds.top);
            camera.getScreenPosition(debugVector, debugPoint);
            graphics.moveTo(debugPoint.x, debugPoint.y);

            debugVector.setTo(bounds.left, 0, bounds.bottom);
            camera.getScreenPosition(debugVector, debugPoint);
            graphics.lineTo(debugPoint.x, debugPoint.y);

            debugVector.setTo(bounds.right, 0, bounds.bottom);
            camera.getScreenPosition(debugVector, debugPoint);
            graphics.lineTo(debugPoint.x, debugPoint.y);

            debugVector.setTo(bounds.right, 0, bounds.top);
            camera.getScreenPosition(debugVector, debugPoint);
            graphics.lineTo(debugPoint.x, debugPoint.y);

            debugVector.setTo(bounds.left, 0, bounds.top);
            camera.getScreenPosition(debugVector, debugPoint);
            graphics.lineTo(debugPoint.x, debugPoint.y);
        }

    }

}