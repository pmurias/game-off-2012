package gremlin.scene {
    import flash.geom.Matrix3D;
    import flash.utils.Dictionary;
    import gremlin.animation.Animation;
    import gremlin.animation.AnimationState;
    import gremlin.animation.Bone;
    import gremlin.core.Context;
    import gremlin.meshes.ModelResource;

    /**
     * ...
     * @author mosowski
     */
    public class AnimatedEntity extends ModelEntity {
        public var animationStates:Dictionary;
        public var currentAnimationState:AnimationState;

        public function AnimatedEntity(_modelResource:ModelResource=null, _node:Node=null) {
            super(_modelResource, _node);
            animationStates = new Dictionary();
        }

        public function getAnimationState(animationName:String):AnimationState {
            var animationState:AnimationState = animationStates[animationName];
            if (animationState == null) {
                animationState = animationStates[animationName] = new AnimationState(modelResource.skeletonResource.animations[animationName]);
            }
            return animationState;
        }

        public function setAnimationState(animationName:String):AnimationState {
            currentAnimationState = animationStates[animationName];
            if (currentAnimationState == null) {
                currentAnimationState = animationStates[animationName] = new AnimationState(modelResource.skeletonResource.animations[animationName]);
            }
            return currentAnimationState;
        }

        override public function setLocalAutoParams(ctx:Context):void {
            super.setLocalAutoParams(ctx);
            modelResource.skeletonResource.setAnimationState(currentAnimationState);
            var bones:Vector.<Bone> = modelResource.skeletonResource.bones;
            for (var i:int = 0; i < bones.length; ++i) {
                ctx.autoParams.bonesMatrices.value[i] =  bones[i].currentMatrix;
            }
        }

    }

}