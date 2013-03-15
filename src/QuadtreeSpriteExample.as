package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    import starling.core.Starling;

    public class QuadtreeSpriteExample extends Sprite
    {
        private var _starling:Starling;

        public function QuadtreeSpriteExample()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _starling = new Starling(QuadtreeSpriteScene, stage);
            _starling.start();
        }
    }
}
