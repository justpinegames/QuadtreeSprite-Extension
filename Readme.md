# QuadtreeSprite Starling extension

## About
QuadtreeSprite is a Starling extensions which is useful when you need a container for large amount of children DisplayObjects which are usually not visible on the screen at the same time. Perfect use-case: Large 2D world map.

There are a few things different in the API so check the usage section below.

The example creates 100,000 Quad objects on 20,000 x 20,000 world, which results in the following performance on my machine:
* Sprite - 0.03 FPS (Not really designed for this :) )
* QuadtreeSprite - 60 FPS

## Usage

Creation:

    // Define the world bounds, if objects is outside them it will always be displayed
    var worldBounds:Rectangle = new Rectangle(...);
    var container:QuadtreeSprite = new QuadtreeSprite(worldBounds);

Adding/Removing children:

    // Same as in Starling:
    container.addChild(new Quad(...));
    container.removeChild(...);

Important to note is that you have to **explicitly** update object when it's position or size has changed!

    var object:Quad = ...;
    container.addChild(object);
    object.x = 10;
    container.updateChild(object);

To change the visible portion of the scene use visibleViewport, everything outside that rectangle will be removed from display list:

    container.visibleViewport = new Rectangle(...);

When visible objects change you can listen to Event.CHANGE, you should sort here if you need your objects to be in order:

    container.addEventListener(Event.CHANGE, ...);

You can iterate through the currently visible objects, or all of which the container holds:

    // visible objects
    for (var i:int = 0; i < container.numChildren; ++i) {
        var object:DisplayObject = container.getChildAt(i);
    }

    // all objects
    for (var i:int = 0; i < container.dynamicNumChildren; ++i) {
        var object:DisplayObject = container.dynamicGetChildAt(i);
    }




