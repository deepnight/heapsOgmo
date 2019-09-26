package ogmo;

class Project {
	var json : Dynamic;
	public var name(get,never) : String; inline function get_name() return json.name;
	public var tilesets : Map<String, Tileset> = new Map();
	public var levels : Array<Level> = [];

	public function new(project:hxd.res.Resource) {
		var raw = project.entry.getText();
		json = haxe.Json.parse(raw);

		// Init tilesets
		for( jsonTileset in cast(json.tilesets, Array<Dynamic>) ) {
			var parts = jsonTileset.image.split(",");

			var r = ( ~/data:[a-z]+\/([a-z0-9]+)/gi ); // extract image format
			r.match( parts[0] );
			var imageType = r.matched(1);
			switch( imageType ) {
				case "png" :
					var bytes = haxe.crypto.Base64.decode(parts[1]);
					var reader = new format.png.Reader( new haxe.io.BytesInput(bytes) );
					var data = reader.read();
					var wid = 0;
					var hei = 0;
					for(e in data)
						switch e {
							case CHeader(h):
								wid = h.width;
								hei = h.height;
							case _:
						}
					if( wid==0 || hei==0 ) throw "Missing width or height";

					var pixels = hxd.Pixels.alloc(wid, hei, BGRA);
					format.png.Tools.extract32(data, pixels.bytes);

					var t = new Tileset(jsonTileset.label, h2d.Tile.fromPixels(pixels));
					t.path = jsonTileset.path;
					tilesets.set(t.label, t);

				case _ : throw "Unsupported tileset image format: "+imageType;
			}
		}

		// Init levels
		var basePath = "res/"+project.entry.directory; // HACK: need resource full path here
		var paths : Array<String> = cast json.levelPaths;
		for(path in paths) {
			var path = basePath+"/"+path;
			for(f in sys.FileSystem.readDirectory(path))
				if( f.indexOf(".json")>=0 ) {
					var raw = sys.io.File.read( path+"/"+f, false ).readAll().toString();
					levels.push( new Level(this, haxe.Json.parse(raw)) );
				}
		}
	}
}