package game {
    import flash.display.Stage;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import game.commands.Command;
    import game.commands.Commander;
    import game.commands.CommandSetHeroPosition;
    import game.commands.CommandSetHeroVelocity;
    import game.spawners.SharpItem;
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
        public var uniqueId:uint;
        public var commander:Commander;
        public var level:Level;
        public var sharpItems:Vector.<SharpItem>;
        public var tileSet:TileSet;
        public var rotator:CameraRotator;

        public var hero:Hero;
        public var heroes:Array;

        public var mainLight:DirectionaLight;

        public var layer0Scene:Scene;

        public function GameContext(_ctx:Context) {
            ctx = _ctx;
            stage = ctx.stage;

        }

        public function setupState():void {
            debugInfo = new DebugInfo(ctx);
            stage.addChild(debugInfo);

            commander = new Commander(this);

            rotator = new CameraRotator(this);
            ctx.setCamera(rotator.camera);

            heroes = new Array();

            layer0Scene = new Scene(ctx);

            mainLight = new DirectionaLight();
            mainLight.setDirection(-2, -1.2, 3);
            mainLight.setScene(layer0Scene);

            sharpItems = new Vector.<SharpItem>();

            tileSet = new TileSet(ctx);
            level = new Level(this, 0, 0, 0, ctx.rootNode);
            level.fromObject(ctx.loaderMgr.getLoaderJSON("static/map.bmap"), tileSet);
            level.layers[0].setScene(layer0Scene);

            hero = createHeroPlayer();
            hero.setScene(layer0Scene);
            rotator.node = (hero as HeroPlayer).node;

            var cmdHeroSpawn:CommandSetHeroPosition = new CommandSetHeroPosition();
            cmdHeroSpawn.heroId = hero.id;
            cmdHeroSpawn.x = level.startPosition.x;
            cmdHeroSpawn.y = level.startPosition.y;
            cmdHeroSpawn.z = level.startPosition.z;
            commander.queueCommand(cmdHeroSpawn);

            commander.tick();

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
            debugInfo.tick();

            updatePlayerControl();
            hero.tick();

            var i:int;
            for (i = 0; i < level.spawners.length; ++i) {
                level.spawners[i].tick();
            }
            for (i = 0; i < sharpItems.length; ++i) {
                sharpItems[i].tick();
            }
            for (i = sharpItems.length - 1; i >= 0; --i) {
                if (sharpItems[i].dead) {
                    sharpItems[i].destroy();
                    sharpItems.splice(i, 1);
                }
            }

            commander.tick();

            ctx.rootNode.updateTransformation();
            rotator.tick();
            ctx.setCamera(rotator.camera);

            ctx.renderTargetMgr.defaultRenderTarget.activate();
            layer0Scene.render();
            ctx.renderTargetMgr.defaultRenderTarget.finish();
        }

        public function onKeyDown(ke:KeyboardEvent):void {
            if (ke.keyCode == KeyCodes.KC_SPACE) {
                commander.reset();
            }
        }

        public function onKeyUp(ke:KeyboardEvent):void {
        }

        public function updatePlayerControl():void {
            var velocityX:Number = 0;
            var velocityZ:Number = 0;
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_DOWN)) {
                velocityZ = -0.04;
            }
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_UP)) {
                velocityZ = 0.04;
            }
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_LEFT)) {
                velocityX = -0.04;
            }
            if (ctx.keyboardState.isKeyDown(KeyCodes.KC_RIGHT)) {
                velocityX = 0.04;
            }

            if (velocityX != hero.velocity.x || velocityZ != hero.velocity.z) {
                var cmd:CommandSetHeroVelocity = new CommandSetHeroVelocity();
                cmd.heroId = hero.id;
                cmd.x = velocityX;
                cmd.z = velocityZ;
                commander.queueCommand(cmd);
            }
        }

        public function getUniqueId():uint {
            return uniqueId++;
        }

        public function createHeroPlayer():HeroPlayer {
            var heroPlayer:HeroPlayer = new HeroPlayer(this);
            heroes[heroPlayer.id] = heroPlayer;
            return heroPlayer;
        }

    }

}