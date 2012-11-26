package game {
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
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
    import game.modes.CloningMode;
    import game.modes.FairMode;
    import game.modes.Mode;
    import game.pickable.Pickable;
    import game.pickable.PickableBonus;
    import game.pickable.PickableCloningMode;
    import game.pickable.PickableEye;
    import game.pickable.PickablePoint;
    import game.spawners.SharpItem;
    import game.spawners.Spawner;
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
        public var graphics:Graphics;
        public var time:Number;
        public var timeStep:Number;
        public var debugInfo:DebugInfo;
        public var uniqueId:uint;
        public var commander:Commander;
        public var level:Level;
        public var gameObjects:Vector.<GameObject>;
        public var tileSet:TileSet;

        public var hero:Hero;

        public var bloodSpatters:Vector.<BloodSpatter>;
        public var deadBodies:Vector.<BeholderDead>;

        public var spawners:Vector.<Spawner>;
        public var sharpItems:Vector.<SharpItem>;

        public var heroesById:Array;
        public var heroes:Vector.<Hero>;

        public var pickablesById:Array;
        public var pickables:Vector.<Pickable>;

        public var crates:Vector.<Crate>;

        public var mainLight:DirectionaLight;

        public var layer0:Scene;
        public var layerPostprocess:Scene;
        public var layerGUI:Scene;

        public var mode:Mode;
        public var nextMode:Mode;

        public var deathBlackout:DeathBlackout;
        public var staticEmbeded:StaticEmbeded;
        public var splasher:Splasher;
        public var hud:HUD;

        public var points:int;
        public var deaths:int;

        public function GameContext(_ctx:Context) {
            ctx = _ctx;
            stage = ctx.stage;

            var yt:YoutubePlayer = new YoutubePlayer("i5KORjVtczU");
            stage.addChild(yt);
        }

        public function setupState():void {
            debugInfo = new DebugInfo(ctx);
            stage.addChild(debugInfo);
            graphics = debugInfo.graphics;
            debugInfo.visible = false;
            time = 0;
            timeStep = 1 / 32;

            commander = new Commander(this);

            bloodSpatters = new Vector.<BloodSpatter>();
            deadBodies = new Vector.<BeholderDead>();

            spawners = new Vector.<Spawner>();
            sharpItems = new Vector.<SharpItem>();

            heroesById = new Array();
            heroes = new Vector.<Hero>();

            pickablesById = new Array();
            pickables = new Vector.<Pickable>();

            crates = new Vector.<Crate>();

            layer0 = new Scene(ctx);
            layerPostprocess = new Scene(ctx);
            layerGUI = new Scene(ctx);

            mainLight = new DirectionaLight();
            mainLight.setDirection(-2, -1.2, 3);
            mainLight.setScene(layer0);

            gameObjects = new Vector.<GameObject>();

            tileSet = new TileSet(ctx);

            deathBlackout = new DeathBlackout(this);
            staticEmbeded = new StaticEmbeded();
            splasher = new Splasher(this);
            hud = new HUD(this);

            initLevel();

            ctx.addListener(Context.RESIZE, onResize);
            ctx.addListener(Context.ENTER_FRAME, onEnterFrame);

            ctx.addListener(Context.KEY_DOWN, onKeyDown);
            ctx.addListener(Context.KEY_UP, onKeyUp);

            var timer:Timer = new Timer(1/timeStep);
            timer.addEventListener(TimerEvent.TIMER, tick);
            timer.start();
        }

        public function initLevel():void {
            level = new Level(this, 0, 0, 0, ctx.rootNode);
            level.fromObject(ctx.loaderMgr.getLoaderJSON("static/map.bmap"), tileSet);
            level.layers[0].setScene(layer0);

            hero = new HeroPlayer(this);

            var gr:HeroReaper = new HeroReaper(this);
            gr.setPosition(10, 0, 5);

            mode = new FairMode(this);
            mode.enter();

            var cmdHeroSpawn:CommandSetHeroPosition = new CommandSetHeroPosition();
            cmdHeroSpawn.heroId = hero.id;
            cmdHeroSpawn.x = level.startPosition.x;
            cmdHeroSpawn.y = level.startPosition.y;
            cmdHeroSpawn.z = level.startPosition.z;
            commander.queueCommand(cmdHeroSpawn);

            commander.tick();
        }

        public function resetLevel():void {
            spawners.length = 0;
            for (var i:int = 0; i < gameObjects.length; ++i) {
                gameObjects[i].destroy();
            }
            level.destroyTiles();

            gameObjects.length = 0;
            sharpItems.length = 0;
            crates.length = 0;
            heroes.length = 0;
            pickables.length = 0;
            heroesById = [];
            pickablesById = [];

        }

        public function enterMode(mode:Mode):void {
            nextMode = mode;
            this.mode.addSingleTimeListener(Mode.MODE_EXITED, onCurrentModeExited);
            this.mode.exit();
        }

        public function onCurrentModeExited(params:Object = null):void {
            mode = nextMode;
            nextMode = null;
            mode.enter();
        }

        public function die():void {
            deathBlackout.addSingleTimeListener(DeathBlackout.BLACKOUT_COMPLETED, onDeathCompleted);
            deathBlackout.begin();
            addDeath();
        }

        public function onDeathCompleted(params:Object = null):void {
            deathBlackout.end();
            new BeholderDead(this, hero.node);
            resetLevel();
            initLevel();
        }

        public function onResize(params:Object = null):void {
        }

        public function addPoints(value:int):void {
            points += value;
            hud.pointsTextField.text = "Points: " + points;
        }

        public function addDeath():void {
            deaths++;
            hud.deathsTextField.text = "Deaths: " + deaths;
        }

        private function tick(e:Event):void {
            time += timeStep;
            mode.tick();
            deathBlackout.tick();

            var i:int;
            for (i = 0; i < spawners.length; ++i) {
                spawners[i].tick();
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
            graphics.clear();

            mode.processInput();
            mode.render();
        }

        public function onKeyDown(ke:KeyboardEvent):void {
            if (ke.keyCode == KeyCodes.KC_SPACE) {
            } if (ke.keyCode == KeyCodes.KC_D) {
                debugInfo.visible = !debugInfo.visible;
            }
        }

        public function onKeyUp(ke:KeyboardEvent):void {
        }

        public function getUniqueId():uint {
            return uniqueId++;
        }

    }

}