package gremlin.error {
    import flash.utils.getQualifiedClassName;

    /**
     * ...
     * @author mosowski
     */
    public class EAbstractClass extends Error {

        public function EAbstractClass(c:Class) {
            super("Class " + getQualifiedClassName(c) + " is abstract and cannot be instantiated.");

        }

    }

}