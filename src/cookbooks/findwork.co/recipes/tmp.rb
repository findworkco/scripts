def test_me()
  data_dir = ENV.fetch("data_dir")
  use_sops = ENV.fetch("use_sops")
  if use_sops == "TRUE"; then
    sops_secret_filepath = "#{data_dir}/var/sops/find-work/scripts/secret.yml"
    puts `sops #{sops_secret_filepath} --decrypt --extract '["find_work_db_user_password"]'`
  else
    puts "use default password"
  end
end
