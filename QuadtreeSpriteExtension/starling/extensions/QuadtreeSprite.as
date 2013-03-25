package starling.extensions
{
    import flash.utils.Dictionary;

    import starling.extensions.quadtree.Quadtree;

    import flash.geom.Rectangle;

    import starling.core.RenderSupport;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.events.Event;

    public class QuadtreeSprite extends Sprite
    {
        private var _quadtree:Quadtree;
        private var _viewport:Rectangle;
        private var _children:Vector.<DisplayObject>;

        private var _childrenPositions:Dictionary;

        private var _dirty:Boolean;

        public function QuadtreeSprite(worldSpace:Rectangle, maintainOrder:Boolean = false)
        {
            _quadtree = new Quadtree(worldSpace.left, worldSpace.top, worldSpace.right, worldSpace.bottom);
            _viewport = worldSpace.clone();
            _children = new Vector.<DisplayObject>();

            if (maintainOrder) _childrenPositions = new Dictionary();

            _dirty = true;
        }

        override public function render(support:RenderSupport, parentAlpha:Number):void
        {
            refresh();
            super.render(support, parentAlpha);
        }

        public function updateChild(child:DisplayObject):void
        {
            // TODO Is it better to save them in a set and update them at the time when the refresh is called?
            // Solves the problem of updating a child multiple times per frame.

            _quadtree.update(child, child.bounds);
            _dirty = true;
        }

        override public function addChild(child:DisplayObject):DisplayObject
        {
            addChildAt(child, this.dynamicNumChildren);
            return child;
        }

        override public function addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            // No need to set the dirty, we can just check if the object intersects.
            if (_viewport.intersects(child.bounds)) super.addChildAt(child, this.numChildren);

            if (_childrenPositions)
            {
                _children.splice(index, 0, child);

                for (var i:int = index; i < _children.length; i++)
                    _childrenPositions[_children[i]] = i;

                this.invalidate();
            }
            else
            {
                // Don't care about the order
                _children.push(child);
            }

            _quadtree.insert(child, child.bounds);

            // TODO Can this be removed?
            _dirty = true;

            return child;
        }

        public function get dynamicNumChildren():int
        {
            return _children.length;
        }

        public function dynamicGetChildAt(index:int):DisplayObject
        {
            return _children[index];
        }

        override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
        {
            var index:int = _children.indexOf(child);
            _children.splice(index, 1);

            _quadtree.remove(child);

            if (_childrenPositions) delete _childrenPositions[child];

            // to remove the need for refresh, remove the child from the container if it's there
            if (this.contains(child)) super.removeChild(child, dispose);

            return child;
        }

        public function refresh():void
        {
            if (!_dirty) return;

            _dirty = false;

            this.removeChildren();

            var visibleObjects:Vector.<Object> = _quadtree.objectsInRectangle(_viewport);

            // To maintain the order sort children by their insertion index
            if (_childrenPositions)
            {
                visibleObjects.sort(function(first:DisplayObject, second:DisplayObject):Number
                {
                    return _childrenPositions[first] - _childrenPositions[second];
                });
            }

            for each (var visibleObject:DisplayObject in visibleObjects)
            {
                super.addChildAt(visibleObject, this.numChildren);
            }

            this.dispatchEventWith(Event.CHANGE);
        }

        public function get visibleViewport():Rectangle
        {
            return _viewport;
        }

        public function set visibleViewport(viewport:Rectangle):void
        {
            if (viewport.equals(_viewport)) return;

            _viewport = viewport.clone();
            _dirty = true;
        }

        public function get dirty():Boolean
        {
            return _dirty;
        }

        public function invalidate():void
        {
            _dirty = true;
        }

    }
}
