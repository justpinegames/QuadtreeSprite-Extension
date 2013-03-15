package starling.extensions.quadtree
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    public class Quadtree
    {
        private var _root:QuadtreeNode;

        private var _bounds:Rectangle;
        private var _minimumBounds:Point;

        private var _objectNodeMapping:Dictionary;

        public function Quadtree(minX:Number, minY:Number, maxX:Number, maxY:Number, minimumSize:Number = 100)
        {
            _bounds = new Rectangle(minX, minY, maxX - minX, maxY - minY);
            _minimumBounds = new Point(minimumSize, minimumSize);

            _root = new QuadtreeNode(_bounds, _minimumBounds);

            _objectNodeMapping = new Dictionary(true);

        }

        public function insert(object:Object, bounds:Rectangle):Boolean
        {
            var targetQuadtreeNode:QuadtreeNode = _root.insert(object, bounds);

            if (targetQuadtreeNode) {
                _objectNodeMapping[object] = targetQuadtreeNode;
            }

            return targetQuadtreeNode != null;
        }

        public function nodeForObject(object:Object):QuadtreeNode
        {
            return _objectNodeMapping[object];
        }

        public function remove(object:Object):Boolean
        {
            var node:QuadtreeNode = _objectNodeMapping[object];

            /// Object not found
            if (!node)
            {
                return false;
            }

            node.removeObject(object);

            delete _objectNodeMapping[object];

            return true;
        }

        public function update(object:Object, bounds:Rectangle):void
        {
            this.remove(object);
            this.insert(object, bounds);
        }

        public function objectsInRectangle(rectangle:Rectangle):Vector.<Object>
        {
            return _root.objectInBounds(rectangle);
        }

        public function get root():QuadtreeNode
        {
            return _root;
        }
    }
}
