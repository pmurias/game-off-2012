package game {
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Vector3D;
    import flash.utils.Timer;
    import gremlin.core.Context;
	/**
     * ...
     * @author mosowski
     */
    public class TipManager {
        public var gameCtx:GameContext;
        public var tips:Vector.<TipSpawner>;
        public var timer:Timer;

        public function TipManager(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            tips = new Vector.<TipSpawner>();
            gameCtx.addListener(GameContext.TICK, tick);
        }

        public function destroy():void {
            for (var i:int = 0; i < tips.length;++i) {
                tips[i].destroy();
            }
            tips.length = 0;
        }

        public function tick(e:Event):void {
            for (var i:int = 0; i < tips.length; ++i) {
                if (Vector3D.distance(gameCtx.hero.node.derivedPosition, tips[i].spawnPosition) < tips[i].range) {
                    if (tips[i].mode == TipSpawner.PLACE) {
                        tips[i].show();
                    } else if (tips[i].mode == TipSpawner.HERO) {
                        tips[i].node.copyPositionFrom(gameCtx.hero.node.position);
                        tips[i].show();
                    } else if (tips[i].mode == TipSpawner.GAMEOBJECT) {
                        if (tips[i].gameObject == null || tips[i].gameObject.dead == true) {
                            tips[i].gameObject = null;
                            tips[i].hide();
                        } else {
                            tips[i].node.copyPositionFrom(tips[i].gameObject.node.position);
                            tips[i].show();
                        }
                    }
                } else {
                    tips[i].hide();
                }
            }
        }

    }

}