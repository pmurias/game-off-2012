package gremlin.core {
    import gremlin.materials.Material;
    import gremlin.scene.Scene;

    /**
     * ...
     * @author mosowski
     */
    public interface IRenderable {
        function setMaterial(material:Material):void;
        function getMaterial():Material;
        function isVisible():Boolean;
        function render(ctx:Context):void;
    }

}