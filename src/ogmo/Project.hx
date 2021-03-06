package ogmo;

@:allow(ogmo.Entity)
@:allow(ogmo.Decal)
@:allow(ogmo.Layer)
class Project {
	var json : Dynamic;
	public var fullPath : String;
	public var name(get,never) : String; inline function get_name() return json.name;
	public var tilesets : Map<String, Tileset> = new Map();
	public var levels : Array<Level> = [];

	public var res : hxd.res.Loader;
	var projectResource : hxd.res.Resource;
	public var dir(get,never) : String; inline function get_dir() return projectResource.entry.directory;

	public function new(project:hxd.res.Resource, useEmbededImageData:Bool) {
		fullPath = project.entry.path;
		var raw = project.entry.getText();
		json = haxe.Json.parse(raw);

		res = hxd.res.Loader.currentInstance;
		this.projectResource = project;

		// Init tilesets
		if( json.tilesets!=null )
			for( jsonTileset in cast(json.tilesets, Array<Dynamic>) ) {
				if( useEmbededImageData) {
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

							var t = new Tileset(h2d.Tile.fromPixels(pixels), jsonTileset);
							tilesets.set(t.label, t);

						case _ : throw "Unsupported tileset image format: "+imageType;
					}
				}
				else {
					var path = project.entry.directory+"/"+StringTools.replace(jsonTileset.path,"\\","/");
					var img = res.load(path);
					var t = new Tileset(img.toTile(), jsonTileset);
					tilesets.set(t.label, t);
				}
			}

		// Init levels
		var paths : Array<String> = cast json.levelPaths;
		for( path in paths ) {
			initLevelInDir(path);
		}
	}


	public function loadFile(relativeFilePath:String) : hxd.res.Any {
		var path = dn.FilePath.fromFile(dir+"/"+relativeFilePath);
		return
			try res.load(path.full)
			catch(e:Dynamic) throw "Couldn't load "+path.full;
	}

	function initLevelInDir(path:String) {
		var dir = res.load(projectResource.entry.directory + (path=="." ? "" : "/"+path));
		for(e in dir)
			if( e.name.indexOf(".json")>=0 ) {
				var raw = e.toText();
				levels.push( new Level(this, e, haxe.Json.parse(raw)) );
			}
			else if (e.entry.isDirectory)
				initLevelInDir(e.name);
	}

	public function toString() return '"$name" ($fullPath)';

	public function matchEntityEnum<T>(entityId:String, value:String, baseEnum:Enum<T>) {
		var jsonEntities : Array<Dynamic> = json.entities;

		for(e in jsonEntities) {
			if( e.name!=entityId )
				continue;

			var jsonValues : Array<Dynamic> = e.values;
			for(v in jsonValues) {
				if( v.name==value && v.definition=="Enum" ) {

					var choices : Array<String> = v.choices;
					var choiceMap = new Map();
					for( c in choices ) {
						choiceMap.set(c, true);
						try Type.createEnum(baseEnum,c)
						catch( e:Dynamic ) throw "Choice "+entityId+"."+value+"."+c+" is not matching code enum "+baseEnum;
					}

					for( c in Type.getEnumConstructs(baseEnum) )
						if( !choiceMap.exists(c) )
							throw "Missing enum choice "+entityId+"."+value+"."+c;

					return; // all ok
				}
			}

		}

		throw "Unknown value "+entityId+"."+value;
	}

	public function matchCdbStringRef<T>(entityId:String, value:String, cdbResolver:String->?Bool->Dynamic) {
		var jsonEntities : Array<Dynamic> = json.entities;

		for( level in levels )
		for( layer in level.layers )
		for( e in layer.entities ) {
			if( e.name!=entityId )
				continue;

			var found = false;
			for( k in e.getAllValueNames() ) {
				if( k!=value )
					continue;

				found = true;
				var v = e.getStr(k);
				if( v==null || v=="" )
					break;

				if( cdbResolver(e.getStr(k),true)==null )
					throw '"${e.getStr(k)}" doesn\'t exist in CDB ($entityId @ ${e.x},${e.y} in "${level.name}")';
				else
					break;
			}

			if( !found )
				throw "Unknown value "+entityId+"."+value;
		}
	}

	public function getLevelByName(n:String) {
		if( n.indexOf(".json")<0 )
			n+=".json";

		for(l in levels)
			if( l.name==n )
				return l;

		return null;
	}
}
