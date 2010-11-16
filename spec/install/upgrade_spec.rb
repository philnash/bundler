require "spec_helper"

describe "bundle install for the first time with v1.0" do
  before :each do
    in_app_root

    gemfile <<-G
      source "file://#{gem_repo1}"
      gem "rack"
    G
  end

  it "removes lockfiles in 0.9 YAML format" do
    File.open("Gemfile.lock", "w"){|f| YAML.dump({}, f) }
    bundle :install
    File.read("Gemfile.lock").should_not =~ /^---/
  end

  it "removes env.rb if it exists" do
    bundled_app.join(".bundle").mkdir
    bundled_app.join(".bundle/environment.rb").open("w"){|f| f.write("raise 'nooo'") }
    bundle :install
    bundled_app.join(".bundle/environment.rb").should_not exist
  end

end

describe "bundle install from older version of bundler than lockfile" do
  it "warns user of out of date bundler" do
    install_gemfile <<-G
      source "file://#{gem_repo1}"
      gem "rack"
    G

    File.open("#{bundled_app("Gemfile.lock")}", 'w') do |file|
      file.write <<-G
GEM
  remote: file:#{gem_repo1}/
  specs:
    rack (1.0.0)

PLATFORMS
  #{generic(Gem::Platform.local)}

DEPENDENCIES
  rack

METADATA
  version: #{Bundler::VERSION.succ}
    G
    end

    bundle :install
    out.should include("Your Gemfile.lock was generated by a newer version of Bundler than this one. Please upgrade!")
  end
end
