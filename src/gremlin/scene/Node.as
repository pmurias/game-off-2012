package gremlin.scene {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import gremlin.math.Quaternion;

    /**
     * ...
     * @author mosowski
     */
    public class Node {
        public var derivedPosition:Vector3D;
        public var derivedRotation:Quaternion;
        public var derivedScale:Vector3D;
        public var derivedVisible:Boolean;

        public var parent:Node;
        public var children:Vector.<Node>;

        private var position:Vector3D;
        private var rotation:Quaternion;
        private var scale:Vector3D;
        private var visible:Boolean;

        private var transformationDirty:Boolean;
        public var transformationMatrix:Matrix3D;
        public var normalMatrix:Matrix3D;

        private static const _tempAuxVector3D:Vector3D = new Vector3D();

        public function Node() {
            derivedPosition = new Vector3D();
            derivedRotation = new Quaternion();
            derivedScale = new Vector3D();

            parent = null;
            children = new Vector.<Node>();

            position = new Vector3D();
            rotation = new Quaternion();
            scale = new Vector3D(1, 1, 1);
            visible = true;

            transformationDirty = true;
            transformationMatrix = new Matrix3D();
            normalMatrix = new Matrix3D();
        }

        public function setPosition(x:Number, y:Number, z:Number):void {
            position.setTo(x, y, z);
            transformationDirty = true;
        }

        public function copyPositionFrom(v:Vector3D):void {
            position.copyFrom(v);
            transformationDirty = true;
        }

        public function getPosition():Vector3D {
            return position;
        }

        public function setRotation(x:Number, y:Number, z:Number, w:Number):void {
            rotation.setTo(x, y, z, w);
            transformationDirty = true;
        }

        public function copyRotationFrom(q:Quaternion):void {
            rotation.copyFrom(q);
            transformationDirty = true;
        }

        public function getRotation():Quaternion {
            return rotation;
        }

        public function setScale(x:Number, y:Number, z:Number):void {
            scale.setTo(x, y, z);
            transformationDirty = true;
        }

        public function copyScaleFrom(v:Vector3D):void {
            scale.copyFrom(v);
            transformationDirty = true;
        }

        public function getScale():Vector3D {
            return scale;
        }

        public function setVisible(v:Boolean):void {
            if (v != visible) {
                visible = v;
                transformationDirty = true;
            }
        }

        public function getVisible():Boolean {
            return visible;
        }

        public function markAsDirty():void {
            transformationDirty = true;
        }

        public function addChild(node:Node):void {
            node.parent = this;
            children.push(node);
            node.transformationDirty = true;
        }

        public function updateTransformation(dirty:Boolean = false):void {
            dirty ||= transformationDirty;

            if (dirty) {
                if (parent) {
                    derivedVisible = parent.visible && visible;
                    derivedPosition.copyFrom(position);
                    parent.derivedRotation.transformVector(derivedPosition);
                    derivedPosition.incrementBy(parent.derivedPosition);

                    derivedRotation.copyFrom(parent.derivedRotation);
                    derivedRotation.multiplyBy(rotation);

                    derivedScale.setTo(parent.derivedScale.x * scale.x, parent.derivedScale.y * scale.y, parent.derivedScale.z * scale.z);
                } else {
                    derivedVisible = visible;
                    derivedPosition.copyFrom(position);
                    derivedRotation.copyFrom(rotation);
                    derivedScale.copyFrom(scale);
                }

                derivedRotation.toAngleAxis(_tempAuxVector3D);
                transformationMatrix.identity();
                transformationMatrix.appendScale(derivedScale.x, derivedScale.y, derivedScale.z);
			    transformationMatrix.appendRotation(_tempAuxVector3D.w * (180.0 / Math.PI), _tempAuxVector3D);
			    transformationMatrix.appendTranslation(derivedPosition.x, derivedPosition.y, derivedPosition.z);

                normalMatrix.copyFrom(transformationMatrix);
                normalMatrix.invert();
                normalMatrix.transpose();
            }

            for (var i:int = 0; i < children.length; ++i) {
                children[i].updateTransformation(dirty);
            }

            transformationDirty = false;
        }

        public function getTransformationMatrix():Matrix3D {
            return transformationMatrix;
        }
    }
}