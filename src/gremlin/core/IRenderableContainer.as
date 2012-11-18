package gremlin.core {
    import gremlin.scene.Scene;

    /**
     * ...
     * @author mosowski
     */
    public interface IRenderableContainer {
        function addToScene(scene:Scene):void;
        function removeFromScene(scene:Scene):void;
    }

}