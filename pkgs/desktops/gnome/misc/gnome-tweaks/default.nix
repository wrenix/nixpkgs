{ lib
, meson
, ninja
, fetchurl
, fetchpatch2
, desktop-file-utils
, gdk-pixbuf
, gettext
, glib
, gnome
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk4
, itstool
, libadwaita
, libgudev
, libnotify
, libxml2
, pkg-config
, python3Packages
, wrapGAppsHook4
}:

python3Packages.buildPythonApplication rec {
  pname = "gnome-tweaks";
  version = "46.0";
  format = "other";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.major version}/${pname}-${version}.tar.xz";
    sha256 = "sha256-Fnh4Y0H2ZKxFgHhCIqFkCfqb9cx6XxtG3O/SqhPdujE=";
  };

  patches = [
    # Avoid using Gtk.PropertyExpression (compatibility with pygobject < 3.47.0)
    # https://gitlab.gnome.org/GNOME/gnome-tweaks/-/merge_requests/133
    (fetchpatch2 {
      url = "https://gitlab.gnome.org/GNOME/gnome-tweaks/-/commit/380909bac09131a847a6f8777a9e31c843ea4a67.patch";
      hash = "sha256-aFFGL6ZDyhLZ51wdnE1XtHJQ+AB6ePS0mdlRHsUnaqI=";
    })
    # meson: Use gnome.post_install
    # https://gitlab.gnome.org/GNOME/gnome-tweaks/-/merge_requests/131
    (fetchpatch2 {
      url = "https://gitlab.gnome.org/GNOME/gnome-tweaks/-/commit/eec610429bcf04fbde31ecb214b4e5d4508654d2.patch";
      hash = "sha256-h4fvRH8RSj2LelwuKCyNIIeDX8/QQBBR0PUPam3ut+0=";
    })
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gobject-introspection
    itstool
    libxml2
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gnome-desktop
    gnome.gnome-settings-daemon
    gnome.gnome-shell
    # Makes it possible to select user themes through the `user-theme` extension
    gnome.gnome-shell-extensions
    gnome.mutter
    gsettings-desktop-schemas
    gtk4
    libadwaita
    libgudev
    libnotify
  ];

  pythonPath = with python3Packages; [
    pygobject3
  ];

  postPatch = ''
    patchShebangs meson-postinstall.py
  '';

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/libexec" "$out $pythonPath"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      attrPath = "gnome.${pname}";
    };
  };

  meta = with lib; {
    homepage = "https://wiki.gnome.org/Apps/Tweaks";
    description = "A tool to customize advanced GNOME 3 options";
    maintainers = teams.gnome.members;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
