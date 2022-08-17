cask "flashpoint-infinity" do
	version "0.2"
	sha256 "a67291247808ab3c9ee0d1140f3628367391492d8c43570d23f90ad37b5052a8"

	url "http://localhost:8000/Flashpoint.7z"
	name "Flashpoint Infinity"
	desc "A playable webgame library and archive. The Infinity edition allows downloading each piece of media on demand."
	homepage "https://bluemaxima.org/flashpoint/"

	depends_on "php"
	depends_on "qemu"
	depends_on "eloston-chromium"
	depends_on "waterfox-classic"
	depends_on "gcenx/wine/wine-crossover"

	suite "Flashpoint"
end