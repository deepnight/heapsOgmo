import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = 60;
		engine.backgroundColor = 0xff<<24|0x111133;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

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

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.ENTER, Key.NUMPAD_ENTER);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		// Start
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, font);
		delayer.addF( start, 1 );
	}

	public function start() {
		var p = new ogmo.Project(hxd.Res.map.project);

		var tg = p.levels[0].layers[1].render();
		root.addChild(tg);
		tg.scale(3);

		var tg = p.levels[0].layers[0].render();
		root.addChild(tg);
		tg.scale(3);
	}
}
