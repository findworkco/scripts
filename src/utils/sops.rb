def sops_get(key)
  use_sops = ENV.fetch("use_sops")
  if use_sops == "TRUE"; then
    data_dir = ENV.fetch("data_dir")
    sops_secret_filepath = "#{data_dir}/var/sops/find-work/scripts/secret.yml"
    # TODO: Escape for shell execution
    puts `sops #{sops_secret_filepath} --decrypt --extract #{key}`
  else
    puts "use default password"
  end
end
