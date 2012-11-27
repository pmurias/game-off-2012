package game {
	/**
     * ...
     * @author mosowski
     */
    public class StaticEmbeded {

        [Embed(source = "../../bin/static/cloning_mode.png")]
        public const cloning_mode:Class;

        [Embed(source = "../../bin/static/merge.png")]
        public const merge_mode:Class;

        [Embed(source = "../../bin/static/GhostWriter.ttf", fontName="FontGhostWriter", mimeType="application/x-font-truetype")]
        public const GhostWriter:Class;

        public function StaticEmbeded() {

        }

    }

}