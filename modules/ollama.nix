{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda.override {
      cudaArches = [ "61" ];
    };
  };
}
