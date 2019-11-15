import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	var wrapper : h2d.Object;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = 60;
		engine.backgroundColor = 0xff<<24|0x111133;

		// Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed({compressSounds:true});
        #end

		// Console
		var font = hxd.Res.barlow_condensed_medium_regular_11.toFont();
		var c = new h2d.Console(font, s);
		h2d.Console.HIDE_LOG_TIMEOUT = 99999;
		dn.Lib.redirectTracesToH2dConsole(c);

		wrapper = new h2d.Object(root);
		wrapper.scale(4);
		renderMap(hxd.Res.map.topDown_ogmo, hxd.Res.map.topDown_json);
	}

	function renderMap(ogmo:hxd.res.Resource, level:hxd.res.Resource) {
		level.watch( renderMap.bind(ogmo,level) );

		wrapper.removeChildren();

		var ogmoProject = new ogmo.Project(ogmo, false);
		var level = ogmoProject.getLevelByName(level.entry.name);

		for(layer in level.layersReversed) {
			var obj = layer.render();
			wrapper.addChild(obj);
		}
	}
}
