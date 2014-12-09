require 'mms'

describe MMS::CLI do

  before do
    MMS::CLI.reset
  end

  describe "parsing options" do
    it 'should raise if no options defined' do
      expect { MMS::CLI.parse_options(["--nothing"]) }.to raise_error MMS::CLI::NoOptionsError
    end

    it "should remove args from ARGV by default" do
      argv = ['filename', '-v']
      MMS::CLI.add_options do
        on :v, "Display the MMS version" do
          # irrelevant
        end
      end.parse_options(argv)
      argv.include?('-v').should == false
    end
  end

  describe "adding options" do
    it "should be able to add an option" do
      run = false

      MMS::CLI.add_options do
        on :optiontest, "A test option" do
          run = true
        end
      end.parse_options(["--optiontest"])

      run.should == true
    end
  end

  describe "processing options" do
    it "should be able to process an option" do
      run = false

      MMS::CLI.add_options do
        on :optiontest, "A test option"
      end.add_option_processor do |opts|
        run = true if opts.present?(:optiontest)
      end.parse_options(["--optiontest"])

      run.should == true
    end
  end

end
