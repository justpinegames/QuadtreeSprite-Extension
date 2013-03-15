package starling.extensions.quadtree
{
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class QuadtreeNode
    {
        private var _topRight:QuadtreeNode;
        private var _topLeft:QuadtreeNode;
        private var _bottomRight:QuadtreeNode;
        private var _bottomLeft:QuadtreeNode;

        private var _bounds:Rectangle;
        private var _minimumBounds:Point;

        private var _objectContainer:Vector.<NodeElement>;

        public function QuadtreeNode(bounds:Rectangle, minimumBounds:Point)
        {
            _objectContainer = new Vector.<NodeElement>();
            _minimumBounds = minimumBounds;
            _bounds = bounds;
        }

        public function removeObject(object:Object):void
        {
            for (var i:int = 0; i < _objectContainer.length; i++)
            {
                var element:NodeElement = _objectContainer[i];

                if (element.object === object)
                {
                    _objectContainer.splice(i, 1);
                    return;
                }
            }
        }

        private function objectInBoundsHelper(checkingBounds:Rectangle, found:Vector.<Object>):void
        {
            /// doesn't intersect this node, do not check further
            if (!checkingBounds.intersects(_bounds))
            {
               return;
            }

            for each (var nodeElement:NodeElement in _objectContainer)
            {
                if (checkingBounds.intersects(nodeElement.bounds))
                {
                    found.push(nodeElement.object);
                }
            }

            if (_topLeft)
            {
                _topLeft.objectInBoundsHelper(checkingBounds, found);
            }

            if (_topRight)
            {
                _topRight.objectInBoundsHelper(checkingBounds, found);
            }

            if (_bottomLeft)
            {
                _bottomLeft.objectInBoundsHelper(checkingBounds, found);
            }

            if (_bottomRight)
            {
                _bottomRight.objectInBoundsHelper(checkingBounds, found);
            }
        }

        public function objectInBounds(checkingBounds:Rectangle):Vector.<Object>
        {
            var found:Vector.<Object> = new Vector.<Object>();

            objectInBoundsHelper(checkingBounds, found);

            return found;
        }

        public function insert(object:Object, objectBounds:Rectangle):QuadtreeNode
        {

            /// the object should not be in this node
            if (!_bounds.intersects(objectBounds))
            {
                return null;
            }

            var newWidth:Number = _bounds.width / 2
            var newHeight:Number = _bounds.height / 2;


            if (newHeight < _minimumBounds.x || newWidth < _minimumBounds.y)
            {
                _objectContainer.push(new NodeElement(object, objectBounds));
                return this;
            }

            var intersectCount:int = 0;
            var lastIntersection:Rectangle = null;

            var subBoundTopLeft:Rectangle = new Rectangle(_bounds.x, _bounds.y, newWidth, newHeight);
            if (subBoundTopLeft.intersects(objectBounds))
            {
                intersectCount++;
                lastIntersection = subBoundTopLeft;
            }

            var subBoundTopRight:Rectangle = new Rectangle(_bounds.x + newWidth, _bounds.y, newWidth, newHeight);
            if (subBoundTopRight.intersects(objectBounds))
            {
                intersectCount++;
                lastIntersection = subBoundTopRight;
            }

            var subBoundBottomLeft:Rectangle = new Rectangle(_bounds.x, _bounds.y + newHeight, newWidth, newHeight);
            if (subBoundBottomLeft.intersects(objectBounds))
            {
                intersectCount++;
                lastIntersection = subBoundBottomLeft;
            }

            var subBoundBottomRight:Rectangle = new Rectangle(_bounds.x + newWidth, _bounds.y + newHeight, newWidth, newHeight);
            if (subBoundBottomRight.intersects(objectBounds))
            {
                intersectCount++;
                lastIntersection = subBoundBottomRight;
            }

            if (intersectCount == 1)
            {
                if (lastIntersection == subBoundTopLeft)
                {
                    if (!_topLeft)
                    {
                        _topLeft = new QuadtreeNode(lastIntersection, _minimumBounds);
                    }
                    return _topLeft.insert(object, objectBounds);
                }
                if (lastIntersection == subBoundTopRight)
                {
                    if (!_topRight)
                    {
                        _topRight = new QuadtreeNode(lastIntersection, _minimumBounds);
                    }
                    return _topRight.insert(object, objectBounds);

                }
                if (lastIntersection == subBoundBottomLeft)
                {
                    if (!_bottomLeft)
                    {
                        _bottomLeft = new QuadtreeNode(lastIntersection, _minimumBounds);
                    }
                    return _bottomLeft.insert(object, objectBounds);
                }
                if (lastIntersection == subBoundBottomRight)
                {
                    if (!_bottomRight)
                    {
                        _bottomRight = new QuadtreeNode(lastIntersection, _minimumBounds);
                    }
                    return _bottomRight.insert(object, objectBounds);
                }
            }
            else if (intersectCount > 1)
            {
                _objectContainer.push(new NodeElement(object, objectBounds));
                return this;
            }


            return null;
        }

        public function get objects():Vector.<Object>
        {
            var objects:Vector.<Object> = new Vector.<Object>(_objectContainer.length);

            for each (var element:NodeElement in _objectContainer) {
                objects.push(element.object);
            }

            return objects;
        }

        public function get bounds():Rectangle
        {
            return _bounds;
        }
    }
}

import flash.geom.Rectangle;

internal class NodeElement
{
    private var _object:Object;
    private var _bounds:Rectangle;

    public function NodeElement(object:Object, bounds:Rectangle)
    {
        _object = object;
        _bounds = bounds;
    }

    public function get object():Object
    {
        return _object;
    }

    public function get bounds():Rectangle
    {
        return _bounds;
    }
}