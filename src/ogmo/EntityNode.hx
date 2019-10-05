package ogmo;

class EntityNode {
	var layer : Layer;
	public var x : Int;
	public var y : Int;
	public var cx(get,never) : Int;
	public var cy(get,never) : Int;

	public function new(l:Layer, x,y) {
		this.x = x;
		this.y = y;
		this.layer = l;
	}

	public function toString() return '${layer.name}.Node $x,$y ($cx,$cy)';

	inline function get_cx() return Std.int(x/layer.gridWid);
	inline function get_cy() return Std.int(y/layer.gridHei);
}
