package game {
    import flash.geom.Vector3D;
    import game.spawners.SharpItem;
    import gremlin.core.Context;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class Hero extends GameObject {
        public var entity:ModelEntity;
        public var rotation:Number;
        public var velocity:Vector3D;
        public var moveTarget:Vector3D;
        public var moveTargetSet:Boolean;
        public var speed:Number;
        public var scene:Scene;
        public var isMortal:Boolean;
        public var isDead:Boolean;
        public var collisionEnabled:Boolean;


        public function Hero(gameCtx:GameContext) {
            super(gameCtx);
            gameCtx.heroes.push(this);
            gameCtx.heroesById[id] = this;

            velocity = new Vector3D();
            moveTarget = new Vector3D();
            rotation = 0;
            isMortal = false;
            isDead = false;
            collisionEnabled = true;
            enableShadow();
        }

        public function setPosition(x:Number, y:Number, z:Number):void {
            node.setPosition(x, y, z);
        }

        public function moveTo(x:Number, y:Number, z:Number):void {
            moveTargetSet = true;
            moveTarget.setTo(x, y, z);
        }

        public function setVelocity(x:Number, y:Number, z:Number):void {
            velocity.setTo(x, y, z);
        }

        override public function tick():void {
            super.tick();
            if (isDead == false) {
                if (moveTargetSet) {
                    velocity.setTo(moveTarget.x - node.position.x, 0, moveTarget.z - node.position.z);
                    if (velocity.lengthSquared < 0.1) {
                        velocity.setTo(0, 0, 0);
                        moveTargetSet = false;
                    } else {
                        velocity.normalize();
                    }
                        velocity.scaleBy(speed);
                }
                node.position.incrementBy(velocity);
                collisionComponent.updatePosition();

                if (collisionEnabled == true) {
                    var i:int;
                    var collidingSharpItem:SharpItem = null;
                    for (i = 0; i < gameCtx.sharpItems.length; ++i) {
                        if (gameCtx.sharpItems[i].collisionComponent.bounds.intersects(collisionComponent.bounds)) {
                            collidingSharpItem = gameCtx.sharpItems[i];
                            break;
                        }
                    }
                    if (collidingSharpItem != null) {
                        if (isMortal == true) {
                            die();
                        }
                    }
                    var collidingTile:Tile = gameCtx.level.checkNearTileCollision(this);
                    if (isDead == false && collidingTile != null) {
                        node.position.decrementBy(velocity);
                        if (isMortal == true && collidingTile.type.isLethal == true) {
                            die();
                        }
                    }

                    if (isDead == false && collisionEnabled) {
                        var halfVelocity:Vector3D = velocity.clone();
                        halfVelocity.scaleBy(0.5);
                        for (i = 0; i < gameCtx.crates.length; ++i) {
                            var crate:Crate = gameCtx.crates[i];
                            if (collisionComponent.bounds.intersects(crate.collisionComponent.bounds)) {
                                crate.node.position.incrementBy(halfVelocity);
                                crate.collisionComponent.updatePosition();

                                var crateCanMove:Boolean = true;
                                for (var j:int = 0; j < gameCtx.gameObjects.length; ++j) {
                                    var gameObject:GameObject = gameCtx.gameObjects[j];
                                    if (gameObject.collisionComponent != null && gameObject != this && gameObject != crate) {
                                        if (gameObject.collisionComponent.bounds.intersects(crate.collisionComponent.bounds)) {
                                            crateCanMove = false;
                                            break;
                                        }
                                    }
                                }
                                if (gameCtx.level.checkNearTileCollision(crate)) {
                                    crateCanMove = false;
                                }

                                if (crateCanMove == true) {
                                    crate.node.markAsDirty();
                                    node.position.decrementBy(halfVelocity);
                                    collisionComponent.updatePosition();
                                } else {
                                    crate.node.position.decrementBy(halfVelocity);
                                    crate.collisionComponent.updatePosition();

                                    node.position.decrementBy(velocity);
                                    break;
                                }
                            }
                        }
                    }
                    collisionComponent.updatePosition();
                }

                if (velocity.lengthSquared > 0) {
                    node.markAsDirty();
                }

                if (velocity.x != 0 || velocity.z != 0) {
                    var newRot:Number = Math.atan2( -velocity.x, -velocity.z);

                    rotation = gameCtx.ctx.mathUtils.getSmoothlyBlendedAngle(rotation, newRot, 0.1);
                }

                node.rotation.setFromAxisAngle(Vector3D.Y_AXIS, rotation);

                node.markAsDirty();
            } else {
                velocity.setTo(0, 0, 0);
            }
        }

        public function die():void {

        }

        override public function destroy():void {
            super.destroy();
            node.removeFromParent();
            gameCtx.heroes.splice(gameCtx.heroes.indexOf(this), 1);
            delete gameCtx.heroesById[id];
        }

    }

}