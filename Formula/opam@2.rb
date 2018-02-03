class OpamAT2 < Formula
  desc "The OCaml package manager v2.0.0 (release candidate)"
  homepage "https://opam.ocaml.org"
  url "https://github.com/ocaml/opam/releases/download/2.0.0-rc/opam-full-2.0.0-rc.tar.gz"
  sha256 "1196b5a1aee66aa87eb01c005733992612718b6ee157b777340878f0e0434af6"
  head "https://github.com/ocaml/opam.git"

  depends_on "ocaml" => :recommended
  depends_on "glpk" => :build

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

    bash_completion.install "src/state/complete.sh"
    zsh_completion.install "src/state/complete.zsh" => "_opam"
  end

  def caveats; <<~EOS
    OPAM uses ~/.opam by default for its package database, so you need to
    initialize it first by running (as a normal user):

    $  opam init

    Run the following to initialize your environment variables:

    $  eval `opam env`

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
