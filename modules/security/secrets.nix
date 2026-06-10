{ inputs, config, ... }:

{
  # --- Secrets Management ---
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets = {
    # "secret_name".sopsFile = ../../secrets/file_name.yaml;
  };
  # secrets are created via the sops command:
  # 1. Generate a new age key pair and save it to your local config directory.
  #   a. nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
  #   b. your public key will be output
  # 2. Create a .sops.yaml file in your project root to map your public key to your secret files.
  #   a. See ".sops.yaml"
  # 3. Run sops on a new path, e.g. secrets/my_secret.yaml, to open an encrypted buffer in your editor.
  # 4. Enter your secrets in standard YAML key-value pairs and save the file.
  # 5. Verify the file now contains a sops metadata block.
}
