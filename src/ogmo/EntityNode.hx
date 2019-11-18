package ogmo;

class EntityNode {
	var parent : Entity;
	public var x : Int;
	public var y : Int;
	public var cx(get,never) : Int;
	public var cy(get,never) : Int;

	public function new(e:Entity, x,y) {
		this.parent = e;
		this.x = x;
		this.y = y;
	}

	public function toString() return '${parent.name}.Node $x,$y ($cx,$cy)';

	inline function get_cx() return Std.int( x / parent.getGridWid() );
	inline function get_cy() return Std.int( y / parent.getGridHei() );
}
