package gremlin.error {
    import gremlin.core.IRenderable;
	/**
     * ...
     * @author mosowski
     */
    public class ENoMaterial extends Error {

        public function ENoMaterial(r:IRenderable) {
            super("No material given on renderable " + r);
        }

    }

}