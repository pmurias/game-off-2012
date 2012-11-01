package gremlin.debug {

    /**
     * ...
     * @author mosowski
     */
    public class MemoryStats {
        public var textureMemory:uint;
        public var vertexMemory:uint;
        public var indexMemory:uint;
        public var numPrograms:uint;
        public var frameBufferMemory:uint;

        public function MemoryStats() {

        }

        public function reset():void {
            textureMemory = 0;
            vertexMemory = 0;
            indexMemory = 0;
            numPrograms = 0;
            frameBufferMemory = 0;
        }

    }

}