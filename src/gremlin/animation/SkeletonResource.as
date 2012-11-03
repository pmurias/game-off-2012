package gremlin.animation {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.IResource;
    import gremlin.math.Quaternion;

    /**
     * ...
     * @author mosowski
     */
    public class SkeletonResource implements IResource {
        public var name:String;
        public var bones:Vector.<Bone>;
        public var animations:Dictionary;
        public var isLoaded:Boolean;

        public function SkeletonResource(_ctx:Context) {
            bones = new Vector.<Bone>();
            animations = new Dictionary();
        }

        public function fromJSON(json:Object):void {
            var i:int, j:int;

            name = json[0];

            for (i = 0; i < json[1].length; ++i) {
                var bone:Bone = new Bone();
                bone.name = json[1][i].name;
                bone.id = i;
                bone.head.setTo(json[1][i].head[0], json[1][i].head[1], json[1][i].head[2]);
                bone.tail.setTo(json[1][i].tail[0], json[1][i].tail[1], json[1][i].tail[2]);
                bone.rotation.setTo(json[1][i].rot[0], json[1][i].rot[1], json[1][i].rot[2], json[1][i].rot[3]);
                bones.push(bone);
            }

            for (i = 0; i < json[1].length; i++) {
                for (j = 0; j < json[1][i].chld.length; j++) {
                    bones[json[1][i].chld[j]].parent = bones[i];
                    bones[i].children.push(bones[json[1][i].chld[j]]);
                }
            }

            var animation:Animation;
			var track:AnimationTrack;
			for (var animName:String in json[2]) {
				animation = new Animation();
				animation.name = animName;
				animation.length = json[2][animName].len;
				
				for (j = 0; j < json[2][animName].frames.length; j++) {
					animation.frames.push(json[2][animName].frames[j]);
				}
				
				for (i = 0; i < bones.length; i++) {
					track = new AnimationTrack();
					for (j = 0; j < json[2][animName].frames.length; j++) {
						track.location.push(new Vector3D(
							json[2][animName].tracks[i][j].loc[0],
							json[2][animName].tracks[i][j].loc[1],
							json[2][animName].tracks[i][j].loc[2]
						));
						track.rotation.push(new Quaternion(
							json[2][animName].tracks[i][j].rot[0],
							json[2][animName].tracks[i][j].rot[1],
							json[2][animName].tracks[i][j].rot[2],
							json[2][animName].tracks[i][j].rot[3]
						));

						track.matrix.push(new Matrix3D());
					}
					animation.tracks.push(track);
				}
				animations[animName] = animation;
			}

            preprocessAnimationData();

            isLoaded = true;
        }

        private function preprocessAnimationData():void {
            var bone:Bone, animation:Animation;
            for each (bone in bones) {
				if (!bone.parent) {
					bone.preprocessRestPose(bone.head, new Quaternion());
				}
			}

            for each (animation in animations) {
				for each (bone in bones) {
					if (!bone.parent) {
						for (var i:int = 0; i < animation.frames.length; i++) {
							bone.preprocessTracks(bone.head, new Quaternion(), i, animation);
						}
					}
				}
			}
        }

        public function setAnimationState(animationState:AnimationState):void {
            var time:Number = animationState.getTime();
            var animation:Animation = animationState.getAnimation();

			var currentFrame:int = animationState.getCurrentFrame();
			var nextFrame:int = currentFrame + 1;
			var blendFactor:Number = (time - animation.frames[currentFrame]) / (animation.frames[nextFrame] - animation.frames[currentFrame]);
			
			for each (var bone:Bone in bones) {
				bone.blendRawMatrices(animation.tracks[bone.id].rawMatrix[currentFrame], animation.tracks[bone.id].rawMatrix[nextFrame], blendFactor);
			}
        }

        public function isResourceLoaded():Boolean {
            return isLoaded;
        }

    }

}