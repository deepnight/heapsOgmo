package ogmo;

class Tileset {
	public var tile : h2d.Tile;
	public var label : String;
	public var fullPath : String;
	public var tWid : Int;
	public var tHei : Int;
	var tiles : Map<Int,h2d.Tile> = new Map();

	public function new(t:h2d.Tile, json:Dynamic) {
		this.tile = t;
		label = json.label;
		fullPath = json.path;
		tWid = json.tileWidth;
		tHei = json.tileHeight;

		// Extract all tiles
		var perLine = M.ceil(tile.width/tWid);
		var tx = 0;
		var ty = 0;
		for( ty in 0...M.ceil(tile.height/tHei) )
		for( tx in 0...perLine )
			tiles.set( tx+ty*perLine, tile.sub(tx*tWid, ty*tHei, tWid, tHei) );
	}

	public function toString() return 'Tileset:$label';

	public function coordId(tx,ty) return tx + ty*M.ceil(tile.width/tWid);

	public inline function getTile(id:Int) : h2d.Tile {
		return tiles.get(id);
	}
}