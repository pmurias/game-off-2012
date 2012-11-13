package game {
    import flash.display.Stage;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.events.KeyboardEvent;
    import flash.geom.Vector3D;
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
            rotator = new CameraRotator(this);
            ctx.setCamera(rotator.camera);

            layer0Scene = new Scene(ctx);

            mainLight = new DirectionaLight();
            mainLight.setDirection(-2, -1.2, 3);
            mainLight.setScene(layer0Scene);

            hero = new HeroPlayer(this);
            hero.setPosition(25,1,25)
            hero.setScene(layer0Scene);

            rotator.node = (hero as HeroPlayer).node;

            tileSet = new TileSet(ctx);
            level = new Level(50, 50, 1, ctx.rootNode);
            for (var i:int = 0; i < 50; ++i) {
                for (var j:int = 0 ; j < 50; ++j) {
                    level.layers[0].tiles[i][j].setType(tileSet.types["floor"]);
                }
            }

            /* just for test */
            for ( i= 5; i < 28; i+=4) {
                for ( j = 5; j <= 28; j += 4) {
                    var random:Number = Math.random();
                    if (random < 0.33) {
                        level.layers[0].tiles[i][j].setType(tileSet.types["block"]);
                        level.layers[0].tiles[i-1][j].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i-1][j].setRotation(3);
                        level.layers[0].tiles[i+1][j].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i+1][j].setRotation(1);
                        level.layers[0].tiles[i][j-1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i][j-1].setRotation(2);
                        level.layers[0].tiles[i][j+1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i][j + 1].setRotation(0);
                    } else if (random < 0.66) {
                        level.layers[0].tiles[i][j].setType(tileSet.types["block"]);
                        level.layers[0].tiles[i + 1][j].setType(tileSet.types["block"]);

                        level.layers[0].tiles[i-1][j].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i-1][j].setRotation(3);
                        level.layers[0].tiles[i+2][j].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i+2][j].setRotation(1);
                        level.layers[0].tiles[i][j-1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i][j-1].setRotation(2);
                        level.layers[0].tiles[i][j+1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i][j + 1].setRotation(0);
                        level.layers[0].tiles[i+1][j-1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i+1][j-1].setRotation(2);
                        level.layers[0].tiles[i+1][j+1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i+1][j + 1].setRotation(0);
                    } else {
                        level.layers[0].tiles[i][j].setType(tileSet.types["block"]);
                        level.layers[0].tiles[i][j+1].setType(tileSet.types["block"]);

                        level.layers[0].tiles[i-1][j].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i-1][j].setRotation(3);
                        level.layers[0].tiles[i+1][j].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i + 1][j].setRotation(1);
                        level.layers[0].tiles[i-1][j+1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i-1][j+1].setRotation(3);
                        level.layers[0].tiles[i+1][j+1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i+1][j+1].setRotation(1);
                        level.layers[0].tiles[i][j-1].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i][j-1].setRotation(2);
                        level.layers[0].tiles[i][j+2].setType(tileSet.types["spikes"]);
                        level.layers[0].tiles[i][j + 2].setRotation(0);

                    }
                }
            }
            level.layers[0].setScene(layer0Scene);


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
        }

        private function onEnterFrame(params:Object = null):void {

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


    }

}