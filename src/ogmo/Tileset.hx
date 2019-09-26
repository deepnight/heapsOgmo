package ogmo;

class Tileset {
	public var t: h2d.Tile;
	public var label: String;
	public var path: String;

	public function new(l:String, t:h2d.Tile) {
		label = l;
		this.t = t;
	}
}