cask "flashpoint-infinity" do
	version "0.5"
	sha256 "3648a788441244dcde4c6aaa94f09264460564dae927f0f2f838a699420398f5"

	url "https://bluemaxima.org/flashpoint/Flashpoint%2011%20Infinity%20Mac.7z"
	name "Flashpoint Infinity"
	desc "A playable webgame library and archive. The Infinity edition allows downloading each piece of media on demand."
	homepage "https://bluemaxima.org/flashpoint/"

	depends_on formula: "php"
	depends_on formula: "qemu"
	depends_on cask: "eloston-chromium"
	depends_on cask: "waterfox-classic"
	depends_on cask: "gcenx/wine/wine-crossover"

	suite "Flashpoint"
end
