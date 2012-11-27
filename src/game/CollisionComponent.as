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

        public var collisionPolygons:Vector.<Vector.<Point>>;
        public var rectangles:Vector.<Rectangle>;
        public var useFullTransformation:Boolean;
        public var origins:Vector.<Point>;

        public function CollisionComponent(node:Node) {
            this.node = node;
            useFullTransformation = false;
        }

        public function setBounds(polygons:Vector.<Vector.<Point>>):void {
            collisionPolygons = polygons;
            rectangles = new Vector.<Rectangle>(polygons.length, true);
            origins = new Vector.<Point>();
            for (var i:int = 0; i < polygons.length; ++i) {
                rectangles[i] = new Rectangle();
                origins[i] = new Point();
            }
            updateBounds();
        }

        private function calculateBoundsRect(rectId:int):void {
            var rect:Rectangle = rectangles[rectId];
            rect.setTo(0, 0, 0, 0);
            var px:Number, py:Number;
            var transform:Vector.<Number> = node.getTransformationMatrix().rawData;
            // 0 4 8 C
            // 1 5 9 D
            // 2 6 A E
            // 3 7 B F
            var polygon:Vector.<Point> = collisionPolygons[rectId];
            for (var i:int = 0; i < polygon.length; ++i) {
                if (useFullTransformation == false) {
                    px = polygon[i].x + transform[12];
                    py = polygon[i].y + transform[14];
                } else {
                    px = polygon[i].x * transform[0] + polygon[i].y * transform[8] + transform[12];
                    py = polygon[i].x * transform[2] + polygon[i].y * transform[10] + transform[14];
                }

                if (i == 0) {
                    rect.left = rect.right = px;
                    rect.top = rect.bottom = py;
                } else {
                    if (px < rect.left) {
                        rect.left = px;
                    }
                    if (px > rect.right) {
                        rect.right = px;
                    }
                    if (py < rect.top) {
                        rect.top = py;
                    }
                    if (py > rect.bottom) {
                        rect.bottom = py;
                    }
                }
            }
        }

        public function updateBounds():void {
            var i:int;
            if (useFullTransformation == false) {
                for (i = 0; i < rectangles.length; ++i) {
                    var rect:Rectangle = rectangles[i];
                    if (rect.width == 0 && rect.height == 0) {
                        calculateBoundsRect(i);
                        origins[i].setTo(rect.x, rect.y);
                    } else {
                        rect.x = node.derivedPosition.x + origins[i].x;
                        rect.y = node.derivedPosition.z + origins[i].y;
                    }
                }
            } else {
                for (i = 0; i < rectangles.length; ++i) {
                    calculateBoundsRect(i);
                }
            }
        }

        //NOTE: works assuming node doesn't have any parent transformation and
        // only translation affects bounds
        public function updatePosition():void {
            for (var i:int = 0; i < rectangles.length; ++i) {
                rectangles[i].x = node.position.x + origins[i].x;
                rectangles[i].y = node.position.z + origins[i].y;
            }
        }

        public function intersects(collisionComponent:CollisionComponent):Boolean {
            for (var i:int = 0; i < rectangles.length; ++i) {
                for (var j:int = 0; j < collisionComponent.rectangles.length; ++j) {
                    if (rectangles[i].intersects(collisionComponent.rectangles[j])) {
                        return true;
                    }
                }
            }
            return false;
        }

        private static var debugVector:Vector3D = new Vector3D();
        private static var debugPoint:Point = new Point();
        public function debugDraw(graphics:Graphics, camera:Camera):void {
            for (var i:int = 0; i < rectangles.length; ++i) {
                var rect:Rectangle = rectangles[i];
                debugVector.setTo(rect.left, 0, rect.top);
                camera.getScreenPosition(debugVector, debugPoint);
                graphics.moveTo(debugPoint.x, debugPoint.y);

                debugVector.setTo(rect.left, 0, rect.bottom);
                camera.getScreenPosition(debugVector, debugPoint);
                graphics.lineTo(debugPoint.x, debugPoint.y);

                debugVector.setTo(rect.right, 0, rect.bottom);
                camera.getScreenPosition(debugVector, debugPoint);
                graphics.lineTo(debugPoint.x, debugPoint.y);

                debugVector.setTo(rect.right, 0, rect.top);
                camera.getScreenPosition(debugVector, debugPoint);
                graphics.lineTo(debugPoint.x, debugPoint.y);

                debugVector.setTo(rect.left, 0, rect.top);
                camera.getScreenPosition(debugVector, debugPoint);
                graphics.lineTo(debugPoint.x, debugPoint.y);
            }
        }

    }

}