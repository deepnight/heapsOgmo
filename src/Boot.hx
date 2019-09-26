class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;
		new Main(s2d);
		onResize();
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);

		var tmod = hxd.Timer.tmod;
		#if debug
		tmod *= hxd.Key.isDown(hxd.Key.NUMPAD_ADD) || Main.ME!=null && Main.ME.ca.ltDown() ? 5 : 1;
		#end
		dn.heaps.Controller.beforeUpdate();
		dn.Process.updateAll(tmod);
	}
}

