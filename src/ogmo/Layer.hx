package ogmo;

class Layer {
	var project(get,never) : Project; inline function get_project() return level.project;
	var level : Level;

	public var gridWid : Int;
	public var gridHei : Int;
	public var offX: Int;
	public var offY: Int;

	public var cWid(get,never) : Int; inline function get_cWid() return M.ceil( level.pxWid/gridWid );
	public var cHei(get,never) : Int; inline function get_cHei() return M.ceil( level.pxHei/gridHei );

	var tilesetLabel : String;
	var tileset(get,never) : Tileset; inline function get_tileset() return project.tilesets.get(tilesetLabel);
	var tile(get,never) : h2d.Tile; inline function  get_tile() return tileset.t;

	var tileIds : Map<Int,Int> = new Map();

	public function new(l:Level, json:Dynamic) {
		level = l;
		offX = json.offsetX;
		offY = json.offsetY;
		gridWid = json.gridCellWidth;
		gridHei = json.gridCellHeight;
		tilesetLabel = json.tileset;

		if( json.data!=null ) {
			// Ids in 1D array
			var a : Array<Int> = cast json.data;
			var idx = 0;
			for(tid in a)
				tileIds.set(idx++, tid);
		}
		else if( json.data2D!=null ) {
			// Ids in 2D array
			var a : Array<Array<Int>> = cast json.data2D;
			var idx = 0;
			for(line in a)
			for(tid in line)
				tileIds.set(idx++, tid);
		}
		else
			trace("unsupported level format");
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;
	public inline function coordId(cx,cy) return isValid(cx,cy) ? cx + cy*cWid : 0;

	public inline function getTileId(cx,cy) {
		return tileIds.get( coordId(cx,cy) );
	}

	public function render() {
		var tg = new h2d.TileGroup(tile);
		trace('level=$cWid x $cHei grid=$gridWid x $gridHei');
		trace(getTileId(0,0)+" "+getTileId(0,1));

		for(cy in 0...cHei)
		for(cx in 0...cWid) {
			if( getTileId(cx,cy)<0 )
				continue;

			tg.add(
				cx*gridWid, cy*gridHei,
				tileset.getTile( getTileId(cx,cy) )
			);
		}
		return tg;
	}
}
