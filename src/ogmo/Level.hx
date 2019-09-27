package ogmo;

@:allow(ogmo.Layer)
class Level {
	var project : Project;
	public var layers : Array<Layer> = [];

	public var pxWid : Int;
	public var pxHei : Int;
	public var offX: Int;
	public var offY : Int;

	public function new(p:Project, json:Dynamic) {
		project = p;
		pxWid = json.width;
		pxHei = json.height;
		offX = json.offsetX;
		offY = json.offsetY;
		var jsonLayers : Array<Dynamic> = cast json.layers;
		for(l in jsonLayers)
			layers.push( new Layer(this, l) );
		layers.reverse();
	}
}