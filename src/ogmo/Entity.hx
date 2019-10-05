package ogmo;

enum Mob {
	Melee;
	Distance;
}

class Entity {
	var project(get,never) : Project; inline function get_project() return level.project;
	var level(get,never) : Level; inline function get_level() return layer.level;
	var layer : Layer;

	public var name : String;
	public var x : Int;
	public var y : Int;
	public var cx(get,never) : Int; inline function get_cx() return Std.int(x/layer.gridWid);
	public var cy(get,never) : Int; inline function get_cy() return Std.int(y/layer.gridHei);
	var values : Dynamic;

	var projectSettingsJson : Dynamic;
	public var pxWid(get,never) : Int; inline function get_pxWid() return projectSettingsJson.size.x;
	public var pxHei(get,never) : Int; inline function get_pxHei() return projectSettingsJson.size.y;
	public var color(get,never) : Int; inline function get_color() return dn.Color.hexToInt(projectSettingsJson.color.substr(0,7));
	public var nodes : Array<EntityNode> = new Array();

	public function new(l:Layer, json:Dynamic) {
		layer = l;
		name = json.name;
		x = json.x;
		y = json.y;
		values = json.values==null ? {} : json.values;

		if( json.nodes!=null ) {
			var jsonNodes : Array<Dynamic> = cast json.nodes;
			for(n in jsonNodes)
				nodes.push( new EntityNode(layer, n.x, n.y) );
			trace(nodes);
		}

		var jsonEnts : Array<Dynamic> = project.json.entities;
		for(e in jsonEnts)
			if( e.name==name ) {
				projectSettingsJson = e;
				break;
			}
	}

	public function toString() return '$name @ $cx,$cy($x,$y) ; values=$values';

	public inline function has(v:String) return Reflect.hasField(values,v);
	public inline function get(v:String) return Reflect.field(values,v);

	public inline function getStr(v:String, ?def:String=null) {
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