package ogmo;

class Project {
	var json : Dynamic;
	public var name(get,never) : String; inline function get_name() return json.name;
	public var tiles : Array<{ label:String, path:String, t:h2d.Tile }> = [];

	public function new(project:hxd.res.Resource) {
		var raw = project.entry.getText();
		json = haxe.Json.parse(raw);

		// Init tilesets
		for( tileset in cast(json.tilesets, Array<Dynamic>) ) {
			var parts = tileset.image.split(",");

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

					tiles.push({
						label : tileset.label,
						path : tileset.path,
						t : h2d.Tile.fromPixels(pixels),
					});

				case _ : throw "Unsupported tileset image format: "+imageType;
			}
		}
	}
}