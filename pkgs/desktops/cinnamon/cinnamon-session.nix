{ stdenv, fetchurl, pkgconfig, autoreconfHook, glib, gettext, gnome_common, gtk3, dbus_glib, 
upower, json_glib,intltool, systemd, hicolor_icon_theme, makeWrapper}:

let
  version = "2.0.6";
in
stdenv.mkDerivation {
  name = "cinnamon-session-${version}";
  
  src = fetchurl {
    url = "http://github.com/linuxmint/cinnamon-session/archive/${version}.tar.gz";
    sha256 = "0rs5w7npj3wf3gkk3sfb83awks2h7vjd6cz8mvfgbh6m3grn66l3";
  };
  
  
  configureFlags = "--disable-schemas-compile --enable-systemd --disable-gconf" ; 

  patches = [ ./remove-sessionmigration.patch ./timeout.patch]; 

  buildInputs = [
    pkgconfig autoreconfHook
    glib gettext gnome_common
    gtk3 dbus_glib upower json_glib
    intltool systemd makeWrapper
   ];

  preBuild = "patchShebangs ./scripts";

  installPhase = ''
    wrapProgram $out/bin/cinnamon-session \
      --prefix XDG_DATA_DIRS ":" "${hicolor_icon_theme}/share"
  '';  

  postInstall =  ''
         rm $out/share/icons/hicolor/icon-theme.cache
   ''; 
 meta = {
    homepage = "http://cinnamon.linuxmint.com";
    description = "the cinnamon session files " ;

    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.roelof ];
  };
}


