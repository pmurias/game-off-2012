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
        public var rotation:Quaternion;
        public var children:Vector.<Bone>;

        public var restHead:Vector3D;
        public var restTail:Vector3D;

        public var currentMatrix:Matrix3D;
        public var currentMatrixData:Vector.<Number>;

        public function Bone() {
            head = new Vector3D();
            tail = new Vector3D();
            tail = new Vector3D();
            rotation = new Quaternion();
            children = new Vector.<Bone>();

            restHead = new Vector3D();
            restTail = new Vector3D();

            currentMatrix = new Matrix3D();
            currentMatrixData = new Vector.<Number>(16, true);
        }

        public function preprocessRestPose(parentTail:Vector3D, parentRot:Quaternion):void {
            var tmp:Vector3D = tail.clone();
            parentRot.transformVector(tmp);
            var newTail:Vector3D = parentTail.add(tmp);
            var newRot:Quaternion = parentRot.clone();
            newRot.multiplyBy(rotation);

            restHead = parentTail.clone();
            restTail = parentTail.subtract(newTail);
            restTail.normalize();

            for each (var child:Bone in children) {
                child.preprocessRestPose(newTail, newRot);
            }
        }

        public function preprocessTracks(parentTail:Vector3D, parentRot:Quaternion, frame:int, animation:Animation):void {
            var frameLoc:Vector3D = animation.tracks[id].location[frame];
            var frameRot:Quaternion = animation.tracks[id].rotation[frame];

            var tmpQuat:Quaternion = frameRot.clone();
            var tmpFrameTail:Vector3D = tail.clone();
            rotation.transformVector(tmpQuat.values);
            tmpQuat.transformVector(tmpFrameTail);
            parentRot.transformVector(tmpFrameTail);

            var tmpFrameHead:Vector3D = frameLoc.clone();
            rotation.transformVector(tmpFrameHead);
            tmpFrameTail.incrementBy(tmpFrameHead);
            var newTail:Vector3D = parentTail.add(tmpFrameTail);

            var newRot:Quaternion = parentRot.clone();
            newRot.multiplyBy(rotation);
            newRot.multiplyBy(frameRot);

            var poseHead:Vector3D = parentTail.add(tmpFrameHead);
            var poseTail:Vector3D = poseHead.subtract(newTail);
            poseTail.normalize();
            var poseRot:Quaternion = new Quaternion();
            Quaternion.rotationBetween(poseRot, restTail, poseTail);
            animation.tracks[id].matrix[frame].identity();
            animation.tracks[id].matrix[frame].appendTranslation(-restHead.x, -restHead.y, -restHead.z);
            var rotVec:Vector3D = new Vector3D();
            poseRot.toAngleAxis(rotVec);
            animation.tracks[id].matrix[frame].appendRotation(rotVec.w * (180.0 / Math.PI), rotVec);
            animation.tracks[id].matrix[frame].appendTranslation(poseHead.x, poseHead.y, poseHead.z);

            animation.tracks[id].rawMatrix[frame] = animation.tracks[id].matrix[frame].rawData;

            for each (var child:Bone in children) {
                child.preprocessTracks(newTail, newRot, frame, animation);
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