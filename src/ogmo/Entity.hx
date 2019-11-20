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
	public var cx(get,never) : Int; inline function get_cx() return Std.int(x/(gridWidOverride==null ? layer.gridWid : gridWidOverride));
	public var cy(get,never) : Int; inline function get_cy() return Std.int(y/(gridHeiOverride==null ? layer.gridHei : gridHeiOverride));
	var values : Dynamic;

	var projectSettingsJson : Dynamic;
	public var pxWid : Int;
	public var pxHei : Int;
	public var color(get,never) : Int; inline function get_color() return dn.Color.hexToInt(projectSettingsJson.color.substr(0,7));
	public var nodes : Array<EntityNode> = new Array();

	var gridWidOverride : Null<Int>;
	var gridHeiOverride : Null<Int>;

	public function new(l:Layer, json:Dynamic) {
		layer = l;
		name = json.name;
		x = json.x;
		y = json.y;
		pxWid = json.width==null ? 0 : json.width;
		pxHei = json.height==null ? 0 : json.height;
		values = json.values==null ? {} : json.values;

		if( json.nodes!=null ) {
			var jsonNodes : Array<Dynamic> = cast json.nodes;
			for(n in jsonNodes)
				nodes.push( new EntityNode(this, n.x, n.y) );
		}

		var jsonEnts : Array<Dynamic> = project.json.entities;
		for(e in jsonEnts)
			if( e.name==name ) {
				projectSettingsJson = e;
				break;
			}
	}

	public function overrideGridSize(gw:Int,?gh:Int) {
		gridWidOverride = gw;
		gridHeiOverride = gh==null ? gw : gh;
	}
	public function resetGridSize() {
		gridWidOverride = gridHeiOverride = null;
	}
	public function getGridWid() return gridWidOverride==null ? layer.gridWid : gridWidOverride;
	public function getGridHei() return gridHeiOverride==null ? layer.gridHei : gridHeiOverride;

	public inline function xToGrid(g:Int) return Std.int( x/g );
	public inline function yToGrid(g:Int) return Std.int( y/g );

	public function prependStartToNodes() {
		nodes.unshift( new EntityNode(this, x, y) );
	}

	public function toString() return '$name @ $cx,$cy($x,$y ; ${pxWid}x${pxHei}) ; values=$values';

	public inline function has(v:String) return Reflect.hasField(values,v);
	public inline function get(v:String) return Reflect.field(values,v);

	@:allow(ogmo.Project) inline function getAllValueNames() return Reflect.fields(values);

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