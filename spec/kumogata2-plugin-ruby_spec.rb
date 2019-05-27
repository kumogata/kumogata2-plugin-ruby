describe Kumogata2::Plugin::Ruby do
  describe '#parse' do
    it 'Ruby format 1' do
      opts = {
        path_or_url: 'spec/fixtures/parse1.rb',
      }
      options = opts.kind_of?(Hashie::Mash) ? opts : Hashie::Mash.new(opts)
      template = Kumogata2::Plugin::Ruby.new(options).parse(open(options.path_or_url, &:read))
      expect(template).to eq ({ 'AWSTemplateFormatVersion' => '2010-09-09' })
    end

    it 'Ruby format 2' do
      opts = {
        path_or_url: 'spec/fixtures/parse2.rb',
      }
      options = opts.kind_of?(Hashie::Mash) ? opts : Hashie::Mash.new(opts)
      template = Kumogata2::Plugin::Ruby.new(options).parse(open(options.path_or_url, &:read))
      expect(template).to eq ({
                                'AWSTemplateFormatVersion' => '2010-09-09',
                                'Parameters' => {
                                  'foo_bar'=> 'hoge',
                                }
                              })
    end
    it 'Ruby format 3' do
      opts = {
        path_or_url: 'spec/fixtures/parse3.rb',
      }
      options = opts.kind_of?(Hashie::Mash) ? opts : Hashie::Mash.new(opts)
      template = Kumogata2::Plugin::Ruby.new(options).parse(open(options.path_or_url, &:read))
      expect(template).to eq ({
                                'AWSTemplateFormatVersion' => '2010-09-09',
                                'Version::Version1' => '2012-10-17',
                                'Version:Version2' => '2012-10-17',
                                'Version.Version3' => '2012-10-17',
                                'Version-Version4' => '2012-10-17'
                              })
    end
  end

  describe '#dump' do
    it 'JSON format' do
      data = <<-JSON
      {
        "Version": "2012-10-17"
      }
      JSON

      opts = {}
      template = Kumogata2::Plugin::Ruby.new(opts).dump(JSON.parse(data))
      expect(template).to eq "template do\n  Version \"2012-10-17\"\nend\n"
    end

    it 'JSON format 2' do
      data = <<-JSON
      {
        "Version_Version1": "2012-10-17"
      }
      JSON

      opts = {}
      template = Kumogata2::Plugin::Ruby.new(opts).dump(JSON.parse(data))
      expect(template).to eq <<-'EOS'
template do
  Version_Version1 "2012-10-17"
end
EOS
    end

    it 'JSON format 3' do
      data = <<-JSON
      {
        "Version::Version1": "2012-10-17",
        "Version:Version2": "2012-10-17",
        "Version.Version3": "2012-10-17",
        "Version-Version4": "2012-10-17"
      }
      JSON

      opts = {}
      template = Kumogata2::Plugin::Ruby.new(opts).dump(JSON.parse(data))
      expect(template).to eq <<-'EOS'
template do
  Version__Version1 "2012-10-17"
  Version___Version2 "2012-10-17"
  Version____Version3 "2012-10-17"
  Version_____Version4 "2012-10-17"
end
EOS
    end
  end
end
