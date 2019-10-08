package ogmo;

enum LayerType {
	TileLayer;
	EntityLayer;
	IntGridLayer;
}

@:allow(ogmo.Entity)
class Layer {
	var project(get,never) : Project; inline function get_project() return level.project;
	var level : Level;

	public var name : String;
	public var type : LayerType;
	public var gridWid : Int;
	public var gridHei : Int;
	public var offX: Int;
	public var offY: Int;

	public var cWid(get,never) : Int; inline function get_cWid() return M.ceil( level.pxWid/gridWid );
	public var cHei(get,never) : Int; inline function get_cHei() return M.ceil( level.pxHei/gridHei );

	var tilesetLabel : String;
	public var tileset(get,never) : Tileset; inline function get_tileset() return project.tilesets.get(tilesetLabel);
	var tileIds : Map<Int,Int> = new Map();

	var intGridIds : Map<Int,Int> = new Map();
	var intGridColors: Map<Int,Int> = new Map();

	public var entities : Array<Entity> = [];

	public function new(l:Level, json:Dynamic) {
		level = l;
		name = json.name;
		offX = json.offsetX;
		offY = json.offsetY;
		gridWid = json.gridCellWidth;
		gridHei = json.gridCellHeight;
		tilesetLabel = json.tileset;

		if( json.data!=null ) {
			// Tile layer: Ids in 1D array
			type = TileLayer;
			var a : Array<Int> = cast json.data;
			var idx = 0;
			for(tid in a)
				tileIds.set(idx++, tid);
		}
		else if( json.data2D!=null ) {
			// Tile layer: Ids in 2D array
			type = TileLayer;
			var a : Array<Array<Int>> = cast json.data2D;
			var idx = 0;
			for(line in a)
			for(tid in line)
				tileIds.set(idx++, tid);
		}
		else if( json.dataCoords!=null ) {
			// Tile layer: Coords in 1D array
			type = TileLayer;
			var a : Array<Array<Int>> = cast json.dataCoords;
			var idx = 0;
			for(c in a) {
				if( c.length==2 )
					tileIds.set(idx, tileset.coordId(c[0], c[1]));
				idx++;
			}
		}
		else if( json.dataCoords2D!=null ) {
			// Tile layer: Coords in 2D array
			type = TileLayer;
			var a : Array<Array<Array<Int>>> = cast json.dataCoords2D;
			var idx = 0;
			for(line in a)
			for(c in line) {
				if( c.length==2 )
					tileIds.set(idx, tileset.coordId(c[0], c[1]));
				idx++;
			}
		}
		else if( json.entities!=null ) {
			// Entity layer
			type = EntityLayer;
			var jsonEntities : Array<Dynamic> = cast json.entities;
			for(e in jsonEntities)
				entities.push( new Entity(this, e) );
		}
		else if( json.grid!=null ) {
			// IntGrid layer (1D)
			type = IntGridLayer;
			var jsonGrid : Array<Dynamic> = cast json.grid;
			var idx = 0;
			for(tid in jsonGrid)
				intGridIds.set(idx++, Std.parseInt(tid));
		}
		// TODO: support IntGrid 2D
		else
			throw "Unsupported layer format in: "+json.name;


		// Parse IntGrid colors
		var layerDefs : Array<Dynamic> = project.json.layers;
		for(l in layerDefs)
			if( l.definition=="grid" && l.name==name ) {
				for(k in Reflect.fields(l.legend)) {
					var c : String = Reflect.field(l.legend,k);
					intGridColors.set( Std.parseInt(k), dn.Color.hexToInt(c.substr(0,7)) );
				}
			}
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;
	public inline function coordId(cx,cy) return isValid(cx,cy) ? cx + cy*cWid : 0;

	public inline function getTileId(cx,cy) {
		return !tileIds.exists(coordId(cx,cy)) ? -1 : tileIds.get( coordId(cx,cy) );
	}

	public inline function getIntGrid(cx,cy) {
		return isValid(cx,cy) && intGridIds.exists(coordId(cx,cy)) ? intGridIds.get(coordId(cx,cy)) : 0;
	}

	public function render(?parent:h2d.Object, ?alpha=1.0, ?blend:h2d.BlendMode) : h2d.Object {
		var wrapper = new h2d.Object(parent);
		wrapper.alpha = alpha;
		if( blend==null )
			blend = Alpha;

		switch type {
			case TileLayer:
				var tg = new h2d.TileGroup(tileset.tile, wrapper);
				tg.blendMode = blend;
				for(cy in 0...cHei)
				for(cx in 0...cWid) {
					if( getTileId(cx,cy)<0 )
						continue;

					tg.add(
						cx*gridWid, cy*gridHei,
						tileset.getTile( getTileId(cx,cy) )
					);
				}

			case EntityLayer:
				for(e in entities) {
					var g = new h2d.Graphics(wrapper);
					g.setPosition(e.x, e.y);
					g.lineStyle(1,e.color,1);
					g.beginFill(e.color, 0.6);
					g.drawRect(0,0,e.pxWid,e.pxHei);
				}

			case IntGridLayer:
				for(cy in 0...cHei)
				for(cx in 0...cWid) {
					if( getIntGrid(cx,cy)<=0 )
						continue;
					var g = new h2d.Graphics(wrapper);
					g.beginFill( intGridColors.get(getIntGrid(cx,cy)), 1 );
					g.drawRect(cx*gridWid, cy*gridHei, gridWid, gridHei);
				}
		}

		return wrapper;
	}
}
