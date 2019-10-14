package ogmo;

@:allow(ogmo.Layer)
@:allow(ogmo.Entity)
class Level {
	var project : Project;
	public var name : String;
	public var directory : String;
	public var layers : Array<Layer> = [];

	public var layersReversed : Array<Layer> = [];
	var layersByName : Map<String,Layer> = new Map();

	public var pxWid : Int;
	public var pxHei : Int;
	public var offX: Int;
	public var offY : Int;

	var values : Dynamic;

	public function new(p:Project, file:hxd.res.Resource, json:Dynamic) {
		project = p;
		name = file.name;
		directory = file.entry.directory;

		pxWid = json.width;
		pxHei = json.height;
		offX = json.offsetX;
		offY = json.offsetY;

		values = json.values==null ? {} : json.values;

		var jsonLayers : Array<Dynamic> = cast json.layers;
		for(json in jsonLayers) {
			var l = new Layer(this, json);
			layers.push(l);
			layersByName.set(l.name, l);
		}

		layersReversed = layers.copy();
		layersReversed.reverse();
	}

	public function toString() return 'Level:$name';

	public inline function getLayerByName(id:String) return layersByName.get(id);

	public inline function has(v:String) return Reflect.hasField(values,v);
	public inline function get(v:String) return Reflect.field(values,v);

	public inline function getStr(v:String, ?def:String="") {
		return has(v) ? get(v): def;
	}

	public inline function getBool(v:String, ?def=false) {
		return has(v) ? get(v)=="true" : def;
	}

	public inline function getInt(v:String, ?def=0) {
		var out = Std.parseInt( get(v) );
		return has(v) && out!=null ? out : def;
	}

	public inline function getFloat(v:String, ?def=0.) {
		var out = Std.parseFloat( get(v) );
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
			throw name+" has no enum field "+v;

		try return e.createByName(get(v))
		catch(err:Dynamic) {
			throw "Enum value "+get(v)+" found in "+name+"."+v+" doesn't exist in source code!";
		}
	}

}