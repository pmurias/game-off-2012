package gremlin.animation {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import gremlin.math.Quaternion;

    /**
     * ...
     * @author mosowski
     */
    public class Bone {
        public var id:int;
        public var parent:Bone;
        public var name:String;
        public var head:Vector3D;
        public var tail:Vector3D;
        public var children:Vector.<Bone>;

        public var currentMatrix:Matrix3D;
        public var currentMatrixData:Vector.<Number>;

        public function Bone() {
            head = new Vector3D();
            tail = new Vector3D();
            children = new Vector.<Bone>();

            currentMatrix = new Matrix3D();
            currentMatrixData = new Vector.<Number>(16, true);
        }



        public function preprocessTracks(parentTail:Vector3D, totalRot:Quaternion, frame:int, animation:Animation):void {
            var frameLoc:Vector3D = animation.tracks[id].location[frame];
            var frameRot:Quaternion = animation.tracks[id].rotation[frame];

            //TODO: does blender save frameLoc in bone space or parent space?
            var transformedTail:Vector3D = parentTail.add(frameLoc);
            var transformedTotalRot:Quaternion = totalRot.clone();

            //var translation:Vector3D = transformedTail.subtract(head);

            transformedTotalRot.multiplyBy(frameRot);
            var rotatedTail:Vector3D = tail.clone();
            transformedTotalRot.transformVector(rotatedTail);
            transformedTail.incrementBy(rotatedTail);

            animation.tracks[id].matrix[frame].identity();
            var rotVec:Vector3D = new Vector3D();
            transformedTotalRot.toAngleAxis(rotVec);
            animation.tracks[id].matrix[frame].appendTranslation(-head.x, -head.y, -head.z);
            animation.tracks[id].matrix[frame].appendRotation(rotVec.w * (180.0 / Math.PI), rotVec);
            animation.tracks[id].matrix[frame].appendTranslation(parentTail.x, parentTail.y, parentTail.z);

            animation.tracks[id].rawMatrix[frame] = animation.tracks[id].matrix[frame].rawData;

            for each (var child:Bone in children) {
                child.preprocessTracks(transformedTail, transformedTotalRot, frame, animation);
            }
        }

        public function blendRawMatrices(src:Vector.<Number>, dest:Vector.<Number>, factor:Number):void {
            for (var i:int = 0; i < 16; i++) {
                currentMatrixData[i] = src[i] + (dest[i] - src[i]) * factor;
            }
            currentMatrix.copyRawDataFrom(currentMatrixData);
        }
    }

}