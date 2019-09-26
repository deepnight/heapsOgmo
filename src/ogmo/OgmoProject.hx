package ogmo;

class OgmoProject {
	var json : Dynamic;
	public var name(get,never) : String; inline function get_name() return json.name;
	public var tiles : Array<{ label:String, path:String, t:h2d.Tile }> = [];

	public function new(project:hxd.res.Resource) {
		var raw = project.entry.getText();
		json = haxe.Json.parse(raw);
		trace(name);
		// var tilesets : Array<Dynamic> = cast json.tile
		for( t in cast(json.tilesets, Array<Dynamic>) ) {
			var parts = t.image.split(",");

			// Image format
			var r = ( ~/data:[a-z]+\/([a-z0-9]+)/gi );
			r.match( parts[0] );
			var format = r.matched(1);
			trace(format);
			trace(t.path+" is "+format);
			switch( format ) {
				case "png" :
					var bytes = haxe.crypto.Base64.decode(parts[1]);
					// var bytes = haxe.io.Bytes.ofString(t.parts[1]);
					var input = new haxe.io.BytesInput(bytes);
					var reader = new format.png.Reader(input);
					// var i = new hxd.res.Image()
					reader.read();
					// format.png.Tools
					// var tex = new h3d.mat.Texture()

				case _ : throw "Unsupported tileset image format: "+format;
			}
		}
	}
}