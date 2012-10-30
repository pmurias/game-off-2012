package gremlin.textures {
    import flash.display.BitmapData;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import gremlin.core.Context;

    /**
     * ...
     * @author mosowski
     */
    public class TextureResource {
        public var ctx:Context;
        public var texture3d:Texture;
        public var width:int;
        public var height:int;
        public var bitmapSource:BitmapData;
        public var isRenderTarget:Boolean;
        public var isReady:Boolean;

        public function TextureResource(_ctx:Context) {
            ctx = _ctx;
            isReady = false;
            isRenderTarget = false;
        }

        public function prepareAsRenderTarget(w:int, h:int):void {
            if (texture3d) {
                texture3d.dispose();
            }

            width = w;
            height = h;
            texture3d = ctx.createTexture(
                width,
                height,
                Context3DTextureFormat.BGRA,
                true
            );
            isReady = true;
            isRenderTarget = true;
        }

        public function setBitmapSource(src:BitmapData):void {
            if (texture3d) {
                if (src.width != width || src.height != height) {
                    texture3d.dispose();
                    texture3d = null;
                }
            }

            width = src.width;
            height = src.height;
            bitmapSource = src;
            if (!texture3d) {
                texture3d = ctx.createTexture(
                    src.width,
                    src.height,
                    Context3DTextureFormat.BGRA,
                    false
                );
            }

            texture3d.uploadFromBitmapData(src);
            isReady = true;
        }

        public function restore():void {
            if (bitmapSource) {
                setBitmapSource(bitmapSource);
            } else if (isRenderTarget) {
                prepareAsRenderTarget(width, height);
            }
        }
    }

}