# About

A simple lib to import **Ogmo 3** maps to Heaps projects. It only supports basic stuff, and it's not meant to support 100% of all Ogmo features. If you need all advanced Ogmo features, you can install:

``haxelib install ogmo-3``

See: https://github.com/Ogmo-Editor-3/ogmo-3-lib

# Usage

```haxe
hxd.Res.initEmbed(); // init resources in default sub-folder "./res/"

var ogmoProject = new ogmo.Project( hxd.Res.myOgmoProjectFile );

for( level in ogmoProject.levels )
for( layer in level.layers ) {
	var obj = layer.render();
	myScene.addChild(obj);
}
```

See `./test/src/Main.hx`.

# Credits

"Inca" tileset by Kronbits: https://kronbits.itch.io/inca-game-assets