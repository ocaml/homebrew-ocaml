class OpamAT2 < Formula
  desc "The OCaml package manager v2.0.0 (release candidate)"
  homepage "https://opam.ocaml.org"
  url "https://github.com/ocaml/opam/releases/download/2.0.0-rc3/opam-full-2.0.0-rc3.tar.gz"
  sha256 "d7ae1ce1be0c794dc557a50dee1b3844b2b646f9639279e02efb978471015e7c"
  head "https://github.com/ocaml/opam.git"
  revision 1

  depends_on "ocaml" => :recommended
  depends_on "glpk" => :build

  patch do
    url "https://github.com/dra27/opam/commit/818aedbcf064bf377384b75d9fb13d521956ee45.diff"
    sha256 "02959b1e7c69517da8a69dd7bef6f70153a6b34ee156d9b56f8ac4dd5610af21"
  end

  def install
    ENV.deparallelize

    build_ocaml = build.without? "ocaml"

    if build_ocaml
      system "make", "cold", "CONFIGURE_ARGS=--prefix #{prefix} --mandir #{man}"
      ENV.prepend_path "PATH", "#{buildpath}/bootstrap/ocaml/bin"
    else
      system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
      system "make", "lib-ext"
      system "make"
    end
    system "make", "man"
    system "make", "install"

    bash_completion.install "src/state/shellscripts/complete.sh"
    zsh_completion.install "src/state/shellscripts/complete.zsh" => "_opam"
  end

  def caveats; <<~EOS
    OPAM uses ~/.opam by default for its package database, so you need to
    initialize it first by running (as a normal user):

    $  opam init

    Run the following to initialize your environment variables:

    $  eval `opam env`

    Starting in 2.0.0~rc2 is also possible to set up a shell hook, so this
    is not required anymore.

    If upgrading from 2.0.0~rc to enable sandboxing you need to run

    $ opam init --reinit -ni

    To export the needed variables every time, add them to your dotfiles.
      * On Bash, add them to `~/.bash_profile`.
      * On Zsh, add them to `~/.zprofile` or `~/.zshrc` instead.

    Documentation and tutorials are available at https://opam.ocaml.org, or
    via "man opam" and "opam --help".
    EOS
  end

  test do
    system bin/"opam", "--help"
  end
end
