import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;

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

		// Start
		var p = new ogmo.Project(hxd.Res.map.project);

		for(level in p.levels)
		for(layer in level.layers) {
			var o = layer.render();
			root.addChild(o);
			o.scale(3);
		}
	}
}
