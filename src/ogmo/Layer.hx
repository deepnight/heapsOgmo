package ogmo;

class Layer {
	var project(get,never) : Project; inline function get_project() return level.project;
	var level : Level;

	public var gridWid : Int;
	public var gridHei : Int;
	public var offX: Int;
	public var offY: Int;

	public var cWid(get,never) : Int; inline function get_cWid() return Std.int( level.pxWid/gridWid );
	public var cHei(get,never) : Int; inline function get_cHei() return Std.int( level.pxHei/gridHei );

	var tilesetLabel : String;
	var tileset(get,never) : Tileset; inline function get_tileset() return project.tilesets.get(tilesetLabel);

	public function new(l:Level, json:Dynamic) {
		level = l;
		offX = json.offsetX;
		offY = json.offsetY;
		gridWid = json.gridCellWidth;
		gridHei = json.gridCellHeight;
		tilesetLabel = json.tileset;
	}
}
