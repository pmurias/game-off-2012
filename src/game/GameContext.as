package game {
    import flash.display.Stage;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.utils.Timer;
    import game.commands.Command;
    import game.commands.Commander;
    import game.commands.CommandSetHeroPosition;
    import game.commands.CommandSetHeroVelocity;
    import game.pickable.Pickable;
    import game.pickable.PickableBonus;
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
        public var time:Number;
        public var debugInfo:DebugInfo;
        public var uniqueId:uint;
        public var commander:Commander;
        public var level:Level;
        public var gameObjects:Vector.<GameObject>;
        public var tileSet:TileSet;
        public var rotator:CameraRotator;

        public var hero:Hero;

        public var heroesById:Array;
        public var heroes:Vector.<Hero>;

        public var pickablesById:Array;
        public var pickables:Vector.<Pickable>;

        public var mainLight:DirectionaLight;

        public var layer0:Scene;

        public function GameContext(_ctx:Context) {
            ctx = _ctx;
            stage = ctx.stage;

            var yt:YoutubePlayer = new YoutubePlayer("i5KORjVtczU");
            stage.addChild(yt);
        }

        public function setupState():void {
            debugInfo = new DebugInfo(ctx);
            stage.addChild(debugInfo);
            time = 0;

            commander = new Commander(this);

            rotator = new CameraRotator(this);
            ctx.setCamera(rotator.camera);

            heroesById = new Array();
            heroes = new Vector.<Hero>();

            pickablesById = new Array();
            pickables = new Vector.<Pickable>();

            layer0 = new Scene(ctx);

            mainLight = new DirectionaLight();
            mainLight.setDirection(-2, -1.2, 3);
            mainLight.setScene(layer0);

            gameObjects = new Vector.<GameObject>();

            tileSet = new TileSet(ctx);
            level = new Level(this, 0, 0, 0, ctx.rootNode);
            level.fromObject(ctx.loaderMgr.getLoaderJSON("static/map.bmap"), tileSet);
            level.layers[0].setScene(layer0);

            hero = new HeroPlayer(this);
            rotator.node = (hero as HeroPlayer).node;

            var p:PickableBonus  = new PickableBonus(this);
            p.node.setPosition(2 * 2 + 1, 0, 5 * 2 + 1);
            p.setMaterial(ctx.materialMgr.getMaterial("PickableH"));

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
//
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

            var timer:Timer = new Timer(32);
            timer.addEventListener(TimerEvent.TIMER, tick);
            timer.start();
        }

        private function tick(e:Event):void {
            time += 1 / 32;
            hero.tick();

            var i:int;
            for (i = 0; i < level.spawners.length; ++i) {
                level.spawners[i].tick();
            }
            for (i = 0; i < gameObjects.length; ++i) {
                gameObjects[i].tick();
            }
            for (i = gameObjects.length - 1; i >= 0; --i) {
                if (gameObjects[i].dead) {
                    gameObjects[i].destroy();
                    gameObjects.splice(i, 1);
                }
            }

            commander.tick();
        }

        private function onEnterFrame(params:Object = null):void {
            debugInfo.tick();

            updatePlayerControl();

            ctx.rootNode.updateTransformation();
            rotator.tick();
            ctx.setCamera(rotator.camera);

            ctx.renderTargetMgr.defaultRenderTarget.activate();
            layer0.render();
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

    }

}