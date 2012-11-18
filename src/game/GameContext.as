package game {
    import flash.display.Stage;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import gremlin.core.Context;
    import gremlin.events.KeyCodes;
    import gremlin.gremlin2d.Quad2d;
    import gremlin.lights.DirectionaLight;
    import gremlin.math.Quaternion;
    import gremlin.particles.BillboardParticlesEntity;
    import gremlin.scene.Camera;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class GameContext {
        public var ctx:Context;
        public var stage:Stage;
        public var debugInfo:DebugInfo;
        public var level:Level;
        public var tileSet:TileSet;
        public var rotator:CameraRotator;

        public var hero:Hero;

        public var mainLight:DirectionaLight;

        public var layer0Scene:Scene;

        public function GameContext(_ctx:Context) {
            ctx = _ctx;
            stage = ctx.stage;

        }

        public function setupState():void {
            debugInfo = new DebugInfo(ctx);
            stage.addChild(debugInfo);

            rotator = new CameraRotator(this);
            ctx.setCamera(rotator.camera);

            layer0Scene = new Scene(ctx);

            mainLight = new DirectionaLight();
            mainLight.setDirection(-2, -1.2, 3);
            mainLight.setScene(layer0Scene);

            tileSet = new TileSet(ctx);
            level = new Level(0, 0, 0, ctx.rootNode);
            level.fromObject(ctx.loaderMgr.getLoaderJSON("static/map.bmap"), tileSet);
            level.layers[0].setScene(layer0Scene);

            hero = new HeroPlayer(this);
            hero.position.copyFrom(level.startPosition);
            hero.setScene(layer0Scene);

            rotator.node = (hero as HeroPlayer).node;


            //part = new BillboardParticlesEntity(ctx);
            //part.minLife = 15;
            //part.maxLife = 16;
            //part.minStartSize = 1;
            //part.maxStartSize = 2;
            //part.minEndSize = 0.1;
            //part.maxEndSize = 0.1;
            //part.minVelocity = 0;
            //part.maxVelocity = 0.1;
            //part.spawnRate = 6;
            //part.node = node0;
            //part.setQuota(100);
            //part.setMaterial(ctx.materialMgr.getMaterial("Particle"));
            //part.setScene(scene0);

            //var quad:Quad2d = new Quad2d();
            //quad.transformation.identity();
            //quad.transformation.scale(ctx.stage.stageWidth, ctx.stage.stageHeight);
            //quad.transformation.translate(ctx.stage.stageWidth / 2, ctx.stage.stageHeight / 2);
            //quad.setMaterial(ctx.materialMgr.getMaterial("QuadRTT"));
            //quad.setScene(scene1);
            //ctx.addListener(Context.RESIZE, function(params:Object):void {
                //quad.transformation.identity();
                //quad.transformation.scale(ctx.stage.stageWidth, ctx.stage.stageHeight);
                //quad.transformation.translate(ctx.stage.stageWidth / 2, ctx.stage.stageHeight / 2);
            //});

            ctx.addListener(Context.ENTER_FRAME, onEnterFrame);

            ctx.addListener(Context.KEY_DOWN, onKeyDown);
            ctx.addListener(Context.KEY_UP, onKeyUp);
            ctx.addListener(Context.MOUSE_DOWN, onMouseDown);
            ctx.addListener(Context.MOUSE_UP, onMouseUp);
        }

        private function onEnterFrame(params:Object = null):void {
            debugInfo.tick();

            hero.tick();

            ctx.rootNode.updateTransformation();
            rotator.tick();
            ctx.setCamera(rotator.camera);

            ctx.renderTargetMgr.defaultRenderTarget.activate();
            layer0Scene.render();
            ctx.renderTargetMgr.defaultRenderTarget.finish();
        }

        public function onKeyDown(ke:KeyboardEvent):void {
            if (ke.keyCode == KeyCodes.KC_UP) {
                hero.velocity.z = 0.04;
            } else if (ke.keyCode == KeyCodes.KC_DOWN) {
                hero.velocity.z = -0.04;
            } else if (ke.keyCode == KeyCodes.KC_LEFT) {
                hero.velocity.x = -0.04;
            } else if (ke.keyCode == KeyCodes.KC_RIGHT) {
                hero.velocity.x = 0.04;
            }
        }

        public function onKeyUp(ke:KeyboardEvent):void {
            if (ke.keyCode == KeyCodes.KC_UP && hero.velocity.z > 0) {
                hero.velocity.z = 0;
            } else if (ke.keyCode == KeyCodes.KC_DOWN && hero.velocity.z < 0) {
                hero.velocity.z = 0;
            } else if (ke.keyCode == KeyCodes.KC_LEFT && hero.velocity.x < 0) {
                hero.velocity.x = 0;
            } else if (ke.keyCode == KeyCodes.KC_RIGHT && hero.velocity.x > 0) {
                hero.velocity.x = 0;
            }
        }

        public function onMouseDown(me:MouseEvent):void {
            if (stage.mouseY < stage.stageHeight*1/4) {
                hero.velocity.z = 0.04;
            }
            if (stage.mouseY > stage.stageHeight*3/4) {
                hero.velocity.z = -0.04;
            }
            if (stage.mouseX < stage.stageWidth*1/4) {
                hero.velocity.x = -0.04;
            }
            if (stage.mouseX > stage.stageWidth*3/4) {
                hero.velocity.x = 0.04;
            }
            if (stage.mouseX > stage.stageWidth * 1 / 4 && stage.stage.mouseX < stage.stageWidth * 3 / 4
            && stage.mouseY > stage.stageHeight * 1 / 4 && stage.stage.mouseY < stage.stageHeight * 3 / 4 ) {
                hero.velocity.setTo(0, 0, 0);
            }
        }

        public function onMouseUp(me:MouseEvent):void {
            hero.velocity.setTo(0, 0, 0);
        }


    }

}