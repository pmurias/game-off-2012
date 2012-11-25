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

        [Embed(source = "../../bin/static/Decade.ttf", fontName="Decade", mimeType="application/x-font-truetype")]
        public const Decade:Class;

        public function StaticEmbeded() {

        }

    }

}