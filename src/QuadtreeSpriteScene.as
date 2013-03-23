package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import starling.core.Starling;
    import starling.display.Button;
    import starling.display.DisplayObject;

    import starling.display.Quad;

    import starling.display.Sprite;
    import starling.events.EnterFrameEvent;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.extensions.QuadtreeSprite;
    import starling.textures.Texture;
    import starling.utils.Color;
    import starling.utils.RectangleUtil;

    public class QuadtreeSpriteScene extends Sprite
    {
        private static const SQUARE_SIZE:Number = 50;
        private static const SQUARE_COUNT:int = 100000;
        private static const WORLD_BOUND:int = 10000;

        private var _quadtreeSprite:QuadtreeSprite;

        private var _velocityX:Number;
        private var _velocityY:Number;

        private var _buttonExample100K:Button;
        private var _buttonExampleOrdered:Button;

        private var _worldBounds:Rectangle;

        public function QuadtreeSpriteScene()
        {
            _velocityX = 0;
            _velocityY = 0;
            this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        private function randomPointInRectangle(rectangle:Rectangle):Point
        {
            return new Point (rectangle.x + rectangle.width * Math.random(),
                              rectangle.y + rectangle.height * Math.random());
        }

        private function randomColor():uint
        {
            return Color.rgb(Math.random() * 255, Math.random() * 255, Math.random() * 255);
        }

        private function addedToStage(event:Event):void
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            this.addChild(new Quad(this.stage.stageWidth, this.stage.stageHeight, 0xe4e5de));

            var buttonBitmap:BitmapData = new BitmapData(300, 30, false, 0x7eb249);

            _buttonExample100K = new Button(Texture.fromBitmapData(buttonBitmap), "Create 100,000 objects (may take a few seconds)");
            _buttonExample100K.addEventListener(Event.TRIGGERED, setupScene100K);
            _buttonExample100K.pivotX = _buttonExample100K.width / 2;
            _buttonExample100K.pivotY = _buttonExample100K.height / 2;
            _buttonExample100K.x = this.stage.stageWidth / 2;
            _buttonExample100K.y = this.stage.stageHeight / 2 - 30;
            this.addChild(_buttonExample100K);

            _buttonExampleOrdered = new Button(Texture.fromBitmapData(buttonBitmap), "Create 50 objects and maintain order");
            _buttonExampleOrdered.addEventListener(Event.TRIGGERED, setupSceneOrdered);
            _buttonExampleOrdered.pivotX = _buttonExampleOrdered.width / 2;
            _buttonExampleOrdered.pivotY = _buttonExampleOrdered.height / 2;
            _buttonExampleOrdered.x = this.stage.stageWidth / 2;
            _buttonExampleOrdered.y = this.stage.stageHeight / 2 + 30;
            this.addChild(_buttonExampleOrdered);

        }

        private function setupCommon():void
        {
            _buttonExample100K.removeFromParent(true);
            _buttonExampleOrdered.removeFromParent(true);

            Starling.current.showStats = true;

            this.addEventListener(TouchEvent.TOUCH, touchEvent);
            this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
        }

        public function setupScene100K():void
        {
            setupCommon();

            _worldBounds = new Rectangle(-WORLD_BOUND, -WORLD_BOUND, WORLD_BOUND * 2, WORLD_BOUND * 2);
            _quadtreeSprite = new QuadtreeSprite(_worldBounds);
            _quadtreeSprite.visibleViewport = new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight);

            this.addChild(_quadtreeSprite);

            for (var i:int = 0; i < SQUARE_COUNT; ++i)
            {
                var square:Quad = new Quad(SQUARE_SIZE, SQUARE_SIZE, randomColor());
                var randomPosition:Point = randomPointInRectangle(_worldBounds);
                square.x = randomPosition.x;
                square.y = randomPosition.y;
                _quadtreeSprite.addChild(square);
            }

        }

        public function setupSceneOrdered():void
        {
            setupCommon();

            _worldBounds = new Rectangle(-WORLD_BOUND, -WORLD_BOUND, WORLD_BOUND * 2, WORLD_BOUND * 2);
            _quadtreeSprite = new QuadtreeSprite(_worldBounds, true);
            _quadtreeSprite.visibleViewport = new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight);

            this.addChild(_quadtreeSprite);

            for (var i:int = 0; i < 25; ++i)
            {
                var square:Quad = new Quad(SQUARE_SIZE, SQUARE_SIZE, randomColor());
                square.x = 20 * i;
                square.y = 20 * i;
                _quadtreeSprite.addChild(square);
            }

            for (var j:int = 25; j < 50; ++j)
            {
                var square:Quad = new Quad(SQUARE_SIZE, SQUARE_SIZE, randomColor());
                square.x = 20 * j;
                square.y = 20 * j;
                _quadtreeSprite.addChildAt(square, 0);
            }
        }

        private function touchEvent(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);

            if (touch && touch.phase == TouchPhase.HOVER)
            {
                var screenWidthHalf:Number = this.stage.stageWidth / 2;
                var screenHeightHalf:Number = this.stage.stageHeight / 2;

                _velocityX = (touch.globalX - screenWidthHalf) * 4;
                _velocityY = (touch.globalY - screenHeightHalf) * 4;
            }
        }

        private function enterFrame(event:EnterFrameEvent):void
        {
            _quadtreeSprite.x += _velocityX * event.passedTime;
            _quadtreeSprite.y += _velocityY * event.passedTime;

            // Limit to world bounds
            _quadtreeSprite.x = Math.min(Math.max(_worldBounds.left + this.stage.stageWidth, _quadtreeSprite.x), _worldBounds.right);
            _quadtreeSprite.y = Math.min(Math.max(_worldBounds.top + this.stage.stageHeight, _quadtreeSprite.y), _worldBounds.bottom);


            var newViewPort:Rectangle = _quadtreeSprite.visibleViewport.clone();
            newViewPort.x = -_quadtreeSprite.x;
            newViewPort.y = -_quadtreeSprite.y;

            _quadtreeSprite.visibleViewport = newViewPort;
        }
    }
}
