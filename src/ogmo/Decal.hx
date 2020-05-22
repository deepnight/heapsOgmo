package ogmo;

class Decal {
	var project(get,never) : Project; inline function get_project() return level.project;
	var level(get,never) : Level; inline function get_level() return layer.level;
	var layer : Layer;

	public var texture : String;
	public var dir : String;
	public var x : Int;
	public var y : Int;
	public var tile : h2d.Tile;
	public var scaleX : Float;
	public var scaleY : Float;
	public var rotation : Float;
	var values : Dynamic;

	public function new(l:Layer, dir:String, json:Dynamic) {
		layer = l;
		this.dir = dir;
		x = json.x;
		y = json.y;
		texture = json.texture;
		values = json.values;
		scaleX = json.scaleX!=null ? json.scaleX : 1.0;
		scaleY = json.scaleY!=null ? json.scaleY : 1.0;
		rotation = json.rotation!=null ? json.rotation : 0.;

		var file = project.loadFile(dir+"/"+texture);
		tile = file.toTile();
	}

	public function makeBitmap(?parent:h2d.Object) : h2d.Bitmap {
		var bmp = new h2d.Bitmap(tile, parent);
		bmp.tile.setCenterRatio();
		bmp.setPosition(x, y);
		bmp.scaleX = scaleX;
		bmp.scaleY = scaleY;
		bmp.rotation = rotation;
		return bmp;
	}

	public function toString() return '$texture @ $x,$y';

	public inline function has(v:String) : Bool return Reflect.hasField(values,v);
	public inline function get(v:String) : Dynamic return Reflect.field(values,v);

	@:allow(ogmo.Project) inline function getAllValueNames() return Reflect.fields(values);

	public inline function getStr(v:String, ?def:String=null) {
		return has(v) ? get(v): def;
	}

	public inline function getBool(v:String, ?def=false) {
		return has(v) ? get(v)=="true" || get(v)==true : def;
	}

	public inline function getInt(v:String, ?def=0) {
		var out =
			Type.typeof(get(v))==TInt ? get(v)
			: Type.typeof(get(v))==TFloat ? Std.int(get(v))
			: Std.parseInt(get(v));
		return has(v) && out!=null ? out : def;
	}

	public inline function getFloat(v:String, ?def=0.) {
		var out = Type.typeof(get(v))==TInt || Type.typeof(get(v))==TFloat
			? get(v)
			: Std.parseFloat(get(v));
		return has(v) && !Math.isNaN(out) && Math.isFinite(out) ? out : def;
	}

	public inline function getColor(v:String, ?def=0x0) {
		if( !has(v) )
			return def;
		var out = dn.Color.hexToInt( get(v).substr(0,7) );
		return has(v) && out!=null ? out : def;
	}

	public inline function getEnum<T>(v:String, e:Enum<T>) : T {
		if( !has(v) )
			throw texture+" has no enum field "+v;

		try return e.createByName(get(v))
		catch(err:Dynamic) {
			throw "Enum value "+get(v)+" found in "+texture+"."+v+" doesn't exist in source code!";
		}
	}

}