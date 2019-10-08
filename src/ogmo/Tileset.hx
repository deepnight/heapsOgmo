package ogmo;

class Tileset {
	public var t: h2d.Tile; // TODO rename > tile
	public var label: String;
	public var path: String;
	public var tWid : Int;
	public var tHei : Int;
	var tiles : Map<Int,h2d.Tile> = new Map();

	public function new(t:h2d.Tile, json:Dynamic) {
		this.t = t;
		label = json.label;
		path = json.path;
		tWid = json.tileWidth;
		tHei = json.tileHeight;

		// Extract all tiles
		var perLine = M.ceil(t.width/tWid);
		var tx = 0;
		var ty = 0;
		for( ty in 0...M.ceil(t.height/tHei) )
		for( tx in 0...perLine )
			tiles.set( tx+ty*perLine, t.sub(tx*tWid, ty*tHei, tWid, tHei) );
	}

	public function coordId(tx,ty) return tx + ty*M.ceil(t.width/tWid);

	public inline function getTile(id:Int) : h2d.Tile {
		return tiles.get(id);
	}
}