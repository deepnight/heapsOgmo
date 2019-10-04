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
		dn.Process.updateAll(tmod);
	}
}

